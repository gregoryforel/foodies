-- Migration 007: DAG cycle prevention trigger
-- Prevents circular sub-recipe references.

CREATE OR REPLACE FUNCTION check_recipe_cycle() RETURNS TRIGGER AS $$
DECLARE
    parent_recipe_id UUID;
    has_cycle BOOLEAN;
BEGIN
    IF NEW.sub_recipe_id IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT rs.recipe_id INTO parent_recipe_id
    FROM recipe_steps rs WHERE rs.id = NEW.step_id;

    -- Walk the sub-recipe DAG downward from NEW.sub_recipe_id
    -- If we find parent_recipe_id, we have a cycle
    WITH RECURSIVE descendants AS (
        SELECT NEW.sub_recipe_id AS recipe_id
        UNION
        SELECT rsc.sub_recipe_id
        FROM recipe_step_components rsc
        JOIN recipe_steps rs ON rs.id = rsc.step_id
        JOIN descendants d ON rs.recipe_id = d.recipe_id
        WHERE rsc.sub_recipe_id IS NOT NULL
    )
    SELECT EXISTS(
        SELECT 1 FROM descendants WHERE recipe_id = parent_recipe_id
    ) INTO has_cycle;

    IF has_cycle THEN
        RAISE EXCEPTION 'Circular sub-recipe reference detected: recipe % cannot reference % because it would create a cycle',
            parent_recipe_id, NEW.sub_recipe_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_recipe_cycle
    BEFORE INSERT OR UPDATE ON recipe_step_components
    FOR EACH ROW
    EXECUTE FUNCTION check_recipe_cycle();
