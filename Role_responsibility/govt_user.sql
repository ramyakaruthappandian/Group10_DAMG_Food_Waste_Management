--UPDATE food_admin.govt_food_view
--   SET quality = 8,
--       user_id_gov = 0001
-- WHERE food_id = 2;

UPDATE food_admin.govt_food_view
   SET quality = 8,
       user_id_gov = 2
 WHERE food_id = 1;
 UPDATE food_admin.govt_food_view
   SET quality = 3,
       user_id_gov = 2
 WHERE food_id = 5;
 UPDATE food_admin.govt_food_view
   SET quality = 6,
       user_id_gov = 2
 WHERE food_id = 4;
 
COMMIT;

select * from food_admin.govt_food_view;
