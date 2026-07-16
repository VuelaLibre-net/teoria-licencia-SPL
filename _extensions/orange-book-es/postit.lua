-- Traduce los divs `::: {.postit}` a una llamada `#postit[...]` de Typst.
--
-- Hace falta un filtro porque Quarto emite un div con clase como un `#block[]`
-- pelado: la clase se pierde por el camino, así que no hay nada a lo que
-- enganchar un show rule.
--
-- Va en un fichero aparte, y no dentro de orange-book.lua, para que aquel siga
-- siendo copia literal del de Quarto (ver CLAUDE.md).
--
-- Sólo se declara en el formato typst de la extensión, así que el EPUB no pasa
-- por aquí: allí el div sobrevive como <div class="postit"> y puede llevar CSS.

local function is_postit(el)
  return el.classes ~= nil and el.classes:includes("postit")
end

return {
  Div = function(el)
    if not is_postit(el) then
      return nil
    end
    local blocks = pandoc.List()
    blocks:insert(pandoc.RawBlock("typst", "#postit["))
    blocks:extend(el.content)
    blocks:insert(pandoc.RawBlock("typst", "]"))
    return blocks
  end,
}
