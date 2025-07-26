package main

import (
	"log"
	"net/http"
)

func returnAnError(w http.ResponseWriter, errorCode int, message string, err error) {
	w.WriteHeader(errorCode)
	w.Header().Add("Content-Type", "text/plain")
	w.Write([]byte(message))
	log.Printf("%v", err)
}
