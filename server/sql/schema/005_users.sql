-- +goose Up
ALTER TABLE users ADD COLUMN user_token TEXT;

-- +goose Down
ALTER TABLE users DROP COLUMN user_token;

