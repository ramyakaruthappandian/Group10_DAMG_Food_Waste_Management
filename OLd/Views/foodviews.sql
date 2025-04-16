-- Supplier View (shows only supplier-related data)
CREATE OR REPLACE VIEW supplier_view AS
SELECT * FROM supplier 
WHERE user_details_user_id IN (
  SELECT user_id FROM user_details WHERE user_role_role_id = 1
);

-- NGO View (shows only NGO-related data)
CREATE OR REPLACE VIEW ngo_view AS
SELECT * FROM ngo_request 
WHERE user_details_user_id IN (
  SELECT user_id FROM user_details WHERE user_role_role_id = 2
);

-- Government View (shows quality data)
CREATE OR REPLACE VIEW govt_view AS
SELECT * FROM quality
WHERE user_details_user_id IN (
  SELECT user_id FROM user_details WHERE user_role_role_id = 3
);

-- Logistics View (shows delivery data)
CREATE OR REPLACE VIEW logistics_view AS
SELECT * FROM logistic
WHERE user_details_user_id IN (
  SELECT user_id FROM user_details WHERE user_role_role_id = 4
);