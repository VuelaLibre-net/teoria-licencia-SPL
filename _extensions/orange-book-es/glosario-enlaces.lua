-- glosario-enlaces.lua
-- Filtro Lua de Quarto para enlazar automáticamente la primera aparición
-- de los términos y acrónimos del glosario en el cuerpo del texto.

local function is_typst_book()
  return quarto.doc.is_format("typst")
end

-- Limpia un texto para generar un identificador único uniforme
local function clean_id(str)
  str = str:gsub("Á", "a"):gsub("É", "e"):gsub("Í", "i"):gsub("Ó", "o"):gsub("Ú", "u"):gsub("Ñ", "n"):gsub("Ü", "u")
  str = str:gsub("á", "a"):gsub("é", "e"):gsub("í", "i"):gsub("ó", "o"):gsub("ú", "u"):gsub("ñ", "n"):gsub("ü", "u")
  str = str:lower()
  str = str:gsub("[^%w%s%-]", "")
  str = str:gsub("[%s%-]+", "-")
  str = str:gsub("^%-+", ""):gsub("%-+$", "")
  return str
end

-- Determina si un texto está compuesto únicamente por mayúsculas y no tiene minúsculas
local function is_all_uppercase(str)
  return str:match("%a") and not str:match("%l")
end

-- Convierte una cadena a minúsculas UTF-8 básica para español
local function utf8_lower(str)
  str = str:lower()
  str = str:gsub("Á", "á"):gsub("É", "é"):gsub("Í", "í"):gsub("Ó", "ó"):gsub("Ú", "ú"):gsub("Ñ", "ñ"):gsub("Ü", "ü")
  return str
end

-- Elimina los espacios en blanco al principio y al final de una cadena, devolviendo un único valor
local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

-- Encuentra un término con control de límites de palabras (word boundary) y sensibilidad a mayúsculas
local function find_word_case(text, key, all_uppercase)
  local searchText = text
  local searchKey = key
  if not all_uppercase then
    searchText = utf8_lower(text)
    searchKey = utf8_lower(key)
  end
  
  local start = 1
  while true do
    local s, e = searchText:find(searchKey, start, true)
    if not s then return nil end
    
    local before = s > 1 and text:sub(s - 1, s - 1) or " "
    local after = e < #text and text:sub(e + 1, e + 1) or " "
    
    local before_is_alphanumeric = before:match("[%w\128-\255]")
    local after_is_alphanumeric = after:match("[%w\128-\255]")
    
    if not before_is_alphanumeric and not after_is_alphanumeric then
      return s, e
    end
    start = s + 1
  end
end

-- Divide una cadena de texto sin términos en una lista de inlines (Str y Space)
local function text_to_inlines(text)
  local result = pandoc.List()
  local start = 1
  while start <= #text do
    local s, e = text:find("%s+", start)
    if s then
      if s > start then
        result:insert(pandoc.Str(text:sub(start, s - 1)))
      end
      result:insert(pandoc.Space())
      start = e + 1
    else
      result:insert(pandoc.Str(text:sub(start)))
      break
    end
  end
  return result
end

-- Procesa un fragmento de texto plano buscando los términos del glosario
local function process_text_segment(text, terms, seen)
  if text == "" then return pandoc.List() end
  
  local earliest_s = nil
  local earliest_e = nil
  local best_term = nil
  local best_key = nil
  
  for _, term in ipairs(terms) do
    if not seen[term.id] then
      for _, key in ipairs(term.search_keys) do
        local s, e = find_word_case(text, key, is_all_uppercase(key))
        if s then
          if not earliest_s or s < earliest_s then
            earliest_s = s
            earliest_e = e
            best_term = term
            best_key = key
          end
        end
      end
    end
  end
  
  if earliest_s then
    -- Encontrado: marcar como visto
    seen[best_term.id] = true
    
    local before_text = text:sub(1, earliest_s - 1)
    local match_text = text:sub(earliest_s, earliest_e)
    local after_text = text:sub(earliest_e + 1)
    
    local result = pandoc.List()
    
    if before_text ~= "" then
      result:extend(process_text_segment(before_text, terms, seen))
    end
    
    local link_inline = pandoc.Link({ pandoc.Str(match_text) }, "#glosario-" .. best_term.id)
    result:insert(link_inline)
    
    if is_typst_book() then
      local clean_key = best_term.search_keys[1]:gsub('"', '\\"')
      result:insert(pandoc.RawInline('typst', '#index("' .. clean_key .. '")'))
    end
    
    if after_text ~= "" then
      if after_text:match("^%.%w") then
        after_text = "\xe2\x80\x8b" .. after_text
      end
      result:extend(process_text_segment(after_text, terms, seen))
    end
    
    return result
  else
    return text_to_inlines(text)
  end
end

-- Recorre los inlines de un bloque buscando y reemplazando los términos
local function process_inlines(inlines, terms, seen)
  local result = pandoc.List()
  local text_accum = ""
  local accum_inlines = {}
  
  local function flush_accum()
    if #accum_inlines == 0 then return end
    local processed = process_text_segment(text_accum, terms, seen)
    result:extend(processed)
    text_accum = ""
    accum_inlines = {}
  end
  
  for _, inline in ipairs(inlines) do
    if inline.t == "Str" then
      text_accum = text_accum .. inline.text
      table.insert(accum_inlines, inline)
    elseif inline.t == "Space" then
      text_accum = text_accum .. " "
      table.insert(accum_inlines, inline)
    elseif inline.t == "SoftBreak" then
      text_accum = text_accum .. " "
      table.insert(accum_inlines, inline)
    else
      flush_accum()
      if inline.t == "Link" then
        result:insert(inline)
      elseif inline.content then
        inline.content = process_inlines(inline.content, terms, seen)
        result:insert(inline)
      else
        result:insert(inline)
      end
    end
  end
  
  flush_accum()
  return result
