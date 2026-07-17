-- Filtro Pandoc: convierte un .qmd de la colección en Markdown pensado para
-- que lo indexe un RAG (NotebookLM y similares), no para que lo lea un humano.
--
-- Un RAG no ve la maqueta: trocea el texto y recupera trozos sueltos. Todo lo
-- que aquí se traduce persigue que cada trozo se explique solo:
--
--   * Los recuadros pierden el div y ganan su etiqueta COMO TEXTO. Sin esto,
--     pandoc emite `<div class="callout-warning" title="Seguridad">` y el dato
--     que importa —que eso es una advertencia de seguridad— queda en un
--     atributo HTML que el chunk arrastra como basura.
--   * Las ilustraciones no viajan al RAG, pero su pie sí dice algo. La imagen
--     se sustituye por el pie, marcado como tal.
--   * Las referencias cruzadas se resuelven a "figura 5.1". El .qmd las escribe
--     `@fig-04-cap05-pistola-luces`, que como texto no informa de nada.
--
-- Recibe por metadatos:
--   etiqueta  "5" para el capítulo 5, "A" para el apéndice A, "" si no numera.
--
-- Los encabezados bajan un nivel: en el fichero de salida el H1 es el título
-- del libro, así que el capítulo pasa a H2 y sus secciones a H3.

local etiqueta = ""
local numeros = {}          -- id de figura/tabla -> "5.1"
local nfig, ntbl = 0, 0
local sec = { 0, 0, 0, 0, 0 }

-- Etiqueta de cada recuadro cuando el .qmd no la trae en title=. Es el mismo
-- mapeo del temario que usa la maqueta (warning → Seguridad, etc.); en la
-- práctica todos los bloques traen su title=, pero sin este respaldo un bloque
-- sin título perdería la categoría en silencio.
local ETIQUETAS = {
  ["callout-warning"]   = "Seguridad",
  ["callout-important"] = "Normativa",
  ["callout-tip"]       = "Regla de oro",
  ["callout-note"]      = "Airmanship",
}

local function numero(n)
  if etiqueta == "" then return tostring(n) end
  return etiqueta .. "." .. n
end

