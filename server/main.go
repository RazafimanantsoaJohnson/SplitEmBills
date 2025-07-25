package main

import (
	"fmt"
	"net/http"
)

type config struct {
}

func main() {
	mux := http.NewServeMux()

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
