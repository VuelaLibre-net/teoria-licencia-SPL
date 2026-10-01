-- figura-corregir.lua
-- Marca de agua de revisión sobre las figuras que hay que rehacer.
--
-- Una figura que necesita cambios lleva la clase `.corregir`:
--
--   ![Pie. *(CORREGIR: qué está mal.)*](imagenes/…){#fig-… .corregir}
--
-- y este filtro le superpone, en diagonal, la misma etiqueta que la marca de
-- agua de página del estado «En revisión»: «EN REVISIÓN» o, en la edición
-- inglesa, «IN REVIEW». Cuando llega la figura nueva se quita la clase y el
-- texto del pie; la imagen nunca se toca.
--
-- PDF (Typst): la imagen va en un box y la etiqueta se coloca encima con
-- place(). Lleva el rojo y la inclinación de la marca de página, pero más
-- opacidad, porque aquí sí debe verse a la primera, y un contorno blanco fino
-- para leerse también sobre fondos de color.
--
-- EPUB y web: estilos en línea, no una hoja de estilos. El sitio web publica el
-- CUERPO del HTML dentro de su propia plantilla, así que una regla CSS en la
-- cabecera no llegaría. Si un lector de EPUB no admite position:absolute, la
-- etiqueta sale debajo de la imagen: se sigue entendiendo.
--
-- Se registra en `filters:` del _quarto.yml del libro (vale para todos los
-- formatos), no en _extension.yml, cuyos filtros sólo corren en Typst.

local etiqueta = "EN REVISIÓN"

local function leer_idioma(meta)
  local lang = meta.lang and pandoc.utils.stringify(meta.lang) or ""
  if lang:sub(1, 2) == "en" then
    etiqueta = "IN REVIEW"
  end
end

-- La etiqueta se escala con la imagen: con un cuerpo fijo, en las figuras
-- pequeñas se salía por los lados, y en las anchas y bajas, por arriba y por
-- abajo. Se mide la imagen tal como quedará en la caja disponible y el cuerpo
-- es el menor de 1/6,5 del ancho y 1/5,5 del alto; lo que aun así sobresalga se
-- recorta (clip).
local function typst(img)
  local src = img.src:gsub("\\", "\\\\"):gsub('"', '\\"')
  return pandoc.RawInline("typst",
    '#layout(region => {\n'
    .. '  let im = image("' .. src .. '")\n'
    .. '  let t = measure(im, width: region.width)\n'
    .. '  let cuerpo = calc.min(t.width / 6.5, t.height / 5.5)\n'
    .. '  box(width: t.width, height: t.height, clip: true, {\n'
    .. '    image("' .. src .. '", width: t.width)\n'
    .. '    place(center + horizon, rotate(-38deg, text(size: cuerpo, weight: "black", '
    .. 'fill: rgb(200, 30, 30, 140), stroke: 0.04em + rgb(255, 255, 255, 170), "' .. etiqueta .. '")))\n'
    .. '  })\n'
    .. '})')
end

local function html(img)
  local abre = '<span class="figura-corregir" style="position: relative; '
    .. 'display: inline-block; max-width: 100%; overflow: hidden;">'
  local marca = '<span aria-hidden="true" style="position: absolute; inset: 0; '
    .. 'display: flex; align-items: center; justify-content: center; '
    .. 'pointer-events: none;"><span style="transform: rotate(-38deg); '
    .. 'font-weight: 900; font-size: 2.5em; letter-spacing: 0.05em; '
    .. 'white-space: nowrap; color: rgba(200, 30, 30, 0.55); text-shadow: 0 0 2px rgba(255, 255, 255, 0.8);">'
    .. etiqueta .. '</span></span></span>'
  return {
    pandoc.RawInline("html", abre),
    img,
    pandoc.RawInline("html", marca),
  }
end

-- La nota «(CORREGIR: …)» del pie no debe salir en el índice de ilustraciones
-- del PDF. Se envuelve en un context que la omite mientras el estado
-- `indice-figuras` vale true, cosa que sólo ocurre al componer esa lista
-- (lib.typ). En EPUB y web no hay índice de figuras: no se toca.
local function nota(em)
  if not quarto.doc.is_format("typst") then
    return nil
  end
  local texto = pandoc.utils.stringify(em)
  if not (texto:find("^%(CORREGIR:") or texto:find("^%(FIX:")) then
    return nil
  end
  return {
    pandoc.RawInline("typst", '#context if not state("indice-figuras", false).get() ['),
    em,
    pandoc.RawInline("typst", ']'),
  }
end

local function marcar(img)
  if not img.classes:includes("corregir") then
    return nil
  end
  if quarto.doc.is_format("typst") then
    return typst(img)
  elseif quarto.doc.is_format("html") or quarto.doc.is_format("epub") then
    return html(img)
  end
  return nil
end

return {
  { Meta = leer_idioma },
  { Image = marcar, Emph = nota },
}
