-- Migration: Diagnostic tool sample data seed
-- Purpose: Seed minimal-but-realistic data for the diagnostic tree system.
-- Scope: diagnostic_categories, diagnostic_trees, diagnostic_nodes, diagnostic_ratings (+ seed users)
-- Notes:
--   - Idempotent inserts (safe to run multiple times).
--   - Keeps data isolated with "Sample:" tree titles and "diag_seed_*" users.

START TRANSACTION;

-- -----------------------------------------------------------------------------
-- 1) Seed users required by diagnostic data (creator + raters)
-- -----------------------------------------------------------------------------

INSERT INTO users (
    first_name,
    last_name,
    username,
    email,
    password,
    role,
    status
)
SELECT
    'Diagnostic',
    'Admin',
    'diag_seed_admin',
    'diag_seed_admin@dailyfixer.local',
    '$2a$10$7r9Q6Ck9S3R4lY5hM2kN0eK4xQ1fV8QnM3iFj9mHk2LwZp8TgYy1C',
    'admin',
    'active'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE username = 'diag_seed_admin'
);

INSERT INTO users (
    first_name,
    last_name,
    username,
    email,
    password,
    role,
    status
)
SELECT
    'Alex',
    'Tester',
    'diag_seed_user_1',
    'diag_seed_user_1@dailyfixer.local',
    '$2a$10$7r9Q6Ck9S3R4lY5hM2kN0eK4xQ1fV8QnM3iFj9mHk2LwZp8TgYy1C',
    'user',
    'active'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE username = 'diag_seed_user_1'
);

INSERT INTO users (
    first_name,
    last_name,
    username,
    email,
    password,
    role,
    status
)
SELECT
    'Jamie',
    'Tester',
    'diag_seed_user_2',
    'diag_seed_user_2@dailyfixer.local',
    '$2a$10$7r9Q6Ck9S3R4lY5hM2kN0eK4xQ1fV8QnM3iFj9mHk2LwZp8TgYy1C',
    'user',
    'active'
WHERE NOT EXISTS (
    SELECT 1 FROM users WHERE username = 'diag_seed_user_2'
);

SET @diag_creator_id := (SELECT user_id FROM users WHERE username = 'diag_seed_admin' LIMIT 1);
SET @diag_rater_1 := (SELECT user_id FROM users WHERE username = 'diag_seed_user_1' LIMIT 1);
SET @diag_rater_2 := (SELECT user_id FROM users WHERE username = 'diag_seed_user_2' LIMIT 1);

-- -----------------------------------------------------------------------------
-- 2) Ensure main + sub diagnostic categories exist
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Home Repair', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Home Repair' AND parent_id IS NULL
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Home Electronic Repair', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Home Electronic Repair' AND parent_id IS NULL
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Vehicle Repair', NULL
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Vehicle Repair' AND parent_id IS NULL
);

SET @cat_home_repair := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Home Repair' AND parent_id IS NULL
    ORDER BY category_id
    LIMIT 1
);

SET @cat_home_electronics := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Home Electronic Repair' AND parent_id IS NULL
    ORDER BY category_id
    LIMIT 1
);

SET @cat_vehicle_repair := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Vehicle Repair' AND parent_id IS NULL
    ORDER BY category_id
    LIMIT 1
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Plumbing', @cat_home_repair
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Plumbing' AND parent_id = @cat_home_repair
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Home Appliances', @cat_home_electronics
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Home Appliances' AND parent_id = @cat_home_electronics
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Engine & Mechanical', @cat_vehicle_repair
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Engine & Mechanical' AND parent_id = @cat_vehicle_repair
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Electrical (Basic)', @cat_home_repair
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Electrical (Basic)' AND parent_id = @cat_home_repair
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Computers & Laptops', @cat_home_electronics
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Computers & Laptops' AND parent_id = @cat_home_electronics
);

INSERT INTO diagnostic_categories (name, parent_id)
SELECT 'Braking System', @cat_vehicle_repair
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_categories WHERE name = 'Braking System' AND parent_id = @cat_vehicle_repair
);

SET @subcat_plumbing := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Plumbing' AND parent_id = @cat_home_repair
    ORDER BY category_id
    LIMIT 1
);

