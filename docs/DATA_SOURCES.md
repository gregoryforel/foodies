# Data Sources

## Nutrition Data

### USDA FoodData Central

Primary source for nutrient data. We use two databases:

- **SR Legacy** (Standard Reference Legacy): The classic USDA nutrient database with ~7,700 food items and up to 150 nutrients per food. Stable, well-tested data.
- **Foundation Foods**: Newer, more detailed dataset with analytical data and sample information.

Each ingredient in our database tracks its `fdc_id` (FoodData Central ID) for provenance.

**API:** https://fdc.nal.usda.gov/fdc-app.html
**Bulk Download:** https://fdc.nal.usda.gov/download-datasets.html

### Open Food Facts

Secondary source, primarily for branded/packaged foods. Tracked via `open_food_facts_id`.

**API:** https://world.openfoodfacts.org/data

## Nutrient Values

All nutrient values are stored **per 100g** of the ingredient, matching USDA's standard representation.

The `data_source` column in `ingredient_nutrients` tracks where each value came from:
- `usda_foundation` — USDA Foundation Foods
- `usda_sr_legacy` — USDA SR Legacy
- `usda_branded` — USDA Branded Foods
- `manual` — Manually entered or calculated

## Import Strategy

For v0, seed data is manually curated from USDA SR Legacy values. Future plans:

1. **Bulk import script** that reads USDA CSV downloads and populates `ingredients` and `ingredient_nutrients`
2. **Matching pipeline** that links our ingredients to USDA FDC IDs
3. **Update mechanism** that refreshes nutrient data when USDA publishes new releases
4. **Open Food Facts integration** for barcode-scanned packaged ingredients

## Allergen Data

Allergen assignments are based on:
- EU Regulation 1169/2011 (EU14 mandatory allergen labeling)
- FDA Food Allergen Labeling and Consumer Protection Act (FALCPA)
- Manual review of ingredient composition

## Density Data

Volume↔mass conversion densities are sourced from:
- USDA Agricultural Handbook No. 456 (Nutrient Retention Factors)
- King Arthur Baking ingredient weight chart
- Published food science references

Densities can vary by preparation method (sifted vs packed flour), tracked via the `notes` column.
