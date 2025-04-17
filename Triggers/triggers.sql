-- trigger for supplier 
CREATE OR REPLACE TRIGGER trg_instead_of_food_supplier
INSTEAD OF INSERT ON v_food_supplier
FOR EACH ROW
BEGIN
  INSERT INTO food_table (food_id, food_name, unit_of_measure, total_quantity,supplier_id, quality, user_id_gov)
  VALUES (
    NVL(:NEW.food_id, food_seq.NEXTVAL),
    :NEW.food_name,
    :NEW.unit_of_measure,
    :NEW.total_quantity,
    :NEW.supplier_id,
    0,  -- set quality to 0 by default
    (SELECT user_id FROM user_details WHERE user_name = 'default_gov_user')
  );
END;
/


-- trigger for main food data table
CREATE OR REPLACE TRIGGER food_table_after_update
AFTER UPDATE OF quality, user_id_gov ON food_table
FOR EACH ROW
BEGIN
  -- Only care when new quality is above 5
  IF :NEW.quality > 5 THEN
    MERGE INTO main_food_data m
    USING (
      SELECT 
        :NEW.food_id        AS food_id,
        :NEW.total_quantity AS total_quantity,
        :NEW.unit_of_measure AS unit_of_measure
      FROM dual
    ) src
    ON (m.food_id = src.food_id)
    WHEN MATCHED THEN
      UPDATE 
        SET m.total_quantity  = src.total_quantity,
            m.unit_of_measure = src.unit_of_measure,
            m.food_status     = 'Available'
    WHEN NOT MATCHED THEN
      INSERT (main_id, total_quantity, unit_of_measure, food_status, food_id)
      VALUES (
        main_food_seq.NEXTVAL,
        src.total_quantity,
        src.unit_of_measure,
        'Available',
        src.food_id
      );
  END IF;
END;
/

CREATE OR REPLACE TRIGGER check_quantity_before_request 
BEFORE INSERT ON ngo_request
FOR EACH ROW
DECLARE
  v_available NUMBER;
BEGIN
  -- Try fetching available quantity
  SELECT total_quantity
  INTO v_available
  FROM main_food_data
  WHERE main_id = :NEW.main_id;

  -- If requested quantity > available, raise error
  IF :NEW.req_quantity > v_available THEN
    raise_application_error(-20000, 'Requested quantity exceeds available stock.');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    raise_application_error(-20001, 'Invalid MAIN_ID: No matching stock available.');
END;
/



--logistics 
CREATE OR REPLACE TRIGGER logistic_after_delivery
AFTER UPDATE OF delivery_status ON logistic
FOR EACH ROW
DECLARE
  v_main_id  NUMBER;
  v_req_qty  NUMBER;
BEGIN
  -- Only run if we changed from not delivered ('F') to delivered ('T')
  IF :NEW.delivery_status = 'T' AND :OLD.delivery_status <> 'T' THEN

    -- 1) Find the main_id and the requested quantity from ngo_request
    SELECT main_id, req_quantity
      INTO v_main_id, v_req_qty
      FROM ngo_request
     WHERE ngo_request_id = :NEW.ngo_request_id;

    -- 2) Update main_food_data to subtract the requested quantity
    UPDATE main_food_data
       SET total_quantity = total_quantity - v_req_qty
     WHERE main_id = v_main_id;

    -- Optional: check if the update actually affected 1 row
    IF SQL%ROWCOUNT = 0 THEN
      raise_application_error(-20001, 'No matching food data found to update.');
    END IF;

    -- Optional: check if total_quantity is still >= 0 (in case quantity changed in the meantime)
    -- You could also do this check in a BEFORE UPDATE trigger on main_food_data, or re-query the new value.

  END IF;
END;
/