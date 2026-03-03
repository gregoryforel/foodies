-- name: GetUserByID :one
SELECT * FROM app_users WHERE id = $1;

-- name: GetUserByExternalID :one
SELECT * FROM app_users WHERE external_id = $1;

-- name: CreateUser :one
INSERT INTO app_users (display_name, email, preferred_unit_system, preferred_locale)
VALUES ($1, $2, $3, $4)
RETURNING *;
