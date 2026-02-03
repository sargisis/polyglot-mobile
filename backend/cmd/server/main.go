package main

import (
	"log"
	"net/http"
	"polyglot-backend/internal/api"
	"polyglot-backend/internal/database"
)

func main() {
	database.InitDB()
	router := api.NewRouter()

	log.Println("Server starting on :8080")
	if err := http.ListenAndServe(":8080", router); err != nil {
		log.Fatal(err)
	}
}
