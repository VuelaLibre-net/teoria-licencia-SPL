# Mantenimiento de los audiolibros

Qué hacer cuando cambia un capítulo, o cuando hay que crear el audiolibro de
un libro por primera vez. La cadena y sus decisiones están en
[LEEME.md](LEEME.md); aquí sólo va el procedimiento.

La regla de fondo: **el `.qmd` es la única fuente**. El guion y el audio se
derivan siempre de él. Si algo suena mal, se corrige en el léxico, en las
reglas o en el reparto, nunca a mano en el guion ni en el MP3.

## Antes de empezar

1. Abre VoiceStudio y comprueba la cadena:

   ```sh
   make audio-voces
   ```

   Tienen que salir con ✓ las cinco voces `SPL …`. Si falta alguna, ve a
   «Recrear las voces» más abajo.
2. En VoiceStudio, `torch.compile` tiene que estar **desactivado**. Con él, la
   VRAM se llena tras unas decenas de frases (ver LEEME.md, «Casting»). Para
   comprobarlo:

   ```sh
   curl -s http://127.0.0.1:3900/api/settings/perf/torch-compile-disabled
   ```

   Debe decir `"enabled": true`.
3. El motor de `sintesis.motor` (`reparto.yml`) tiene que estar instalado:
   `curl -s http://127.0.0.1:3900/engines/tts` debe darlo como `available`.
   Si no lo está, ver LEEME.md, «Motores».
4. Cierra otras aplicaciones que usen la GPU y vigila la temperatura. En el
   portátil, la síntesis se frena a medida que se calienta (85 °C tras una
   tanda): `nvidia-smi --query-gpu=temperature.gpu --format=csv`.

## Ha cambiado un capítulo

Ejemplo: se corrige `03-meteorologia/cap05-….qmd`.

1. **Confirma el cambio en git** antes de sintetizar.

   El nombre de la carpeta de salida lleva la versión del libro y la fecha de
   su último commit, igual que el PDF: `build/audio/03-meteorologia-<versión>-<aammdd>/`.
   Si sintetizas sin confirmar, el audio nuevo sale con el nombre de la
   edición anterior.

2. **Revisa el guion** sin gastar GPU:

   ```sh
   make audio-guion 03 cap05
   ```

   Abre `build/audio/guion/03-meteorologia/cap05-….txt`. Hay una línea por
   fragmento: la voz delante, el texto tal como sonará y la pausa detrás. Mira
   sobre todo lo que cambió. Fíjate en:
   - **Siglas nuevas.** Lánzalo así para ver las que no tienen entrada:

     ```sh
     tools/audio/sembrar.py 03
     ```

     Las que se lean mal van a `pronunciacion.yml`.
   - **Números, unidades o normas leídos raro.** Se arreglan en
     `normalizar.py` o en `reglas.yml`.
   - **Palabras en inglés.** Su lectura va en la sección `palabras:` de
     `pronunciacion.yml`.
   - **Tablas.** Una tabla nueva de más de 8 filas o 1500 caracteres no se lee:
     se remite al libro. Si importa oírla, divídela en el `.qmd`.

   Si el guion deja cifras, Markdown o TeX sin verbalizar, `audio.py` se
   niega a sintetizar y dice dónde están. Corrige y repite este paso.

3. **Sintetiza el capítulo:**

   ```sh
   make audio 03 cap05
   ```

   Sólo se sintetizan los fragmentos que han cambiado. El resto sale de la
   caché (`~/.cache/spl-audio/fragmentos/`), así que una errata corregida
   cuesta segundos. Un
   capítulo entero nuevo con CosyVoice3 tarda entre una y dos veces lo que
   dura (con OmniVoice, la mitad).

4. **Verifica:**

   ```sh
   make audio-verificar 03 cap05
   ```

   Comprueba lo siguiente:
   - Cada sección con un WER por encima del 12 % sale marcada con ✗ y su
     minuto. **Escúchala**: suele ser una frase saltada o repetida, o una
     sigla mal dicha.
   - La sonoridad tiene que quedar entre -21 y -17 LUFS y no puede haber
     silencios de más de 3 s.

   La transcripción va en CPU y tarda unos 4 min por capítulo de 10 min. Con
   `SIN_ASR=1` sólo se mide la señal.

