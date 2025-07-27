-- +goose Up
CREATE TABLE payments(id UUID PRIMARY KEY, created_on TIMESTAMP NOT NULL, updated_at TIMESTAMP NOT NULL, user_id UUID NOT NULL REFERENCES users(id),
room_id UUID REFERENCES payment_rooms(id) NOT NULL, item_description TEXT, amount FLOAT NOT NULL);

-- +goose Down
DROP TABLE payments;
