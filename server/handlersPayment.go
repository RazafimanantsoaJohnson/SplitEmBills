package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/RazafimanantsoaJohnson/SplitEmBills/internal/database"
	"github.com/google/uuid"
)

type newPaymentResponse struct {
	Id            string `json:"id"`
	CreatedOn     string `json:"createdOn"`
	RoomId        string `json:"roomId"`
	PaymentStatus string `json:"paymentStatus"`
	UserId        string `json:"userId"`
}

type newPaymentRequest struct {
	UserId string `json:"userId"`
	RoomId string `json:"roomId"`
}

func (cfg *config) handleCreatePayment(w http.ResponseWriter, r *http.Request) {
	connectedUserMessage := map[string]string{}
	newPayment, err := unmarshallRequestBody[newPaymentRequest](r, w)
	if err != nil {
		return
	}
	createdPayment, err := cfg.db.CreatePayment(context.Background(), database.CreatePaymentParams{
		ID:     uuid.New(),
		UserID: newPayment.UserId,
		RoomID: newPayment.RoomId,
	})
	if err != nil {
		log.Printf("%v", err)
		returnAnError(w, 400, "unable to create payment", err)
		return
	}

	// get room creator
	roomId, err := uuid.Parse(newPayment.RoomId)
	if err != nil {
		returnAnError(w, 400, "Invalid room id provided", err)
		return
	}
	roomCreator, err := cfg.db.GetRoomCreator(context.Background(), roomId)
	if err != nil {
		returnAnError(w, 500, "unable to parse the response", err)
		return
	}
	connectedUserMessage["userId"] = newPayment.UserId
	fmt.Println(roomCreator)
	err = cfg.sendFirebaseMessage(roomCreator.UserToken.String, connectedUserMessage) // should handle this error
	if err != nil {
		log.Printf("%v", err)
	}
	response := newPaymentResponse{
		Id:            createdPayment.ID.(string),
		CreatedOn:     createdPayment.CreatedOn.String(),
		PaymentStatus: createdPayment.PaymentStatus.String,
		UserId:        createdPayment.UserID.(string),
		RoomId:        createdPayment.RoomID.(string),
	}
	jsonResponse, err := json.Marshal(&response)
	if err != nil {
		returnAnError(w, 500, "unable to parse the response", err)
		return
	}
	w.Header().Add("Content-Type", "application/json")
	w.Write(jsonResponse)
}
