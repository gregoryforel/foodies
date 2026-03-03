-- Migration 001: Core user structure
-- All IDs are UUID (use gen_random_uuid()).
-- All tables have created_at and updated_at timestamps.

CREATE TABLE app_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    external_id TEXT UNIQUE,
    display_name TEXT NOT NULL,
    email TEXT UNIQUE,
    preferred_unit_system TEXT NOT NULL DEFAULT 'metric'
        CHECK (preferred_unit_system IN ('metric', 'us')),
    preferred_locale TEXT NOT NULL DEFAULT 'en',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
