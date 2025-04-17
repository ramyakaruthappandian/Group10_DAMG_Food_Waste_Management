-- Insert a supplier record.
INSERT INTO food_Admin.supplier (supplier_id, supplier_name, user_id_supplier)
VALUES (
  food_Admin.supplier_seq.NEXTVAL,
  'Supplier One Inc.',
  (SELECT user_id FROM food_Admin.user_details WHERE user_name = 'supplier_user')
);
INSERT INTO food_Admin.supplier (supplier_id, supplier_name, user_id_supplier)
VALUES (
  food_Admin.supplier_seq.NEXTVAL,
  'Supplier two Inc.',
  (SELECT user_id FROM food_Admin.user_details WHERE user_name = 'supplier_user2')
);
INSERT INTO food_Admin.supplier (supplier_id, supplier_name, user_id_supplier)
VALUES (
  food_Admin.supplier_seq.NEXTVAL,
  'Supplier three Inc.',
  (SELECT user_id FROM food_Admin.user_details WHERE user_name = 'supplier_user3')
);

INSERT INTO food_Admin.v_food_supplier (food_name, unit_of_measure, total_quantity, supplier_id)
VALUES ('Apples', 'KG', 15, 1);
INSERT INTO food_Admin.v_food_supplier (food_name, unit_of_measure, total_quantity, supplier_id)
VALUES ('Pizza', 'KG', 45, 2);
INSERT INTO food_Admin.v_food_supplier (food_name, unit_of_measure, total_quantity, supplier_id)
VALUES ('Brownie', 'KG', 5, 3);
INSERT INTO food_Admin.v_food_supplier (food_name, unit_of_measure, total_quantity, supplier_id)
VALUES ('Momos', 'KG', 25, 2);
INSERT INTO food_Admin.v_food_supplier (food_name, unit_of_measure, total_quantity, supplier_id)
VALUES ('Fries', 'KG', 60, 3);
COMMIT;
show user

select * from food_Admin.v_food_supplier;
select * from food_Admin.supplier;
select * from food_Admin.food_table;