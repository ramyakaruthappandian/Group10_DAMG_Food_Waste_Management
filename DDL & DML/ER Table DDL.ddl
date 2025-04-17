--===========================================================
-- Set session to wait for up to 60 seconds for DDL locks
--===========================================================
ALTER SESSION SET DDL_LOCK_TIMEOUT = 60;
/

--===========================================================
-- DROP TRIGGERS (if they exist)
--===========================================================
BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER FKNTM_food_table';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-4080) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER FKNTM_logistic';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-4080) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER FKNTM_main_food_data';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-4080) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER FKNTM_ngo_request';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-4080) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER FKNTM_supplier';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-4080) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TRIGGER FKNTM_user_details';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-4080) THEN
         RAISE;
      END IF;
END;
/

--===========================================================
-- DROP TABLES in Reverse Dependency Order
--===========================================================
BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE logistic CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-942) THEN  -- ignore "table does not exist"
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE ngo_request CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-942) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE main_food_data CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-942) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE food_table CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-942) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE supplier CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-942) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE user_details CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-942) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP TABLE user_role CASCADE CONSTRAINTS';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-942) THEN
         RAISE;
      END IF;
END;
/

--===========================================================
-- DROP SEQUENCES (if they exist)
--===========================================================
BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE food_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-2289) THEN  -- sequence does not exist
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE logistic_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-2289) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE main_food_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-2289) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE ngo_request_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-2289) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE supplier_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-2289) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE user_details_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-2289) THEN
         RAISE;
      END IF;
END;
/

BEGIN
   EXECUTE IMMEDIATE 'DROP SEQUENCE user_role_seq';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE NOT IN (-2289) THEN
         RAISE;
      END IF;
END;
/

--===========================================================
-- CREATE TABLES and Constraints
--===========================================================

-- TABLE: user_role (Parent)
CREATE TABLE user_role 
(
  role_id   NUMBER(10)  NOT NULL,
  role_name VARCHAR2(100 CHAR)  NOT NULL,
  CONSTRAINT user_role_PK PRIMARY KEY (role_id)
);
/

-- TABLE: user_details (Parent)
CREATE TABLE user_details 
(
  user_id           NUMBER(10)  NOT NULL,
  user_name         VARCHAR2(100 CHAR)  NOT NULL,
  password          VARCHAR2(100 CHAR)  NOT NULL,
  first_name        VARCHAR2(100 CHAR)  NOT NULL,
  last_name         VARCHAR2(100 CHAR)  NOT NULL,
  address           VARCHAR2(100 CHAR)  NOT NULL,
  contact_number    NUMBER(10)  NOT NULL,
  user_role_role_id NUMBER(10)  NOT NULL,
  CONSTRAINT user_details_PK PRIMARY KEY (user_id),
  CONSTRAINT user_details_user_name_UN UNIQUE (user_name),
  CONSTRAINT user_details_user_role_FK FOREIGN KEY (user_role_role_id)
     REFERENCES user_role (role_id)
);
/

-- TABLE: supplier (Parent for food_table)
CREATE TABLE supplier 
(
  supplier_id      NUMBER(10)  NOT NULL,
  supplier_name    VARCHAR2(100)  NOT NULL,
  user_id_supplier NUMBER(10)  NOT NULL,
  CONSTRAINT supplier_PK PRIMARY KEY (supplier_id),
  CONSTRAINT supplier_user_details_FK FOREIGN KEY (user_id_supplier)
     REFERENCES user_details (user_id)
);
/

-- TABLE: food_table
CREATE TABLE food_table 
(
  food_id         NUMBER         NOT NULL,
  food_name       VARCHAR2(100)  NOT NULL,
  unit_of_measure VARCHAR2(10)   NOT NULL,  -- Now a text field for units (e.g. 'KG', 'LBS')
  supplier_id     NUMBER(10)     NOT NULL,
  quality         NUMBER         NOT NULL,  -- quality points
  total_quantity  NUMBER(10)     NOT NULL,  -- newly added column for total quantity
  user_id_gov     NUMBER(10)     NOT NULL,  -- FK for government official
  CONSTRAINT food_table_PK PRIMARY KEY (food_id),
  CONSTRAINT food_table_supplier_FK FOREIGN KEY (supplier_id)
     REFERENCES supplier (supplier_id),
  CONSTRAINT food_table_user_details_FK FOREIGN KEY (user_id_gov)
     REFERENCES user_details (user_id)
);
/

-- TABLE: main_food_data (Dependent on food_table)
CREATE TABLE main_food_data 
(
  main_id         NUMBER(10)  NOT NULL,
  total_quantity  NUMBER(10)  NOT NULL,
  unit_of_measure VARCHAR2 (10)  NOT NULL,
  food_status     VARCHAR2 (10 CHAR)  NOT NULL,  -- e.g., 'Disposed' or 'Available'
  food_id         NUMBER  NOT NULL,
  CONSTRAINT main_food_data_PK PRIMARY KEY (main_id),
  CONSTRAINT main_food_data_food_table_FK FOREIGN KEY (food_id)
     REFERENCES food_table (food_id)
);
/

