-- name: CreatePaymentRoom :one
INSERT INTO payment_rooms(id, created_on, updated_at, created_by, raw_json_data)
VALUES(?, DATETIME('now','localtime'), DATETIME('now','localtime'), ?, ?) RETURNING *;

-- name: GetAllPaymentRooms :many
SELECT * FROM payment_rooms;


