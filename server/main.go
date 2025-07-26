package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/RazafimanantsoaJohnson/SplitEmBills/internal/database"
	"github.com/joho/godotenv"
	_ "github.com/mattn/go-sqlite3"
)

type config struct {
	db *database.Queries
}

func main() {
	godotenv.Load(".env")
	dbPath := os.Getenv("DB")

	cfg := config{
		db: createDbClient(dbPath),
	}

	mux := http.NewServeMux()

	mux.HandleFunc("GET /users", cfg.handleCreateUser)
	mux.HandleFunc("POST /rooms", cfg.handlerCreatePaymentRoom)
	mux.HandleFunc("GET /hello", func(w http.ResponseWriter, r *http.Request) {
		fmt.Println("hello johnson")
	})
	server := http.Server{
		Addr:    ":8000",
		Handler: mux,
	}
	fmt.Println("Listening to port 8000")
	server.ListenAndServe()
}

func createDbClient(dbPath string) *database.Queries {
	db, err := sql.Open("sqlite3", dbPath)
	if err != nil {
		log.Fatal(err)
	}
	return database.New(db)
}
