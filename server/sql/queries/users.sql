-- name: CreateUser :one
INSERT INTO users(id, created_on, updated_at, username, user_token , balance)
VALUES (?, DATETIME('now', 'localtime'), DATETIME('now','localtime'), ?,?, 50000.0) RETURNING *;

-- name: GetUser :one
SELECT * FROM users WHERE id=? LIMIT 1;

-- name: GetUserWithUsername :many
SELECT * FROM users WHERE username= ?;

