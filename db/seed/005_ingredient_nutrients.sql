-- Seed: nutrient values per ingredient (per 100g, from USDA SR Legacy)
-- Top 14 nutrients for each ingredient

-- All-Purpose Flour (USDA FDC 168936)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 364), ('Protein', 10.33), ('Total lipid (fat)', 0.98),
    ('Carbohydrate, by difference', 76.31), ('Fiber, total dietary', 2.7),
    ('Sugars, total including NLEA', 0.27), ('Calcium, Ca', 15), ('Iron, Fe', 4.64),
    ('Sodium, Na', 2), ('Potassium, K', 107), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.155),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'all-purpose-flour';

-- Butter, unsalted (USDA FDC 173410)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 717), ('Protein', 0.85), ('Total lipid (fat)', 81.11),
    ('Carbohydrate, by difference', 0.06), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 0.06), ('Calcium, Ca', 24), ('Iron, Fe', 0.02),
    ('Sodium, Na', 11), ('Potassium, K', 24), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 215), ('Fatty acids, total saturated', 51.368),
    ('Vitamin A, RAE', 684)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'butter-unsalted';

-- Granulated Sugar (USDA FDC 169655)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 387), ('Protein', 0), ('Total lipid (fat)', 0),
    ('Carbohydrate, by difference', 99.98), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 99.80), ('Calcium, Ca', 1), ('Iron, Fe', 0.01),
    ('Sodium, Na', 1), ('Potassium, K', 2), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'granulated-sugar';

-- Eggs, whole, raw (USDA FDC 171287)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 143), ('Protein', 12.56), ('Total lipid (fat)', 9.51),
    ('Carbohydrate, by difference', 0.72), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 0.37), ('Calcium, Ca', 56), ('Iron, Fe', 1.75),
    ('Sodium, Na', 142), ('Potassium, K', 138), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 372), ('Fatty acids, total saturated', 3.126),
    ('Vitamin A, RAE', 160)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'eggs-whole-raw';

-- Salt (USDA FDC 173468)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 0), ('Protein', 0), ('Total lipid (fat)', 0),
    ('Carbohydrate, by difference', 0), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 0), ('Calcium, Ca', 24), ('Iron, Fe', 0.33),
    ('Sodium, Na', 38758), ('Potassium, K', 8), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'salt-table';

-- Whole Milk (USDA FDC 171265)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 61), ('Protein', 3.15), ('Total lipid (fat)', 3.27),
    ('Carbohydrate, by difference', 4.78), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 5.05), ('Calcium, Ca', 113), ('Iron, Fe', 0.03),
    ('Sodium, Na', 43), ('Potassium, K', 132), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 10), ('Fatty acids, total saturated', 1.865),
    ('Vitamin A, RAE', 46)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'whole-milk';

-- Olive Oil (USDA FDC 171413)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 884), ('Protein', 0), ('Total lipid (fat)', 100),
    ('Carbohydrate, by difference', 0), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 0), ('Calcium, Ca', 1), ('Iron, Fe', 0.56),
    ('Sodium, Na', 2), ('Potassium, K', 1), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 13.808),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'olive-oil';

-- Chicken Breast, raw (USDA FDC 171077)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 120), ('Protein', 22.50), ('Total lipid (fat)', 2.62),
    ('Carbohydrate, by difference', 0), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 0), ('Calcium, Ca', 5), ('Iron, Fe', 0.37),
    ('Sodium, Na', 45), ('Potassium, K', 370), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 64), ('Fatty acids, total saturated', 0.563),
    ('Vitamin A, RAE', 7)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'chicken-breast-raw';

-- Onion, raw (USDA FDC 170000)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 40), ('Protein', 1.10), ('Total lipid (fat)', 0.10),
    ('Carbohydrate, by difference', 9.34), ('Fiber, total dietary', 1.7),
    ('Sugars, total including NLEA', 4.24), ('Calcium, Ca', 23), ('Iron, Fe', 0.21),
    ('Sodium, Na', 4), ('Potassium, K', 146), ('Vitamin C, total ascorbic acid', 7.4),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.042),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'onion-raw';

-- Garlic, raw (USDA FDC 169230)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 149), ('Protein', 6.36), ('Total lipid (fat)', 0.50),
    ('Carbohydrate, by difference', 33.06), ('Fiber, total dietary', 2.1),
    ('Sugars, total including NLEA', 1.00), ('Calcium, Ca', 181), ('Iron, Fe', 1.70),
    ('Sodium, Na', 17), ('Potassium, K', 401), ('Vitamin C, total ascorbic acid', 31.2),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.089),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'garlic-raw';

-- Tomatoes, raw (USDA FDC 170457)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 18), ('Protein', 0.88), ('Total lipid (fat)', 0.20),
    ('Carbohydrate, by difference', 3.89), ('Fiber, total dietary', 1.2),
    ('Sugars, total including NLEA', 2.63), ('Calcium, Ca', 10), ('Iron, Fe', 0.27),
    ('Sodium, Na', 5), ('Potassium, K', 237), ('Vitamin C, total ascorbic acid', 13.7),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.028),
    ('Vitamin A, RAE', 42)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'tomatoes-raw';

