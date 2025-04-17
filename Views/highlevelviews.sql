-- supplier view
CREATE OR REPLACE VIEW v_food_supplier AS
SELECT food_id,
       food_name,
       unit_of_measure,
       total_quantity,
       supplier_id
FROM food_table;

--govt view
CREATE OR REPLACE VIEW govt_food_view AS
SELECT food_id,
       food_name,
       quality,
       user_id_gov
  FROM food_table;

--ngo view
CREATE OR REPLACE VIEW food_admin.v_ngo_request_status AS
SELECT 
    nr.ngo_request_id,
    nr.req_quantity,
    nr.user_id_ngo,
    nr.main_id,
    CASE 
      WHEN l.delivery_status = 'T' THEN 'Closed'
      WHEN l.delivery_status = 'F' THEN 'Open'
      ELSE 'Unknown'
    END AS delivery_status
FROM food_admin.ngo_request nr
LEFT JOIN food_admin.logistic l 
  ON nr.ngo_request_id = l.ngo_request_id;
/




