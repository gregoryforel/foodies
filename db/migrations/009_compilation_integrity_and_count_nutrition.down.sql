-- Migration 009 down: revert compilation integrity and count-unit nutrition fixes

-- Drop performance indexes
DROP INDEX IF EXISTS idx_recipe_tags_tag_recipe;
DROP INDEX IF EXISTS idx_ingredient_diet_flags_compatible_true;
DROP INDEX IF EXISTS idx_ingredient_allergens_contains;

-- Drop tag stale triggers/functions
DROP TRIGGER IF EXISTS trg_stale_on_tags_change ON tags;
DROP TRIGGER IF EXISTS trg_stale_on_recipe_tags_change ON recipe_tags;
DROP FUNCTION IF EXISTS mark_tagged_recipes_stale();

-- Drop ingredient stale triggers/functions
DROP TRIGGER IF EXISTS trg_stale_on_ingredient_portions_change ON ingredient_portions;
DROP TRIGGER IF EXISTS trg_stale_on_ingredient_diet_flags_change ON ingredient_diet_flags;
DROP TRIGGER IF EXISTS trg_stale_on_ingredient_allergens_change ON ingredient_allergens;
DROP TRIGGER IF EXISTS trg_stale_on_ingredient_densities_change ON ingredient_densities;
DROP TRIGGER IF EXISTS trg_stale_on_ingredient_nutrients_change ON ingredient_nutrients;
DROP TRIGGER IF EXISTS trg_stale_on_ingredient_change ON ingredients;
DROP FUNCTION IF EXISTS mark_recipes_using_ingredient_stale();

-- Drop count-unit nutrition table
DROP INDEX IF EXISTS idx_ingredient_portions_unique;
DROP TABLE IF EXISTS ingredient_portions CASCADE;

-- Drop data integrity constraints
ALTER TABLE ingredient_densities
    DROP CONSTRAINT IF EXISTS chk_ingredient_densities_positive;

ALTER TABLE ingredient_nutrients
    DROP CONSTRAINT IF EXISTS chk_ingredient_nutrients_amount_nonneg;

ALTER TABLE recipe_step_components
    DROP CONSTRAINT IF EXISTS chk_recipe_step_components_quantity_positive,
    DROP CONSTRAINT IF EXISTS chk_recipe_step_components_position_nonneg;

ALTER TABLE recipe_steps
    DROP CONSTRAINT IF EXISTS chk_recipe_steps_passive_nonneg,
    DROP CONSTRAINT IF EXISTS chk_recipe_steps_active_nonneg,
    DROP CONSTRAINT IF EXISTS chk_recipe_steps_position_positive;

ALTER TABLE recipes
    DROP CONSTRAINT IF EXISTS chk_recipes_yield_positive,
    DROP CONSTRAINT IF EXISTS chk_recipes_servings_positive;
