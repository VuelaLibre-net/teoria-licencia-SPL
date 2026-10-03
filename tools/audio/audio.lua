-- Filtro Pandoc: convierte un .qmd de la colección en la materia prima del
-- guion del audiolibro. No escribe Markdown: devuelve una lista PLANA de
-- bloques `Div` con un atributo `rol` y un único `Plain` de texto, que
-- tools/audio/guion.py lee del JSON de pandoc para asignar voz y pausas.
--
-- El oído no ve la maqueta, igual que el RAG (ver tools/rag/rag.lua, del que
-- sale la numeración de figuras y tablas): todo lo que aquí se traduce
-- persigue que cada trozo se entienda sólo escuchándolo.
--
--   * Los recuadros dejan su rótulo como bloque propio (rol `rotulo`) que dice
--     una voz y su contenido con el rol de la caja, que dice otra.
--   * La imagen no suena; su pie sí: «Figura 1.2: …», sin la nota CORREGIR.
--   * Las tablas pequeñas se leen fila a fila; las grandes se remiten al libro.
--   * Las referencias @fig-x pasan a «figura 1.2».
--
-- La verbalización (números, unidades, siglas) NO se hace aquí, sino en
-- normalizar.py: aquí sólo se decide qué se dice y con qué rol.
--
-- Recibe por metadatos:
--   etiqueta  "5" para el capítulo 5, "" si no numera.

local etiqueta = ""
local numeros = {}          -- id de figura/tabla -> "5.1"
local nfig, ntbl = 0, 0
local vfig, vtbl = 0, 0

local ROTULOS = {
  ["callout-warning"]   = { rol = "seguridad",    titulo = "Seguridad" },
  ["callout-important"] = { rol = "normativa",    titulo = "Normativa" },
  ["callout-tip"]       = { rol = "regla-de-oro", titulo = "Regla de oro" },
  ["callout-note"]      = { rol = "airmanship",   titulo = "Airmanship" },
  ["callout-caution"]   = { rol = "seguridad",    titulo = "Precaución" },
}

-- Una tabla se lee entera si cabe en el oído: pocas filas y poco texto. Por
-- encima, leerla celda a celda es una lista interminable que nadie retiene.
local TABLA_MAX_FILAS = 8
local TABLA_MAX_CARACTERES = 1500

local function numero(n)
  if etiqueta == "" then return tostring(n) end
  return etiqueta .. "." .. n
end

-- --- Texto ---------------------------------------------------------------

-- stringify junta Str y Space, pero un salto de línea dentro de un párrafo
-- debe sonar como espacio, y las comillas tipográficas no suenan.
local function texto(x)
  local t = pandoc.utils.stringify(x)
  t = t:gsub("[\r\n]+", " "):gsub("%s+", " ")
  t = t:gsub("^%s+", ""):gsub("%s+$", "")
  return t
end

local function bloque(rol, t, attrs)
  if not t or t:match("^%s*$") then return nil end
  local a = { rol = rol }
  for k, v in pairs(attrs or {}) do a[k] = v end
  return pandoc.Div({ pandoc.Plain({ pandoc.Str(t) }) }, pandoc.Attr("", {}, a))
end

-- --- PRIMERA PASADA: numerar (como rag.lua) --------------------------------

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
    if not (il.t == "Str" and il.text:match("^{#tbl%-[%w%-]+}$")) then
      salida:insert(il)
    end
  end
  return salida
end

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

-- --- SEGUNDA PASADA: elementos en línea -----------------------------------

