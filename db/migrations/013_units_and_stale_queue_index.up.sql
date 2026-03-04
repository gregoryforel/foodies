-- Migration 013: additional conversion integrity + stale queue performance

ALTER TABLE units
    ADD CONSTRAINT chk_units_conversion_shape
    CHECK (
        (
            dimension IN ('mass', 'volume', 'length', 'count')
            AND to_base_factor IS NOT NULL
            AND to_base_factor > 0
            AND COALESCE(to_base_offset, 0) = 0
        )
        OR
        (
            dimension = 'temperature'
            AND to_base_factor IS NOT NULL
            AND to_base_factor > 0
        )
    );

CREATE INDEX IF NOT EXISTS idx_compiled_recipes_stale_queue
    ON compiled_recipes (compiled_at)
    WHERE is_stale = true;
