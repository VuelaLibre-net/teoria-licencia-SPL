# Audiolibro en español

Cadena que convierte los `.qmd` de un libro en audiolibro: un MP3 por capítulo
y un M4B por libro con capítulos, portada y metadatos. La voz la pone
[VoiceStudio](https://github.com/debpalash/VoiceStudio) (motor OmniVoice),
instalado y abierto en la misma máquina.

No entra en `make all`, ni en el CI, ni en el release: sintetizar un libro lleva
horas de GPU y se hace a mano.

Para rehacer el audio cuando cambia un capítulo, o para crear el de un libro
nuevo, sigue [MANTENIMIENTO.md](MANTENIMIENTO.md).

## Uso

```sh
make audio-voces              # comprueba VoiceStudio y las voces del reparto
make audio-voces CREAR=1      # diseña las voces que falten
make audio-guion 01 cap01     # sólo el guion, para revisarlo
make audio 01 cap01           # el MP3 del capítulo 1 (también: 1, intro)
make audio 01                 # todos los MP3 del libro 01 y su M4B
make audio-verificar 01 cap01 # QA: transcripción, sonoridad, silencios
```

También vale `make audio LIBRO=01 CAP="cap01 cap02"`.

Las salidas van a `build/audio/`:

- `guion/<libro>/<capítulo>.txt` es lo que se va a decir: una línea por
  fragmento, con la voz delante y la pausa detrás. Se revisa aquí.
- `<libro>-<versión>-<fecha>/NN-<capítulo>.mp3`, uno por capítulo. Cada
  sección `##` es un capítulo dentro del MP3.
- `<libro>-<versión>-<fecha>.m4b` es el libro entero, con créditos hablados al
  principio y al final.

Repetir la orden no repite trabajo. Cada salida guarda una huella de lo que se
pidió, y VoiceStudio guarda en caché cada fragmento ya sintetizado. Corregir una
sigla sólo vuelve a sintetizar los fragmentos donde aparece.

## Requisitos

- VoiceStudio abierto, con su API en `http://127.0.0.1:3900`. Para usar otra
  dirección, exporta `VOICESTUDIO_URL`.
- `num2words` y PyYAML: `python3 -m pip install --user num2words PyYAML`.
- `quarto` y `ffmpeg`, los mismos que usan los demás entregables.

En una RTX 3060 de 6 GB, un capítulo de 9 minutos tarda unos 4 minutos con la
calidad máxima (`num_step: 32`).

## Cómo se arma

1. **`audio.lua`** es un filtro de pandoc derivado de `tools/rag/rag.lua`.
   Aplana el capítulo en bloques con un *rol*: título, sección, narración, cita,
   seguridad, normativa, regla de oro, airmanship, resumen, ejercicio, solución,
   más allá, figura, tabla…
   - De las figuras se dice el pie, sin la nota CORREGIR.
   - Las tablas pequeñas se leen fila a fila. Las grandes se remiten al libro.
   - Antes de la solución de un ejercicio hay una pausa para pensar.
2. **`normalizar.py`** verbaliza el texto en español aeronáutico:
   - números con espacio o punto de millares y coma decimal;
   - unidades, con su género: «doscientas millas náuticas»;
   - niveles de vuelo: «nivel de vuelo uno cuatro cinco»;
   - normas: «sera punto tres mil doscientos diez»; reglamentos: «dos mil
     dieciocho barra mil ciento treinta y nueve»;
   - códigos METAR, rangos, ordinales, horas, fórmulas y direcciones web.

   Los datos están en **`reglas.yml`** y las siglas y palabras extranjeras en
   **`pronunciacion.yml`**.
3. **`guion.py`** asigna voz, velocidad y pausas según **`reparto.yml`**.
4. **`audio.py`** comprueba que el guion no deja restos sin verbalizar (cifras,
   Markdown, TeX) y lo manda a VoiceStudio por `POST /longform/render`, a
   través de **`cliente.py`**. Después descarga el resultado.

## Corregir una pronunciación

1. Busca la palabra en el guion (`build/audio/guion/…/capNN.txt`).
2. Añade la entrada a `pronunciacion.yml`:
   - en `siglas:` si va en mayúsculas;
   - en `palabras:` si no.

   Escribe la lectura con ortografía española y la tilde donde caiga el acento:
   `NOTAM: nótam`, `airmanship: érmanship`. Entrecomilla lo que YAML confundiría
   con un booleano (`"NO": "no"`).
3. `make audio NN capNN` de nuevo.

`tools/audio/sembrar.py [NN]` lista las siglas que aún no tienen entrada, con la
lectura que les daría la heurística y su desarrollo del glosario.

## Voces

El reparto nombra las voces por **nombre de perfil** de VoiceStudio. Las
iniciales son voces diseñadas, que sólo fijan género, edad y tono. Para fijar el
acento castellano:

1. Clona una grabación en VoiceStudio: de 5 a 20 segundos limpios, con el
   consentimiento del locutor.
2. Ponle el **mismo nombre** que la voz diseñada y borra esta.

El siguiente `make audio` usa la voz nueva sin tocar nada más. El audiolibro
declara en sus créditos y en sus metadatos que lo narran voces sintéticas.

## Verificación

`make audio-verificar` hace dos comprobaciones:

- **Transcripción**: transcribe cada sección con el reconocedor de VoiceStudio y
  la compara con el guion. Si el porcentaje de error pasa del 12 %, conviene
  escuchar la sección.
- **Señal**: con ffmpeg mide la sonoridad (el objetivo de ACX es -19 LUFS), el
  pico y los silencios de más de 3 s.

Con 6 GB de VRAM, el reconocedor large-v3 puede colgarse junto al modelo de voz.
`verificar.py` descarga antes el modelo de voz. Si aun así no responde, usa
`SIN_ASR=1` para medir sólo la señal, y en VoiceStudio cambia el motor ASR a
«Faster-Whisper (crash-isolated subprocess)».

## Casting: elegir las voces

Las voces diseñadas suenan neutras. El acento peninsular se consigue clonando
grabaciones reales con licencia libre. Las candidatas están en `casting.yml`:

- **davefx**: CC0, voz donada para síntesis.
- **Sharvard**, masculina y femenina: CC BY 3.0. Exige atribución, que entra
  en los créditos.
- Las de Common Voice (CC0), que genera `preparar-cv` fuera del repo.

Las fuentes se descargan a `~/.cache/spl-audio/fuentes/` y no se redistribuyen.

```sh
tools/audio/casting.py preparar-cv ~/Descargas/cv-corpus-25.0/es   # opcional
tools/audio/casting.py referencias        # referencia de 15–20 s por candidata
tools/audio/casting.py clonar             # perfiles «CAST <id>» en VoiceStudio
tools/audio/casting.py sintetizar --motor omnivoice   # y cosyvoice, voxcpm2…
tools/audio/casting.py medir              # velocidad, huecos, picos, WER
tools/audio/casting.py panel              # build/audio/casting/panel.html
tools/audio/casting.py elegir votos.json  # reparto: sexo del papel, sin repetir voz
tools/audio/casting.py aplicar            # CAST ganadores → «SPL …» y reparto.yml
```

Antes de clonar conviene una criba de oído de las grabaciones originales
(`panel --referencias` y `criba votos.json`), para descartar acentos no
peninsulares: MLS no anota acento.

Con 6 GB de VRAM hay tres trampas, ya resueltas en el código:

- La referencia debe durar menos de unos 9 s. VoiceStudio la codifica entera
  de una vez y una de 12 s agota la memoria. Las de MLS, con clips de 10–20 s,
  se recortan en una pausa y se transcriben con `transcribir.py` en CPU.
- `torch.compile` tiene que estar desactivado en VoiceStudio (issue #2135):
  reserva memoria para cada longitud de frase y llena la tarjeta.
- Se sintetiza por `/generate`. La vía `/v1/audio/speech` carga una segunda
  copia del motor que no se libera.

El panel es una escucha ciega: cada voz lleva un código al azar y la clave está
aparte, en `build/audio/casting/clave.json`. Al terminar, la voz ganadora de
cada papel se renombra en VoiceStudio a su nombre `SPL …` del reparto.
