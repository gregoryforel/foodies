-- Migration 004: Recipes, steps, and the DAG

CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID REFERENCES app_users(id),
    title TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    servings INT NOT NULL DEFAULT 4,
    visibility TEXT NOT NULL DEFAULT 'private'
        CHECK (visibility IN ('private', 'public', 'unlisted')),
    source_locale TEXT NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE recipe_steps (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipe_id UUID NOT NULL REFERENCES recipes(id) ON DELETE CASCADE,
    position INT NOT NULL,
    instruction TEXT NOT NULL,
    active_seconds INT NOT NULL DEFAULT 0,
    passive_seconds INT NOT NULL DEFAULT 0,
    UNIQUE(recipe_id, position)
);

CREATE TABLE recipe_step_components (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    step_id UUID NOT NULL REFERENCES recipe_steps(id) ON DELETE CASCADE,
    position INT NOT NULL DEFAULT 0,
    ingredient_id UUID REFERENCES ingredients(id),
    sub_recipe_id UUID REFERENCES recipes(id),
    quantity NUMERIC NOT NULL,
    unit_id UUID NOT NULL REFERENCES units(id),
    optional BOOLEAN NOT NULL DEFAULT false,
    preparation_note TEXT,
    CONSTRAINT exactly_one_component CHECK (
        (ingredient_id IS NOT NULL AND sub_recipe_id IS NULL) OR
        (ingredient_id IS NULL AND sub_recipe_id IS NOT NULL)
    ),
    UNIQUE(step_id, position)
);

CREATE INDEX idx_recipe_steps_recipe ON recipe_steps(recipe_id);
CREATE INDEX idx_recipe_step_components_step ON recipe_step_components(step_id);
CREATE INDEX idx_recipe_step_components_ingredient ON recipe_step_components(ingredient_id);
CREATE INDEX idx_recipe_step_components_sub_recipe ON recipe_step_components(sub_recipe_id);
