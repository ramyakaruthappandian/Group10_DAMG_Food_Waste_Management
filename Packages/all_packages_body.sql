--==================================================
-- Supplier Package
--==================================================
CREATE OR REPLACE PACKAGE pkg_supplier AS
  PROCEDURE add_food_item(
    p_supplier_id IN NUMBER,
    p_food_name   IN VARCHAR2,
    p_unit        IN VARCHAR2
  );

  PROCEDURE update_food_item(
    p_food_id         IN NUMBER,
    p_new_food_name   IN VARCHAR2
  );
END pkg_supplier;
/

CREATE OR REPLACE PACKAGE BODY pkg_supplier AS

  PROCEDURE add_food_item(
    p_supplier_id IN NUMBER,
    p_food_name   IN VARCHAR2,
    p_unit        IN VARCHAR2
  ) IS
  BEGIN
    INSERT INTO food_table (
      food_id, food_name, unit_of_measure, supplier_id, quality, total_quantity, user_id_gov
    )
    VALUES (
      food_seq.NEXTVAL, p_food_name, p_unit, p_supplier_id, 0, 10, 5
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001, 'Error in add_food_item: ' || SQLERRM);
  END add_food_item;

  PROCEDURE update_food_item(
    p_food_id         IN NUMBER,
    p_new_food_name   IN VARCHAR2
  ) IS
  BEGIN
    UPDATE food_table
       SET food_name = p_new_food_name
     WHERE food_id = p_food_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20002, 'Error in update_food_item: ' || SQLERRM);
  END update_food_item;

END pkg_supplier;
/

--==================================================
-- Govt Official Package
--==================================================
CREATE OR REPLACE PACKAGE pkg_govt_official AS
  PROCEDURE update_quality(
    p_food_id      IN NUMBER,
    p_quality      IN NUMBER,
    p_user_id_gov  IN NUMBER
  );
END pkg_govt_official;
/

CREATE OR REPLACE PACKAGE BODY pkg_govt_official AS

  PROCEDURE update_quality(
    p_food_id      IN NUMBER,
    p_quality      IN NUMBER,
    p_user_id_gov  IN NUMBER
  ) IS
  BEGIN
    UPDATE food_table
       SET quality     = p_quality,
           user_id_gov = p_user_id_gov
     WHERE food_id     = p_food_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20003, 'pkg_govt_official.update_quality failed: ' || SQLERRM);
  END update_quality;

END pkg_govt_official;
/

--==================================================
-- NGO Package
--==================================================
CREATE OR REPLACE PACKAGE pkg_ngo AS
  PROCEDURE place_request(
    p_user_id_ngo  IN NUMBER,
    p_req_quantity IN NUMBER,
    p_main_id      IN NUMBER
  );
END pkg_ngo;
/

CREATE OR REPLACE PACKAGE BODY pkg_ngo AS

  PROCEDURE place_request(
    p_user_id_ngo  IN NUMBER,
    p_req_quantity IN NUMBER,
    p_main_id      IN NUMBER
  ) IS
  BEGIN
    INSERT INTO ngo_request (
      ngo_request_id, req_quantity, user_id_ngo, main_id
    )
    VALUES (
      ngo_request_seq.NEXTVAL, p_req_quantity, p_user_id_ngo, p_main_id
    );
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20004, 'Error in place_request: ' || SQLERRM);
  END place_request;

END pkg_ngo;
/

--==================================================
-- Logistics Package
--==================================================
CREATE OR REPLACE PACKAGE pkg_logistics AS
  PROCEDURE update_delivery_status(
    p_logistics_id IN NUMBER,
    p_status       IN CHAR
  );
END pkg_logistics;
/

CREATE OR REPLACE PACKAGE BODY pkg_logistics AS

  PROCEDURE update_delivery_status(
    p_logistics_id IN NUMBER,
    p_status       IN CHAR
  ) IS
  BEGIN
    UPDATE logistic
       SET delivery_status = p_status
     WHERE logistics_id    = p_logistics_id;
  EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20005, 'Error in update_delivery_status: ' || SQLERRM);
  END update_delivery_status;

END pkg_logistics;
/
