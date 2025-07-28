package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strconv"

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
	UserId          string  `json:"userId"`
	RoomId          string  `json:"roomId"`
	Amount          float32 `json:"amount"`
	ItemDescription string  `json:"itemDescription"`
}

type roomEnterRequest struct {
	UserId string `json:"userId"`
	RoomId string `json:"roomId"`
}

type assignPayment struct {
	UserId string ``
}

func (cfg *config) handleEnterRoom(w http.ResponseWriter, r *http.Request) {
	newPayment, err := unmarshallRequestBody[roomEnterRequest](r, w)
	if err != nil {
		return
	}
	fmt.Println(newPayment)

	requester, err := cfg.db.GetUser(context.Background(), newPayment.UserId)
	if err != nil {
		returnAnError(w, 400, "unable to find the specified userId", err)
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

	userBalance := strconv.Itoa(int(requester.Balance.Int64))
	connectedUserMessage := map[string]string{
		"userId":   newPayment.UserId,
		"username": requester.Username,
		"balance":  userBalance,
	}

	err = cfg.sendFirebaseMessage(roomCreator.UserToken.String, connectedUserMessage) // should handle this error
	if err != nil {
		log.Printf("%v", err)
	}

}

func (cfg *config) handleCreatePayment(w http.ResponseWriter, r *http.Request) {
	newPayment, err := unmarshallRequestBody[newPaymentRequest](r, w)
	if err != nil {
		log.Printf("%v", err)
		return
	}

	createdPayment, err := cfg.db.CreatePayment(context.Background(), database.CreatePaymentParams{
		ID:              uuid.New(),
		UserID:          newPayment.UserId,
		RoomID:          newPayment.RoomId,
		Amount:          float64(newPayment.Amount),
		ItemDescription: sql.NullString{String: newPayment.ItemDescription, Valid: true},
	})
	if err != nil {
		log.Printf("%v", err)
		returnAnError(w, 400, "unable to create payment", err)
		return
	}

	assignedUser, err := cfg.db.GetUser(context.Background(), newPayment.UserId)
	if err != nil {
		returnAnError(w, 400, "unable to find the specified user", err)
		return
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

	assignedPaymentMessage := map[string]string{
		"itemDescription": createdPayment.ItemDescription.String,
		"amount":          strconv.FormatFloat(createdPayment.Amount, 'f', -1, 64),
		"roomId":          createdPayment.RoomID.(string),
		"id":              createdPayment.ID.(string),
	}
	err = cfg.sendFirebaseMessage(assignedUser.UserToken.String, assignedPaymentMessage) // should handle this error
	if err != nil {
		log.Printf("%v", err)
	}

	w.Header().Add("Content-Type", "application/json")
	w.Write(jsonResponse)
}

func (cfg *config) handleProcessPayment(w http.ResponseWriter, r *http.Request) {
	paymentId := r.PathValue("paymentId")
	err := cfg.db.ProcessPayment(context.Background(), paymentId)
	if err != nil {
		returnAnError(w, 400, "unable to process the payment", err)
	}
}

func (cfg *config) handleGetUserPaymentInRoom(w http.ResponseWriter, r *http.Request) {
	type userIdRomm struct {
		UserId string `json:"userId"`
		RoomId string `json:"roomId"`
	}
	type paymentInRoom struct {
		Id          string  `json:"id"`
		Description string  `json:"description"`
		Amount      float64 `json:"amount"`
	}
	result := []paymentInRoom{}
	body, err := unmarshallRequestBody[userIdRomm](r, w)
	if err != nil {
		log.Printf("%v", err)
		return
	}

	dbResponse, err := cfg.db.GetAllUserPaymentInRoom(context.Background(), database.GetAllUserPaymentInRoomParams{
		UserID: body.UserId,
		RoomID: body.RoomId,
	})
	if err != nil {
		returnAnError(w, 400, "error when resolving request", err)
		return
	}

	for i := 0; i < len(dbResponse); i++ {
		result = append(result, paymentInRoom{
			Id:          dbResponse[i].ID.(string),
			Description: dbResponse[i].ItemDescription.String,
			Amount:      dbResponse[i].Amount,
		})
	}
	response, err := json.Marshal(&result)
	if err != nil {
		returnAnError(w, 400, "error when resolving request", err)
		return
	}
	w.Header().Add("Content-Type", "application/json")
	w.Write(response)
}
