package main

import (
	"database/sql"
	"encoding/csv"
	"fmt"
	"log"
	"os"

	_ "modernc.org/sqlite"
)

func main() {
	db, err := sql.Open("sqlite", "polyglot.db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// Ensure tables exist
	query := `
	CREATE TABLE IF NOT EXISTS words (
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		text TEXT NOT NULL,
		lang TEXT NOT NULL,
		UNIQUE(text, lang)
	);

	CREATE TABLE IF NOT EXISTS translations (
		source_id INTEGER,
		target_id INTEGER,
		PRIMARY KEY (source_id, target_id),
		FOREIGN KEY(source_id) REFERENCES words(id),
		FOREIGN KEY(target_id) REFERENCES words(id)
	);
	`
	_, err = db.Exec(query)
	if err != nil {
		log.Fatal("Failed to create tables:", err)
	}

	file, err := os.Open("data/dataset.csv")
	if err != nil {
		log.Fatal("Unable to read input file", err)
	}
	defer file.Close()

	csvReader := csv.NewReader(file)
	records, err := csvReader.ReadAll()
	if err != nil {
		log.Fatal("Unable to parse file as CSV", err)
	}

	for _, record := range records {
		englishWord := record[0]
		armenianWord := record[1]

		fmt.Printf("Importing: %s -> %s\n", englishWord, armenianWord)

		// Insert English Word
		var enID int64
		err = db.QueryRow("SELECT id FROM words WHERE text = ? AND lang = 'en'", englishWord).Scan(&enID)
		if err == sql.ErrNoRows {
			res, err := db.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", englishWord, "en")
			if err != nil {
				log.Printf("Error inserting word '%s' (en): %v", englishWord, err)
			}
			enID, _ = res.LastInsertId()
		}

		// Insert Armenian Word
		var hyID int64
		err = db.QueryRow("SELECT id FROM words WHERE text = ? AND lang = 'hy'", armenianWord).Scan(&hyID)
		if err == sql.ErrNoRows {
			res, err := db.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", armenianWord, "hy")
			if err != nil {
				log.Printf("Error inserting word '%s' (hy): %v", armenianWord, err)
			}
			hyID, _ = res.LastInsertId()
		}

		// Link them
		var exists int
		db.QueryRow("SELECT COUNT(*) FROM translations WHERE source_id = ? AND target_id = ?", enID, hyID).Scan(&exists)
		if exists == 0 {
			_, err = db.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", enID, hyID)
			if err != nil {
				log.Printf("Error linking words %d -> %d: %v", enID, hyID, err)
			}
			_, err = db.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", hyID, enID)
			if err != nil {
				log.Printf("Error linking words %d -> %d: %v", hyID, enID, err)
			}
		}
	}

	fmt.Println("Import completed successfully!")
}
