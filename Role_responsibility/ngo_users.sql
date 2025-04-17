select * from food_admin.main_food_data;
INSERT INTO food_admin.ngo_request (ngo_request_id, req_quantity, user_id_ngo, main_id)
VALUES (food_Admin.ngo_request_seq.NEXTVAL, 10, 3, 1);
select * from food_admin.ngo_request;
SELECT * FROM food_admin.v_ngo_request_status;
COMMIT; 