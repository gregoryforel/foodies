-- Down Migration 015: final data model hardening

-- ============================================================
-- 7) Missing feature foundations
-- ============================================================
DROP INDEX IF EXISTS idx_ingredient_prices_lookup;
DROP TABLE IF EXISTS ingredient_prices;

ALTER TABLE recipe_steps
    DROP COLUMN IF EXISTS can_prepare_ahead,
    DROP COLUMN IF EXISTS make_ahead_note;

DROP INDEX IF EXISTS idx_shopping_list_items_list;
DROP TABLE IF EXISTS shopping_list_items;
DROP TABLE IF EXISTS shopping_list_recipe_items;
DROP TABLE IF EXISTS shopping_lists;

DROP INDEX IF EXISTS idx_meal_plan_items_plan_time;
DROP TABLE IF EXISTS meal_plan_items;
DROP TABLE IF EXISTS meal_plans;

DROP TABLE IF EXISTS recipe_forks;
DROP TABLE IF EXISTS recipe_review_ratings;

-- ============================================================
-- 6) Multi-tenancy and authorization foundations
-- ============================================================
DROP TABLE IF EXISTS ingredient_library_items;
DROP TABLE IF EXISTS ingredient_libraries;

DROP INDEX IF EXISTS idx_recipe_permissions_principal;
DROP TABLE IF EXISTS recipe_permissions;

DROP INDEX IF EXISTS idx_organization_members_user;
DROP TABLE IF EXISTS organization_members;
DROP TABLE IF EXISTS organizations;

-- ============================================================
-- 5) Recipe graph precomputation support (closure table)
-- ============================================================
DROP INDEX IF EXISTS idx_recipe_closure_descendant;
DROP TABLE IF EXISTS recipe_closure;

-- ============================================================
-- 4) Compiled payload versioning
-- ============================================================
ALTER TABLE compiled_recipes
    DROP COLUMN IF EXISTS compile_schema_version;

-- ============================================================
-- 3) Missing FK-side / lookup indexes
-- ============================================================
DROP INDEX IF EXISTS idx_unit_translations_locale;
DROP INDEX IF EXISTS idx_nutrient_translations_locale;
DROP INDEX IF EXISTS idx_diet_flag_translations_locale;
DROP INDEX IF EXISTS idx_allergen_translations_locale;
DROP INDEX IF EXISTS idx_tag_translations_locale;
DROP INDEX IF EXISTS idx_step_translations_locale;
DROP INDEX IF EXISTS idx_ingredient_translations_locale;
DROP INDEX IF EXISTS idx_recipe_translations_locale;
DROP INDEX IF EXISTS idx_recipe_tags_tag_id;
DROP INDEX IF EXISTS idx_ingredient_diet_flags_diet_flag_id;
DROP INDEX IF EXISTS idx_ingredient_allergens_allergen_id;
DROP INDEX IF EXISTS idx_ingredient_nutrients_nutrient_id;

-- ============================================================
-- 2) Tighten yield unit integrity
-- ============================================================
DROP TRIGGER IF EXISTS trg_enforce_recipe_yield_unit_dimension ON recipes;
DROP FUNCTION IF EXISTS enforce_recipe_yield_unit_dimension();

-- ============================================================
-- 1) Ensure compiled rows always exist for recipes
-- ============================================================
DROP TRIGGER IF EXISTS trg_compiled_row_on_recipe_insert ON recipes;
DROP FUNCTION IF EXISTS ensure_compiled_row_for_recipe();
