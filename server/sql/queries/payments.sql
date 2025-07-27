-- name: CreatePayment :one
INSERT INTO payments(id, created_on, updated_at, amount ,user_id, room_id, payment_status)
VALUES (?, DATETIME('now','localtime'), DATETIME('now','localtime'),0.0 , ?, ?, "PENDING" ) RETURNING *;

-- name: AssignPayment :exec
UPDATE payments SET user_id=?, payment_status= "ASSIGNED" WHERE id=?;

-- name: ProcessPayment :exec
UPDATE payments SET updated_at= DATETIME('now','localtime'), amount=?, payment_status="PROCESSED" WHERE id=?;
