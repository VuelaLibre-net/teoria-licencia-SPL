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
}
