-- Migration 005: Compiled recipes
-- Populated by the compilation pipeline when a recipe is created/updated.
-- The website reads from this table, not from the normalized tables.

CREATE TABLE compiled_recipes (
    recipe_id UUID PRIMARY KEY REFERENCES recipes(id) ON DELETE CASCADE,
    compiled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_stale BOOLEAN NOT NULL DEFAULT true,

    compiled_steps JSONB NOT NULL DEFAULT '[]',
    compiled_grocery_list JSONB NOT NULL DEFAULT '[]',
    compiled_nutrition_per_serving JSONB NOT NULL DEFAULT '{}',
    compiled_nutrition_total JSONB NOT NULL DEFAULT '{}',

    compiled_allergens TEXT[] NOT NULL DEFAULT '{}',
    compiled_diet_flags TEXT[] NOT NULL DEFAULT '{}',

    total_active_seconds INT NOT NULL DEFAULT 0,
    total_passive_seconds INT NOT NULL DEFAULT 0,
    total_calories_per_serving NUMERIC
);

CREATE INDEX idx_compiled_allergens ON compiled_recipes USING GIN (compiled_allergens);
CREATE INDEX idx_compiled_diet_flags ON compiled_recipes USING GIN (compiled_diet_flags);
CREATE INDEX idx_compiled_calories ON compiled_recipes (total_calories_per_serving);
