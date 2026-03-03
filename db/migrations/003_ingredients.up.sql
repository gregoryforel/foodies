-- Migration 003: Ingredients, nutrition, allergens, and diet flags

-- Nutrient categories for grouping in UI
CREATE TABLE nutrient_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    sort_order INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Canonical nutrient definitions. Seeded from USDA FoodData Central.
CREATE TABLE nutrients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fdc_nutrient_id INT UNIQUE,
    fdc_nutrient_number TEXT,
    name TEXT NOT NULL,
    unit TEXT NOT NULL,
    category_id UUID REFERENCES nutrient_categories(id),
    display_rank INT NOT NULL DEFAULT 9999,
    is_displayed BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Canonical ingredients
CREATE TABLE ingredients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fdc_id INT,
    open_food_facts_id TEXT,
    name TEXT NOT NULL,
    name_slug TEXT NOT NULL UNIQUE,
    food_group TEXT,
    default_unit_id UUID REFERENCES units(id),
    data_sources JSONB DEFAULT '[]',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Per-ingredient density for volume<->mass conversion
CREATE TABLE ingredient_densities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    density_g_per_ml NUMERIC NOT NULL,
    notes TEXT,
    UNIQUE(ingredient_id, notes),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Nutrient values per ingredient (per 100g)
CREATE TABLE ingredient_nutrients (
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    nutrient_id UUID NOT NULL REFERENCES nutrients(id) ON DELETE CASCADE,
    amount_per_100g NUMERIC NOT NULL,
    data_source TEXT,
    PRIMARY KEY (ingredient_id, nutrient_id)
);

-- Allergens (EU14 + common additions)
CREATE TABLE allergens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    regulatory_group TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ingredient_allergens (
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    allergen_id UUID NOT NULL REFERENCES allergens(id) ON DELETE CASCADE,
    severity TEXT NOT NULL DEFAULT 'contains'
        CHECK (severity IN ('contains', 'may_contain', 'free_from')),
    PRIMARY KEY (ingredient_id, allergen_id)
);

-- Diet compatibility flags
CREATE TABLE diet_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ingredient_diet_flags (
    ingredient_id UUID NOT NULL REFERENCES ingredients(id) ON DELETE CASCADE,
    diet_flag_id UUID NOT NULL REFERENCES diet_flags(id) ON DELETE CASCADE,
    compatible BOOLEAN NOT NULL,
    PRIMARY KEY (ingredient_id, diet_flag_id)
);
