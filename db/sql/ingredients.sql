-- name: GetIngredientByID :one
SELECT * FROM ingredients WHERE id = $1;

-- name: GetIngredientBySlug :one
SELECT * FROM ingredients WHERE name_slug = $1;

-- name: ListIngredients :many
SELECT * FROM ingredients ORDER BY name LIMIT $1 OFFSET $2;

-- name: SearchIngredients :many
SELECT * FROM ingredients
WHERE name ILIKE '%' || $1 || '%'
ORDER BY name
LIMIT $2;

-- name: GetIngredientDensity :one
SELECT * FROM ingredient_densities
WHERE ingredient_id = $1 AND (notes IS NULL OR notes = '')
LIMIT 1;

-- name: GetIngredientDensityWithNotes :one
SELECT * FROM ingredient_densities
WHERE ingredient_id = $1 AND notes = $2;

-- name: ListIngredientNutrients :many
SELECT
    n.name AS nutrient_name,
    n.unit AS nutrient_unit,
    n.display_rank,
    n.is_displayed,
    nc.name AS category_name,
    inu.amount_per_100g
FROM ingredient_nutrients inu
JOIN nutrients n ON n.id = inu.nutrient_id
LEFT JOIN nutrient_categories nc ON nc.id = n.category_id
WHERE inu.ingredient_id = $1
ORDER BY n.display_rank;

-- name: ListIngredientAllergens :many
SELECT a.name, ia.severity
FROM ingredient_allergens ia
JOIN allergens a ON a.id = ia.allergen_id
WHERE ia.ingredient_id = $1;

-- name: ListIngredientDietFlags :many
SELECT df.name, idf.compatible
FROM ingredient_diet_flags idf
JOIN diet_flags df ON df.id = idf.diet_flag_id
WHERE idf.ingredient_id = $1;
