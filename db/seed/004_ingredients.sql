-- Seed: ingredients with USDA FoodData Central references
-- Using real FDC IDs where available

INSERT INTO ingredients (name, name_slug, food_group, fdc_id, default_unit_id) VALUES
    ('All-Purpose Flour',    'all-purpose-flour',    'Grains',       168936, (SELECT id FROM units WHERE name = 'g')),
    ('Butter, unsalted',     'butter-unsalted',      'Dairy',        173410, (SELECT id FROM units WHERE name = 'g')),
    ('Granulated Sugar',     'granulated-sugar',     'Sweeteners',   169655, (SELECT id FROM units WHERE name = 'g')),
    ('Eggs, whole, raw',     'eggs-whole-raw',       'Eggs',         171287, (SELECT id FROM units WHERE name = 'piece')),
    ('Salt, table',          'salt-table',           'Spices',       173468, (SELECT id FROM units WHERE name = 'g')),
    ('Whole Milk',           'whole-milk',           'Dairy',        171265, (SELECT id FROM units WHERE name = 'ml')),
    ('Olive Oil',            'olive-oil',            'Oils',         171413, (SELECT id FROM units WHERE name = 'ml')),
    ('Chicken Breast, raw',  'chicken-breast-raw',   'Poultry',      171077, (SELECT id FROM units WHERE name = 'g')),
    ('Onion, raw',           'onion-raw',            'Vegetables',   170000, (SELECT id FROM units WHERE name = 'g')),
    ('Garlic, raw',          'garlic-raw',           'Vegetables',   169230, (SELECT id FROM units WHERE name = 'g')),
    ('Tomatoes, raw',        'tomatoes-raw',         'Vegetables',   170457, (SELECT id FROM units WHERE name = 'g')),
    ('Heavy Cream',          'heavy-cream',          'Dairy',        170857, (SELECT id FROM units WHERE name = 'ml')),
    ('Black Pepper',         'black-pepper',         'Spices',       170931, (SELECT id FROM units WHERE name = 'g')),
    ('Thyme, fresh',         'thyme-fresh',          'Herbs',        170937, (SELECT id FROM units WHERE name = 'g')),
    ('Water',                'water',                'Beverages',    NULL,   (SELECT id FROM units WHERE name = 'ml')),
    ('White Rice, raw',      'white-rice-raw',       'Grains',       169756, (SELECT id FROM units WHERE name = 'g')),
    ('Lemon, raw',           'lemon-raw',            'Fruits',       167746, (SELECT id FROM units WHERE name = 'piece')),
    ('Beef Tenderloin, raw', 'beef-tenderloin-raw',  'Beef',         174036, (SELECT id FROM units WHERE name = 'g')),
    ('Mushrooms, white, raw','mushrooms-white-raw',  'Vegetables',   169251, (SELECT id FROM units WHERE name = 'g')),
    ('Dijon Mustard',        'dijon-mustard',        'Condiments',   172236, (SELECT id FROM units WHERE name = 'g'));

-- Ingredient densities (g/ml) for volume<->mass conversion
INSERT INTO ingredient_densities (ingredient_id, density_g_per_ml, notes) VALUES
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'),  0.593, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'granulated-sugar'),   0.845, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'butter-unsalted'),    0.911, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'whole-milk'),         1.030, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'olive-oil'),          0.918, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'heavy-cream'),        0.994, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'water'),              1.000, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'white-rice-raw'),     0.850, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'salt-table'),         1.217, NULL);

-- Allergen assignments
INSERT INTO ingredient_allergens (ingredient_id, allergen_id, severity) VALUES
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM allergens WHERE name = 'Gluten'), 'contains'),
    ((SELECT id FROM ingredients WHERE name_slug = 'butter-unsalted'),   (SELECT id FROM allergens WHERE name = 'Milk'),   'contains'),
    ((SELECT id FROM ingredients WHERE name_slug = 'eggs-whole-raw'),    (SELECT id FROM allergens WHERE name = 'Eggs'),   'contains'),
    ((SELECT id FROM ingredients WHERE name_slug = 'whole-milk'),        (SELECT id FROM allergens WHERE name = 'Milk'),   'contains'),
    ((SELECT id FROM ingredients WHERE name_slug = 'heavy-cream'),       (SELECT id FROM allergens WHERE name = 'Milk'),   'contains'),
    ((SELECT id FROM ingredients WHERE name_slug = 'dijon-mustard'),     (SELECT id FROM allergens WHERE name = 'Mustard'),'contains');

