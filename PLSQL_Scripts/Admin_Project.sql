SET SERVEROUTPUT ON;

DECLARE
   -- Exception for "user does not exist"
   user_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(user_not_exist, -1918);
   
   -- Exception for "role does not exist"
   role_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(role_not_exist, -1919);
BEGIN
   -- 1. Create admin role if it doesn't exist
   BEGIN
      EXECUTE IMMEDIATE 'CREATE ROLE food_admin_role';
      DBMS_OUTPUT.PUT_LINE('Created food_admin_role');
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -1921 THEN -- role already exists
            DBMS_OUTPUT.PUT_LINE('food_admin_role already exists');
         ELSE
            RAISE;
         END IF;
   END;
   
   -- 2. Drop existing admin user if it exists
   BEGIN
      EXECUTE IMMEDIATE 'DROP USER food_admin CASCADE';
      DBMS_OUTPUT.PUT_LINE('Dropped existing food_admin user');
   EXCEPTION
      WHEN user_not_exist THEN
         DBMS_OUTPUT.PUT_LINE('food_admin user did not exist');
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error dropping food_admin: ' || SQLERRM);
   END;

   -- 3. Create the admin user
   EXECUTE IMMEDIATE 'CREATE USER food_admin IDENTIFIED BY "SecureAdmin123#" 
                     DEFAULT TABLESPACE users 
                     TEMPORARY TABLESPACE temp 
                     QUOTA UNLIMITED ON users';
   DBMS_OUTPUT.PUT_LINE('Created food_admin user');

   -- 4. Grant essential privileges (with error handling)
   BEGIN
      -- Basic privileges
      EXECUTE IMMEDIATE 'GRANT CREATE SESSION, ALTER SESSION TO food_admin';
      
      -- User management privileges
      EXECUTE IMMEDIATE 'GRANT CREATE USER, ALTER USER, DROP USER TO food_admin';
      
      -- Role management privileges
      EXECUTE IMMEDIATE 'GRANT CREATE ROLE, DROP ANY ROLE, GRANT ANY ROLE TO food_admin';
      
      -- Object privileges
      EXECUTE IMMEDIATE 'GRANT CREATE TABLE, CREATE VIEW, CREATE PROCEDURE, CREATE SEQUENCE TO food_admin';
      
      -- Resource privileges
      EXECUTE IMMEDIATE 'GRANT UNLIMITED TABLESPACE TO food_admin';
      
      DBMS_OUTPUT.PUT_LINE('Granted all system privileges');
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error granting privileges: ' || SQLERRM);
   END;

   -- 5. Grant the admin role with admin option
   BEGIN
      EXECUTE IMMEDIATE 'GRANT food_admin_role TO food_admin WITH ADMIN OPTION';
      DBMS_OUTPUT.PUT_LINE('Granted food_admin_role with admin option');
   EXCEPTION
      WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('Error granting role: ' || SQLERRM);
   END;

   -- 6. Additional powerful privileges (if needed)
   BEGIN
      EXECUTE IMMEDIATE 'GRANT GRANT ANY PRIVILEGE TO food_admin';
      DBMS_OUTPUT.PUT_LINE('Granted privilege granting capability');
   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE = -1031 THEN -- ORA-01031: insufficient privileges
            DBMS_OUTPUT.PUT_LINE('Skipping GRANT ANY PRIVILEGE due to insufficient privileges');
         ELSE
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
         END IF;
   END;

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Admin account setup completed successfully');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Critical error: ' || SQLERRM);
      ROLLBACK;
END;
/