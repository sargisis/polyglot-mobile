package database

import (
	"database/sql"
	"fmt"
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

func GetTranslation(text string, sourceLang string, targetLang string) ([]string, error) {
	// Normalized lookup
	text = strings.TrimSpace(text)

	query := `
	SELECT t.text 
	FROM words w
	JOIN translations tr ON w.id = tr.source_id
	JOIN words t ON tr.target_id = t.id
	WHERE LOWER(w.text) = LOWER(?) AND w.lang = ? AND t.lang = ?
	`

	rows, err := DB.Query(query, text, sourceLang, targetLang)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []string
	for rows.Next() {
		var translatedText string
		if err := rows.Scan(&translatedText); err != nil {
			return nil, err
		}
		results = append(results, translatedText)
	}

	if len(results) == 0 {
		return nil, sql.ErrNoRows
	}

	return results, nil
}

func SearchWords(queryStr string) ([]string, error) {
	queryStr = strings.TrimSpace(queryStr)
	if queryStr == "" {
		return []string{}, nil
	}

	// Simple prefix search
	sqlQuery := `
	SELECT text FROM words 
	WHERE text LIKE ? || '%' 
	GROUP BY text
	ORDER BY text ASC
	LIMIT 20
	`

	rows, err := DB.Query(sqlQuery, queryStr)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var results []string
	for rows.Next() {
		var text string
		if err := rows.Scan(&text); err != nil {
			return nil, err
		}
		results = append(results, text)
	}
	return results, nil
}

func AddTranslation(sourceText, sourceLang, targetText, targetLang string) error {
	// Normalize
	sourceText = strings.TrimSpace(sourceText)
	targetText = strings.TrimSpace(targetText)

	if sourceText == "" || targetText == "" {
		return fmt.Errorf("text cannot be empty")
	}

	tx, err := DB.Begin()
	if err != nil {
		return err
	}
	defer tx.Rollback()

	// Helper to get or insert word
	getOrInsert := func(text, lang string) (int64, error) {
		var id int64
		err := tx.QueryRow("SELECT id FROM words WHERE LOWER(text) = LOWER(?) AND lang = ?", text, lang).Scan(&id)
		if err == sql.ErrNoRows {
			res, err := tx.Exec("INSERT INTO words (text, lang) VALUES (?, ?)", text, lang)
			if err != nil {
				return 0, err
			}
			return res.LastInsertId()
		}
		return id, err
	}

	sourceID, err := getOrInsert(sourceText, sourceLang)
	if err != nil {
		return err
	}

	targetID, err := getOrInsert(targetText, targetLang)
	if err != nil {
		return err
	}

	// Link
	var exists int
	tx.QueryRow("SELECT COUNT(*) FROM translations WHERE source_id = ? AND target_id = ?", sourceID, targetID).Scan(&exists)
	if exists == 0 {
		_, err = tx.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", sourceID, targetID)
		if err != nil {
			return err
		}
		_, err = tx.Exec("INSERT INTO translations (source_id, target_id) VALUES (?, ?)", targetID, sourceID)
		if err != nil {
			return err
		}
	}

	return tx.Commit()
}
