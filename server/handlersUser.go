package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"log"
	"net/http"

	"github.com/RazafimanantsoaJohnson/SplitEmBills/internal/database"
	"github.com/google/uuid"
)

type signin struct {
	Username  string `json:"username"`
	UserToken string `json:"userToken"`
}

type userResponse struct {
	Id       string `json:"id"`
	Username string `json:"username"`
}

// func (cfg *config) handleCreateUser(w http.ResponseWriter, r *http.Request) {
// 	cfg.db.CreateUser(context.Background(), database.CreateUserParams{
// 		uuid.New(),
// 		"Second user",
// 	})
// 	w.WriteHeader(200)
// }

func (cfg *config) handleSignin(w http.ResponseWriter, r *http.Request) {
	signinUser, err := unmarshallRequestBody[signin](r, w)
	if err != nil {
		log.Printf("%v", err)
		return
	}
	userInDb, err := cfg.db.GetUserWithUsername(context.Background(), signinUser.Username)
	if err != nil {
		returnAnError(w, 500, "unable to handle user signin", err)
		return
	}
	response := userResponse{}
	if len(userInDb) == 0 {
		createdUser, err := cfg.db.CreateUser(context.Background(), database.CreateUserParams{
			ID:        uuid.New(),
			Username:  signinUser.Username,
			UserToken: sql.NullString{String: signinUser.UserToken, Valid: true},
		})
		if err != nil {
			returnAnError(w, 500, "unable to handle user signin", err)
			return
		}
		response = userResponse{
			Username: createdUser.Username,
			Id:       createdUser.ID.(string),
		}
	} else {
		response = userResponse{
			Username: userInDb[0].Username,
			Id:       userInDb[0].ID.(string),
		}
	}

	jsonResponse, err := json.Marshal(response)

	w.Header().Add("Content-Type", "application/json")
	w.Write(jsonResponse)
}
