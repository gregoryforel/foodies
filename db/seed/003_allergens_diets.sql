-- Seed: allergens (EU14 + common additions)
INSERT INTO allergens (name, regulatory_group) VALUES
    ('Gluten',       'EU14'),
    ('Crustaceans',  'EU14'),
    ('Eggs',         'EU14'),
    ('Fish',         'EU14'),
    ('Peanuts',      'EU14'),
    ('Soybeans',     'EU14'),
    ('Milk',         'EU14'),
    ('Tree Nuts',    'EU14'),
    ('Celery',       'EU14'),
    ('Mustard',      'EU14'),
    ('Sesame',       'EU14'),
    ('Sulphites',    'EU14'),
    ('Lupin',        'EU14'),
    ('Molluscs',     'EU14'),
    ('Shellfish',    'FDA8'),
    ('Corn',         'custom'),
    ('Nightshades',  'custom');

-- Seed: diet flags
INSERT INTO diet_flags (name) VALUES
    ('vegan'),
    ('vegetarian'),
    ('keto'),
    ('paleo'),
    ('halal'),
    ('kosher'),
    ('gluten_free'),
    ('dairy_free'),
    ('low_fodmap'),
    ('whole30');