local INLINES = {
  -- La nota de figura pendiente de corregir es para el ilustrador, no para el
  -- oyente: `*(CORREGIR: …)*`.
  Emph = function(e)
    if texto(e):match("^%(?CORREGIR") then return {} end
  end,
  Span = function(s)
    -- La entradilla ↗ MÁS ALLÁ DEL EXAMEN se dice como rótulo aparte; aquí se
    -- marca para que `aplanar` la encuentre.
    if s.classes:includes("mas-alla-tag") then
      return pandoc.Str("§MASALLA§")
    end
    return s.content
  end,
  Note = function() return {} end,
  Cite = function(c)
    local id = c.citations[1] and c.citations[1].id
    if not id then return c end
    local clase = id:match("^fig%-") and "figura" or (id:match("^tbl%-") and "tabla")
    if not clase then return c end
    local n = numeros[id]
    return pandoc.Str(n and (clase .. " " .. n) or clase)
  end,
  -- El TeX se deja en signos Unicode, que normalizar.py verbaliza junto con
  -- los mismos signos cuando aparecen en prosa.
  Math = function(m)
    local t = m.text
    t = t:gsub("_%{([^}]+)%}", " %1")
    t = t:gsub("_(%w)", " %1")
    for _, cmd in ipairs({ "mathrm", "mathbf", "mathit", "text", "operatorname" }) do
      t = t:gsub("\\" .. cmd .. "%s*%{([^}]+)%}", "%1")
    end
    t = t:gsub("\\sqrt%s*%{([^}]+)%}", "√(%1)")
    t = t:gsub("%^{\\circ}", "°"):gsub("%^\\circ", "°")
    t = t:gsub("%^{?2}?", " al cuadrado "):gsub("%^{?3}?", " al cubo ")
    t = t:gsub("%{,%}", ",")
    t = t:gsub("\\frac%s*%{([^{}]+)%}%s*%{([^{}]+)%}", " %1 entre %2 ")
    -- Ordenados de más largo a más corto, para que `\\leq` gane a `\\le` y
    -- `\\left` a los dos. Se sustituyen con espacios alrededor: `\\sin\\alpha`
    -- debe sonar «seno alfa», no quedarse en una palabra.
    local signos = {
      { "\\rightarrow", "→" }, { "\\arctan", "arco tangente de" }, { "\\arcsin", "arco seno de" }, { "\\Rightarrow", "→" }, { "\\approx", "≈" },
      { "\\qquad", "; " }, { "\\times", "×" }, { "\\Delta", "incremento de" },
      { "\\alpha", "alfa" }, { "\\beta", "beta" }, { "\\right", "" }, { "\\left", "" },
      { "\\quad", " " }, { "\\cdot", "·" }, { "\\leq", "≤" }, { "\\geq", "≥" },
      { "\\div", "÷" }, { "\\rho", "ro" }, { "\\sin", "seno" }, { "\\cos", "coseno" },
      { "\\tan", "tangente" }, { "\\pm", "±" }, { "\\pi", "pi" }, { "\\le", "≤" },
      { "\\ge", "≥" }, { "\\to", "→" }, { "\\%", "%" }, { "\\,", " " }, { "\\;", " " },
      { "\\!", "" }, { "\\ ", " " },
    }
    for _, par in ipairs(signos) do
      t = t:gsub(par[1]:gsub("%p", "%%%0"), " " .. par[2]:gsub("%%", "%%%%") .. " ")
    end
    t = t:gsub("[{}]", ""):gsub("%s+", " ")
    return pandoc.Str(t)
  end,
}

-- --- TERCERA PASADA: aplanar los bloques en guion --------------------------

local aplanar

local function emitir(salida, b)
  if b then salida:insert(b) end
end

-- Un párrafo cuyo único contenido es una negrita: el rótulo de un post-it o
-- de un ejercicio («**Ejercicio 2.1 — De la carta a la brújula.**»).
local function es_rotulo(b)
  return b and (b.t == "Para" or b.t == "Plain") and #b.content == 1
      and b.content[1].t == "Strong"
end

-- La solución de un ejercicio abre con `**Solución.**` en negrita y sigue en
-- el mismo párrafo.
local function empieza_por_solucion(b)
  return b and (b.t == "Para" or b.t == "Plain") and b.content[1]
      and b.content[1].t == "Strong" and texto(b.content[1]):match("^Soluci")
end

