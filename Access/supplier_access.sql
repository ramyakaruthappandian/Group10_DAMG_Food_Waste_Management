--Supplier-roleGRANT SELECT, INSERT, UPDATE, DELETE ON v_food_supplier TO supplier_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON food_admin.supplier TO supplier_user;
GRANT SELECT ON food_table TO supplier_user;
GRANT SELECT ON food_Admin.supplier_seq TO supplier_user;
GRANT SELECT ON food_Admin.user_details TO supplier_user;

SELECT sequence_owner, sequence_name
  FROM all_sequences
 WHERE sequence_name = 'SUPPLIER_SEQ';
