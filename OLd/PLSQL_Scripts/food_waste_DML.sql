SET SERVEROUTPUT ON;

DECLARE
   dup EXCEPTION;
   PRAGMA EXCEPTION_INIT(dup, -1);  
BEGIN
   
   FOR i IN 1 .. 4 LOOP
      BEGIN
         CASE i 
            WHEN 1 THEN 
               INSERT INTO user_role(role_id, role_name) VALUES (1, 'supplier');
            WHEN 2 THEN 
               INSERT INTO user_role(role_id, role_name) VALUES (2, 'ngo');
            WHEN 3 THEN 
               INSERT INTO user_role(role_id, role_name) VALUES (3, 'govt.');
            WHEN 4 THEN 
               INSERT INTO user_role(role_id, role_name) VALUES (4, 'logistics');
         END CASE;
      EXCEPTION
         WHEN dup THEN NULL;
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;

   
   FOR i IN 1 .. 10 LOOP
      BEGIN
         INSERT INTO user_details(user_id, user_name, password, first_name, last_name, Address, contact_number, user_role_role_id)
         VALUES (i,
                 'user' || i,
                 'password' || i,
                 'First' || i,
                 'Last' || i,
                 'Address ' || i,
                 1000000000 + i,
                 MOD(i-1, 5) + 1  
                );
      EXCEPTION
         WHEN dup THEN NULL;
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;

  
   FOR i IN 1 .. 10 LOOP
      BEGIN
         INSERT INTO supplier(supplier_id, supplier_name, food_name, food_description, quantity, unit_of_measure, food_prepared_time, perishable_by, user_details_user_id, main_food_data_main_id)
         VALUES ( 'S' || LPAD(i, 3, '0'),
                  'Supplier ' || i,
                  'Food ' || i,
                  'Description ' || i,
                  100 + i,
                  'KG',
                  SYSDATE - i,         
                  SYSDATE + i,         
                  MOD(i-1, 10) + 1,    
                  i                   
                );
      EXCEPTION
         WHEN dup THEN NULL;
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;

   
   FOR i IN 1 .. 10 LOOP
      BEGIN
         INSERT INTO main_food_data(main_id, total_quantity, unit_of_measure, food_status, supplier_supplier_id)
         VALUES (i,
                 200 + i,
                 'KG',
                 'Fresh',
                 'S' || LPAD(i, 3, '0')    
                );
      EXCEPTION
         WHEN dup THEN NULL;
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;

   
   FOR i IN 1 .. 10 LOOP
      BEGIN
         INSERT INTO ngo_request(ngo_request_id, food_quantity, unit_of_measure_request, ngo_request_status, user_details_user_id, logistic_logistics_id, main_food_data_main_id, user_id1)
         VALUES (i,
                 50 + i,
                 'KG',
                 1,         
                 i,         
                 i,         
                 i,         
                 i          
                );
      EXCEPTION
         WHEN dup THEN NULL;
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;

   
   FOR i IN 1 .. 10 LOOP
      BEGIN
         INSERT INTO quality(quality_points, user_details_user_id)
         VALUES (i,
                 i   
                );
      EXCEPTION
         WHEN dup THEN NULL;
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;

   FOR i IN 1 .. 10 LOOP
      BEGIN
         INSERT INTO logistic(logistics_id, driver, delivery_status, ngo_request_ngo_request_id, user_details_user_id, quality_quality_points, user_id1)
         VALUES (i,
                 'Driver ' || i,
                 MOD(i, 2), 
                 i,          
                 i,          
                 i,          
                 i           
                );
      EXCEPTION
         WHEN dup THEN NULL;
         WHEN OTHERS THEN NULL;
      END;
   END LOOP;

   COMMIT;
   DBMS_OUTPUT.PUT_LINE('Dummy data inserted successfully.');
EXCEPTION
   WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
      ROLLBACK;
END;
/
--select * from LOGISTIC;
--select * from user_role;
--select * from user_details;
--select * from supplier;
--select * from ngo_request;
--select * from quality;