local function celdas(fila)
  local r = {}
  for _, c in ipairs(fila.cells) do r[#r + 1] = texto(c.contents) end
  return r
end

local function tabla(salida, t)
  vtbl = vtbl + 1
  local pie = texto(limpia_pie((t.caption.long[1] or {}).content or {}))
  local nombre = "Tabla " .. numero(vtbl)
  local cabecera = {}
  for _, fila in ipairs(t.head.rows) do cabecera = celdas(fila) end
  local filas = {}
  for _, cuerpo in ipairs(t.bodies) do
    for _, fila in ipairs(cuerpo.body) do filas[#filas + 1] = celdas(fila) end
  end
  local total = #table.concat(cabecera, " ")
  for _, f in ipairs(filas) do total = total + #table.concat(f, " ") end

  if #filas > TABLA_MAX_FILAS or total > TABLA_MAX_CARACTERES then
    local t2 = "La " .. nombre:lower()
    if pie ~= "" then t2 = t2 .. ", «" .. pie .. "»," end
    emitir(salida, bloque("tabla", t2 .. " se consulta en el libro."))
    return
  end

  emitir(salida, bloque("rotulo", pie ~= "" and (nombre .. ": " .. pie .. ".") or (nombre .. "."), { caja = "tabla" }))
  -- Cada fila se dice como una frase: la primera celda es el nombre de la fila
  -- y las demás van precedidas del rótulo de su columna.
  for _, f in ipairs(filas) do
    local partes = { f[1] or "" }
    for i = 2, #f do
      local col = cabecera[i]
      if f[i] ~= "" then
        partes[#partes + 1] = (col and col ~= "") and (col .. ": " .. f[i]) or f[i]
      end
    end
    local frase = table.concat(partes, ". ")
    if cabecera[1] and cabecera[1] ~= "" then frase = cabecera[1] .. " " .. frase end
    emitir(salida, bloque("tabla", frase .. "."))
  end
end

local function lista(salida, items, rol, ordenada)
  for i, item in ipairs(items) do
    local partes = {}
    local sub = pandoc.List({})
    for _, b in ipairs(item) do
      if b.t == "Para" or b.t == "Plain" then
        partes[#partes + 1] = texto(b)
      else
        sub:insert(b)
      end
    end
    local t = table.concat(partes, " ")
    emitir(salida, bloque(rol, t, { item = ordenada and tostring(i) or "-" }))
    aplanar(salida, sub, rol)
  end
end

local function figura(salida, f)
  vfig = vfig + 1
  local pie = texto(f.caption.long):gsub("%s*%.?%s*$", "")
  local t = "Figura " .. numero(vfig)
  t = pie ~= "" and (t .. ": " .. pie .. ".") or (t .. ".")
  emitir(salida, bloque("figura", t))
end

-- Un párrafo puede llevar dentro la marca del span mas-alla-tag: se parte en
-- rótulo («Más allá del examen.») y resto.
local function parrafo(salida, b, rol)
  local t = texto(b)
  if t:find("§MASALLA§", 1, true) then
    emitir(salida, bloque("rotulo", "Más allá del examen.", { caja = "mas-alla" }))
    t = t:gsub("§MASALLA§", ""):gsub("^%s+", "")
    rol = "mas-alla"
  end
  emitir(salida, bloque(rol, t))
end

function aplanar(salida, bloques, rol)
  local i = 1
  while i <= #bloques do
    local b = bloques[i]
    if b.t == "Header" then
      local r = b.level == 1 and "titulo-capitulo" or "seccion"
      emitir(salida, bloque(r, texto(b.content), { nivel = tostring(b.level) }))
    elseif b.t == "Para" or b.t == "Plain" then
      parrafo(salida, b, rol)
    elseif b.t == "LineBlock" then
      for _, linea in ipairs(b.content) do emitir(salida, bloque(rol, texto(linea))) end
    elseif b.t == "BlockQuote" then
      aplanar(salida, b.content, rol == "narracion" and "cita" or rol)
    elseif b.t == "BulletList" then
      lista(salida, b.content, rol, false)
    elseif b.t == "OrderedList" then
      lista(salida, b.content, rol, true)
    elseif b.t == "DefinitionList" then
      for _, par in ipairs(b.content) do
        emitir(salida, bloque("rotulo", texto(par[1]) .. ".", { caja = "definicion" }))
        for _, def in ipairs(par[2]) do aplanar(salida, def, rol) end
      end
    elseif b.t == "Figure" then
      figura(salida, b)
    elseif b.t == "Table" then
      tabla(salida, b)
    elseif b.t == "CodeBlock" then
      -- El único de la colección es un METAR crudo (03/cap10). Leído de corrido
      -- no se entiende; el texto que lo sigue lo descifra grupo a grupo.
      emitir(salida, bloque("codigo", "En el libro aparece el mensaje completo: " .. b.text:gsub("%s+", " ") .. "."))
    elseif b.t == "Div" then
      local hecho = false
      for clase, def in pairs(ROTULOS) do
        if b.classes:includes(clase) then
          emitir(salida, bloque("rotulo", (b.attributes.title or def.titulo) .. ".", { caja = def.rol }))
          aplanar(salida, b.content, def.rol)
          emitir(salida, bloque("fin-caja", " ", { caja = def.rol }))
          hecho = true
          break
        end
      end
      if not hecho and b.classes:includes("postit") then
        local contenido = pandoc.List(b.content)
        local titulo = "Resumen del capítulo."
        if es_rotulo(contenido[1]) then
          titulo = texto(contenido[1]):gsub("%s*[%.:]?%s*$", ".")
          contenido:remove(1)
        end
        emitir(salida, bloque("rotulo", titulo, { caja = "resumen" }))
        aplanar(salida, contenido, "resumen")
        emitir(salida, bloque("fin-caja", " ", { caja = "resumen" }))
        hecho = true
      end
      if not hecho and b.classes:includes("ejercicio") then
        local contenido = pandoc.List(b.content)
        if es_rotulo(contenido[1]) then
          emitir(salida, bloque("rotulo", texto(contenido[1]), { caja = "ejercicio" }))
          contenido:remove(1)
        end
        local r = "ejercicio"
        for _, c in ipairs(contenido) do
          if empieza_por_solucion(c) then
            emitir(salida, bloque("pausa-ejercicio", " ", { caja = "ejercicio" }))
            emitir(salida, bloque("rotulo", "Solución.", { caja = "solucion" }))
            local resto = pandoc.List(c.content)
            resto:remove(1)
            r = "solucion"
            emitir(salida, bloque(r, texto(resto)))
          else
            aplanar(salida, { c }, r)
          end
        end
        emitir(salida, bloque("fin-caja", " ", { caja = "ejercicio" }))
        hecho = true
      end
      if not hecho and b.classes:includes("mas-alla") then
        aplanar(salida, b.content, "mas-alla")
        hecho = true
      end
      if not hecho then
        -- arco-*, y cualquier div sin semántica de audio: se desenvuelve.
        aplanar(salida, b.content, rol)
      end
    end
    -- HorizontalRule, RawBlock y lo demás no suenan.
    i = i + 1
  end
end

function Pandoc(doc)
  etiqueta = pandoc.utils.stringify(doc.meta.etiqueta or "")
  numerar(doc)
  doc = doc:walk(INLINES)
  local salida = pandoc.List({})
  aplanar(salida, doc.blocks, "narracion")
  return pandoc.Pandoc(salida, doc.meta)
end
