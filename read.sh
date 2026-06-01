#!/bin/bash
# ============================================================
# Script 1: Start Reading (read.sh) — versione Ubuntu
# Legge ad alta voce il testo selezionato/evidenziato usando
# pico2wave (offline) con voce italiana.
#
# Dipendenze:
#   - xclip            (sudo apt install xclip)
#   - libttspico-utils (sudo apt install libttspico-utils)
#   - alsa-utils       (sudo apt install alsa-utils)
#
# Come associare a una scorciatoia da tastiera (GNOME):
#   Impostazioni → Tastiera → Scorciatoie personalizzate
#   → + → Comando: /percorso/completo/read.sh
#   Suggerimento scorciatoia: Ctrl+Alt+R
# ============================================================

LANG_CODE="it-IT"
PID_FILE="/tmp/pico_tts_pid"
TMPFILE="/tmp/pico_tts.wav"

# --- Controllo dipendenze ---
for cmd in xclip pico2wave aplay; do
    if ! command -v "$cmd" &>/dev/null; then
        MSG="Errore: '$cmd' non trovato. Installa con: sudo apt install xclip libttspico-utils alsa-utils"
        notify-send "TTS Error" "$MSG" 2>/dev/null
        echo "$MSG" >&2
        exit 1
    fi
done

# --- Acquisizione testo dalla selezione primaria ---
TEXT=$(xclip -o -selection primary 2>/dev/null)
if [ -z "$TEXT" ]; then
    notify-send "TTS" "Nessun testo evidenziato col mouse." 2>/dev/null
    echo "Nessun testo evidenziato col mouse." >&2
    exit 1
fi

# --- Sanificazione del testo ---
# Rimuove caratteri di controllo e normalizza newline/tab in spazi.
TEXT=$(echo "$TEXT" | tr -d '\000-\010\013\014\016-\037' | tr '\n\r\t' '   ')

# --- Terminazione di eventuali letture in corso ---
# Evita sovrapposizioni: ferma il processo precedente prima di avviarne uno nuovo.
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        kill "$OLD_PID" 2>/dev/null
        sleep 0.2
    fi
    rm -f "$PID_FILE"
fi

# --- Generazione audio con pico2wave ---
pico2wave -l="$LANG_CODE" -w="$TMPFILE" "$TEXT"
if [ $? -ne 0 ] || [ ! -f "$TMPFILE" ]; then
    notify-send "TTS Error" "pico2wave non ha generato l'audio." 2>/dev/null
    echo "Errore: pico2wave non ha generato l'audio." >&2
    exit 1
fi

# --- Riproduzione audio in background (non bloccante) ---
aplay "$TMPFILE" &
PID=$!

# Salva il PID per poter fermare la lettura con stop.sh
echo "$PID" > "$PID_FILE"
echo "▶ Lettura avviata (PID: $PID, lingua: $LANG_CODE)"