-- Diet flag assignments
-- Vegan: incompatible with animal products
INSERT INTO ingredient_diet_flags (ingredient_id, diet_flag_id, compatible) VALUES
    -- Flour: generally compatible with most diets
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM diet_flags WHERE name = 'kosher'),     true),
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM diet_flags WHERE name = 'keto'),       false),
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),false),
    ((SELECT id FROM ingredients WHERE name_slug = 'all-purpose-flour'), (SELECT id FROM diet_flags WHERE name = 'paleo'),      false),
    -- Butter: not vegan, not dairy-free
    ((SELECT id FROM ingredients WHERE name_slug = 'butter-unsalted'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      false),
    ((SELECT id FROM ingredients WHERE name_slug = 'butter-unsalted'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'butter-unsalted'), (SELECT id FROM diet_flags WHERE name = 'dairy_free'), false),
    ((SELECT id FROM ingredients WHERE name_slug = 'butter-unsalted'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'butter-unsalted'), (SELECT id FROM diet_flags WHERE name = 'kosher'),     true),
    -- Sugar
    ((SELECT id FROM ingredients WHERE name_slug = 'granulated-sugar'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'granulated-sugar'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'granulated-sugar'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'granulated-sugar'), (SELECT id FROM diet_flags WHERE name = 'keto'),       false),
    -- Eggs: not vegan
    ((SELECT id FROM ingredients WHERE name_slug = 'eggs-whole-raw'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      false),
    ((SELECT id FROM ingredients WHERE name_slug = 'eggs-whole-raw'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'eggs-whole-raw'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'eggs-whole-raw'), (SELECT id FROM diet_flags WHERE name = 'kosher'),     true),
    ((SELECT id FROM ingredients WHERE name_slug = 'eggs-whole-raw'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    -- Salt
    ((SELECT id FROM ingredients WHERE name_slug = 'salt-table'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'salt-table'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'salt-table'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'salt-table'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    ((SELECT id FROM ingredients WHERE name_slug = 'salt-table'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'salt-table'), (SELECT id FROM diet_flags WHERE name = 'kosher'),     true),
    -- Milk: not vegan, not dairy-free
    ((SELECT id FROM ingredients WHERE name_slug = 'whole-milk'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      false),
    ((SELECT id FROM ingredients WHERE name_slug = 'whole-milk'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'whole-milk'), (SELECT id FROM diet_flags WHERE name = 'dairy_free'), false),
    -- Olive oil
    ((SELECT id FROM ingredients WHERE name_slug = 'olive-oil'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'olive-oil'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'olive-oil'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    ((SELECT id FROM ingredients WHERE name_slug = 'olive-oil'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'olive-oil'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'olive-oil'), (SELECT id FROM diet_flags WHERE name = 'kosher'),     true),
    -- Chicken: not vegan, not vegetarian
    ((SELECT id FROM ingredients WHERE name_slug = 'chicken-breast-raw'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      false),
    ((SELECT id FROM ingredients WHERE name_slug = 'chicken-breast-raw'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), false),
    ((SELECT id FROM ingredients WHERE name_slug = 'chicken-breast-raw'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'chicken-breast-raw'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'chicken-breast-raw'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    ((SELECT id FROM ingredients WHERE name_slug = 'chicken-breast-raw'), (SELECT id FROM diet_flags WHERE name = 'paleo'),      true),
    -- Onion
    ((SELECT id FROM ingredients WHERE name_slug = 'onion-raw'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'onion-raw'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'onion-raw'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'onion-raw'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'onion-raw'), (SELECT id FROM diet_flags WHERE name = 'kosher'),     true),
    -- Garlic
    ((SELECT id FROM ingredients WHERE name_slug = 'garlic-raw'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'garlic-raw'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'garlic-raw'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    -- Tomatoes
    ((SELECT id FROM ingredients WHERE name_slug = 'tomatoes-raw'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'tomatoes-raw'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'tomatoes-raw'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'tomatoes-raw'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    -- Heavy cream: not vegan, not dairy-free
    ((SELECT id FROM ingredients WHERE name_slug = 'heavy-cream'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      false),
    ((SELECT id FROM ingredients WHERE name_slug = 'heavy-cream'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'heavy-cream'), (SELECT id FROM diet_flags WHERE name = 'dairy_free'), false),
    ((SELECT id FROM ingredients WHERE name_slug = 'heavy-cream'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    -- Black pepper
    ((SELECT id FROM ingredients WHERE name_slug = 'black-pepper'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'black-pepper'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'black-pepper'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'black-pepper'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    -- Thyme
    ((SELECT id FROM ingredients WHERE name_slug = 'thyme-fresh'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'thyme-fresh'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'thyme-fresh'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    -- Water
    ((SELECT id FROM ingredients WHERE name_slug = 'water'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'water'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'water'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'water'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    ((SELECT id FROM ingredients WHERE name_slug = 'water'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'water'), (SELECT id FROM diet_flags WHERE name = 'kosher'),     true),
    -- Beef: not vegan, not vegetarian
    ((SELECT id FROM ingredients WHERE name_slug = 'beef-tenderloin-raw'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      false),
    ((SELECT id FROM ingredients WHERE name_slug = 'beef-tenderloin-raw'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), false),
    ((SELECT id FROM ingredients WHERE name_slug = 'beef-tenderloin-raw'), (SELECT id FROM diet_flags WHERE name = 'halal'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'beef-tenderloin-raw'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'beef-tenderloin-raw'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    ((SELECT id FROM ingredients WHERE name_slug = 'beef-tenderloin-raw'), (SELECT id FROM diet_flags WHERE name = 'paleo'),      true),
    -- Mushrooms
    ((SELECT id FROM ingredients WHERE name_slug = 'mushrooms-white-raw'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'mushrooms-white-raw'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'mushrooms-white-raw'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true),
    ((SELECT id FROM ingredients WHERE name_slug = 'mushrooms-white-raw'), (SELECT id FROM diet_flags WHERE name = 'keto'),       true),
    -- Dijon mustard
    ((SELECT id FROM ingredients WHERE name_slug = 'dijon-mustard'), (SELECT id FROM diet_flags WHERE name = 'vegan'),      true),
    ((SELECT id FROM ingredients WHERE name_slug = 'dijon-mustard'), (SELECT id FROM diet_flags WHERE name = 'vegetarian'), true),
    ((SELECT id FROM ingredients WHERE name_slug = 'dijon-mustard'), (SELECT id FROM diet_flags WHERE name = 'gluten_free'),true);
