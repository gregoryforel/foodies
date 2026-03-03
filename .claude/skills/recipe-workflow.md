# Recipe Platform Workflow

## Adding a New Ingredient

1. Add the ingredient to `db/seed/` or create a new seed file
2. Include: name, slug, food_group, FDC ID (if available), default unit
3. Add nutrient data (at least top 14 nutrients, per 100g)
4. Add allergen flags if applicable
5. Add diet compatibility flags
6. Add density data if the ingredient is commonly measured by volume

## Adding a New Recipe

1. Insert into `recipes` table with title, slug, description, servings
2. Add `recipe_steps` with position, instruction, timing
3. Add `recipe_step_components` for each step (ingredients or sub-recipe references)
4. Run `make compile-recipes` to generate compiled data

## Modifying the Schema

1. Create new migration file: `db/migrations/NNN_description.up.sql`
2. Create rollback: `db/migrations/NNN_description.down.sql`
3. Run `make migrate`
4. Update sqlc queries in `db/sql/`
5. Run `make sqlc`
6. Update Go code

## Testing

```bash
make test                    # All tests
go test ./internal/convert/  # Just conversion tests
```
