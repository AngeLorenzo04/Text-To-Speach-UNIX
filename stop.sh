#!/bin/bash
# ============================================================
# Script 2: Stop Reading (stop.sh)
# Interrompe immediatamente la lettura avviata da read.sh
# terminando in modo pulito i processi edge-playback e mpv.
#
# Come associare a una scorciatoia da tastiera:
#   KDE Plasma:
#     Impostazioni → Scorciatoie → Scorciatoie personalizzate
#     → Nuovo → Comando globale → Comando: /percorso/completo/stop.sh
#   GNOME:
#     Impostazioni → Tastiera → Scorciatoie → Scorciatoie personalizzate
#     → + → Comando: /percorso/completo/stop.sh
#   i3 / Sway (nel file di config):
#     bindsym $mod+F9 exec /percorso/completo/stop.sh
# ============================================================

PID_FILE="/tmp/edge_tts_read.pid"
STOPPED=0

# --- Fase 1: termina il process group dell'edge-playback tracciato ---
# Usando 'kill -- -PGID' si killa l'intero gruppo di processi,
# incluso mpv che edge-playback ha spawnaato come figlio.
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if kill -0 "$PID" 2>/dev/null; then
        # Recupera il process group ID (PGID) del processo
        PGID=$(ps -o pgid= -p "$PID" 2>/dev/null | tr -d ' ')
        if [ -n "$PGID" ] && [ "$PGID" -ne 1 ]; then
            # Killa l'intero process group (edge-playback + mpv figlio)
            kill -TERM -- "-$PGID" 2>/dev/null
            sleep 0.3
            kill -KILL -- "-$PGID" 2>/dev/null
        else
            # Fallback: killa solo il processo diretto
            kill -KILL "$PID" 2>/dev/null
        fi
        STOPPED=1
    fi
    rm -f "$PID_FILE"
fi

# --- Fase 2: termina tutti i processi edge-playback residui ---
# Gestisce il caso in cui read.sh sia stato avviato più volte
# o il PID file sia andato perso.
if pgrep -x "edge-playback" &>/dev/null; then
    pkill -KILL -x "edge-playback" 2>/dev/null
    STOPPED=1
fi

# --- Fase 3: killa mpv direttamente ---
# edge-playback usa mpv per la riproduzione: anche se edge-playback
# è già morto, mpv può continuare a suonare i dati già ricevuti.
# pkill -x "mpv" ferma TUTTE le istanze di mpv aperte sul sistema.
# Se usi mpv per altri scopi, sostituisci con il comando commentato
# sotto, che tenta di filtrare solo le istanze senza finestra video.
if pgrep -x "mpv" &>/dev/null; then
    pkill -KILL -x "mpv" 2>/dev/null
    STOPPED=1
fi

# Alternativa più selettiva (killa solo mpv senza video, tipico di TTS):
# pkill -KILL -f "mpv --no-video\|mpv.*--vo=null\|mpv.*audio" 2>/dev/null

# --- Feedback ---
if [ "$STOPPED" -eq 1 ]; then
    echo "⏹ Lettura interrotta."
    notify-send "TTS" "⏹ Lettura interrotta." 2>/dev/null
else
    echo "ℹ Nessuna lettura in corso."
    notify-send "TTS" "ℹ Nessuna lettura in corso." 2>/dev/null
fi
