package handlers

import (
	"encoding/json"
	"net/http"
	"polyglot-backend/internal/database"
)

func SearchHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	query := r.URL.Query().Get("q")
	// If query is empty, maybe return empty list or top words

	results, err := database.SearchWords(query)
	if err != nil {
		http.Error(w, "Search failed: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Ensure not nil for JSON
	if results == nil {
		results = []string{}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(results)
}
