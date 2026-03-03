# Architecture

## System Design

```
         Cloudflare CDN (later)
              |
         Go backend (stdlib + sqlc + templ)
              |
          PostgreSQL 17
              |
    +---------+---------+
    |                   |
  Web                 Mobile
  (htmx + templ +     (Flutter, later)
   Alpine.js)
```

## Data Model

### Recipe DAG

Recipes can reference sub-recipes through `recipe_step_components`. Each step component is either a direct ingredient or a reference to another recipe. This forms a directed acyclic graph (DAG).

Example: Beef Wellington references Puff Pastry as a sub-recipe. The Puff Pastry recipe's ingredients (flour, butter, water, salt) roll up into the Beef Wellington's consolidated grocery list.

Cycle prevention is enforced at the database level via a trigger (`check_recipe_cycle`) that walks the DAG before allowing inserts.

### Compilation Pipeline

When a recipe is saved/published, it is "compiled":

1. **DAG resolution:** A recursive CTE walks the sub-recipe tree, resolving all leaf ingredients.
2. **Grocery list consolidation:** Quantities are aggregated per ingredient across all steps and sub-recipes. Identical ingredients are summed.
3. **Allergen collection:** Union of all allergens from all ingredients.
4. **Diet compatibility:** Intersection — a recipe is "vegan" only if ALL ingredients are vegan-compatible.
5. **Timing aggregation:** Sum of active_seconds and passive_seconds across all steps.
6. **Nutrition rollup:** Per-100g nutrient data is scaled by ingredient quantity and summed.

The compiled result is stored in `compiled_recipes` as structured JSONB plus extracted columns for indexing.

### Unit System

- All quantities stored in metric base units (g, ml, °C)
- US conversion uses `units.to_base_factor` and `units.to_base_offset`
- Volume↔mass conversion uses per-ingredient `ingredient_densities.density_g_per_ml`
- Temperature: °C to °F = (°C × 1.8) + 32

### i18n

- `translations` table for entity-level translations (ingredients, nutrients, allergens, etc.)
- Currently English only
- Future: `recipe_translations` and `recipe_step_translations` tables

## Data Sources

Nutrient data comes from USDA FoodData Central (SR Legacy and Foundation Foods databases). Each ingredient tracks its `fdc_id` for provenance. See `docs/DATA_SOURCES.md` for details.
