-- Numera el manual completo por parte en EPUB sin tocar los nueve libros.
--
-- El EPUB escribe un XHTML por capítulo y descarta los nodos `part`. Quarto sí
-- conserva en cada nodo el capítulo global del libro. Los límites son la
-- estructura de las nueve partes del completo (14, 4, 10, 7, 7, 8, 5, 14, 7).
-- Sólo se declara desde la configuración del manual completo.

local LIMITES = { 14, 18, 28, 35, 42, 50, 55, 69, 76 }
local ROMANOS = { "I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX" }
local secciones = {}
local ultimo_capitulo = nil

local function numeros_actuales()
  local estado = quarto.doc.file_metadata()
  local archivo = estado and estado.file
  local global = archivo and archivo.bookItemType == "chapter" and archivo.bookItemNumber
  if type(global) ~= "number" then
    return nil
  end
  local anterior = 0
  for parte, limite in ipairs(LIMITES) do
    if global <= limite then
      return parte, global - anterior
    end
    anterior = limite
  end
  return nil
end

local function prefijo(parte, capitulo)
  return ROMANOS[parte] .. "." .. capitulo
end

local function anteponer(el, numero)
  el.content:insert(1, pandoc.Space())
  el.content:insert(1, pandoc.Str(numero))
  el.classes:insert("unnumbered")
  return el
end

return quarto.utils.combineFilters({
  quarto.utils.file_metadata_filter(),
  {
    Header = function(el)
      local parte, capitulo = numeros_actuales()
      if parte == nil or el.level < 1 or el.level > 4 then
        return nil
      end
      if el.level == 1 then
        secciones = {}
        ultimo_capitulo = capitulo
      elseif ultimo_capitulo ~= capitulo then
        secciones = {}
        ultimo_capitulo = capitulo
      end
      if el.level > 1 then
        secciones[el.level] = (secciones[el.level] or 0) + 1
        for nivel = el.level + 1, 4 do
          secciones[nivel] = nil
        end
      end
      local numero = prefijo(parte, capitulo)
      for nivel = 2, el.level do
        numero = numero .. "." .. secciones[nivel]
      end
      return anteponer(el, numero)
    end,

  },
})
