package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	firebase "firebase.google.com/go/v4"
	"firebase.google.com/go/v4/messaging"
	"github.com/RazafimanantsoaJohnson/SplitEmBills/internal/database"
	"github.com/joho/godotenv"
	_ "github.com/mattn/go-sqlite3"
)

type config struct {
	db          *database.Queries
	firebase    *firebase.App
	fbMessaging *messaging.Client
}

func main() {
	godotenv.Load(".env")
	dbPath := os.Getenv("DB")
	port := os.Getenv("PORT")
	fb, err := initializeFirebaseApp()
	if err != nil {
		log.Fatalf("unable to connect to firebase %v", err)
	}
	messaging, err := fb.Messaging(context.Background())
	if err != nil {
		log.Fatal("unable to get fcm client")
	}

	cfg := config{
		db:          createDbClient(dbPath),
		firebase:    fb,
		fbMessaging: messaging,
	}

	mux := http.NewServeMux()

	mux.HandleFunc("POST /users", cfg.handleSignin)
	mux.HandleFunc("POST /rooms", cfg.handlerCreatePaymentRoom)
	mux.HandleFunc("POST /rooms/enter", cfg.handleEnterRoom)
	mux.HandleFunc("POST /payments", cfg.handleCreatePayment)
	mux.HandleFunc("POST /payments/process/{paymentId}", cfg.handleProcessPayment)

	server := http.Server{
		Addr:    ":" + port,
		Handler: mux,
	}
	fmt.Println("Listening to port ", port)
	server.ListenAndServe()
}

func createDbClient(dbPath string) *database.Queries {
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		log.Fatal(err)
	}
	return database.New(db)
}
