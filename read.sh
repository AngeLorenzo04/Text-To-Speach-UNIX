#!/bin/bash
# ============================================================
# Script 1: Start Reading (read.sh)
# Legge ad alta voce il testo selezionato/evidenziato usando
# edge-playback con voce italiana (it-IT-DiegoNeural).
#
# Dipendenze:
#   - edge-tts / edge-playback  (pip install edge-tts)
#   - mpv                       (sudo pacman -S mpv)
#   - xclip  (X11)              (sudo pacman -S xclip)
#   - wl-clipboard (Wayland)    (sudo pacman -S wl-clipboard)
#
# Come associare a una scorciatoia da tastiera:
#   KDE Plasma:
#     Impostazioni → Scorciatoie → Scorciatoie personalizzate
#     → Nuovo → Comando globale → Comando: /percorso/completo/read.sh
#   GNOME:
#     Impostazioni → Tastiera → Scorciatoie → Scorciatoie personalizzate
#     → + → Comando: /percorso/completo/read.sh
#   i3 / Sway (nel file di config):
#     bindsym $mod+F8 exec /percorso/completo/read.sh
# ============================================================

VOICE="it-IT-DiegoNeural"
PID_FILE="/tmp/edge_tts_read.pid"

# Aggiunge ~/.local/bin al PATH: necessario quando lo script è lanciato
# tramite shortcut KDE/GNOME, che usano un ambiente minimale senza questo path.
export PATH="$HOME/.local/bin:/usr/local/bin:$PATH"

# --- Controllo dipendenze ---
if ! command -v edge-playback &>/dev/null; then
    notify-send "TTS Error" "edge-playback non trovato. Installa con: pip install edge-tts" 2>/dev/null
    echo "Errore: edge-playback non trovato." >&2
    exit 1
fi

# --- Rilevamento ambiente (X11 o Wayland) e acquisizione testo ---
if [ -n "$WAYLAND_DISPLAY" ]; then
    # Ambiente Wayland: usa wl-paste per la selezione primaria
    if ! command -v wl-paste &>/dev/null; then
        notify-send "TTS Error" "wl-clipboard non trovato. Installa con: sudo pacman -S wl-clipboard" 2>/dev/null
        echo "Errore: wl-clipboard non trovato." >&2
        exit 1
    fi
    TEXT=$(wl-paste --primary --no-newline 2>/dev/null)
elif [ -n "$DISPLAY" ]; then
    # Ambiente X11: usa xclip per la selezione primaria
    if ! command -v xclip &>/dev/null; then
        notify-send "TTS Error" "xclip non trovato. Installa con: sudo pacman -S xclip" 2>/dev/null
        echo "Errore: xclip non trovato." >&2
        exit 1
    fi
    TEXT=$(xclip -o -selection primary 2>/dev/null)
else
    echo "Errore: nessun server grafico rilevato (DISPLAY e WAYLAND_DISPLAY non impostati)." >&2
    exit 1
fi

# --- Verifica che ci sia testo selezionato ---
if [ -z "$TEXT" ]; then
    notify-send "TTS" "Nessun testo evidenziato." 2>/dev/null
    echo "Nessun testo evidenziato." >&2
    exit 1
fi

# --- Sanificazione del testo ---
# Rimuove caratteri di controllo e normalizza gli spazi bianchi.
# Il testo viene passato come argomento tra virgolette, quindi
# non è necessario fare escaping manuale: bash gestisce l'espansione
# in modo sicuro tramite "$TEXT".
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

# --- Avvio lettura in background (non bloccante) ---
# 'setsid' crea una nuova sessione (e process group) per edge-playback:
# in questo modo stop.sh può killare l'intero gruppo (edge-playback + mpv)
# con un singolo 'kill -- -PGID', senza colpire altri processi.
nohup setsid edge-playback --voice "$VOICE" --text "$TEXT" \
    </dev/null >/tmp/edge_tts_read.log 2>&1 &

BGPID=$!
echo "$BGPID" > "$PID_FILE"

echo "▶ Lettura avviata (PID: $BGPID, voce: $VOICE)"
