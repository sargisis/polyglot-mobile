package main

import (
	"database/sql"
	"fmt"
	"log"

	_ "modernc.org/sqlite"
)

func main() {
	db, err := sql.Open("sqlite", "polyglot.db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// 1. Check if words exist
	rows, _ := db.Query("SELECT id, text, lang FROM words WHERE text = 'Right'")
	fmt.Println("Words 'Right':")
	for rows.Next() {
		var id int
		var text, lang string
		rows.Scan(&id, &text, &lang)
		fmt.Printf("- ID: %d, Text: %s, Lang: %s\n", id, text, lang)
	}
	rows.Close()

	// 2. Check translations logic manually
	query := `
	SELECT t.text 
	FROM words w
	JOIN translations tr ON w.id = tr.source_id
	JOIN words t ON tr.target_id = t.id
	WHERE w.text = ? AND w.lang = ? AND t.lang = ?
	COLLATE NOCASE
	`
	rows, err = db.Query(query, "Right", "en", "hy")
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	fmt.Println("Translations for Right (en->hy):")
	count := 0
	for rows.Next() {
		var trans string
		rows.Scan(&trans)
		fmt.Printf("- %s\n", trans)
		count++
	}
	if count == 0 {
		fmt.Println("No translations found via query.")
	}
}
