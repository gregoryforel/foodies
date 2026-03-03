-- Seed: measurement units
-- Mass units (base: grams)
INSERT INTO units (name, name_plural, system, dimension, to_base_factor, to_base_offset) VALUES
    ('g',    'grams',        'metric',    'mass',        1,         0),
    ('kg',   'kilograms',    'metric',    'mass',        1000,      0),
    ('oz',   'ounces',       'us',        'mass',        28.3495,   0),
    ('lb',   'pounds',       'us',        'mass',        453.592,   0);

-- Volume units (base: ml)
INSERT INTO units (name, name_plural, system, dimension, to_base_factor, to_base_offset) VALUES
    ('ml',    'milliliters',  'metric',    'volume',      1,         0),
    ('l',     'liters',       'metric',    'volume',      1000,      0),
    ('tsp',   'teaspoons',    'us',        'volume',      4.929,     0),
    ('tbsp',  'tablespoons',  'us',        'volume',      14.787,    0),
    ('fl_oz', 'fluid ounces', 'us',        'volume',      29.5735,   0),
    ('cup',   'cups',         'us',        'volume',      236.588,   0);

-- Temperature units (base: °C)
-- °C: factor=1, offset=0 → base = (value - 0) / 1 = value
-- °F: factor=1.8, offset=32 → base = (value - 32) / 1.8
INSERT INTO units (name, name_plural, system, dimension, to_base_factor, to_base_offset) VALUES
    ('°C',  'degrees Celsius',    'metric',  'temperature', 1,    0),
    ('°F',  'degrees Fahrenheit', 'us',      'temperature', 1.8,  32);

-- Count / universal
INSERT INTO units (name, name_plural, system, dimension, to_base_factor, to_base_offset) VALUES
    ('piece', 'pieces',  'universal', 'count', 1, 0),
    ('pinch', 'pinches', 'universal', 'count', 1, 0);

-- Length
INSERT INTO units (name, name_plural, system, dimension, to_base_factor, to_base_offset) VALUES
    ('cm',   'centimeters', 'metric', 'length', 1,    0),
    ('inch', 'inches',      'us',     'length', 2.54, 0);
