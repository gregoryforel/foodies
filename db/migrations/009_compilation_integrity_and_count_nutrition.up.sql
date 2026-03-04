-- Migration 009: compilation integrity and count-unit nutrition fixes

-- ============================================================
-- 1) Data integrity constraints
-- ============================================================
ALTER TABLE recipes
    ADD CONSTRAINT chk_recipes_servings_positive CHECK (servings > 0),
    ADD CONSTRAINT chk_recipes_yield_positive CHECK (yield_amount IS NULL OR yield_amount > 0);

ALTER TABLE recipe_steps
    ADD CONSTRAINT chk_recipe_steps_position_positive CHECK (position > 0),
    ADD CONSTRAINT chk_recipe_steps_active_nonneg CHECK (active_seconds >= 0),
    ADD CONSTRAINT chk_recipe_steps_passive_nonneg CHECK (passive_seconds >= 0);

ALTER TABLE recipe_step_components
    ADD CONSTRAINT chk_recipe_step_components_position_nonneg CHECK (position >= 0),
    ADD CONSTRAINT chk_recipe_step_components_quantity_positive CHECK (quantity > 0);

ALTER TABLE ingredient_nutrients
    ADD CONSTRAINT chk_ingredient_nutrients_amount_nonneg CHECK (amount_per_100g >= 0);

ALTER TABLE ingredient_densities
    ADD CONSTRAINT chk_ingredient_densities_positive CHECK (density_g_per_ml > 0);

-- ============================================================
-- 2) Count-unit nutrition support
-- ============================================================
CREATE TABLE ingredient_portions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    unit_id UUID NOT NULL REFERENCES units(id),
    grams_per_unit NUMERIC NOT NULL CHECK (grams_per_unit > 0),
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX idx_ingredient_portions_unique
    ON ingredient_portions (ingredient_id, unit_id, COALESCE(description, ''));

-- ============================================================
-- 3) Compilation invalidation for ingredient-side changes
-- ============================================================
CREATE OR REPLACE FUNCTION mark_recipes_using_ingredient_stale() RETURNS TRIGGER AS $$
DECLARE
    changed_ingredient_id UUID;
BEGIN
    IF TG_TABLE_NAME = 'ingredients' THEN
        changed_ingredient_id := COALESCE(NEW.id, OLD.id);
    ELSE
        changed_ingredient_id := COALESCE(NEW.ingredient_id, OLD.ingredient_id);
    END IF;

    IF changed_ingredient_id IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;

    WITH RECURSIVE directly_affected AS (
        SELECT DISTINCT rs.recipe_id
        FROM recipe_step_components rsc
        JOIN recipe_steps rs ON rs.id = rsc.step_id
        WHERE rsc.ingredient_id = changed_ingredient_id
    ), ancestors AS (
        SELECT recipe_id FROM directly_affected
        UNION
        SELECT rs.recipe_id
        FROM ancestors a
        JOIN recipe_step_components rsc ON rsc.sub_recipe_id = a.recipe_id
        JOIN recipe_steps rs ON rs.id = rsc.step_id
    )
    UPDATE compiled_recipes
    SET is_stale = true
    WHERE recipe_id IN (SELECT recipe_id FROM ancestors);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stale_on_ingredient_change
    AFTER UPDATE OF name, default_unit_id ON ingredients
    FOR EACH ROW EXECUTE FUNCTION mark_recipes_using_ingredient_stale();

CREATE TRIGGER trg_stale_on_ingredient_nutrients_change
    AFTER INSERT OR UPDATE OR DELETE ON ingredient_nutrients
    FOR EACH ROW EXECUTE FUNCTION mark_recipes_using_ingredient_stale();

CREATE TRIGGER trg_stale_on_ingredient_densities_change
    AFTER INSERT OR UPDATE OR DELETE ON ingredient_densities
    FOR EACH ROW EXECUTE FUNCTION mark_recipes_using_ingredient_stale();

CREATE TRIGGER trg_stale_on_ingredient_allergens_change
    AFTER INSERT OR UPDATE OR DELETE ON ingredient_allergens
    FOR EACH ROW EXECUTE FUNCTION mark_recipes_using_ingredient_stale();

CREATE TRIGGER trg_stale_on_ingredient_diet_flags_change
    AFTER INSERT OR UPDATE OR DELETE ON ingredient_diet_flags
    FOR EACH ROW EXECUTE FUNCTION mark_recipes_using_ingredient_stale();

CREATE TRIGGER trg_stale_on_ingredient_portions_change
    AFTER INSERT OR UPDATE OR DELETE ON ingredient_portions
    FOR EACH ROW EXECUTE FUNCTION mark_recipes_using_ingredient_stale();

-- ============================================================
-- 4) Compilation invalidation for tag changes
-- ============================================================
CREATE OR REPLACE FUNCTION mark_tagged_recipes_stale() RETURNS TRIGGER AS $$
DECLARE
    changed_tag_id UUID;
BEGIN
    IF TG_TABLE_NAME = 'recipe_tags' THEN
        changed_tag_id := COALESCE(NEW.tag_id, OLD.tag_id);
    ELSE
        changed_tag_id := COALESCE(NEW.id, OLD.id);
    END IF;

    IF changed_tag_id IS NULL THEN
        RETURN COALESCE(NEW, OLD);
    END IF;

    UPDATE compiled_recipes cr
    SET is_stale = true
    WHERE cr.recipe_id IN (
        SELECT rt.recipe_id
        FROM recipe_tags rt
        WHERE rt.tag_id = changed_tag_id
    );

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_stale_on_recipe_tags_change
    AFTER INSERT OR UPDATE OR DELETE ON recipe_tags
    FOR EACH ROW EXECUTE FUNCTION mark_tagged_recipes_stale();

CREATE TRIGGER trg_stale_on_tags_change
    AFTER UPDATE OF name, category ON tags
    FOR EACH ROW EXECUTE FUNCTION mark_tagged_recipes_stale();

-- ============================================================
-- 5) Performance indexes for compile/filter paths
-- ============================================================
CREATE INDEX idx_ingredient_allergens_contains
    ON ingredient_allergens (ingredient_id, allergen_id)
    WHERE severity = 'contains';

CREATE INDEX idx_ingredient_diet_flags_compatible_true
    ON ingredient_diet_flags (diet_flag_id, ingredient_id)
    WHERE compatible = true;

CREATE INDEX idx_recipe_tags_tag_recipe
    ON recipe_tags (tag_id, recipe_id);
