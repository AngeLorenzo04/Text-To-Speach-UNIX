# 🔊 Text-To-Speech UNIX

Leggi ad alta voce qualsiasi testo evidenziato con il mouse su Arch Linux, usando la voce italiana naturale **it-IT-DiegoNeural** tramite Microsoft Edge TTS (`edge-playback`).

Compatibile con ambienti **X11** e **Wayland**.

---

## Indice

- [Funzionalità](#funzionalità)
- [Prerequisiti](#prerequisiti)
- [Installazione](#installazione)
- [Struttura del progetto](#struttura-del-progetto)
- [Utilizzo](#utilizzo)
- [Scorciatoie da tastiera](#scorciatoie-da-tastiera)
- [Risoluzione dei problemi](#risoluzione-dei-problemi)
- [Cambiare voce o lingua](#cambiare-voce-o-lingua)

---

## Funzionalità

- **Legge il testo evidenziato**: basta selezionare del testo con il mouse e premere una scorciatoia.
- **Voce naturale**: usa `edge-tts` con la voce italiana `it-IT-DiegoNeural` (qualità Microsoft Neural TTS).
- **Stop immediato**: interrompe la lettura istantaneamente con un secondo shortcut.
- **Compatibilità X11/Wayland**: rileva automaticamente l'ambiente grafico e usa il tool corretto (`xclip` o `wl-paste`).
- **Non bloccante**: gli script terminano subito, ideali per essere lanciati da shortcut di tastiera.
- **Anti-sovrapposizione**: avviare una nuova lettura ferma automaticamente quella in corso.
- **Richiede connessione internet**: `edge-tts` genera l'audio tramite le API Microsoft.

---

## Prerequisiti

| Pacchetto | Scopo | Installazione |
|---|---|---|
| `mpv` | Riproduzione audio (usato internamente da `edge-playback`) | `sudo pacman -S mpv` |
| `xclip` | Lettura selezione primaria (X11) | `sudo pacman -S xclip` |
| `wl-clipboard` | Lettura selezione primaria (Wayland) | `sudo pacman -S wl-clipboard` |
| `libnotify` | Notifiche desktop (`notify-send`) | `sudo pacman -S libnotify` |
| `edge-tts` | TTS engine + `edge-playback` | `pip install edge-tts` |

> **Nota**: installa `xclip` se sei su X11, `wl-clipboard` se sei su Wayland. Puoi installarli entrambi senza problemi.

---

## Installazione

### 1. Installa le dipendenze di sistema

```bash
sudo pacman -S mpv xclip wl-clipboard libnotify
```

### 2. Installa edge-tts

```bash
pip install edge-tts
```

Verifica che `edge-playback` sia nel PATH:

```bash
which edge-playback
# Output atteso: /home/tuoutente/.local/bin/edge-playback
```

Se il comando non viene trovato, aggiungi la cartella bin locale al PATH nel tuo `~/.bashrc` o `~/.zshrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Rendi gli script eseguibili

```bash
chmod +x read.sh stop.sh
```

### 4. (Consigliato) Sposta gli script in una posizione stabile

```bash
mkdir -p ~/.local/bin/tts
cp read.sh stop.sh ~/.local/bin/tts/
```

---

## Struttura del progetto

```
Text-To-Speech-UNIX/
├── read.sh          # Avvia la lettura del testo evidenziato
├── stop.sh          # Interrompe immediatamente la lettura
└── README.md        # Questa documentazione
```

**File temporanei creati a runtime:**

| File | Contenuto |
|---|---|
| `/tmp/edge_tts_read.pid` | PID del processo `edge-playback` in corso |
| `/tmp/edge_tts_read.log` | Log di output/errore di `edge-playback` |

---

## Utilizzo

### Avviare la lettura

1. **Evidenzia** del testo con il mouse (senza copiarlo — è sufficiente la selezione).
2. **Esegui** `read.sh` senza cliccare altrove:

```bash
./read.sh
# Output: ▶ Lettura avviata (PID: 12345, voce: it-IT-DiegoNeural)
```

> ⚠️ Se esegui lo script cliccando sul terminale, perdi la selezione. Usa sempre una **scorciatoia da tastiera** (vedi sezione successiva).

### Fermare la lettura

```bash
./stop.sh
# Output: ⏹ Lettura interrotta.
```

### Test con delay (senza shortcut)

Per testare senza scorciatoia, usa un delay per avere tempo di selezionare il testo:

```bash
sleep 3 && ./read.sh
# Hai 3 secondi per selezionare il testo
```

---

## Scorciatoie da tastiera

Per usare il sistema comodamente è **indispensabile** associare i due script a scorciatoie globali. Usa il **percorso assoluto** degli script nel campo comando.

### KDE Plasma

1. Apri **Impostazioni di sistema → Scorciatoie → Scorciatoie personalizzate**.
2. Clicca **Modifica → Nuovo → Azione globale → Esegui comando**.
3. Nella scheda **Trigger**: assegna la combinazione (es. `Ctrl+Alt+R`).
4. Nella scheda **Azione**: inserisci il percorso completo:
   ```
   /home/tuoutente/.local/bin/tts/read.sh
   ```
5. Ripeti per `stop.sh` (es. `Ctrl+Alt+S`).

### GNOME

1. Apri **Impostazioni → Tastiera → Visualizza e personalizza scorciatoie**.
2. Scorri fino a **Scorciatoie personalizzate** e clicca **+**.
3. Compila i campi:
   - **Nome**: `TTS Leggi` / `TTS Stop`
   - **Comando**: `/home/tuoutente/.local/bin/tts/read.sh`
   - **Scorciatoia**: es. `Ctrl+Alt+R`
4. Ripeti per `stop.sh`.

### i3 / Sway

Aggiungi al file di configurazione (`~/.config/i3/config` o `~/.config/sway/config`):

```
bindsym $mod+F8 exec /home/tuoutente/.local/bin/tts/read.sh
bindsym $mod+F9 exec /home/tuoutente/.local/bin/tts/stop.sh
```

Ricarica la configurazione: `$mod+Shift+R`.

### Hyprland

Aggiungi a `~/.config/hypr/hyprland.conf`:

```
bind = CTRL ALT, R, exec, /home/tuoutente/.local/bin/tts/read.sh
bind = CTRL ALT, S, exec, /home/tuoutente/.local/bin/tts/stop.sh
```

---

## Risoluzione dei problemi

### La lettura non parte

```bash
# 1. Verifica che edge-playback sia raggiungibile
edge-playback --help

# 2. Testa edge-playback manualmente
edge-playback --voice it-IT-DiegoNeural --text "Test voce italiana"

# 3. Controlla i log dell'ultimo avvio
cat /tmp/edge_tts_read.log

# 4. Verifica che la selezione primaria funzioni
xclip -o -selection primary    # X11
wl-paste --primary             # Wayland
```

### La lettura non si ferma

```bash
# Verifica quali processi sono in esecuzione
ps aux | grep -E "mpv|edge" | grep -v grep

# Stop manuale di emergenza
pkill -KILL edge-playback; pkill -KILL mpv
```

### edge-playback non trovato dopo pip install

```bash
# Aggiungi al tuo ~/.bashrc o ~/.zshrc:
export PATH="$HOME/.local/bin:$PATH"

# Ricarica la shell
source ~/.bashrc
```

### Wayland: nessun testo acquisito

Su alcuni compositor Wayland la selezione primaria va abilitata esplicitamente. Verifica che `wl-paste` funzioni:

```bash
# Seleziona del testo, poi:
wl-paste --primary
```

Se fallisce, installa il pacchetto `wl-clipboard`:

```bash
sudo pacman -S wl-clipboard
```

---

## Cambiare voce o lingua

La voce è configurata nella variabile `VOICE` in cima a `read.sh`:

```bash
VOICE="it-IT-DiegoNeural"
```

Per vedere tutte le voci disponibili:

```bash
edge-tts --list-voices
```

Alcune voci italiane disponibili:

| Voce | Genere |
|---|---|
| `it-IT-DiegoNeural` | Maschile |
| `it-IT-ElsaNeural` | Femminile |
| `it-IT-IsabellaNeural` | Femminile |

Voci in altre lingue (esempi):

| Voce | Lingua |
|---|---|
| `en-US-AriaNeural` | Inglese (US) |
| `en-GB-SoniaNeural` | Inglese (UK) |
| `fr-FR-DeniseNeural` | Francese |
| `de-DE-KatjaNeural` | Tedesco |
| `es-ES-ElviraNeural` | Spagnolo |
