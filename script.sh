#!/bin/bash

#Verificare daca SQLite3 este instalat, si instalarea lui in caz ca nu
if ! command -v sqlite3 &> /dev/null
then
    echo "SQLite3 nu este instalat. Instalare..."
    sudo apt update && sudo apt install sqlite3 -y
fi


#Calea absoluta a directorului monitorizat
DIR_PATH="$1"

#Numele fisierului de log si numele fisierului bazei de date
LOG_FILE="$(basename "$DIR_PATH")_inotifyFile"

DB_FILE="inotify_events.db"

#Cream fisierul de log in cazul in care nu exista deja
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
fi

#Creearea bazei de date daca nu exista
if [ ! -f "$DB_FILE" ]; then
  sqlite3 "$DB_FILE" <<EOF
CREATE TABLE Events (
    ID INTEGER PRIMARY KEY AUTOINCREMENT,
    FileName TEXT NOT NULL,
    Event TEXT NOT NULL,
    EventTime DATETIME DEFAULT CURRENT_TIMESTAMP
);
EOF
fi

#Functie de logare in fisier
log_event() {
  local file="$1"
  local event="$2"
  # local event_message="$3"
  # sqlite3 "$DB_FILE" "INSERT INTO Events (FileName, Event) VALUES ('$file', '$event');"
}

#Functie inserare in baza de date
insert_event_db(){
  local file_name="$1"
  local event="$2"
  sqlite3 inotify_events.db <<EOF
INSERT INTO Events (FileName, Event) VALUES ('$file_name', '$event');
EOF
}


#Monitorizarea propriu zisa a fiecarui tip de instructiune din inotify
inotifywait -m -r -e access,modify,attrib,close_write,close_nowrite,open,moved_from,moved_to,create,delete,delete_self,move_self,unmount,q_overflow,ignored --format '%w%f %e' "$DIR_PATH" | while read file event; do
  FILE_NAME=$(basename "$file")
  case "$event" in
    ACCESS)
      log_event "Fisierul $FILE_NAME a fost accesat"
      insert_event_db "$FILE_NAME" "Fisierul a fost accesat"
      ;;
    MODIFY)
      log_event "Fisierul $FILE_NAME a fost modificat"
      insert_event_db "$FILE_NAME" "Fisierul a fost modificat"
      ;;
    ATTRIB)
      log_event "Atributele fisierului $FILE_NAME au fost schimbate"
      insert_event_db "$FILE_NAME" "Atributele fisierului au fost schimbate"
      ;;
    CLOSE_WRITE)
      log_event "Fisierul $FILE_NAME a fost inchis dupa scriere"
      insert_event_db "$FILE_NAME" "Fisierul a fost inchis dupa scriere"
      ;;
    CLOSE_NOWRITE)
      log_event "Fisierul $FILE_NAME a fost inchis fara scriere"
      insert_event_db "$FILE_NAME" "Fisierul a fost inchis fara scriere"
      ;;
    OPEN)
      log_event "Fisierul $FILE_NAME a fost deschis"
      insert_event_db "$FILE_NAME" "Fisierul a fost deschis"
      ;;
    MOVED_FROM)
      log_event "Fisierul $FILE_NAME a fost mutat din director"
      insert_event_db "$FILE_NAME" "Fisierul a fost mutat din director"
      ;;
    MOVED_TO)
      log_event "Fisierul $FILE_NAME a fost mutat in director"
      insert_event_db "$FILE_NAME" "Fisierul a fost mutat in director"
      ;;
    CREATE)
      log_event "Fisierul sau directorul $FILE_NAME a fost creat"
      insert_event_db "$FILE_NAME" "Fisierul sau directorul a fost creat"
      ;;
    DELETE)
      log_event "Fisierul sau directorul $FILE_NAME a fost sters"
      insert_event_db "$FILE_NAME" "Fisierul sau directorul a fost sters"
      ;;
    DELETE_SELF)
      log_event "Directorul $FILE_NAME a fost sters"
      insert_event_db "$FILE_NAME" "Directorul a fost sters"
      ;;
    MOVE_SELF)
      log_event "Directorul $FILE_NAME a fost mutat"
      insert_event_db "$FILE_NAME" "Directorul a fost mutat"
      ;;
    UNMOUNT)
      log_event "Sistemul de fisiere care contine fisierul $FILE_NAME a fost demontat"
      insert_event_db "$FILE_NAME" "Sistemul de fisiere a fost demontat"
      ;;
    Q_OVERFLOW)
      log_event "Coada de evenimente a fost depasita"
      insert_event_db "$FILE_NAME" "Coada de evenimente a fost depasita"
      ;;
    IGNORED)
      log_event "Evenimentul pentru $FILE_NAME a fost ignorat"
      insert_event_db "$FILE_NAME" "Evenimentul a fost ignorat"
      ;;
  esac
done