-- Heavy Cream (USDA FDC 170857)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 340), ('Protein', 2.05), ('Total lipid (fat)', 36.08),
    ('Carbohydrate, by difference', 2.84), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 2.92), ('Calcium, Ca', 65), ('Iron, Fe', 0.03),
    ('Sodium, Na', 38), ('Potassium, K', 75), ('Vitamin C, total ascorbic acid', 0.6),
    ('Cholesterol', 137), ('Fatty acids, total saturated', 23.032),
    ('Vitamin A, RAE', 411)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'heavy-cream';

-- Black Pepper (USDA FDC 170931)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 251), ('Protein', 10.39), ('Total lipid (fat)', 3.26),
    ('Carbohydrate, by difference', 63.95), ('Fiber, total dietary', 25.3),
    ('Sugars, total including NLEA', 0.64), ('Calcium, Ca', 443), ('Iron, Fe', 9.71),
    ('Sodium, Na', 20), ('Potassium, K', 1329), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 1.392),
    ('Vitamin A, RAE', 27)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'black-pepper';

-- Thyme, fresh (USDA FDC 170937)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 101), ('Protein', 5.56), ('Total lipid (fat)', 1.68),
    ('Carbohydrate, by difference', 24.45), ('Fiber, total dietary', 14.0),
    ('Sugars, total including NLEA', 0), ('Calcium, Ca', 405), ('Iron, Fe', 17.45),
    ('Sodium, Na', 9), ('Potassium, K', 609), ('Vitamin C, total ascorbic acid', 160.1),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.467),
    ('Vitamin A, RAE', 238)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'thyme-fresh';

-- Water
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 0), ('Protein', 0), ('Total lipid (fat)', 0),
    ('Carbohydrate, by difference', 0), ('Calcium, Ca', 3), ('Sodium, Na', 5),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'water';

-- White Rice, raw (USDA FDC 169756)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 365), ('Protein', 7.13), ('Total lipid (fat)', 0.66),
    ('Carbohydrate, by difference', 79.95), ('Fiber, total dietary', 1.3),
    ('Sugars, total including NLEA', 0.12), ('Calcium, Ca', 28), ('Iron, Fe', 0.80),
    ('Sodium, Na', 5), ('Potassium, K', 115), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.180),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'white-rice-raw';

-- Lemon, raw (USDA FDC 167746)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 29), ('Protein', 1.10), ('Total lipid (fat)', 0.30),
    ('Carbohydrate, by difference', 9.32), ('Fiber, total dietary', 2.8),
    ('Sugars, total including NLEA', 2.50), ('Calcium, Ca', 26), ('Iron, Fe', 0.60),
    ('Sodium, Na', 2), ('Potassium, K', 138), ('Vitamin C, total ascorbic acid', 53.0),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.039),
    ('Vitamin A, RAE', 1)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'lemon-raw';

-- Beef Tenderloin, raw (USDA FDC 174036)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 218), ('Protein', 20.17), ('Total lipid (fat)', 14.94),
    ('Carbohydrate, by difference', 0), ('Fiber, total dietary', 0),
    ('Sugars, total including NLEA', 0), ('Calcium, Ca', 12), ('Iron, Fe', 1.94),
    ('Sodium, Na', 50), ('Potassium, K', 318), ('Vitamin C, total ascorbic acid', 0),
    ('Cholesterol', 68), ('Fatty acids, total saturated', 5.710),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'beef-tenderloin-raw';

-- Mushrooms, white, raw (USDA FDC 169251)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 22), ('Protein', 3.09), ('Total lipid (fat)', 0.34),
    ('Carbohydrate, by difference', 3.26), ('Fiber, total dietary', 1.0),
    ('Sugars, total including NLEA', 1.98), ('Calcium, Ca', 3), ('Iron, Fe', 0.50),
    ('Sodium, Na', 5), ('Potassium, K', 318), ('Vitamin C, total ascorbic acid', 2.1),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.050),
    ('Vitamin A, RAE', 0)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'mushrooms-white-raw';

-- Dijon Mustard (USDA FDC 172236)
INSERT INTO ingredient_nutrients (ingredient_id, nutrient_id, amount_per_100g, data_source)
SELECT i.id, n.id, v.amount, 'usda_sr_legacy'
FROM ingredients i, (VALUES
    ('Energy', 66), ('Protein', 4.37), ('Total lipid (fat)', 3.34),
    ('Carbohydrate, by difference', 5.83), ('Fiber, total dietary', 3.3),
    ('Sugars, total including NLEA', 2.89), ('Calcium, Ca', 58), ('Iron, Fe', 1.51),
    ('Sodium, Na', 1135), ('Potassium, K', 138), ('Vitamin C, total ascorbic acid', 0.3),
    ('Cholesterol', 0), ('Fatty acids, total saturated', 0.178),
    ('Vitamin A, RAE', 1)
) AS v(nutrient_name, amount)
JOIN nutrients n ON n.name = v.nutrient_name
WHERE i.name_slug = 'dijon-mustard';
