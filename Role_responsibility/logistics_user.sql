select * from food_admin.logistic;
INSERT INTO food_admin.logistic (logistics_id, driver, delivery_status, ngo_request_id, user_id)
VALUES (food_admin.logistic_seq.NEXTVAL, 'DriverX', 'F', 1, 4);
INSERT INTO food_admin.logistic (logistics_id, driver, delivery_status, ngo_request_id, user_id)
VALUES (food_admin.logistic_seq.NEXTVAL, 'BMWX', 'F', 2, 4);

UPDATE food_admin.logistic
   SET delivery_status = 'T'
 WHERE logistics_id = 1; 
  COMMIT;
 UPDATE food_admin.logistic
   SET delivery_status = 'T'
 WHERE logistics_id = 2; 
 COMMIT;
