-- Migration 002: Measurement units and conversion
-- Everything is stored in metric. US display is computed.

CREATE TABLE units (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL UNIQUE,
    name_plural TEXT NOT NULL,
    system TEXT NOT NULL CHECK (system IN ('metric', 'us', 'universal')),
    dimension TEXT NOT NULL CHECK (dimension IN ('mass', 'volume', 'temperature', 'length', 'count')),
    to_base_factor NUMERIC,
    to_base_offset NUMERIC DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
