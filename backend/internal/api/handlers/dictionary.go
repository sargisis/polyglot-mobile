package handlers

import (
	"encoding/json"
	"net/http"
)

func DictionaryHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodGet {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	word := r.URL.Query().Get("word")
	if word == "" {
		http.Error(w, "Missing 'word' parameter", http.StatusBadRequest)
		return
	}

	// TODO: Integrate actual dictionary logic here
	response := map[string]string{
		"word":       word,
		"definition": "This is a mock definition for " + word,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