end

-- Añade claves de búsqueda basadas en el término y variaciones
local function add_search_keys(entry, term)
  term = trim(term)
  table.insert(entry.search_keys, term)

  -- Si tiene coma ("Bernoulli, teorema de"), añadir "teorema de Bernoulli"
  if term:find(",") then
    local parts = {}
    for p in term:gmatch("[^,]+") do
      table.insert(parts, trim(p))
    end
    if #parts == 2 then
      table.insert(entry.search_keys, parts[2] .. " " .. parts[1])
      if #parts[1] >= 4 then
        table.insert(entry.search_keys, parts[1])
      end
    end
  end
end

-- Función principal del documento
local function Pandoc(doc)
  if not is_typst_book() then
    return doc
  end

  -- Cargar glosario
  local terms = {}
  local f = io.open("glosario.qmd", "r")
  if not f then
    local file_state = quarto.doc.file_metadata()
    if file_state and file_state.file and file_state.file.resourceDir then
      f = io.open(file_state.file.resourceDir .. "/glosario.qmd", "r")
    end
  end

  if f then
    for line in f:lines() do
      local term = line:match("^%*%*(.+)%*%*$")
      if term then
        local prefix, paren = term:match("^([^%(]+)%((.+)%)%s*$")
        if not prefix then
          prefix = term
          paren = nil
        end
        
        local entry = {
          id = "",
          search_keys = {}
        }
        
        if prefix:find("/") then
          for p in prefix:gmatch("[^/]+") do
            add_search_keys(entry, p)
          end
        else
          add_search_keys(entry, prefix)
        end
        
        entry.id = clean_id(entry.search_keys[1])
        
        if paren then
          for p in paren:gmatch("[^/,]+") do
            p = trim(p)
            p = p:gsub("^%*+", ""):gsub("%*+$", "")
            p = p:gsub("^_+", ""):gsub("_+$", "")
            if #p >= 2 and #p <= 15 then
              table.insert(entry.search_keys, p)
            end
          end
        end
        
        table.insert(terms, entry)
      end
    end
    f:close()
  end

  -- Ordenar por longitud descendente para emparejar términos más largos primero
  for _, term in ipairs(terms) do
    table.sort(term.search_keys, function(a, b) return #a > #b end)
  end

  local in_chapter = false
  local in_glossary = false
  local seen = {}

  doc = doc:walk({
    Header = function(h)
      if h.level == 1 then
        local title = pandoc.utils.stringify(h.content)
        local lower_title = title:lower()
        if lower_title:find("glosario") then
          in_glossary = true
          in_chapter = false
        elseif h.classes:includes("unnumbered") and not lower_title:find("introduccion") then
          in_glossary = false
          in_chapter = false
        else
          in_glossary = false
          in_chapter = true
          seen = {}
        end
      end
      return h
    end,

    DefinitionList = function(el)
      if in_glossary then
        for _, item in ipairs(el.content) do
          local term_inlines = item[1]
          local term_text = pandoc.utils.stringify(term_inlines)
          
          local match_id = nil
          local first_word = term_text:match("^([^%(]+)")
          if first_word then
            if first_word:find("/") then
              first_word = first_word:match("^[^/]+")
            end
            first_word = trim(first_word)
            match_id = clean_id(first_word)
          end
          
          if match_id then
            table.insert(item[1], pandoc.RawInline('typst', ' <glosario-' .. match_id .. '>'))
          end
        end
        return el
      end
      return nil
    end,

    Para = function(el)
      if in_chapter then
        el.content = process_inlines(el.content, terms, seen)
        return el
      end
      return nil
    end,

    Plain = function(el)
      if in_chapter then
        el.content = process_inlines(el.content, terms, seen)
        return el
      end
      return nil
    end
  })

  -- Encontrar la posición del Colofón para insertar el Índice alfabético antes de él
  local insert_idx = nil
  for i, block in ipairs(doc.blocks) do
    if block.t == "Header" then
      local title = pandoc.utils.stringify(block.content)
      local lower_title = title:lower()
      if lower_title:find("colofon") or lower_title:find("colofón") then
        insert_idx = i
        break
      end
    elseif block.t == "Div" and block.classes:includes("colofon") then
      insert_idx = i
      break
    elseif block.t == "RawBlock" and block.format == "typst" and block.text == "#colofon[" then
      insert_idx = i
      break
    end
  end

  local index_header = pandoc.Header(1, {pandoc.Str("Índice alfabético")}, pandoc.Attr("indice-alfabetico", {"unnumbered", "unlisted"}, {}))
  -- in-dexter no aplica la lengua del documento: normalizamos sólo la clave de
  -- ordenación para que las tildes no creen letras independientes en español.
  local index_block = pandoc.RawBlock('typst', '#let orden-es = key => upper(key).replace("Á", "A").replace("É", "E").replace("Í", "I").replace("Ó", "O").replace("Ú", "U").replace("Ü", "U")\n#columns(3, gutter: 15pt)[\n  #show par: pad.with(left: 0.65em)\n  #make-index(title: none, sort-order: orden-es)\n]')

  if insert_idx then
    table.insert(doc.blocks, insert_idx, index_header)
    table.insert(doc.blocks, insert_idx + 1, index_block)
  else
    table.insert(doc.blocks, index_header)
    table.insert(doc.blocks, index_block)
  end

  -- Importar in-dexter al principio del documento
  table.insert(doc.blocks, 1, pandoc.RawBlock('typst', '#import "@preview/in-dexter:0.7.2": *'))

  return doc
end

return quarto.utils.combineFilters({
  quarto.utils.file_metadata_filter(),
  { Pandoc = Pandoc }
})
