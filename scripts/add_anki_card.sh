#!/bin/bash

DECK=$(echo "" | rofi -dmenu -p "Deck (Remember)")
[ $? -ne 0 ] && exit 1 
DECK=${DECK:-Remember}   # Use "Default" if empty


FRONT=$(echo "" | rofi -dmenu -p "Front" -l 0)
[ -z "$FRONT" ] && exit 1

BACK=$(echo "" | rofi -dmenu -p "Back" -l 0)
[ -z "$BACK" ] && exit 1

RESULT=$(curl -s localhost:8765 -X POST -d "{
  \"action\": \"addNote\",
  \"version\": 6,
  \"params\": {
    \"note\": {
      \"deckName\": \"$DECK\",
      \"modelName\": \"Basic+\",
      \"fields\": {\"Front\": \"$FRONT\", \"Back\": \"$BACK\"},
      \"options\": {\"allowDuplicate\": false}
    }
  }
}")

if echo "$RESULT" | grep -q '"error": null'; then
    notify-send "Anki" "Card added to $DECK"
else
    notify-send "Anki" "Failed to add card"
fi
