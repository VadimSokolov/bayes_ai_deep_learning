--[[
  index-terms.lua — inject back-of-book \index{} tags for a curated vocabulary.

  Reads misc/index-terms.txt. Line grammar (see that file):
      term                    index "term" under itself
      surface => Canonical    match "surface", index under "Canonical"
  Comments start with #, blank lines are ignored; makeindex "!" gives subentries
  (e.g.  Beta distribution => distribution!Beta).

  Behaviour:
    * LaTeX/PDF output only; a no-op for HTML and if the term file is missing.
    * Tags the FIRST occurrence of each canonical entry per chapter (the seen set
      resets at every level-1 header), matching whole words case-insensitively.
    * Emits nothing visible: \index{} produces no text, so layout is unchanged.
]]

if not FORMAT:match("latex") then
  return {}
end

local stringify = pandoc.utils.stringify
local terms = {}
local seen = {}

local function trim(s) return (s:gsub("^%s+", ""):gsub("%s+$", "")) end

-- Lowercase and fold pandoc's smart quotes to ASCII so needles with apostrophes
-- ("Bayes' theorem", "Student's t") match the curly quotes in stringified text.
local function normalize(s)
  s = s:lower()
  s = s:gsub("\226\128\152", "'"):gsub("\226\128\153", "'")   -- ‘ ’ -> '
  s = s:gsub("\226\128\156", '"'):gsub("\226\128\157", '"')   -- “ ” -> "
  return s
end

local function latex_escape(s)
  -- Escape LaTeX specials that would break \index{}; leave makeindex control
  -- characters (! @ | ") intact so curated subentries and sort keys still work.
  s = s:gsub("\\", "\\textbackslash{}")
  s = s:gsub("([&%%#%$_%^~])", "\\%1")
  return s
end

local function load_terms()
  local candidates = { "misc/index-terms.txt", "index-terms.txt" }
  local dir = os.getenv("QUARTO_PROJECT_DIR")
  if dir then table.insert(candidates, 1, dir .. "/misc/index-terms.txt") end
  local fh
  for _, p in ipairs(candidates) do
    fh = io.open(p, "r")
    if fh then break end
  end
  if not fh then
    io.stderr:write("[index-terms.lua] misc/index-terms.txt not found; no index tags emitted.\n")
    return
  end
  for line in fh:lines() do
    line = trim(line)
    if line ~= "" and line:sub(1, 1) ~= "#" then
      local surface, entry = line, line
      local a = line:find("=>", 1, true)
      if a then
        surface = trim(line:sub(1, a - 1))
        entry = trim(line:sub(a + 2))
      end
      if surface ~= "" and entry ~= "" then
        terms[#terms + 1] = { needle = normalize(surface), entry = entry }
      end
    end
  end
  fh:close()
  -- Longer needles first so "gradient descent" wins over "gradient".
  table.sort(terms, function(x, y) return #x.needle > #y.needle end)
end

-- ASCII letters and digits only. The class %w depends on the locale: in a UTF-8
-- locale the first byte of an em dash counts as a letter, so a term followed by
-- an em dash was indexed or not depending on the machine that built the book.
local function is_wordchar(c)
  return c ~= nil and c ~= "" and c:match("^[A-Za-z0-9]$") ~= nil
end

-- true if `needle` occurs in `hay` (both lowercase) on whole-word boundaries
local function contains_word(hay, needle)
  local from = 1
  while true do
    local s, e = hay:find(needle, from, true)  -- plain substring, no patterns
    if not s then return false end
    local before = s > 1 and hay:sub(s - 1, s - 1) or ""
    local after = e < #hay and hay:sub(e + 1, e + 1) or ""
    if not is_wordchar(before) and not is_wordchar(after) then
      return true
    end
    from = s + 1
  end
end

local function tag(el)
  local text = stringify(el)
  if text == "" then return nil end
  local hay = normalize(text)
  local raws = {}
  for _, t in ipairs(terms) do
    if not seen[t.entry] and contains_word(hay, t.needle) then
      seen[t.entry] = true
      raws[#raws + 1] = pandoc.RawInline("latex", "\\index{" .. latex_escape(t.entry) .. "}")
    end
  end
  if #raws == 0 then return nil end
  for i = #raws, 1, -1 do
    table.insert(el.content, 1, raws[i])
  end
  return el
end

load_terms()
if #terms == 0 then return {} end

return {
  {
    Header = function(el)
      if el.level == 1 then seen = {} end  -- new chapter: one locator per chapter
      return nil
    end,
    Para = tag,
    Plain = tag,
  }
}
