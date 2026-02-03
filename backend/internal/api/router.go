package api

import (
	"net/http"
	"polyglot-backend/internal/api/handlers"
)

func NewRouter() *http.ServeMux {
	mux := http.NewServeMux()

	// Translation endpoints
	mux.HandleFunc("/api/translate", handlers.TranslateHandler)

	// Dictionary endpoints
	mux.HandleFunc("/api/dictionary", handlers.DictionaryHandler)

	// Health check
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("OK"))
	})

	return mux
}
