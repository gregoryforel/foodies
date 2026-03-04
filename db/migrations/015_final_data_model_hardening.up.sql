-- Migration 015: final data model hardening
-- Closes remaining correctness, scalability, and extensibility gaps.

-- ============================================================
-- 1) Ensure compiled rows always exist for recipes
-- ============================================================
INSERT INTO compiled_recipes (recipe_id, is_stale)
SELECT r.id, true
FROM recipes r
LEFT JOIN compiled_recipes cr ON cr.recipe_id = r.id
WHERE cr.recipe_id IS NULL;

CREATE OR REPLACE FUNCTION ensure_compiled_row_for_recipe() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO compiled_recipes (recipe_id, is_stale)
    VALUES (NEW.id, true)
    ON CONFLICT (recipe_id) DO NOTHING;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_compiled_row_on_recipe_insert ON recipes;

CREATE TRIGGER trg_compiled_row_on_recipe_insert
    AFTER INSERT ON recipes
    FOR EACH ROW
    EXECUTE FUNCTION ensure_compiled_row_for_recipe();

-- ============================================================
-- 2) Tighten yield unit integrity
-- ============================================================
CREATE OR REPLACE FUNCTION enforce_recipe_yield_unit_dimension() RETURNS TRIGGER AS $$
DECLARE
    unit_dimension TEXT;
BEGIN
    IF NEW.yield_unit_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT dimension INTO unit_dimension
    FROM units
    WHERE id = NEW.yield_unit_id;

    IF unit_dimension IS NULL THEN
        RAISE EXCEPTION 'Unknown yield_unit_id: %', NEW.yield_unit_id;
    END IF;

    IF unit_dimension NOT IN ('mass', 'volume', 'count') THEN
        RAISE EXCEPTION 'Invalid yield unit dimension "%"; expected mass, volume, or count', unit_dimension;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_enforce_recipe_yield_unit_dimension ON recipes;

CREATE TRIGGER trg_enforce_recipe_yield_unit_dimension
    BEFORE INSERT OR UPDATE OF yield_unit_id ON recipes
    FOR EACH ROW
    EXECUTE FUNCTION enforce_recipe_yield_unit_dimension();

-- ============================================================
-- 3) Missing FK-side / lookup indexes
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_ingredient_nutrients_nutrient_id
    ON ingredient_nutrients (nutrient_id);

CREATE INDEX IF NOT EXISTS idx_ingredient_allergens_allergen_id
    ON ingredient_allergens (allergen_id);

CREATE INDEX IF NOT EXISTS idx_ingredient_diet_flags_diet_flag_id
    ON ingredient_diet_flags (diet_flag_id);

CREATE INDEX IF NOT EXISTS idx_recipe_tags_tag_id
    ON recipe_tags (tag_id);

CREATE INDEX IF NOT EXISTS idx_recipe_translations_locale
    ON recipe_translations (locale);

CREATE INDEX IF NOT EXISTS idx_ingredient_translations_locale
    ON ingredient_translations (locale);

CREATE INDEX IF NOT EXISTS idx_step_translations_locale
    ON step_translations (locale);

CREATE INDEX IF NOT EXISTS idx_tag_translations_locale
    ON tag_translations (locale);

CREATE INDEX IF NOT EXISTS idx_allergen_translations_locale
    ON allergen_translations (locale);

CREATE INDEX IF NOT EXISTS idx_diet_flag_translations_locale
    ON diet_flag_translations (locale);

CREATE INDEX IF NOT EXISTS idx_nutrient_translations_locale
    ON nutrient_translations (locale);

CREATE INDEX IF NOT EXISTS idx_unit_translations_locale
    ON unit_translations (locale);

-- ============================================================
-- 4) Compiled payload versioning
-- ============================================================
ALTER TABLE compiled_recipes
    ADD COLUMN IF NOT EXISTS compile_schema_version INT NOT NULL DEFAULT 1;