-- Pandoc no interpreta el {#tbl-x} del pie de tabla: lo deja literal en el
-- texto (comprobado). Hay que sacarlo a mano, y quitarlo del pie visible.
local function id_de_pie(inlines)
  for _, il in ipairs(inlines) do
    if il.t == "Str" then
      local id = il.text:match("^{#(tbl%-[%w%-]+)}$")
      if id then return id end
    end
  end
  return nil
end

local function limpia_pie(inlines)
  local salida = pandoc.List({})
  for _, il in ipairs(inlines) do
    if il.t == "Str" and il.text:match("^{#tbl%-[%w%-]+}$") then
      -- Se va también el espacio que lo separaba del pie.
      if #salida > 0 and salida[#salida].t == "Space" then salida:remove(#salida) end
    else
      salida:insert(il)
    end
  end
  return salida
end

-- --- PRIMERA PASADA: numerar ---------------------------------------------
-- Va aparte porque una referencia puede ir ANTES que la figura a la que
-- apunta (pasa ya en cap05 de Comunicaciones), y entonces al resolverla el
-- número aún no existiría.
-- Se numeran TODAS las figuras y tablas, tengan id o no: si sólo se contaran
-- las referenciadas, en un capítulo con una tabla con id y otra sin él saldría
-- "Tabla 1.1" seguida de "Tabla", que al lector del RAG le parecería un fallo.
local function numerar(doc)
  doc:walk({
    Figure = function(f)
      nfig = nfig + 1
      if f.identifier ~= "" then numeros[f.identifier] = numero(nfig) end
    end,
    Table = function(t)
      if #t.caption.long == 0 then return end
      ntbl = ntbl + 1
      local id = t.identifier ~= "" and t.identifier or id_de_pie(t.caption.long[1].content or {})
      if id then numeros[id] = numero(ntbl) end
    end,
  })
end

-- --- SEGUNDA PASADA: transformar -----------------------------------------

local function Header(h)
  h.level = h.level + 1
  if etiqueta ~= "" and not h.classes:includes("unnumbered") then
    if h.level == 2 then
      h.content = { pandoc.Str(etiqueta .. "."), pandoc.Space(), table.unpack(h.content) }
    else
      local prof = h.level - 2
      sec[prof] = sec[prof] + 1
      for i = prof + 1, #sec do sec[i] = 0 end
      local partes = { etiqueta }
      for i = 1, prof do partes[#partes + 1] = tostring(sec[i]) end
      h.content = { pandoc.Str(table.concat(partes, ".")), pandoc.Space(), table.unpack(h.content) }
    end
  end
  return h
end

local function Div(d)
  -- Recuadro del temario: se convierte en cita con su etiqueta por delante.
  for clase, respaldo in pairs(ETIQUETAS) do
    if d.classes:includes(clase) then
      local titulo = d.attributes.title or respaldo
      local bloques = pandoc.List({ pandoc.Para({ pandoc.Strong({ pandoc.Str(titulo) }) }) })
      bloques:extend(d.content)
      return pandoc.BlockQuote(bloques)
    end
  end

  -- El resumen de cada capítulo. Pasa a ser un encabezado propio: es el trozo
  -- más denso del capítulo y así el troceador lo recupera como unidad.
  if d.classes:includes("postit") then
    local contenido = pandoc.List(d.content)
    local titulo = pandoc.List({ pandoc.Str("Resumen del capítulo") })
    -- Los 76 postits de la colección abren con su propio título en negrita
    -- ("**Resumen del capítulo: definiciones y técnica**"). Se asciende ese, en
    -- vez de anteponerle otro y dejar el título dos veces seguidas.
    local primero = contenido[1]
    if primero and primero.t == "Para" and #primero.content == 1
        and primero.content[1].t == "Strong" then
      titulo = pandoc.List(primero.content[1].content)
      contenido:remove(1)
    end
    local bloques = pandoc.List({ pandoc.Header(3, titulo, { class = "unnumbered" }) })
    bloques:extend(contenido)
    return bloques
  end

  -- "Más allá del examen": el contenido se queda (es materia), pero el div
  -- sobra. La entradilla ↗ MÁS ALLÁ DEL EXAMEN ya va dentro, como texto.
  if d.classes:includes("mas-alla") then
    return d.content
  end

  return d
end

local function Span(s)
  if s.classes:includes("mas-alla-tag") then return s.content end
  return s
end

-- La imagen no llega al RAG; su pie sí informa. Los contadores de esta pasada
-- son otros, pero recorren el árbol en el mismo orden que los de `numerar()`,
-- así que dan los mismos números.
local vfig, vtbl = 0, 0

local function Figure(f)
  vfig = vfig + 1
  local pie = pandoc.utils.stringify(f.caption.long)
  local texto = "Figura " .. numero(vfig)
  if pie ~= "" then texto = texto .. ": " .. pie end
  return pandoc.Para({ pandoc.Emph({ pandoc.Str(texto) }) })
end

-- gfm no tiene sintaxis de pie de tabla: si se deja en el Table, el pie se
-- pierde al escribir. Se saca a un párrafo propio delante de la tabla.
local function Table(t)
  local pies = t.caption.long
  if #pies == 0 then return t end
  vtbl = vtbl + 1
  local inlines = pies[1].content or {}
  local limpio = limpia_pie(inlines)
  local cabeza = pandoc.List({ pandoc.Str("Tabla " .. numero(vtbl) .. ":"), pandoc.Space() })
  cabeza:extend(limpio)
  t.caption.long = pandoc.Blocks({})
  return { pandoc.Para({ pandoc.Strong(cabeza) }), t }
end

-- @fig-x / @tbl-x -> "figura 5.1". Pandoc los lee como citas bibliográficas.
local function Cite(c)
  local id = c.citations[1] and c.citations[1].id
  if not id then return c end
  local clase = id:match("^fig%-") and "figura" or (id:match("^tbl%-") and "tabla")
  if not clase then return c end
  local n = numeros[id]
  if not n then
    -- Referencia a algo que no está en este fichero. Mejor la palabra sola
    -- que un identificador que no dice nada.
    return pandoc.Str(clase)
  end
  return pandoc.Str(clase .. " " .. n)
end

function Pandoc(doc)
  etiqueta = pandoc.utils.stringify(doc.meta.etiqueta or "")
  numerar(doc)
  return doc:walk({
    Header = Header,
    Div = Div,
    Span = Span,
    Figure = Figure,
    Table = Table,
    Cite = Cite,
  })
end
