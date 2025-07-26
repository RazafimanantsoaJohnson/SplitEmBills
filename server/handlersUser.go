package main

import (
	"context"
	"net/http"

	"github.com/RazafimanantsoaJohnson/SplitEmBills/internal/database"
	"github.com/google/uuid"
)

func (cfg *config) handleCreateUser(w http.ResponseWriter, r *http.Request) {
	cfg.db.CreateUser(context.Background(), database.CreateUserParams{
		uuid.New(),
		"Second user",
	})
	w.WriteHeader(200)
}
