-- name: GetUnitByID :one
SELECT * FROM units WHERE id = $1;

-- name: GetUnitByName :one
SELECT * FROM units WHERE name = $1;

-- name: ListUnits :many
SELECT * FROM units ORDER BY system, dimension, name;

-- name: ListUnitsBySystem :many
SELECT * FROM units WHERE system = $1 ORDER BY dimension, name;

-- name: ListUnitsByDimension :many
SELECT * FROM units WHERE dimension = $1 ORDER BY system, name;
