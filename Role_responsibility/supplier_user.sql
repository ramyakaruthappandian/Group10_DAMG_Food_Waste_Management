-- Insert a supplier record.
INSERT INTO food_Admin.supplier (supplier_id, supplier_name, user_id_supplier)
VALUES (
  food_Admin.supplier_seq.NEXTVAL,
  'Supplier One Inc.',
  (SELECT user_id FROM food_Admin.user_details WHERE user_name = 'supplier_user')
);

INSERT INTO food_Admin.v_food_supplier (food_name, unit_of_measure, total_quantity, supplier_id)
VALUES ('Apples', 'KG', 100, 1);
COMMIT;
show user

select * from food_Admin.v_food_supplier;
select * from food_Admin.supplier;
select * from food_Admin.food_table;