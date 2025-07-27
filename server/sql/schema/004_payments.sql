-- +goose Up
ALTER TABLE payments ADD payment_status TEXT;

-- +goose Down
ALTER TABLE payments DROP COLUMN payment_status;
