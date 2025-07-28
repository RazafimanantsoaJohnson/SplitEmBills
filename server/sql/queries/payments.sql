-- name: CreatePayment :one
INSERT INTO payments(id, created_on, updated_at,user_id, room_id,  amount , item_description, payment_status)
VALUES (?, DATETIME('now','localtime'), DATETIME('now','localtime'),?, ?, ?, ?,"PENDING" ) RETURNING *;

-- name: AssignPayment :exec
UPDATE payments SET user_id=?, payment_status= "ASSIGNED" WHERE id=?;

-- name: ProcessPayment :exec
UPDATE payments SET updated_at= DATETIME('now','localtime'), payment_status="PROCESSED" WHERE id=?;

-- name: GetAllUserPaymentInRoom :many
SELECT * FROM payments WHERE user_id=? AND room_id =? ;
