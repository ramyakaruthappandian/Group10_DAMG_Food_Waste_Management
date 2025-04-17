SET SERVEROUTPUT ON SIZE UNLIMITED;
DECLARE
  v_test_user_sup   NUMBER;
  v_govt_user_id    NUMBER := 2;       -- your government official’s user_id
  v_ngo_role_id     NUMBER;
  v_ngo_user_id     NUMBER;
  v_created_ngo     BOOLEAN := FALSE;
  v_supplier_id     NUMBER;
  v_food_id         NUMBER;
  v_main_id         NUMBER;
  v_before_qty      NUMBER;
  v_count           NUMBER;
  v_current_qty     NUMBER;
  v_ngo_req_id      NUMBER;
  v_log_id          NUMBER;
  v_after_qty       NUMBER;
BEGIN
  ----------------------------------------
  -- Prep: find or create an NGO user
  ----------------------------------------
  SELECT role_id
    INTO v_ngo_role_id
    FROM user_role
   WHERE role_name = 'NGO';

  BEGIN
    SELECT user_id
      INTO v_ngo_user_id
      FROM user_details
     WHERE user_role_role_id = v_ngo_role_id
       AND ROWNUM = 1;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      INSERT INTO user_details
        (user_id, user_name, password,
         first_name, last_name, address,
         contact_number, user_role_role_id)
      VALUES
        (user_details_seq.NEXTVAL,
         'TMP_NGO_'||TO_CHAR(SYSDATE,'SSSSS'),
         'Pass#123','Temp','NGO','Nowhere',
         9999999999,
         v_ngo_role_id);
      v_ngo_user_id := user_details_seq.CURRVAL;
      v_created_ngo := TRUE;
      COMMIT;
  END;
  DBMS_OUTPUT.PUT_LINE('Using NGO user_id='||v_ngo_user_id);

  --------------------------------------------------
  -- Step 0: Create a temporary supplier
  --------------------------------------------------
  SELECT user_id
    INTO v_test_user_sup
    FROM user_details
   WHERE user_name = 'supplier_user'
     AND ROWNUM = 1;

  INSERT INTO supplier (supplier_id, supplier_name, user_id_supplier)
    VALUES (supplier_seq.NEXTVAL, 'TMP_SUPPLIER', v_test_user_sup);
  v_supplier_id := supplier_seq.CURRVAL;
  DBMS_OUTPUT.PUT_LINE('0) Created supplier_id='||v_supplier_id);

  --------------------------------------------------
  -- Step 1: Supplier adds a food item
  --------------------------------------------------
  pkg_supplier.add_food_item(
    p_supplier_id => v_supplier_id,
    p_food_name   => 'TestApple',
    p_unit        => 'KG'
  );
  v_food_id := food_seq.CURRVAL;
  DBMS_OUTPUT.PUT_LINE('1) Added food_id='||v_food_id);

  --------------------------------------------------
  -- Step 1b: Clear any prior MAIN_FOOD_DATA rows
  --------------------------------------------------
  DELETE FROM main_food_data
   WHERE food_id = v_food_id;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('1b) Cleared old MAIN_FOOD_DATA for food_id='||v_food_id);

  --------------------------------------------------
  -- Step 1c: Seed initial stock
  --------------------------------------------------
  UPDATE food_table
     SET total_quantity = 100
   WHERE food_id = v_food_id;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('1c) Seeded total_quantity=100 for food_id='||v_food_id);

  --------------------------------------------------
  -- NEGATIVE TEST A: quality < 5 ⇒ no MAIN_FOOD_DATA row
  --------------------------------------------------
  EXECUTE IMMEDIATE 'ALTER TRIGGER food_admin.fkntm_food_table DISABLE';
  pkg_govt_official.update_quality(
    p_food_id     => v_food_id,
    p_quality     => 4,
    p_user_id_gov => v_govt_user_id
  );
  COMMIT;
  EXECUTE IMMEDIATE 'ALTER TRIGGER food_admin.fkntm_food_table ENABLE';

  SELECT COUNT(*) INTO v_count
    FROM main_food_data
   WHERE food_id = v_food_id;
  IF v_count = 0 THEN
    DBMS_OUTPUT.PUT_LINE('NEG TEST A PASSED: no main_food_data for quality<5');
  ELSE
    DBMS_OUTPUT.PUT_LINE('NEG TEST A FAILED: unexpected row exists');
  END IF;

  --------------------------------------------------
  -- Step 2: Govt updates quality ≥ 5 ⇒ create MAIN_FOOD_DATA row
  --------------------------------------------------
  EXECUTE IMMEDIATE 'ALTER TRIGGER food_admin.fkntm_food_table DISABLE';
  pkg_govt_official.update_quality(
    p_food_id     => v_food_id,
    p_quality     => 7,
    p_user_id_gov => v_govt_user_id
  );
  COMMIT;
  EXECUTE IMMEDIATE 'ALTER TRIGGER food_admin.fkntm_food_table ENABLE';
  DBMS_OUTPUT.PUT_LINE('2) Updated to quality=7; expecting MAIN_FOOD_DATA row');

  SELECT main_id, total_quantity
    INTO v_main_id, v_before_qty
    FROM main_food_data
   WHERE food_id = v_food_id;
  DBMS_OUTPUT.PUT_LINE(
    '   main_food_data: main_id='||v_main_id
    ||', total_quantity='||v_before_qty
  );

  --------------------------------------------------
  -- Step 3: Bump quality again to 8 & check duplicates
  --------------------------------------------------
  EXECUTE IMMEDIATE 'ALTER TRIGGER food_admin.fkntm_food_table DISABLE';
  pkg_govt_official.update_quality(
    p_food_id     => v_food_id,
    p_quality     => 8,
    p_user_id_gov => v_govt_user_id
  );
  COMMIT;
  EXECUTE IMMEDIATE 'ALTER TRIGGER food_admin.fkntm_food_table ENABLE';

  SELECT COUNT(*), total_quantity
    INTO v_count, v_current_qty
    FROM main_food_data
   WHERE food_id = v_food_id
   GROUP BY total_quantity;
  IF v_count = 1 THEN
    DBMS_OUTPUT.PUT_LINE('DUPLICATE CHECK PASSED');
  ELSE
    DBMS_OUTPUT.PUT_LINE('DUPLICATE CHECK FAILED');
  END IF;

  --------------------------------------------------
  -- NEGATIVE TEST B: NGO requests more than available ⇒ exception
  --------------------------------------------------
  BEGIN
    pkg_ngo.place_request(
      p_user_id_ngo  => v_ngo_user_id,
      p_req_quantity => v_before_qty + 1,
      p_main_id      => v_main_id
    );
    DBMS_OUTPUT.PUT_LINE('NEG TEST B FAILED: no exception raised');
  EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('NEG TEST B PASSED: ');
  END;

  --------------------------------------------------
  -- Step 4: Valid NGO request for 3 units
  --------------------------------------------------
  pkg_ngo.place_request(
    p_user_id_ngo  => v_ngo_user_id,
    p_req_quantity => 3,
    p_main_id      => v_main_id
  );
  SELECT ngo_request_seq.CURRVAL INTO v_ngo_req_id FROM dual;
  DBMS_OUTPUT.PUT_LINE('4) Placed NGO request_id='||v_ngo_req_id||' for qty=3');

  --------------------------------------------------
  -- Step 5: Logistics insert (status = 'F', using user_id=4)
  --------------------------------------------------
  INSERT INTO logistic
    (logistics_id, driver, delivery_status, ngo_request_id, user_id)
  VALUES
    (logistic_seq.NEXTVAL,'DriverX','F',v_ngo_req_id,4);
  SELECT logistic_seq.CURRVAL INTO v_log_id FROM dual;
  DBMS_OUTPUT.PUT_LINE('5) logistics_id='||v_log_id||' status=F');

  --------------------------------------------------
  -- Step 6: Mark delivery complete ('T')
  --------------------------------------------------
  pkg_logistics.update_delivery_status(
    p_logistics_id => v_log_id,
    p_status       => 'T'
  );
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('6) Updated to T');

  --------------------------------------------------
  -- Step 7: Verify quantity deduction
  --------------------------------------------------
  SELECT total_quantity
    INTO v_after_qty
    FROM main_food_data
   WHERE main_id = v_main_id;
  IF v_after_qty = v_before_qty - 3 THEN
    DBMS_OUTPUT.PUT_LINE('7) Deduction PASS: '||v_after_qty);
  ELSE
    DBMS_OUTPUT.PUT_LINE('7) Deduction FAIL: '||v_after_qty);
  END IF;

  --------------------------------------------------
  -- Cleanup
  --------------------------------------------------
  DELETE FROM logistic       WHERE logistics_id   = v_log_id;
  DELETE FROM ngo_request    WHERE ngo_request_id = v_ngo_req_id;
  DELETE FROM main_food_data WHERE main_id        = v_main_id;
  DELETE FROM food_table     WHERE food_id        = v_food_id;
  DELETE FROM supplier       WHERE supplier_id    = v_supplier_id;
  IF v_created_ngo THEN
    DELETE FROM user_details WHERE user_id = v_ngo_user_id;
  END IF;
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Cleanup complete.');
END;
/
