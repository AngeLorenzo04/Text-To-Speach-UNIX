#!/bin/bash
# ============================================================
# Script 2: Stop Reading (stop.sh) — versione Ubuntu
# Interrompe immediatamente la lettura avviata da read.sh
# terminando il processo aplay in corso.
#
# Come associare a una scorciatoia da tastiera (GNOME):
#   Impostazioni → Tastiera → Scorciatoie personalizzate
#   → + → Comando: /percorso/completo/stop.sh
#   Suggerimento scorciatoia: Ctrl+Alt+S
# ============================================================

PID_FILE="/tmp/pico_tts_pid"

# --- Termina il processo aplay tracciato dal PID file ---
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        kill "$PID" 2>/dev/null
        sleep 0.2
        # SIGKILL se non risponde a SIGTERM
        if kill -0 "$PID" 2>/dev/null; then
            kill -9 "$PID" 2>/dev/null
        fi
        echo "⏹️ Lettura interrotta."
        notify-send "TTS" "⏹️ Lettura interrotta." 2>/dev/null
    else
        echo "ℹ Nessuna lettura attiva (processo già terminato)."
        notify-send "TTS" "ℹ Nessuna lettura attiva." 2>/dev/null
    fi
    rm -f "$PID_FILE"
else
    echo "ℹ Nessuna lettura in corso."
    notify-send "TTS" "ℹ Nessuna lettura in corso." 2>/dev/null
fi