SET @subcat_home_appliances := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Home Appliances' AND parent_id = @cat_home_electronics
    ORDER BY category_id
    LIMIT 1
);

SET @subcat_engine_mech := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Engine & Mechanical' AND parent_id = @cat_vehicle_repair
    ORDER BY category_id
    LIMIT 1
);

SET @subcat_electrical_basic := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Electrical (Basic)' AND parent_id = @cat_home_repair
    ORDER BY category_id
    LIMIT 1
);

SET @subcat_computers := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Computers & Laptops' AND parent_id = @cat_home_electronics
    ORDER BY category_id
    LIMIT 1
);

SET @subcat_brakes := (
    SELECT category_id FROM diagnostic_categories
    WHERE name = 'Braking System' AND parent_id = @cat_vehicle_repair
    ORDER BY category_id
    LIMIT 1
);

-- -----------------------------------------------------------------------------
-- 3) Seed diagnostic trees (published)
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_trees (title, description, category_id, creator_id, status)
SELECT
    'Sample: Leaking Kitchen Faucet',
    'Step-by-step tree to identify common faucet leak sources before calling a technician.',
    @subcat_plumbing,
    @diag_creator_id,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_trees WHERE title = 'Sample: Leaking Kitchen Faucet'
);

INSERT INTO diagnostic_trees (title, description, category_id, creator_id, status)
SELECT
    'Sample: Refrigerator Not Cooling',
    'Guided checks for airflow, power, and condenser issues in home refrigerators.',
    @subcat_home_appliances,
    @diag_creator_id,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_trees WHERE title = 'Sample: Refrigerator Not Cooling'
);

INSERT INTO diagnostic_trees (title, description, category_id, creator_id, status)
SELECT
    'Sample: Car Will Not Start',
    'Basic starter diagnostics to separate battery, fuel, and ignition related faults.',
    @subcat_engine_mech,
    @diag_creator_id,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_trees WHERE title = 'Sample: Car Will Not Start'
);

INSERT INTO diagnostic_trees (title, description, category_id, creator_id, status)
SELECT
    'Sample: Circuit Breaker Keeps Tripping',
    'Home electrical checks for overloaded circuits, appliance faults, and breaker issues.',
    @subcat_electrical_basic,
    @diag_creator_id,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_trees WHERE title = 'Sample: Circuit Breaker Keeps Tripping'
);

INSERT INTO diagnostic_trees (title, description, category_id, creator_id, status)
SELECT
    'Sample: Laptop Overheating and Shutting Down',
    'Decision path for thermal shutdown causes: ventilation, fan behavior, and load conditions.',
    @subcat_computers,
    @diag_creator_id,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_trees WHERE title = 'Sample: Laptop Overheating and Shutting Down'
);

INSERT INTO diagnostic_trees (title, description, category_id, creator_id, status)
SELECT
    'Sample: Brake Pedal Feels Spongy',
    'Basic brake-system diagnostics covering fluid level, leaks, and pedal response symptoms.',
    @subcat_brakes,
    @diag_creator_id,
    'published'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_trees WHERE title = 'Sample: Brake Pedal Feels Spongy'
);

SET @tree_faucet := (
    SELECT tree_id FROM diagnostic_trees
    WHERE title = 'Sample: Leaking Kitchen Faucet'
    ORDER BY tree_id
    LIMIT 1
);

SET @tree_fridge := (
    SELECT tree_id FROM diagnostic_trees
    WHERE title = 'Sample: Refrigerator Not Cooling'
    ORDER BY tree_id
    LIMIT 1
);

SET @tree_car := (
    SELECT tree_id FROM diagnostic_trees
    WHERE title = 'Sample: Car Will Not Start'
    ORDER BY tree_id
    LIMIT 1
);

SET @tree_breaker := (
    SELECT tree_id FROM diagnostic_trees
    WHERE title = 'Sample: Circuit Breaker Keeps Tripping'
    ORDER BY tree_id
    LIMIT 1
);

SET @tree_laptop_heat := (
    SELECT tree_id FROM diagnostic_trees
    WHERE title = 'Sample: Laptop Overheating and Shutting Down'
    ORDER BY tree_id
    LIMIT 1
);

SET @tree_brakes := (
    SELECT tree_id FROM diagnostic_trees
    WHERE title = 'Sample: Brake Pedal Feels Spongy'
    ORDER BY tree_id
    LIMIT 1
);

