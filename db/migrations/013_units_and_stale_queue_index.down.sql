-- Migration 013 down: revert conversion integrity and stale queue index

DROP INDEX IF EXISTS idx_compiled_recipes_stale_queue;

ALTER TABLE units
    DROP CONSTRAINT IF EXISTS chk_units_conversion_shape;
