SET SERVEROUTPUT ON;

DECLARE
  v_role_name VARCHAR2(50);
  v_password VARCHAR2(100);
  v_compliant_password VARCHAR2(100);
  v_dba_privileges BOOLEAN := FALSE;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'SELECT 1 FROM dual WHERE EXISTS (
      SELECT 1 FROM session_privs WHERE privilege = ''CREATE USER'')'
    INTO v_dba_privileges;
    v_dba_privileges := TRUE;
  EXCEPTION
    WHEN OTHERS THEN
      v_dba_privileges := FALSE;
  END;
  
  IF NOT v_dba_privileges THEN
    DBMS_OUTPUT.PUT_LINE('Error: Current user lacks CREATE USER privilege');
    DBMS_OUTPUT.PUT_LINE('Please run this script as a DBA or ask your DBA to grant:');
    DBMS_OUTPUT.PUT_LINE('GRANT CREATE USER, ALTER USER, DROP USER TO your_user;');
    DBMS_OUTPUT.PUT_LINE('GRANT CREATE ROLE, DROP ANY ROLE TO your_user;');
    DBMS_OUTPUT.PUT_LINE('GRANT GRANT ANY ROLE TO your_user;');
    RETURN;
  END IF;

 
  FOR role_rec IN (
    SELECT 1 as role_id, 'supplier_role' as role_name FROM dual UNION ALL
    SELECT 2, 'ngo_role' FROM dual UNION ALL
    SELECT 3, 'govt_role' FROM dual UNION ALL
    SELECT 4, 'logistics_role' FROM dual
  ) LOOP
    BEGIN
      EXECUTE IMMEDIATE 'CREATE ROLE ' || role_rec.role_name;
      DBMS_OUTPUT.PUT_LINE('Created role: ' || role_rec.role_name);
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE != -1921 THEN -- ORA-01921: role already exists
          DBMS_OUTPUT.PUT_LINE('Error creating role ' || role_rec.role_name || ': ' || SQLERRM);
        END IF;
    END;
  END LOOP;

  FOR user_rec IN (
    SELECT 
      ud.user_name, 
      ud.password, 
      ur.role_name, 
      ud.user_role_role_id as role_id
    FROM user_details ud
    JOIN user_role ur ON ud.user_role_role_id = ur.role_id
  ) LOOP
    BEGIN
      IF NOT REGEXP_LIKE(user_rec.password, '[A-Z]') OR
         NOT REGEXP_LIKE(user_rec.password, '[0-9]') OR
         NOT REGEXP_LIKE(user_rec.password, '[^a-zA-Z0-9]') THEN
        v_compliant_password := 'A' || user_rec.password || '1!';
      ELSE
        v_compliant_password := user_rec.password;
      END IF;
      
      DECLARE
        user_count NUMBER;
      BEGIN
        SELECT COUNT(*) INTO user_count FROM all_users WHERE username = UPPER(user_rec.user_name);
        IF user_count = 0 THEN
          EXECUTE IMMEDIATE 'CREATE USER ' || user_rec.user_name || 
                         ' IDENTIFIED BY "' || v_compliant_password || '"';
          
          EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || user_rec.user_name;
          EXECUTE IMMEDIATE 'ALTER USER ' || user_rec.user_name || 
                         ' QUOTA 100M ON USERS';
          DBMS_OUTPUT.PUT_LINE('Created user: ' || user_rec.user_name);
        ELSE
          DBMS_OUTPUT.PUT_LINE('User exists: ' || user_rec.user_name);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('Error checking user ' || user_rec.user_name || ': ' || SQLERRM);
      END;
      
      CASE user_rec.role_id
        WHEN 1 THEN 
          BEGIN
            EXECUTE IMMEDIATE 'GRANT supplier_role TO ' || user_rec.user_name;
            DBMS_OUTPUT.PUT_LINE('Granted supplier_role to ' || user_rec.user_name);
          EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error granting role to ' || user_rec.user_name || ': ' || SQLERRM);
          END;
        WHEN 2 THEN 
          BEGIN
            EXECUTE IMMEDIATE 'GRANT ngo_role TO ' || user_rec.user_name;
            DBMS_OUTPUT.PUT_LINE('Granted ngo_role to ' || user_rec.user_name);
          EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error granting role to ' || user_rec.user_name || ': ' || SQLERRM);
          END;
        WHEN 3 THEN 
          BEGIN
            EXECUTE IMMEDIATE 'GRANT govt_role TO ' || user_rec.user_name;
            DBMS_OUTPUT.PUT_LINE('Granted govt_role to ' || user_rec.user_name);
          EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error granting role to ' || user_rec.user_name || ': ' || SQLERRM);
          END;
        WHEN 4 THEN 
          BEGIN
            EXECUTE IMMEDIATE 'GRANT logistics_role TO ' || user_rec.user_name;
            DBMS_OUTPUT.PUT_LINE('Granted logistics_role to ' || user_rec.user_name);
          EXCEPTION WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error granting role to ' || user_rec.user_name || ': ' || SQLERRM);
          END;
      END CASE;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error processing user ' || user_rec.user_name || ': ' || SQLERRM);
    END;
  END LOOP;
END;
/




GRANT SELECT, INSERT, UPDATE, DELETE ON supplier_view TO supplier_role;
GRANT SELECT, INSERT, UPDATE ON ngo_view TO ngo_role;
GRANT SELECT, INSERT, UPDATE ON govt_view TO govt_role;
GRANT SELECT, UPDATE ON logistics_view TO logistics_role;


//Validation
CONNECT user1/password1;

SELECT * FROM supplier_view;


-- Attempt NGO operations (should fail)
BEGIN
  INSERT INTO ngo_request_view VALUES (999, 100, 'KG', 1);
  DBMS_OUTPUT.PUT_LINE('ERROR: Should not have NGO access');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('PASS: Properly restricted from NGO operations');
END;
/

-- Attempt government operations (should fail)
BEGIN
  UPDATE quality_view SET quality_points = 9 WHERE ROWNUM = 1;
  DBMS_OUTPUT.PUT_LINE('ERROR: Should not have government access');
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('PASS: Properly restricted from quality operations');
END;
/