-- -----------------------------------------------------------------------------
-- 4) Seed nodes for tree: Sample: Leaking Kitchen Faucet
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT
    @tree_faucet,
    NULL,
    'Where is the leak mainly visible?',
    '',
    'QUESTION',
    0
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes
    WHERE tree_id = @tree_faucet
      AND parent_id IS NULL
      AND node_text = 'Where is the leak mainly visible?'
);

SET @f_root := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_faucet
      AND parent_id IS NULL
      AND node_text = 'Where is the leak mainly visible?'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_faucet, @f_root, 'Does the faucet drip even when fully closed?', 'At the spout', 'QUESTION', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_faucet AND parent_id = @f_root AND option_label = 'At the spout'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_faucet, @f_root, 'Does leaking increase while water is running?', 'At the base/handle area', 'QUESTION', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_faucet AND parent_id = @f_root AND option_label = 'At the base/handle area'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_faucet, @f_root, 'Check supply hoses and shut-off valves under the sink. Tighten fittings and replace cracked hoses.', 'Under the sink cabinet', 'RESULT', 3
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_faucet AND parent_id = @f_root AND option_label = 'Under the sink cabinet'
);

SET @f_spout_q := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_faucet AND parent_id = @f_root AND option_label = 'At the spout'
    ORDER BY node_id
    LIMIT 1
);

SET @f_base_q := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_faucet AND parent_id = @f_root AND option_label = 'At the base/handle area'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_faucet, @f_spout_q, 'Cartridge or valve seat is likely worn. Replace cartridge and test again.', 'Yes', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_faucet AND parent_id = @f_spout_q AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_faucet, @f_spout_q, 'Aerator may be loose or damaged. Reseat/clean aerator and inspect spout threads.', 'No', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_faucet AND parent_id = @f_spout_q AND option_label = 'No'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_faucet, @f_base_q, 'Handle O-rings are likely worn. Replace O-rings and apply plumber grease.', 'Yes', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_faucet AND parent_id = @f_base_q AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_faucet, @f_base_q, 'Tighten mounting nut and inspect faucet body cracks. Replace faucet if cracked.', 'No', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_faucet AND parent_id = @f_base_q AND option_label = 'No'
);

-- -----------------------------------------------------------------------------
-- 5) Seed nodes for tree: Sample: Refrigerator Not Cooling
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT
    @tree_fridge,
    NULL,
    'Is the refrigerator interior light turning on when the door opens?',
    '',
    'QUESTION',
    0
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes
    WHERE tree_id = @tree_fridge
      AND parent_id IS NULL
      AND node_text = 'Is the refrigerator interior light turning on when the door opens?'
);

SET @r_root := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_fridge
      AND parent_id IS NULL
      AND node_text = 'Is the refrigerator interior light turning on when the door opens?'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_fridge, @r_root, 'Do you hear the compressor or fan running?', 'Yes', 'QUESTION', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_fridge AND parent_id = @r_root AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_fridge, @r_root, 'Check outlet power, plug fit, and breaker. Restore power before further diagnosis.', 'No', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_fridge AND parent_id = @r_root AND option_label = 'No'
);

SET @r_run_q := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_fridge AND parent_id = @r_root AND option_label = 'Yes'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_fridge, @r_run_q, 'Condenser coils may be dirty. Clean coils and verify rear ventilation clearance.', 'Compressor runs constantly', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_fridge AND parent_id = @r_run_q AND option_label = 'Compressor runs constantly'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_fridge, @r_run_q, 'Compressor start relay or capacitor may be faulty. Replace start components.', 'Compressor clicks on/off', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_fridge AND parent_id = @r_run_q AND option_label = 'Compressor clicks on/off'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_fridge, @r_run_q, 'Evaporator fan may have failed or vents are blocked by ice. Defrost and inspect fan.', 'No airflow in freezer section', 'RESULT', 3
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_fridge AND parent_id = @r_run_q AND option_label = 'No airflow in freezer section'
);

