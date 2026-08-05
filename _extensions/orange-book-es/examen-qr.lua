-- Convierte únicamente el enlace aislado de «Ponte a prueba» en un QR para PDF.
--
-- El filtro sólo se registra para Typst: EPUB, RAG y web conservan el enlace
-- textual, que es mejor alternativa que un código opaco fuera del papel.

local PREFIJO = "https://vuelalibre.net/examenes/"

local function es_url_de_examenes(url)
  if url == PREFIJO then
    return true
  end
  return url:match("^" .. PREFIJO .. "[a-z0-9%-]+/$") ~= nil
end

return {
  Para = function(el)
    if #el.content ~= 1 or el.content[1].t ~= "Link" then
      return nil
    end

    local enlace = el.content[1]
    local url = enlace.target
    if not es_url_de_examenes(url) then
      return nil
    end

    return pandoc.RawBlock("typst", '#examen-qr("' .. url .. '")')
  end,
}
