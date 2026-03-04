-- Migration 012: integrity and compilation hardening
-- - Enforce safer identity/unit constraints
-- - Make cycle prevention deferrable for transactional correctness
-- - Add allergen severity split + compile hash fields to compiled_recipes

-- ============================================================
-- 1) External identity uniqueness for ingredients
-- ============================================================
CREATE UNIQUE INDEX IF NOT EXISTS uq_ingredients_fdc_id
    ON ingredients (fdc_id)
    WHERE fdc_id IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS uq_ingredients_open_food_facts_id
    ON ingredients (open_food_facts_id)
    WHERE open_food_facts_id IS NOT NULL;

-- ============================================================
-- 2) Prevent invalid unit dimensions on recipe components
-- ============================================================
CREATE OR REPLACE FUNCTION enforce_recipe_component_unit_dimension() RETURNS TRIGGER AS $$
DECLARE
    unit_dimension TEXT;
BEGIN
    SELECT dimension INTO unit_dimension
    FROM units
    WHERE id = NEW.unit_id;

    IF unit_dimension IS NULL THEN
        RAISE EXCEPTION 'Unknown unit_id for recipe component: %', NEW.unit_id;
    END IF;

    IF unit_dimension NOT IN ('mass', 'volume', 'count') THEN
        RAISE EXCEPTION 'Invalid unit dimension "%" for recipe component', unit_dimension;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_enforce_recipe_component_unit_dimension ON recipe_step_components;

CREATE TRIGGER trg_enforce_recipe_component_unit_dimension
    BEFORE INSERT OR UPDATE OF unit_id ON recipe_step_components
    FOR EACH ROW
    EXECUTE FUNCTION enforce_recipe_component_unit_dimension();

-- ============================================================
-- 3) Cycle prevention trigger must be deferrable
-- ============================================================
DROP TRIGGER IF EXISTS trg_check_recipe_cycle ON recipe_step_components;

CREATE CONSTRAINT TRIGGER trg_check_recipe_cycle
    AFTER INSERT OR UPDATE ON recipe_step_components
    DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE FUNCTION check_recipe_cycle();

-- ============================================================
-- 4) Enrich compiled_recipes allergen and integrity metadata
-- ============================================================
ALTER TABLE compiled_recipes
    ADD COLUMN IF NOT EXISTS compiled_allergens_contains TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS compiled_allergens_may_contain TEXT[] NOT NULL DEFAULT '{}',
    ADD COLUMN IF NOT EXISTS compile_input_hash TEXT;

-- Backfill new contains column from legacy compiled_allergens
UPDATE compiled_recipes
SET compiled_allergens_contains = compiled_allergens
WHERE array_length(compiled_allergens_contains, 1) IS NULL
  AND array_length(compiled_allergens, 1) IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_compiled_allergens_contains
    ON compiled_recipes USING GIN (compiled_allergens_contains);

CREATE INDEX IF NOT EXISTS idx_compiled_allergens_may_contain
    ON compiled_recipes USING GIN (compiled_allergens_may_contain);

CREATE INDEX IF NOT EXISTS idx_compiled_compile_input_hash
    ON compiled_recipes (compile_input_hash);