-- TABLE: ngo_request (Dependent on main_food_data and user_details)
CREATE TABLE ngo_request 
(
  ngo_request_id NUMBER(10)  NOT NULL,
  req_quantity   NUMBER(10)  NOT NULL,
  user_id_ngo    NUMBER(10)  NOT NULL,   -- FK referencing user_details (NGO user)
  main_id        NUMBER(10)  NOT NULL,   -- FK referencing main_food_data
  CONSTRAINT ngo_request_PK PRIMARY KEY (ngo_request_id),
  CONSTRAINT ngo_request_main_food_data_FK FOREIGN KEY (main_id)
     REFERENCES main_food_data (main_id),
  CONSTRAINT ngo_request_user_details_FK FOREIGN KEY (user_id_ngo)
     REFERENCES user_details (user_id)
);
/

-- TABLE: logistic (Dependent on ngo_request and user_details)
CREATE TABLE logistic 
(
  logistics_id    NUMBER(10)  NOT NULL,
  driver          VARCHAR2(100 CHAR)  NOT NULL,
  delivery_status CHAR(1)  NOT NULL,  -- 'T' = delivered, 'F' = not delivered
  ngo_request_id  NUMBER(10)  NOT NULL,
  user_id         NUMBER(10)  NOT NULL,  -- FK referencing user_details (logistics user)
  CONSTRAINT logistic_PK PRIMARY KEY (logistics_id),
  CONSTRAINT logistic_ngo_request_FK FOREIGN KEY (ngo_request_id)
     REFERENCES ngo_request (ngo_request_id),
  CONSTRAINT logistic_user_details_FK FOREIGN KEY (user_id)
     REFERENCES user_details (user_id)
);
/

-- Add comments if desired
COMMENT ON COLUMN logistic.delivery_status IS 'T = delivered, F = not delivered';

--===========================================================
-- CREATE NON-TRANSFERABLE FK TRIGGERS
-- These triggers will prevent changes to certain foreign key columns after insertion.
--===========================================================
CREATE OR REPLACE TRIGGER FKNTM_food_table
BEFORE UPDATE OF supplier_id, user_id_gov ON food_table
FOR EACH ROW
BEGIN
  -- Prevent any update to supplier_id by any user.
  IF :NEW.supplier_id <> :OLD.supplier_id THEN
      raise_application_error(-20225, 'Update to SUPPLIER_ID is not permitted.');
  END IF;
  
  -- Allow update to user_id_gov only by GOVT_USER.
  IF SYS_CONTEXT('USERENV', 'SESSION_USER') <> 'GOVT_USER' THEN
      IF :NEW.user_id_gov <> :OLD.user_id_gov THEN
          raise_application_error(-20225, 'Only GOVT_USER can update USER_ID_GOV.');
      END IF;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER FKNTM_logistic
BEFORE UPDATE OF ngo_request_id, user_id ON logistic
FOR EACH ROW
BEGIN 
  raise_application_error(-20225, 'Non Transferable FK constraint on table logistic is violated'); 
END;
/

CREATE OR REPLACE TRIGGER FKNTM_main_food_data
BEFORE UPDATE OF food_id ON main_food_data
FOR EACH ROW
BEGIN 
  raise_application_error(-20225, 'Non Transferable FK constraint on table main_food_data is violated'); 
END;
/

CREATE OR REPLACE TRIGGER FKNTM_ngo_request
BEFORE UPDATE OF main_id, user_id_ngo ON ngo_request
FOR EACH ROW
BEGIN 
  raise_application_error(-20225, 'Non Transferable FK constraint on table ngo_request is violated'); 
END;
/

CREATE OR REPLACE TRIGGER FKNTM_supplier
BEFORE UPDATE OF user_id_supplier ON supplier
FOR EACH ROW
BEGIN 
  raise_application_error(-20225, 'Non Transferable FK constraint on table supplier is violated'); 
END;
/

CREATE OR REPLACE TRIGGER FKNTM_user_details
BEFORE UPDATE OF user_role_role_id ON user_details
FOR EACH ROW
BEGIN 
  raise_application_error(-20225, 'Non Transferable FK constraint on table user_details is violated'); 
END;
/

--===========================================================
-- CREATE SEQUENCES FOR AUTO-INCREMENTING PRIMARY KEYS
--===========================================================
CREATE SEQUENCE food_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE logistic_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE main_food_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE ngo_request_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE supplier_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE user_details_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE user_role_seq START WITH 1 INCREMENT BY 1;
/

-- End of updated DDL script.