-- -----------------------------------------------------------------------------
-- 6) Seed nodes for tree: Sample: Car Will Not Start
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT
    @tree_car,
    NULL,
    'What happens when you turn the key or press start?',
    '',
    'QUESTION',
    0
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes
    WHERE tree_id = @tree_car
      AND parent_id IS NULL
      AND node_text = 'What happens when you turn the key or press start?'
);

SET @c_root := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_car
      AND parent_id IS NULL
      AND node_text = 'What happens when you turn the key or press start?'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_car, @c_root, 'Battery is likely discharged or connection is loose. Check battery voltage and terminals.', 'No crank, no click', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_car AND parent_id = @c_root AND option_label = 'No crank, no click'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_car, @c_root, 'Do dashboard lights dim significantly while trying to start?', 'Single click only', 'QUESTION', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_car AND parent_id = @c_root AND option_label = 'Single click only'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_car, @c_root, 'Fuel or spark issue likely. Check fuel level, fuel pump sound, and spark plugs.', 'Engine cranks but will not start', 'RESULT', 3
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_car AND parent_id = @c_root AND option_label = 'Engine cranks but will not start'
);

SET @c_click_q := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_car AND parent_id = @c_root AND option_label = 'Single click only'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_car, @c_click_q, 'Battery output is weak. Charge battery or replace if it fails load test.', 'Yes, lights dim', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_car AND parent_id = @c_click_q AND option_label = 'Yes, lights dim'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_car, @c_click_q, 'Starter solenoid or starter motor may be faulty. Inspect starter circuit and relay.', 'No, lights stay bright', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_car AND parent_id = @c_click_q AND option_label = 'No, lights stay bright'
);

-- -----------------------------------------------------------------------------
-- 7) Seed nodes for tree: Sample: Circuit Breaker Keeps Tripping
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT
    @tree_breaker,
    NULL,
    'Does the breaker trip immediately after reset, even with nothing plugged into that circuit?',
    '',
    'QUESTION',
    0
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes
    WHERE tree_id = @tree_breaker
      AND parent_id IS NULL
      AND node_text = 'Does the breaker trip immediately after reset, even with nothing plugged into that circuit?'
);

SET @b_root := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_breaker
      AND parent_id IS NULL
      AND node_text = 'Does the breaker trip immediately after reset, even with nothing plugged into that circuit?'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_breaker, @b_root, 'Possible wiring fault or bad breaker. Keep circuit off and request an electrician.', 'Yes', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_breaker AND parent_id = @b_root AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_breaker, @b_root, 'Does it trip only when a specific appliance is used?', 'No', 'QUESTION', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_breaker AND parent_id = @b_root AND option_label = 'No'
);

SET @b_appliance_q := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_breaker AND parent_id = @b_root AND option_label = 'No'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_breaker, @b_appliance_q, 'That appliance may have an internal short. Stop using it and get it inspected.', 'Yes', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_breaker AND parent_id = @b_appliance_q AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_breaker, @b_appliance_q, 'Circuit overload is likely. Reduce simultaneous high-power devices on this circuit.', 'No', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_breaker AND parent_id = @b_appliance_q AND option_label = 'No'
);

-- -----------------------------------------------------------------------------
-- 8) Seed nodes for tree: Sample: Laptop Overheating and Shutting Down
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT
    @tree_laptop_heat,
    NULL,
    'When does the shutdown usually happen?',
    '',
    'QUESTION',
    0
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes
    WHERE tree_id = @tree_laptop_heat
      AND parent_id IS NULL
      AND node_text = 'When does the shutdown usually happen?'
);

SET @l_root := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_laptop_heat
      AND parent_id IS NULL
      AND node_text = 'When does the shutdown usually happen?'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_laptop_heat, @l_root, 'Likely poor airflow at idle. Clean vents and ensure hard, flat surface usage.', 'After 10-20 minutes of light use', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_laptop_heat AND parent_id = @l_root AND option_label = 'After 10-20 minutes of light use'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_laptop_heat, @l_root, 'Do fan noise and temperatures spike first?', 'During gaming or heavy tasks', 'QUESTION', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_laptop_heat AND parent_id = @l_root AND option_label = 'During gaming or heavy tasks'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_laptop_heat, @l_root, 'Possible battery or power rail issue. Test on charger-only and battery-only modes.', 'Randomly, even when cool', 'RESULT', 3
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_laptop_heat AND parent_id = @l_root AND option_label = 'Randomly, even when cool'
);

