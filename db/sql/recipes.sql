-- name: GetRecipeByID :one
SELECT * FROM recipes WHERE id = $1;

-- name: GetRecipeBySlug :one
SELECT * FROM recipes WHERE slug = $1;

-- name: ListPublicRecipes :many
SELECT * FROM recipes
WHERE visibility = 'public'
ORDER BY created_at DESC
LIMIT $1 OFFSET $2;

-- name: SearchPublicRecipes :many
SELECT * FROM recipes
WHERE visibility = 'public'
  AND (title ILIKE '%' || $1 || '%' OR description ILIKE '%' || $1 || '%')
ORDER BY created_at DESC
LIMIT $2;

-- name: ListRecipeSteps :many
SELECT * FROM recipe_steps
WHERE recipe_id = $1
ORDER BY position;

-- name: ListStepComponents :many
SELECT
    rsc.*,
    i.name AS ingredient_name,
    i.name_slug AS ingredient_slug,
    u.name AS unit_name,
    u.name_plural AS unit_name_plural,
    sr.title AS sub_recipe_title,
    sr.slug AS sub_recipe_slug
FROM recipe_step_components rsc
JOIN units u ON u.id = rsc.unit_id
LEFT JOIN ingredients i ON i.id = rsc.ingredient_id
LEFT JOIN recipes sr ON sr.id = rsc.sub_recipe_id
WHERE rsc.step_id = $1
ORDER BY rsc.position;

-- name: GetCompiledRecipe :one
SELECT cr.*, r.title, r.slug, r.description, r.servings, r.source_locale, r.visibility,
       r.author_id, r.created_at AS recipe_created_at, r.updated_at AS recipe_updated_at
FROM compiled_recipes cr
JOIN recipes r ON r.id = cr.recipe_id
WHERE cr.recipe_id = $1;

-- name: GetCompiledRecipeBySlug :one
SELECT cr.*, r.title, r.slug, r.description, r.servings, r.source_locale, r.visibility,
       r.author_id, r.created_at AS recipe_created_at, r.updated_at AS recipe_updated_at
FROM compiled_recipes cr
JOIN recipes r ON r.id = cr.recipe_id
WHERE r.slug = $1;

-- name: ListCompiledRecipes :many
SELECT cr.*, r.title, r.slug, r.description, r.servings, r.source_locale, r.visibility,
       r.author_id, r.created_at AS recipe_created_at, r.updated_at AS recipe_updated_at
FROM compiled_recipes cr
JOIN recipes r ON r.id = cr.recipe_id
WHERE r.visibility = 'public'
ORDER BY r.created_at DESC
LIMIT $1 OFFSET $2;

-- name: SearchCompiledRecipes :many
SELECT cr.*, r.title, r.slug, r.description, r.servings, r.source_locale, r.visibility,
       r.author_id, r.created_at AS recipe_created_at, r.updated_at AS recipe_updated_at
FROM compiled_recipes cr
JOIN recipes r ON r.id = cr.recipe_id
WHERE r.visibility = 'public'
  AND (r.title ILIKE '%' || $1 || '%' OR r.description ILIKE '%' || $1 || '%')
ORDER BY r.created_at DESC
LIMIT $2;

-- name: UpsertCompiledRecipe :exec
INSERT INTO compiled_recipes (
    recipe_id, compiled_at, is_stale,
    compiled_steps, compiled_grocery_list,
    compiled_nutrition_per_serving, compiled_nutrition_total,
    compiled_allergens, compiled_diet_flags,
    total_active_seconds, total_passive_seconds, total_calories_per_serving
) VALUES ($1, now(), false, $2, $3, $4, $5, $6, $7, $8, $9, $10)
ON CONFLICT (recipe_id) DO UPDATE SET
    compiled_at = now(),
    is_stale = false,
    compiled_steps = EXCLUDED.compiled_steps,
    compiled_grocery_list = EXCLUDED.compiled_grocery_list,
    compiled_nutrition_per_serving = EXCLUDED.compiled_nutrition_per_serving,
    compiled_nutrition_total = EXCLUDED.compiled_nutrition_total,
    compiled_allergens = EXCLUDED.compiled_allergens,
    compiled_diet_flags = EXCLUDED.compiled_diet_flags,
    total_active_seconds = EXCLUDED.total_active_seconds,
    total_passive_seconds = EXCLUDED.total_passive_seconds,
    total_calories_per_serving = EXCLUDED.total_calories_per_serving;

