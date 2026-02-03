package database

import (
	"database/sql"
	"log"
	"strings"

	_ "modernc.org/sqlite"
)

var DB *sql.DB

func InitDB() {
	var err error
	DB, err = sql.Open("sqlite", "polyglot.db")
	if err != nil {
		log.Fatal(err)
	}

	createTables()
	seedData()
}

func createTables() {
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
	_, err := DB.Exec(query)
	if err != nil {
		log.Fatal("Failed to create tables:", err)
	}
}

func seedData() {
	// Simple seed: Hello (en) <-> Բարեւ (hy)
	// Check if exists first
	var count int
	DB.QueryRow("SELECT COUNT(*) FROM words").Scan(&count)
	if count > 0 {
		return
	}

	log.Println("Seeding database...")

	// Insert Hello
	res1, _ := DB.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", "Hello", "en")
	id1, _ := res1.LastInsertId()

	// Insert Բարեւ
	res2, _ := DB.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", "Բարեւ", "hy")
	id2, _ := res2.LastInsertId()

	// Link them
	DB.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", id1, id2)
	DB.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", id2, id1)

	// Insert World
	res3, _ := DB.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", "World", "en")
	id3, _ := res3.LastInsertId()
	res4, _ := DB.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", "Աշխարհ", "hy")
	id4, _ := res4.LastInsertId()
	DB.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", id3, id4)
	DB.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", id4, id3)

	// Insert Thank you
	res5, _ := DB.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", "Thank you", "en")
	id5, _ := res5.LastInsertId()
	res6, _ := DB.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", "Շնորհակալություն", "hy")
	id6, _ := res6.LastInsertId()
	DB.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", id5, id6)
	DB.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", id6, id5)
}

func GetTranslation(text string, sourceLang string, targetLang string) (string, error) {
	// Normalized lookup
	text = strings.TrimSpace(text)

	query := `
	SELECT t.text 
	FROM words w
	JOIN translations tr ON w.id = tr.source_id
	JOIN words t ON tr.target_id = t.id
	WHERE w.text = ? AND w.lang = ? AND t.lang = ?
	COLLATE NOCASE
	`

	var translatedText string
	err := DB.QueryRow(query, text, sourceLang, targetLang).Scan(&translatedText)
	if err != nil {
		return "", err
	}
	return translatedText, nil
}
