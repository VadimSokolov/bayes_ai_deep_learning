--[[
  epub-math.lua — make the book's math survive EPUB. Two jobs, both EPUB-only.

  1. Custom macros. HTML gets them from misc/preamble.html (MathJax) and PDF
     from misc/preamble.tex. EPUB has neither: Quarto writes EPUB math as
     MathML via texmath, which only knows the macros an individual equation
     carries with it. So prepend to each equation the definitions it uses.
     Defining them once in the body would work too, but pandoc's latex_macros
     would then expand every \E{...} in the LaTeX output as well, and the
     LaTeX source is meant to keep the macros unexpanded.

  2. Bare display environments. A \begin{align*}...\end{align*} written
     outside $$...$$ parses as raw TeX, which MathJax renders in HTML and
     LaTeX renders in the PDF, but which the EPUB writer silently drops. The
     book has ~90 of them. texmath understands these environments, so rewrite
     each one into display math and let it convert them.

  Definitions mirror misc/preamble.tex; keep the two in sync. \mini is spelled
  with \operatorname* rather than \DeclareMathOperator*, which texmath does
  not implement.
]]

if not FORMAT:match("epub") then
  return {}
end

local macros = {
  { "Cov",   "\\newcommand{\\Cov}[1]{\\mathrm{Cov}\\left(#1\\right)}" },
  { "Cor",   "\\newcommand{\\Cor}[1]{\\mathrm{Cor}\\left(#1\\right)}" },
  { "Var",   "\\newcommand{\\Var}[1]{\\mathrm{Var}\\left(#1\\right)}" },
  { "sd",    "\\newcommand{\\sd}[1]{\\mathrm{sd}\\left(#1\\right)}" },
  { "E",     "\\newcommand{\\E}[2][]{\\mathrm{E}_{#1}\\left(#2\\right)}" },
  { "prob",  "\\newcommand{\\prob}[1]{\\mathrm{P}\\left(#1\\right)}" },
  { "defeq", "\\newcommand{\\defeq}{\\stackrel{\\mathrm{def}}{=}}" },
  { "mini",  "\\newcommand{\\mini}{\\operatorname*{minimize}}" },
}

-- Display environments texmath can convert. Anything else that arrives as raw
-- TeX (a \pagebreak, say) is left alone for the writer to drop as before.
local math_envs = {
  ["align"] = true, ["alignat"] = true, ["eqnarray"] = true,
  ["equation"] = true, ["flalign"] = true, ["gather"] = true,
  ["multline"] = true, ["split"] = true,
}

-- True when \name appears as a whole control sequence, so \E does not match
-- the \Expect in some other macro's name.
local function uses(text, name)
  local at = 1
  while true do
    local s, e = text:find("\\" .. name, at, true)
    if not s then return false end
    if not text:sub(e + 1, e + 1):match("%a") then return true end
    at = e + 1
  end
end

-- Constructs texmath cannot parse. Without these it gives up on the whole
-- equation and emits the raw TeX into the book, which is what the reader sees.
local function make_texmath_safe(text)
  -- No \cancel variant is implemented. Drop the wrapper and keep the term:
  -- in 12-regression.qmd the next sentence explains why the term is struck.
  text = text:gsub("\\x?b?cancel%s*(%b{})", function(g) return g:sub(2, -2) end)
  -- The optional positioning argument on array is unsupported, and the book
  -- writes it on the following line. Every use is [c], already the default
  -- inside \left( ... \right), so removing it changes nothing visually.
  text = text:gsub("(\\begin{array})%s*%[%a%]", "%1")
  return text
end

local function with_macros(text)
  local needed = {}
  for _, m in ipairs(macros) do
    if uses(text, m[1]) then needed[#needed + 1] = m[2] end
  end
  if #needed == 0 then return text end
  return table.concat(needed, "") .. text
end

local function display_math(el)
  if el.format ~= "tex" and el.format ~= "latex" then return nil end
  local env = el.text:match("^%s*\\begin%s*{([%a]+)%*?}")
  if not env or not math_envs[env] then return nil end
  return pandoc.Math(pandoc.DisplayMath, el.text)
end

local function raw_inline(el) return display_math(el) end

local function raw_block(el)
  local m = display_math(el)
  return m and pandoc.Para({ m }) or nil
end

-- Two passes: the rewritten environments must come back through Math to pick
-- up their macro definitions, and a filter does not revisit what it returns.
return {
  { RawInline = raw_inline, RawBlock = raw_block },
  { Math = function(el)
      el.text = with_macros(make_texmath_safe(el.text))
      return el
    end },
}
