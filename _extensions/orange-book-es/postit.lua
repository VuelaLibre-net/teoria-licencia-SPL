-- Traduce los divs con clase a llamadas de Typst: `::: {.postit}` -> `#postit[...]`.
--
-- Hace falta un filtro porque Quarto emite un div con clase como un `#block[]`
-- pelado: la clase se pierde por el camino, así que no hay nada a lo que
-- enganchar un show rule.
--
-- Va en un fichero aparte, y no dentro de orange-book.lua, para que aquel siga
-- siendo copia literal del de Quarto (ver CLAUDE.md).
--
-- Sólo se declara en el formato typst de la extensión, así que el EPUB no pasa
-- por aquí: allí los divs sobreviven como <div class="..."> y pueden llevar CSS.

-- Clase del div -> función de Typst que la compone.
local ENVOLTORIOS = {
  postit = "postit",
  dedicatoria = "dedicatoria",
  epigrafe = "epigrafe",
  licencia = "licencia",
  colofon = "colofon",
  creditos = "creditos",
  ["mas-alla"] = "mas-alla",
  ["aviso-legal"] = "aviso-legal",
  aval = "aval",
  ["licencia-cc"] = "licencia-cc",
}

-- Ancho del canalón entre las dos columnas de `.dos-columnas`.
local CANALON = "1.2em"

-- Clase del span -> función de Typst. Los spans pierden la clase igual que los
-- divs: `[texto]{.mas-alla-tag}` sale como texto pelado.
local ETIQUETAS = {
  ["mas-alla-tag"] = "mas-alla-tag",
}

-- Clase del span -> color Typst. Las señales luminosas de la Torre (cap. de
-- fallo de comunicaciones) llevan el círculo del color de la luz. La luz blanca
-- se representa con un círculo hueco (○) en el propio texto, no coloreada: un
-- círculo blanco sobre papel blanco no se vería. El mismo par de colores está
-- en epub-estilos.html para el EPUB; si cambia uno, cambia el otro.
local COLORES = {
  ["luz-verde"] = "#2e7d32",
  ["luz-roja"]  = "#c62828",
}

local function funcion_para(el)
  if el.classes == nil then
    return nil
  end
  for clase, funcion in pairs(ENVOLTORIOS) do
    if el.classes:includes(clase) then
      return funcion
    end
  end
  return nil
end

return {
  -- Un encabezado con la clase `.oculto` desaparece del PDF.
  --
  -- Dedicatoria y epígrafe no llevan título: se reconocen por su posición y su
  -- forma, como en cualquier libro impreso. Pero el fichero no puede quedarse
  -- sin encabezado: Quarto exige que todo capítulo del libro tenga uno y, si
  -- falta, sintetiza un `= ` vacío que se lleva número de capítulo, salto de
  -- página y aparece en los encabezados de página como "Capítulo 1.".
  --
  -- Así que el encabezado se escribe y se retira aquí. El salto a página impar,
  -- que normalmente hace el `show heading` de orange-book, lo hacen las propias
  -- funciones #dedicatoria() y #epigrafe().
  Header = function(el)
    if el.classes ~= nil and el.classes:includes("oculto") then
      return {}
    end
    return nil
  end,

  Div = function(el)
    -- `.dos-columnas` no encaja en el patrón de arriba: no envuelve un cuerpo,
    -- reparte DOS cuerpos. Markdown no sabe de columnas, así que se escriben
    -- como dos divs hijos `.columna` y aquí se emiten como un #grid.
    --
    -- No vale `columns(2)` sobre el cuerpo entero: Typst balancea por su cuenta
    -- y partiría las listas por donde le pareciera. Con el grid, cada columna es
    -- lo que dice el .qmd.
    --
    -- En el EPUB este filtro no corre y los divs sobreviven como tales: allí las
    -- dos columnas se apilan, que en una pantalla estrecha se lee mejor.
    if el.classes ~= nil and el.classes:includes("dos-columnas") then
      local columnas = {}
      for _, hijo in ipairs(el.content) do
        if hijo.t == "Div" then
          table.insert(columnas, hijo)
        end
      end
      -- Fallar aquí es preferible a componer media tabla: un div de más o de
      -- menos saldría como un grid descuadrado sin que nada protestara.
      if #columnas ~= 2 then
        error("dos-columnas: se esperaban 2 divs hijos y hay " .. #columnas)
      end
      local blocks = pandoc.List()
      blocks:insert(pandoc.RawBlock("typst",
        "#grid(columns: (1fr, 1fr), gutter: " .. CANALON .. ", ["))
      blocks:extend(columnas[1].content)
      blocks:insert(pandoc.RawBlock("typst", "], ["))
      blocks:extend(columnas[2].content)
      blocks:insert(pandoc.RawBlock("typst", "])"))
      return blocks
    end

    local funcion = funcion_para(el)
    if funcion == nil then
      return nil
    end
    local blocks = pandoc.List()
    blocks:insert(pandoc.RawBlock("typst", "#" .. funcion .. "["))
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock("typst", "]"))
    return blocks
  end,

  -- `.mas-alla-tag` marca la entradilla violeta de las secciones avanzadas.
  --
  -- Hace falta por lo mismo que el Div: el escritor de typst descarta la clase
  -- del span y deja el texto pelado, sin nada a lo que enganchar un estilo.
  Span = function(el)
    if el.classes == nil then
      return nil
    end
    for clase, funcion in pairs(ETIQUETAS) do
      if el.classes:includes(clase) then
        local inlines = pandoc.List()
        inlines:insert(pandoc.RawInline("typst", "#" .. funcion .. "["))
        inlines:extend(el.content)
        inlines:insert(pandoc.RawInline("typst", "]"))
        return inlines
      end
    end
    for clase, color in pairs(COLORES) do
      if el.classes:includes(clase) then
        local inlines = pandoc.List()
        inlines:insert(pandoc.RawInline("typst", '#text(fill: rgb("' .. color .. '"))['))
        inlines:extend(el.content)
        inlines:insert(pandoc.RawInline("typst", "]"))
        return inlines
      end
    end
    return nil
  end,
}
