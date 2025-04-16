SET SERVEROUTPUT ON;

DECLARE
   -- Define an exception for ORA-00942: table or view does not exist.
   table_missing EXCEPTION;
   PRAGMA EXCEPTION_INIT(table_missing, -942);
BEGIN
   -- DROP TABLE statements with error handling
   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE USER_ROLE CASCADE CONSTRAINTS';
   EXCEPTION
      WHEN table_missing THEN NULL;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE LOGISTIC CASCADE CONSTRAINTS';
   EXCEPTION
      WHEN table_missing THEN NULL;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE MAIN_FOOD_DATA CASCADE CONSTRAINTS';
   EXCEPTION
      WHEN table_missing THEN NULL;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE ngo_request CASCADE CONSTRAINTS';
   EXCEPTION
      WHEN table_missing THEN NULL;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE QUALITY CASCADE CONSTRAINTS';
   EXCEPTION
      WHEN table_missing THEN NULL;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE user_details CASCADE CONSTRAINTS';
   EXCEPTION
      WHEN table_missing THEN NULL;
   END;

   BEGIN
      EXECUTE IMMEDIATE 'DROP TABLE supplier CASCADE CONSTRAINTS';
   EXCEPTION
      WHEN table_missing THEN NULL;
   END;

   -- Create the LOGISTIC table and its related objects
   EXECUTE IMMEDIATE '
      CREATE TABLE logistic 
      ( 
         logistics_id               NUMBER(10) NOT NULL, 
         driver                     VARCHAR2(100 CHAR) NOT NULL, 
         delivery_status            NUMBER NOT NULL, 
         ngo_request_ngo_request_id NUMBER(10) NOT NULL, 
         user_details_user_id       NUMBER(10) NOT NULL, 
         quality_quality_points     NUMBER(10) NOT NULL, 
         user_id1                   NUMBER(10) NOT NULL
      )
   ';

   EXECUTE IMMEDIATE '
      COMMENT ON COLUMN logistic.delivery_status IS ''true = delivered
      false = not delivered''
   ';

   EXECUTE IMMEDIATE '
      CREATE UNIQUE INDEX logistic__IDX ON logistic 
         (ngo_request_ngo_request_id ASC)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE logistic 
         ADD CONSTRAINT logistic_PK PRIMARY KEY (logistics_id)
   ';

   -- Create the MAIN_FOOD_DATA table and its related objects
   EXECUTE IMMEDIATE '
      CREATE TABLE main_food_data 
      ( 
         main_id              NUMBER(10) NOT NULL, 
         total_quantity       NUMBER(10) NOT NULL, 
         unit_of_measure      VARCHAR2(10) NOT NULL, 
         food_status          VARCHAR2(10 CHAR) NOT NULL, 
         supplier_supplier_id VARCHAR2(10) NOT NULL
      )
   ';

   EXECUTE IMMEDIATE '
      CREATE UNIQUE INDEX main_food_data__IDX ON main_food_data 
         (supplier_supplier_id ASC)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE main_food_data 
         ADD CONSTRAINT main_food_data_PK PRIMARY KEY (main_id)
   ';

   -- Create the NGO_REQUEST table and its related objects
   EXECUTE IMMEDIATE '
      CREATE TABLE ngo_request 
      ( 
         ngo_request_id          NUMBER(10) NOT NULL, 
         food_quantity           NUMBER(10) NOT NULL, 
         unit_of_measure_request VARCHAR2(10) NOT NULL, 
         ngo_request_status      NUMBER NOT NULL, 
         user_details_user_id    NUMBER(10) NOT NULL, 
         logistic_logistics_id   NUMBER NOT NULL, 
         main_food_data_main_id  NUMBER(10) NOT NULL, 
         user_id1                NUMBER NOT NULL
      )
   ';

   EXECUTE IMMEDIATE '
      COMMENT ON COLUMN ngo_request.ngo_request_status IS ''True = available
      False = not available''
   ';

   EXECUTE IMMEDIATE '
      CREATE UNIQUE INDEX ngo_request__IDX ON ngo_request 
         (logistic_logistics_id ASC)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE ngo_request 
         ADD CONSTRAINT ngo_request_PK PRIMARY KEY (ngo_request_id)
   ';

   -- Create the QUALITY table and its related objects
   EXECUTE IMMEDIATE '
      CREATE TABLE quality 
      ( 
         quality_points       NUMBER(10) NOT NULL, 
         user_details_user_id NUMBER(10) NOT NULL
      )
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE quality 
         ADD CONSTRAINT quality_PK PRIMARY KEY (quality_points)
   ';

   -- Create the SUPPLIER table and its related objects
   EXECUTE IMMEDIATE '
      CREATE TABLE supplier 
      ( 
         supplier_id            VARCHAR2(10) NOT NULL, 
         supplier_name          VARCHAR2(100) NOT NULL, 
         food_name              VARCHAR2(100) NOT NULL, 
         food_description       VARCHAR2(100) NOT NULL, 
         quantity               NUMBER(10,2) NOT NULL, 
         unit_of_measure        VARCHAR2(10) NOT NULL, 
         food_prepared_time     DATE NOT NULL, 
         perishable_by          DATE NOT NULL, 
         user_details_user_id   NUMBER(10) NOT NULL, 
         main_food_data_main_id NUMBER NOT NULL
      )
   ';

   EXECUTE IMMEDIATE '
      CREATE UNIQUE INDEX supplier__IDX ON supplier 
         (main_food_data_main_id ASC)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE supplier 
         ADD CONSTRAINT supplier_PK PRIMARY KEY (supplier_id)
   ';

   -- Create the USER_DETAILS table and its related objects
   EXECUTE IMMEDIATE '
      CREATE TABLE user_details 
      ( 
         user_id           NUMBER(10) NOT NULL, 
         user_name         VARCHAR2(100 CHAR) NOT NULL, 
         password          VARCHAR2(100 CHAR) NOT NULL, 
         first_name        VARCHAR2(100 CHAR) NOT NULL, 
         last_name         VARCHAR2(100 CHAR) NOT NULL, 
         Address           VARCHAR2(100 CHAR) NOT NULL, 
         contact_number    NUMBER(10) NOT NULL, 
         user_role_role_id NUMBER(10) NOT NULL
      )
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE user_details 
         ADD CONSTRAINT user_PK PRIMARY KEY (user_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE user_details 
         ADD CONSTRAINT user_user_name_UN UNIQUE (user_name)
   ';

   -- Create the USER_ROLE table and its related objects
   EXECUTE IMMEDIATE '
      CREATE TABLE user_role 
      ( 
         role_id   NUMBER(10) NOT NULL, 
         role_name VARCHAR2(100 CHAR) NOT NULL
      )
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE user_role 
         ADD CONSTRAINT user_role_PK PRIMARY KEY (role_id)
   ';

   -- Add Foreign Key Constraints
   EXECUTE IMMEDIATE '
      ALTER TABLE logistic 
         ADD CONSTRAINT logistic_ngo_request_FK FOREIGN KEY (ngo_request_ngo_request_id)
         REFERENCES ngo_request (ngo_request_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE logistic 
         ADD CONSTRAINT logistic_quality_FK FOREIGN KEY (quality_quality_points)
         REFERENCES quality (quality_points)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE logistic 
         ADD CONSTRAINT logistic_user_details_FK FOREIGN KEY (user_details_user_id)
         REFERENCES user_details (user_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE main_food_data 
         ADD CONSTRAINT main_food_data_supplier_FK FOREIGN KEY (supplier_supplier_id)
         REFERENCES supplier (supplier_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE ngo_request 
         ADD CONSTRAINT ngo_request_main_food_data_FK FOREIGN KEY (main_food_data_main_id)
         REFERENCES main_food_data (main_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE ngo_request 
         ADD CONSTRAINT ngo_request_user_details_FK FOREIGN KEY (user_details_user_id)
         REFERENCES user_details (user_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE quality 
         ADD CONSTRAINT quality_user_details_FK FOREIGN KEY (user_details_user_id)
         REFERENCES user_details (user_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE supplier 
         ADD CONSTRAINT supplier_user_details_FK FOREIGN KEY (user_details_user_id)
         REFERENCES user_details (user_id)
   ';

   EXECUTE IMMEDIATE '
      ALTER TABLE user_details 
         ADD CONSTRAINT user_details_user_role_FK FOREIGN KEY (user_role_role_id)
         REFERENCES user_role (role_id)
   ';

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Script executed successfully.');

EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      ROLLBACK;
END;
/
