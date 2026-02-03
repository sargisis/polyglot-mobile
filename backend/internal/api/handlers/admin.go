package handlers

import (
	"encoding/json"
	"net/http"
	"polyglot-backend/internal/database"
)

type AddWordRequest struct {
	Source     string `json:"source"`
	SourceLang string `json:"source_lang"`
	Target     string `json:"target"`
	TargetLang string `json:"target_lang"`
}

func AddWordHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req AddWordRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if err := database.AddTranslation(req.Source, req.SourceLang, req.Target, req.TargetLang); err != nil {
		http.Error(w, "Failed to add translation: "+err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusCreated)
	json.NewEncoder(w).Encode(map[string]string{"status": "success"})
}