5. **Escucha** al menos el principio, las cajas y los trozos que cambiaste.

6. **Rehaz el libro** para que el M4B recoja el capítulo:

   ```sh
   make audio 03
   ```

   Los capítulos que no cambiaron salen de la caché. El M4B se monta de nuevo
   con la versión y la fecha nuevas.

### Si el cambio afecta a varios capítulos

Basta con nombrarlos todos y luego rehacer el libro:

```sh
make audio 03 cap02 cap05 cap07
make audio 03
```

Si cambió el léxico, las reglas o el reparto, cambian **todos** los capítulos
que usan esa palabra o esa voz. Lo práctico es lanzar `make audio NN` del libro
entero: lo que no cambió sigue en caché.

## Casos especiales

| Cambio | Efecto | Qué hacer |
|---|---|---|
| Se añade, quita o reordena un capítulo en `_quarto.yml` | Cambia el número de capítulo y de figura de los que van detrás («Capítulo siete», «figura 7.2») | `make audio NN` del libro entero |
| Cambia el título del libro, el autor o la licencia | Créditos hablados y metadatos del M4B | `make audio NN` |
| Cambia `introduccion.qmd` (antes de la marca GUÍA-DE-LECTURA) | Pista de introducción | `make audio NN intro` y luego `make audio NN` |
| Cambia la guía de lectura común | Nada: no entra en el audio | — |
| Cambia sólo una figura (la imagen) | Nada | — |
| Cambia el pie de una figura | Se lee el pie | Como un capítulo |
| Se marca o desmarca `CORREGIR` en un pie | Nada: la nota no se lee | — |
| Cambia `pronunciacion.yml`, `reglas.yml` o `normalizar.py` | Todos los capítulos que contienen lo cambiado | `make audio NN` de los libros afectados |
| Cambia una pausa o una velocidad en `reparto.yml` | Todos los fragmentos de ese rol | `make audio NN` |
| Cambia la semilla o `num_step` en `reparto.yml` | **Todo** se sintetiza de nuevo | Sólo a propósito: son horas de GPU |
| Cambia una `instruccion:` (estilo) en `reparto.yml` | Todos los fragmentos de esa voz | `make audio NN` (sincroniza el perfil solo) |
| Cambia `enfasis:` de un rol, o la negrita de una caja de Seguridad | Los fragmentos de ese rol con negrita | Como un capítulo, o `make audio NN` |
| Cambian los `earcons:` o las `pausas:` de `reparto.yml`, o `earcons.py`/`montaje.py` | Sólo el montaje: la voz sale de la caché | `make audio NN` (minutos) |
| Cambia `sintesis.motor` en `reparto.yml` | **Todo** se sintetiza de nuevo con el otro motor | Repite antes la ronda de motores del casting |
| Sube la versión del libro | Nombre nuevo de carpeta y M4B; el audio sale de caché | `make audio NN` |

## Crear el audiolibro de un libro nuevo

```sh
make audio-guion NN          # revisa todos los .txt
tools/audio/sembrar.py NN    # siglas sin entrada → pronunciacion.yml
make audio NN                # todos los MP3 y el M4B (con CosyVoice3, 1–2× lo que dura)
make audio-verificar NN      # QA de todos los capítulos
```

Dos casos piden atención especial:
- **Libro 04 (Comunicaciones):** la fraseología se dice cifra a cifra
  («uno uno ocho decimal siete»), y la cadena aún no distingue esos ejemplos
  de la prosa. Revisa el guion con cuidado.
- **Libro 09 (Navegación):** tiene muchas fórmulas. Comprueba en el `.txt`
  que se entienden habladas.

## Recrear las voces (otra máquina u otra instalación de VoiceStudio)

Las voces del reparto son clones. Las grabaciones de origen no viven en el
repo: se vuelven a descargar.

1. Mira en `reparto.yml` la `candidata` de cada voz `SPL …`.
2. Prepara las fuentes, en `~/.cache/spl-audio/fuentes/`:
   - **MLS:** `tools/audio/casting.py preparar-mls 12367 7393 10246`. Requiere
     `hf auth login`.
   - **davefx y Sharvard:** descárgalas como indica casting.yml (URL de cada
     candidata).
