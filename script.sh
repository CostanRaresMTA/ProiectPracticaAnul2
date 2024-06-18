#!/bin/bash

#Calea absoluta a directorului monitorizat
DIR_PATH="$1"

#Numele fisierului de log
LOG_FILE="$(basename "$DIR_PATH")_inotifyFile"

#Cream fisierul de log in cazul in care nu exista deja
if [ ! -f "$LOG_FILE" ]; then
  touch "$LOG_FILE"
fi

#Functie scriere in fisierul de log
log_event() {
  local event_message="$1"
  echo "$event_message" >> "$LOG_FILE"
}

#Monitorizarea propriu zisa a fiecarui tip de instructiune din inotify
inotifywait -m -r -e access,modify,attrib,close_write,close_nowrite,open,moved_from,moved_to,create,delete,delete_self,move_self,unmount,q_overflow,ignored --format '%w%f %e' "$DIR_PATH" | while read file event; do
  case "$event" in
  FILE_NAME=$(basename "$file")
    ACCESS)
      log_event "Fisierul $FILE_NAME a fost accesat"
      ;;
    MODIFY)
      log_event "Fisierul $FILE_NAME a fost modificat"
      ;;
    ATTRIB)
      log_event "Atributele fisierului $FILE_NAME au fost schimbate"
      ;;
    CLOSE_WRITE)
      log_event "Fisierul $FILE_NAME a fost inchis dupa scriere"
      ;;
    CLOSE_NOWRITE)
      log_event "Fisierul $FILE_NAME a fost inchis fara scriere"
      ;;
    OPEN)
      log_event "Fisierul $FILE_NAME a fost deschis"
      ;;
    MOVED_FROM)
      log_event "Fisierul $FILE_NAME a fost mutat din director"
      ;;
    MOVED_TO)
      log_event "Fisierul $FILE_NAME a fost mutat in director"
      ;;
    CREATE)
      log_event "Fisierul sau directorul $FILE_NAME a fost creat"
      ;;
    DELETE)
      log_event "Fisierul sau directorul $FILE_NAME a fost sters"
      ;;
    DELETE_SELF)
      log_event "Directorul $FILE_NAME a fost sters"
      ;;
    MOVE_SELF)
      log_event "Directorul $FILE_NAME a fost mutat"
      ;;
    UNMOUNT)
      log_event "Sistemul de fisiere care contine fisierul $FILE_NAME a fost demontat"
      ;;
    Q_OVERFLOW)
      log_event "Coada de evenimente a fost depasita"
      ;;
    IGNORED)
      log_event "Evenimentul pentru $FILE_NAME a fost ignorat"
      ;;
  esac
done
