# 🔊 Text-To-Speech UNIX

Leggi ad alta voce qualsiasi testo evidenziato con il mouse su **Ubuntu / Debian**, usando la voce italiana tramite **pico2wave**. Funziona completamente **offline**, senza connessione internet.

---

## Indice

- [Funzionalità](#funzionalità)
- [Prerequisiti](#prerequisiti)
- [Installazione](#installazione)
- [Struttura del progetto](#struttura-del-progetto)
- [Utilizzo](#utilizzo)
- [Scorciatoie da tastiera](#scorciatoie-da-tastiera)
- [Risoluzione dei problemi](#risoluzione-dei-problemi)
- [Cambiare lingua](#cambiare-lingua)

---

## Funzionalità

- **Legge il testo evidenziato**: basta selezionare del testo con il mouse e premere una scorciatoia.
- **Completamente offline**: nessuna API esterna, tutto gira in locale con `pico2wave`.
- **Stop immediato**: interrompe la lettura istantaneamente con un secondo shortcut.
- **Anti-sovrapposizione**: avviare una nuova lettura ferma automaticamente quella in corso.
- **Non bloccante**: gli script terminano subito, ideali per essere lanciati da shortcut di tastiera.
- **Notifiche desktop**: feedback visivo tramite `notify-send`.

---

## Prerequisiti

| Pacchetto | Scopo | Pacchetto apt |
|---|---|---|
| `xclip` | Lettura della selezione primaria (testo evidenziato) | `xclip` |
| `pico2wave` | Sintesi vocale TTS offline in italiano | `libttspico-utils` |
| `aplay` | Riproduzione del file audio generato | `alsa-utils` |
| `notify-send` | Notifiche desktop (opzionale) | `libnotify-bin` |

---

## Installazione

### 1. Installa le dipendenze

```bash
sudo apt update
sudo apt install xclip libttspico-utils alsa-utils libnotify-bin
```

### 2. Rendi gli script eseguibili

```bash
chmod +x read.sh stop.sh
```

### 3. (Consigliato) Sposta gli script in una posizione stabile

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
| `/tmp/pico_tts.wav` | File audio temporaneo generato da pico2wave |
| `/tmp/pico_tts_pid` | PID del processo `aplay` in corso |

---

## Utilizzo

### Avviare la lettura

1. **Evidenzia** del testo con il mouse (senza copiarlo — è sufficiente la selezione).
2. **Esegui** `read.sh` senza cliccare altrove:

```bash
./read.sh
# Output: ▶ Lettura avviata (PID: 12345, lingua: it-IT)
```

> ⚠️ Se esegui lo script cliccando sul terminale, perdi la selezione. Usa sempre una **scorciatoia da tastiera** (vedi sezione successiva).

### Fermare la lettura

```bash
./stop.sh
# Output: ⏹️ Lettura interrotta.
```

### Test con delay (senza shortcut)

Per testare senza scorciatoia, usa un delay per avere tempo di selezionare il testo:

```bash
sleep 3 && ./read.sh
# Hai 3 secondi per selezionare il testo con il mouse
```

---

## Scorciatoie da tastiera

Per usare il sistema comodamente è **indispensabile** associare i due script a scorciatoie globali. Usa il **percorso assoluto** degli script nel campo comando.

### GNOME (Ubuntu default)

1. Apri **Impostazioni → Tastiera → Visualizza e personalizza scorciatoie**.
2. Scorri fino a **Scorciatoie personalizzate** e clicca **+**.
3. Compila i campi:
   - **Nome**: `TTS Leggi`
   - **Comando**: `/home/tuoutente/.local/bin/tts/read.sh`
   - **Scorciatoia**: es. `Ctrl+Alt+R`
4. Ripeti per `stop.sh`:
   - **Nome**: `TTS Stop`
   - **Comando**: `/home/tuoutente/.local/bin/tts/stop.sh`
   - **Scorciatoia**: es. `Ctrl+Alt+S`

### KDE Plasma

1. Apri **Impostazioni di sistema → Scorciatoie → Scorciatoie personalizzate**.
2. Clicca **Modifica → Nuovo → Azione globale → Esegui comando**.
3. Nella scheda **Trigger**: assegna la combinazione (es. `Ctrl+Alt+R`).
4. Nella scheda **Azione**: inserisci il percorso completo:
   ```
   /home/tuoutente/.local/bin/tts/read.sh
   ```
5. Ripeti per `stop.sh` (es. `Ctrl+Alt+S`).

### i3 / Openbox

Aggiungi al file di configurazione (`~/.config/i3/config`):

```
bindsym $mod+F8 exec /home/tuoutente/.local/bin/tts/read.sh
bindsym $mod+F9 exec /home/tuoutente/.local/bin/tts/stop.sh
```

---

## Risoluzione dei problemi

### Nessun audio

```bash
# 1. Testa pico2wave manualmente
pico2wave -l=it-IT -w=/tmp/test.wav "Ciao, questo è un test" && aplay /tmp/test.wav

# 2. Verifica che la selezione primaria funzioni
xclip -o -selection primary

# 3. Verifica che aplay funzioni
aplay /tmp/pico_tts.wav
```

### Lo script non trova il testo selezionato

```bash
# Seleziona del testo, poi esegui:
xclip -o -selection primary
# Se stampa il testo → xclip funziona
# Se non stampa nulla → il testo non è nella selezione primaria
```

> **Nota**: la selezione primaria in X11 si aggiorna automaticamente quando evidenzi del testo con il mouse. Non serve `Ctrl+C`.

### La lettura non si ferma

```bash
# Stop manuale di emergenza
PID=$(cat /tmp/pico_tts_pid 2>/dev/null)
[ -n "$PID" ] && kill -9 "$PID"
pkill -9 aplay
```

### notify-send non funziona

```bash
sudo apt install libnotify-bin
```

---

## Cambiare lingua

La lingua è configurata nella variabile `LANG_CODE` in cima a `read.sh`:

```bash
LANG_CODE="it-IT"
```

Lingue supportate da pico2wave:

| Codice | Lingua |
|---|---|
| `it-IT` | Italiano |
| `en-US` | Inglese (US) |
| `en-GB` | Inglese (UK) |
| `fr-FR` | Francese |
| `de-DE` | Tedesco |
| `es-ES` | Spagnolo |

> Verifica le lingue disponibili nel tuo sistema con: `ls /usr/share/pico/lang/`

---

## Versione Arch Linux

Esiste una versione alternativa di questi script ottimizzata per **Arch Linux**, che usa `edge-playback` con voci neurali Microsoft di alta qualità (richiede connessione internet).

Disponibile nel branch [`Arch`](../../tree/Arch) di questo repository.
