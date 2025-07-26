-- name: CreateUser :one
INSERT INTO users(id, created_on, updated_at, username, balance)
VALUES (?, DATETIME('now', 'localtime'), DATETIME('now','localtime'), ?, 50000.0) RETURNING *;