-- ============================================================
-- 5) Recipe graph precomputation support (closure table)
-- ============================================================
CREATE TABLE IF NOT EXISTS recipe_closure (
    ancestor_recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    descendant_recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    depth INT NOT NULL CHECK (depth >= 0),
    PRIMARY KEY (ancestor_recipe_id, descendant_recipe_id)
);

CREATE INDEX IF NOT EXISTS idx_recipe_closure_descendant
    ON recipe_closure (descendant_recipe_id);

-- ============================================================
-- 6) Multi-tenancy and authorization foundations
-- ============================================================
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS organization_members (
    organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'editor', 'viewer')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (organization_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_organization_members_user
    ON organization_members (user_id);

CREATE TABLE IF NOT EXISTS recipe_permissions (
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    principal_type TEXT NOT NULL CHECK (principal_type IN ('user', 'org')),
    principal_id UUID NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('owner', 'editor', 'viewer')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (recipe_id, principal_type, principal_id)
);

CREATE INDEX IF NOT EXISTS idx_recipe_permissions_principal
    ON recipe_permissions (principal_type, principal_id);

CREATE TABLE IF NOT EXISTS ingredient_libraries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_type TEXT NOT NULL CHECK (owner_type IN ('user', 'org', 'global')),
    owner_id UUID,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (owner_type, owner_id, name)
);

CREATE TABLE IF NOT EXISTS ingredient_library_items (
    library_id UUID NOT NULL REFERENCES ingredient_libraries(id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (library_id, ingredient_id)
);

-- ============================================================
-- 7) Missing feature foundations
-- ============================================================
CREATE TABLE IF NOT EXISTS recipe_review_ratings (
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (recipe_id, user_id)
);

CREATE TABLE IF NOT EXISTS recipe_forks (
    forked_recipe_id UUID PRIMARY KEY REFERENCES recipes(id) ON DELETE CASCADE,
    parent_recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE RESTRICT,
    forked_by UUID REFERENCES app_users(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (forked_recipe_id <> parent_recipe_id)
);

CREATE TABLE IF NOT EXISTS meal_plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS meal_plan_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    meal_plan_id UUID NOT NULL REFERENCES meal_plans(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE RESTRICT,
    scheduled_at TIMESTAMPTZ NOT NULL,
    meal_type TEXT CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    servings NUMERIC NOT NULL CHECK (servings > 0)
);

CREATE INDEX IF NOT EXISTS idx_meal_plan_items_plan_time
    ON meal_plan_items (meal_plan_id, scheduled_at);

CREATE TABLE IF NOT EXISTS shopping_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS shopping_list_recipe_items (
    shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    servings NUMERIC NOT NULL CHECK (servings > 0),
    PRIMARY KEY (shopping_list_id, recipe_id)
);

CREATE TABLE IF NOT EXISTS shopping_list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    shopping_list_id UUID NOT NULL REFERENCES shopping_lists(id) ON DELETE CASCADE,
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE RESTRICT,
    quantity NUMERIC NOT NULL CHECK (quantity >= 0),
    unit_id UUID NOT NULL REFERENCES units(id),
    checked BOOLEAN NOT NULL DEFAULT false,
    note TEXT
);

CREATE INDEX IF NOT EXISTS idx_shopping_list_items_list
    ON shopping_list_items (shopping_list_id, checked);

ALTER TABLE recipe_steps
    ADD COLUMN IF NOT EXISTS make_ahead_note TEXT,
    ADD COLUMN IF NOT EXISTS can_prepare_ahead BOOLEAN NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS ingredient_prices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    scope_type TEXT NOT NULL CHECK (scope_type IN ('global', 'user', 'org')),
    scope_id UUID,
    currency_code CHAR(3) NOT NULL,
    price_per_kg NUMERIC NOT NULL CHECK (price_per_kg >= 0),
    observed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    source TEXT
);

CREATE INDEX IF NOT EXISTS idx_ingredient_prices_lookup
    ON ingredient_prices (ingredient_id, scope_type, scope_id, observed_at DESC);
