# Libertinus Sans 7.040

Estos tres `.otf` están aquí porque **Typst no los trae y el runner del CI no los tiene**.

Typst 0.15 empotra cuatro fuentes: DejaVu Sans Mono, Libertinus **Serif**, New Computer Modern y New
Computer Modern Math. Libertinus **Sans** no está entre ellas. Compruébalo:

```bash
typst fonts --ignore-system-fonts
```

La colección la usa en tres sitios —el texto de los post-it (`postit.typ`), los créditos de
reconocimientos y los rótulos de la página de licencia (`preliminares.typ`)—, y **Typst no falla ante
una fuente ausente: cae a otra en silencio**. Durante meses los PDF publicados compusieron los 76
post-it en serif sin que nadie se enterase, porque en la máquina de desarrollo la fuente sí estaba
instalada y en el runner no. El único síntoma era un `warning: unknown font family` perdido entre
miles de líneas de salida.

Se vendorizan en vez de instalarse desde un paquete o descargarse al vuelo por el mismo motivo por el
que el CI fija Quarto 1.9.38 y Typst 0.15.0: **los mismos bytes aquí y en el runner**, hoy y dentro de
tres años. No hay paquete `fonts-libertinus` en apt, y una descarga en cada build dependería de una
URL ajena.

## Cómo llegan a Typst

`.github/workflows/ci.yml` las copia a un directorio de fuentes del sistema antes de compilar. Typst
no usa fontconfig: escanea directorios conocidos, `~/.local/share/fonts` entre ellos.

⚠️ **No sirve `TYPST_FONT_PATHS`**: Quarto invoca a Typst con `--font-path` (el suyo, donde están las
FontAwesome), y el parámetro **pisa** la variable de entorno. Las fuentes del sistema, en cambio, **sí
se suman** al `--font-path`, porque Quarto no pasa `--ignore-system-fonts`.

Que la fuente llega se comprueba sobre el entregable, no sobre el código de salida:

```bash
pdffonts build/pdf/01-*.pdf | grep LibertinusSans   # tres líneas: Regular, Bold, Italic
```

Y el CI falla si Typst avisa de cualquier fuente ausente, no sólo de ésta.

## Procedencia y licencia

- **Libertinus 7.040**, de <https://github.com/alerque/libertinus>.
- **SIL Open Font License 1.1**, cuyo texto acompaña a la fuente en `OFL.txt`, como la propia licencia
  exige. Copyright © 2012-2021 The Libertinus Project Authors.
- `OFL.txt` es el del tag `v7.040`, no el de `master`: el de master declara 2012-2024 y no
  correspondería a estos ficheros.
