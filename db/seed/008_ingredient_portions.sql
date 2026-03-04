-- Seed: ingredient portions for count-based nutrition conversion
-- Default portion rows use description = NULL and are consumed by compiler logic.

INSERT INTO ingredient_portions (ingredient_id, unit_id, grams_per_unit, description) VALUES
    ((SELECT id FROM ingredients WHERE name_slug = 'eggs-whole-raw'), (SELECT id FROM units WHERE name = 'piece'), 50, NULL),
    ((SELECT id FROM ingredients WHERE name_slug = 'lemon-raw'), (SELECT id FROM units WHERE name = 'piece'), 84, NULL)
ON CONFLICT (ingredient_id, unit_id, COALESCE(description, '')) DO NOTHING;
