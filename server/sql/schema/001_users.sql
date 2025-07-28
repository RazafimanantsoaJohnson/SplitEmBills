-- +goose Up
CREATE TABLE users(id UUID PRIMARY KEY, created_on TIMESTAMP NOT NULL, updated_at TIMESTAMP NOT NULL , username TEXT NOT NULL UNIQUE, balance INTEGER);

-- +goose Down
DROP TABLE users;
