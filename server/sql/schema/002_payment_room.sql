-- +goose Up
CREATE TABLE payment_rooms(id UUID PRIMARY KEY, created_on TIMESTAMP NOT NULL, updated_at TIMESTAMP NOT NULL, 
created_by UUID REFERENCES users(id), raw_json_data TEXT);

-- +goose Down
DROP TABLE payment_rooms;