3. Clona las candidatas:

   ```sh
   tools/audio/casting.py referencias sharvard-f mls-12367 davefx mls-7393 mls-10246
   tools/audio/casting.py clonar sharvard-f mls-12367 davefx mls-7393 mls-10246
   ```

4. En VoiceStudio, renombra cada `CAST <candidata>` a su `SPL <papel>`.
5. Comprueba con `make audio-voces`.

Las referencias se arman de forma determinista a partir de las mismas
grabaciones, así que la voz resultante es la misma. La caché de la máquina
anterior no viaja: la primera vez se sintetiza todo.

## Cambiar una voz del reparto

Repite el casting (LEEME.md, «Casting»):

1. `sintetizar --motor <motor>` y `panel` para generar la escucha ciega.
2. `elegir votos.json --motor <motor>` para calcular el reparto.
3. `aplicar` para llevarlo a VoiceStudio y a `reparto.yml`. Funciona aunque
   dos voces intercambien papeles; las voces que salen del reparto vuelven a
   llamarse `CAST <candidata>`, sin borrarse.

Antes de aplicar, mira `medidas.csv`. Una voz con buena nota de oído puede
inventar audio en alguna muestra. Con CosyVoice3 le pasó a Sharvard M: un
título de 6 s le salió de 21 s. El Locutor lee todos los títulos, así que eso
lo descarta para el papel.

Después, `make audio NN` de **todos** los libros: los fragmentos de esa voz
se sintetizan de nuevo. Si la voz nueva viene de una licencia CC BY, su
`atribucion` entra sola en los créditos.

## Cuando algo falla

| Síntoma | Causa probable | Arreglo |
|---|---|---|
| `VoiceStudio no responde en http://127.0.0.1:3900` | La aplicación está cerrada | Ábrela |
| `CUDA out of memory` al sintetizar | VRAM retenida, o `torch.compile` activo | Comprueba `torch.compile`; si sigue, **reinicia VoiceStudio** (ni *unload* ni *flush* liberan del todo) |
| OOM justo al empezar con una voz | Referencia demasiado larga para codificarla | Referencia ≤ 9 s: `casting.py referencias <id>` y `clonar --rehacer <id>` |
| `CUDA out of memory` con CosyVoice3 y varios procesos `cosyvoice` en `nvidia-smi` | Alguien usó el render por capítulos de VoiceStudio, que lanza un proceso por capítulo | `curl -X POST "http://127.0.0.1:3900/model/unload/sidecar:cosyvoice"` (repetir hasta `not running`) |
| `faltan voces en VoiceStudio` | Perfil borrado o renombrado | `make audio-voces`, y si hace falta «Recrear las voces» |
| `deja N restos sin verbalizar` | Cifras, Markdown o TeX que el normalizador no conoce | Ajusta `normalizar.py`, `reglas.yml` o `pronunciacion.yml` |
| `pronunciacion.yml: «False: …» no es texto` | YAML leyó `NO`/`SI` como booleano | Entrecomilla la entrada: `"NO": "no"` |
| WER alto en una sección que suena bien | Siglas o cifras que el reconocedor escribe a su manera | Ignóralo si la escucha es buena |
| La síntesis se frena a lo largo de una tanda | VoiceStudio acumula memoria | Reinicia VoiceStudio entre libros |
| `make audio` dice «al día» pero esperabas cambios | El guion no cambió: la edición no afecta a lo que se lee | Mira el `.txt` del guion |

## Qué no hacer

- **No edites** `build/audio/guion/…`: se regenera en cada ejecución.
- **No subas** el audio al repo ni lo añadas a `all`, al CI o al release. Se
  publica aparte, a mano.
- **No uses** la vía `/v1/audio/speech` de VoiceStudio, que carga una segunda
  copia del motor que no se libera, **ni** su render por capítulos
  (`/longform/render`), que con CosyVoice3 lanza un proceso por capítulo. La
  cadena sintetiza por `/generate`.
- **No borres** `~/.cache/spl-audio/fragmentos/` si no quieres sintetizarlo
  todo de nuevo. Ocupa poco: WAV de 24 kHz.
- **No cambies** la semilla ni `num_step` para «probar»: obliga a sintetizar
  toda la colección de nuevo.