SET @l_heavy_q := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_laptop_heat AND parent_id = @l_root AND option_label = 'During gaming or heavy tasks'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_laptop_heat, @l_heavy_q, 'Thermal paste or fan performance may be degraded. Service cooling system.', 'Yes', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_laptop_heat AND parent_id = @l_heavy_q AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_laptop_heat, @l_heavy_q, 'Check GPU/CPU driver stability and disable overclocking profiles.', 'No', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_laptop_heat AND parent_id = @l_heavy_q AND option_label = 'No'
);

-- -----------------------------------------------------------------------------
-- 9) Seed nodes for tree: Sample: Brake Pedal Feels Spongy
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT
    @tree_brakes,
    NULL,
    'Is brake fluid level below the MIN mark in the reservoir?',
    '',
    'QUESTION',
    0
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes
    WHERE tree_id = @tree_brakes
      AND parent_id IS NULL
      AND node_text = 'Is brake fluid level below the MIN mark in the reservoir?'
);

SET @bp_root := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_brakes
      AND parent_id IS NULL
      AND node_text = 'Is brake fluid level below the MIN mark in the reservoir?'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_brakes, @bp_root, 'Potential leak in brake lines/calipers. Do not drive until leak is fixed and system bled.', 'Yes', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_brakes AND parent_id = @bp_root AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_brakes, @bp_root, 'Does the pedal improve after pumping 2-3 times?', 'No', 'QUESTION', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_brakes AND parent_id = @bp_root AND option_label = 'No'
);

SET @bp_pump_q := (
    SELECT node_id FROM diagnostic_nodes
    WHERE tree_id = @tree_brakes AND parent_id = @bp_root AND option_label = 'No'
    ORDER BY node_id
    LIMIT 1
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_brakes, @bp_pump_q, 'Air in hydraulic lines is likely. Bleed brakes and inspect for fluid contamination.', 'Yes', 'RESULT', 1
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_brakes AND parent_id = @bp_pump_q AND option_label = 'Yes'
);

INSERT INTO diagnostic_nodes (tree_id, parent_id, node_text, option_label, node_type, display_order)
SELECT @tree_brakes, @bp_pump_q, 'Master cylinder internal leak may exist. Perform pressure-hold test and replace if needed.', 'No', 'RESULT', 2
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_nodes WHERE tree_id = @tree_brakes AND parent_id = @bp_pump_q AND option_label = 'No'
);

-- -----------------------------------------------------------------------------
-- 10) Seed ratings for browse/ranking experience
-- -----------------------------------------------------------------------------

INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback)
SELECT @tree_faucet, @diag_rater_1, 5, 'Clear steps and easy to follow.'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_ratings WHERE tree_id = @tree_faucet AND user_id = @diag_rater_1
);

INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback)
SELECT @tree_faucet, @diag_rater_2, 4, 'Helped narrow the issue quickly.'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_ratings WHERE tree_id = @tree_faucet AND user_id = @diag_rater_2
);

INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback)
SELECT @tree_fridge, @diag_rater_1, 4, 'Good first-pass checks before calling support.'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_ratings WHERE tree_id = @tree_fridge AND user_id = @diag_rater_1
);

INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback)
SELECT @tree_car, @diag_rater_2, 5, 'Very practical for roadside troubleshooting.'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_ratings WHERE tree_id = @tree_car AND user_id = @diag_rater_2
);

INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback)
SELECT @tree_breaker, @diag_rater_1, 5, 'Great flow for isolating overload vs wiring issues.'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_ratings WHERE tree_id = @tree_breaker AND user_id = @diag_rater_1
);

INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback)
SELECT @tree_laptop_heat, @diag_rater_2, 4, 'Simple enough for non-technical users.'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_ratings WHERE tree_id = @tree_laptop_heat AND user_id = @diag_rater_2
);

INSERT INTO diagnostic_ratings (tree_id, user_id, rating, feedback)
SELECT @tree_brakes, @diag_rater_1, 5, 'Clear safety-first outcomes.'
WHERE NOT EXISTS (
    SELECT 1 FROM diagnostic_ratings WHERE tree_id = @tree_brakes AND user_id = @diag_rater_1
);

COMMIT;