-- name: ResolveRecipeTree :many
-- Resolves all leaf ingredients from a recipe's full sub-recipe tree
-- and aggregates total quantities per ingredient.
WITH RECURSIVE recipe_tree AS (
    SELECT
        rsc.ingredient_id,
        rsc.sub_recipe_id,
        rsc.quantity,
        rsc.unit_id,
        1.0::numeric AS multiplier
    FROM recipe_steps rs
    JOIN recipe_step_components rsc ON rsc.step_id = rs.id
    WHERE rs.recipe_id = $1

    UNION ALL

    SELECT
        rsc.ingredient_id,
        rsc.sub_recipe_id,
        rsc.quantity,
        rsc.unit_id,
        rt.multiplier * (rt.quantity / NULLIF(r.servings, 0))
    FROM recipe_tree rt
    JOIN recipes r ON r.id = rt.sub_recipe_id
    JOIN recipe_steps rs ON rs.recipe_id = r.id
    JOIN recipe_step_components rsc ON rsc.step_id = rs.id
    WHERE rt.sub_recipe_id IS NOT NULL
)
SELECT
    ingredient_id,
    unit_id,
    SUM(quantity * multiplier) AS total_quantity
FROM recipe_tree
WHERE ingredient_id IS NOT NULL
GROUP BY ingredient_id, unit_id;

-- name: ListAllRecipeIDs :many
SELECT id FROM recipes ORDER BY created_at;

-- name: CollectRecipeAllergens :many
-- Collects all allergens for a recipe by traversing sub-recipes.
WITH RECURSIVE recipe_tree AS (
    SELECT rsc.ingredient_id, rsc.sub_recipe_id, 1.0::numeric AS multiplier, rsc.quantity
    FROM recipe_steps rs
    JOIN recipe_step_components rsc ON rsc.step_id = rs.id
    WHERE rs.recipe_id = $1
    UNION ALL
    SELECT rsc.ingredient_id, rsc.sub_recipe_id,
           rt.multiplier * (rt.quantity / NULLIF(r.servings, 0)),
           rsc.quantity
    FROM recipe_tree rt
    JOIN recipes r ON r.id = rt.sub_recipe_id
    JOIN recipe_steps rs ON rs.recipe_id = r.id
    JOIN recipe_step_components rsc ON rsc.step_id = rs.id
    WHERE rt.sub_recipe_id IS NOT NULL
)
SELECT DISTINCT a.name
FROM recipe_tree rt
JOIN ingredient_allergens ia ON ia.ingredient_id = rt.ingredient_id
JOIN allergens a ON a.id = ia.allergen_id
WHERE rt.ingredient_id IS NOT NULL AND ia.severity = 'contains';

-- name: CollectRecipeDietFlags :many
-- Determines diet compatibility: a recipe is compatible with a diet
-- only if ALL its ingredients are compatible.
WITH RECURSIVE recipe_tree AS (
    SELECT rsc.ingredient_id, rsc.sub_recipe_id, 1.0::numeric AS multiplier, rsc.quantity
    FROM recipe_steps rs
    JOIN recipe_step_components rsc ON rsc.step_id = rs.id
    WHERE rs.recipe_id = $1
    UNION ALL
    SELECT rsc.ingredient_id, rsc.sub_recipe_id,
           rt.multiplier * (rt.quantity / NULLIF(r.servings, 0)),
           rsc.quantity
    FROM recipe_tree rt
    JOIN recipes r ON r.id = rt.sub_recipe_id
    JOIN recipe_steps rs ON rs.recipe_id = r.id
    JOIN recipe_step_components rsc ON rsc.step_id = rs.id
    WHERE rt.sub_recipe_id IS NOT NULL
)
SELECT df.name
FROM diet_flags df
WHERE NOT EXISTS (
    SELECT 1
    FROM recipe_tree rt
    JOIN ingredient_diet_flags idf ON idf.ingredient_id = rt.ingredient_id
                                  AND idf.diet_flag_id = df.id
    WHERE rt.ingredient_id IS NOT NULL
      AND idf.compatible = false
)
AND EXISTS (
    SELECT 1
    FROM recipe_tree rt
    WHERE rt.ingredient_id IS NOT NULL
);
