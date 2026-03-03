-- Seed: nutrient categories and nutrients (USDA FoodData Central)

INSERT INTO nutrient_categories (name, sort_order) VALUES
    ('Macronutrients', 1),
    ('Minerals', 2),
    ('Vitamins', 3),
    ('Lipids', 4),
    ('Other', 5);

-- 30 most commonly displayed nutrients from USDA
INSERT INTO nutrients (fdc_nutrient_id, fdc_nutrient_number, name, unit, category_id, display_rank, is_displayed) VALUES
    (1008, '208', 'Energy',                            'kcal', (SELECT id FROM nutrient_categories WHERE name = 'Macronutrients'), 1,  true),
    (1003, '203', 'Protein',                           'g',    (SELECT id FROM nutrient_categories WHERE name = 'Macronutrients'), 2,  true),
    (1004, '204', 'Total lipid (fat)',                 'g',    (SELECT id FROM nutrient_categories WHERE name = 'Macronutrients'), 3,  true),
    (1005, '205', 'Carbohydrate, by difference',       'g',    (SELECT id FROM nutrient_categories WHERE name = 'Macronutrients'), 4,  true),
    (1079, '291', 'Fiber, total dietary',              'g',    (SELECT id FROM nutrient_categories WHERE name = 'Macronutrients'), 5,  true),
    (2000, '269', 'Sugars, total including NLEA',      'g',    (SELECT id FROM nutrient_categories WHERE name = 'Macronutrients'), 6,  true),
    (1051, '255', 'Water',                             'g',    (SELECT id FROM nutrient_categories WHERE name = 'Other'),          30, false),
    (1087, '301', 'Calcium, Ca',                       'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Minerals'),       7,  true),
    (1089, '303', 'Iron, Fe',                          'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Minerals'),       8,  true),
    (1090, '304', 'Magnesium, Mg',                     'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Minerals'),       9,  true),
    (1091, '305', 'Phosphorus, P',                     'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Minerals'),       10, true),
    (1092, '306', 'Potassium, K',                      'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Minerals'),       11, true),
    (1093, '307', 'Sodium, Na',                        'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Minerals'),       12, true),
    (1095, '309', 'Zinc, Zn',                          'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Minerals'),       13, true),
    (1162, '401', 'Vitamin C, total ascorbic acid',    'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       14, true),
    (1165, '404', 'Thiamin',                           'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       15, true),
    (1166, '405', 'Riboflavin',                        'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       16, true),
    (1167, '406', 'Niacin',                            'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       17, true),
    (1175, '415', 'Vitamin B-6',                       'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       18, true),
    (1177, '417', 'Folate, total',                     'µg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       19, true),
    (1178, '418', 'Vitamin B-12',                      'µg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       20, true),
    (1106, '320', 'Vitamin A, RAE',                    'µg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       21, true),
    (1109, '323', 'Vitamin E (alpha-tocopherol)',      'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       22, true),
    (1114, '328', 'Vitamin D (D2 + D3)',               'µg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       23, true),
    (1185, '430', 'Vitamin K (phylloquinone)',         'µg',   (SELECT id FROM nutrient_categories WHERE name = 'Vitamins'),       24, true),
    (1258, '606', 'Fatty acids, total saturated',      'g',    (SELECT id FROM nutrient_categories WHERE name = 'Lipids'),         25, true),
    (1292, '645', 'Fatty acids, total monounsaturated','g',    (SELECT id FROM nutrient_categories WHERE name = 'Lipids'),         26, true),
    (1293, '646', 'Fatty acids, total polyunsaturated','g',    (SELECT id FROM nutrient_categories WHERE name = 'Lipids'),         27, true),
    (1253, '601', 'Cholesterol',                       'mg',   (SELECT id FROM nutrient_categories WHERE name = 'Lipids'),         28, true),
    (1257, '605', 'Fatty acids, total trans',          'g',    (SELECT id FROM nutrient_categories WHERE name = 'Lipids'),         29, true);
