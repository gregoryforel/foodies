-- Migration 012 down: revert integrity and compilation hardening

DROP INDEX IF EXISTS idx_compiled_compile_input_hash;
DROP INDEX IF EXISTS idx_compiled_allergens_may_contain;
DROP INDEX IF EXISTS idx_compiled_allergens_contains;

ALTER TABLE compiled_recipes
    DROP COLUMN IF EXISTS compile_input_hash,
    DROP COLUMN IF EXISTS compiled_allergens_may_contain,
    DROP COLUMN IF EXISTS compiled_allergens_contains;

DROP TRIGGER IF EXISTS trg_check_recipe_cycle ON recipe_step_components;

CREATE TRIGGER trg_check_recipe_cycle
    BEFORE INSERT OR UPDATE ON recipe_step_components
    FOR EACH ROW
    EXECUTE FUNCTION check_recipe_cycle();

DROP TRIGGER IF EXISTS trg_enforce_recipe_component_unit_dimension ON recipe_step_components;
DROP FUNCTION IF EXISTS enforce_recipe_component_unit_dimension();

DROP INDEX IF EXISTS uq_ingredients_open_food_facts_id;
DROP INDEX IF EXISTS uq_ingredients_fdc_id;
