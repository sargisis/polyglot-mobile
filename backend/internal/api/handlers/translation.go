package handlers

import (
	"encoding/json"
	"net/http"
	"polyglot-backend/internal/database"
)

type TranslationRequest struct {
	SourceLang string `json:"source_lang"`
	TargetLang string `json:"target_lang"`
	Text       string `json:"text"`
}

type TranslationResponse struct {
	Original   string `json:"original"`
	Translated string `json:"translated"`
}

func TranslateHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	var req TranslationRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	// Custom database translation logic
	translated, err := database.GetTranslation(req.Text, req.SourceLang, req.TargetLang)
	if err != nil {
		// Fallback or Not Found logic
		http.Error(w, "Translation not found for: "+req.Text, http.StatusNotFound)
		return
	}

	resp := TranslationResponse{
		Original:   req.Text,
		Translated: translated,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}
