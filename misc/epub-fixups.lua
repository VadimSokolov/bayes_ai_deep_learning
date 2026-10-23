--[[
  epub-fixups.lua — repair raw HTML that is legal in HTML but fatal in EPUB.

  EPUB is XHTML, and its parser is strict where a browser is forgiving. Two
  constructs in this book produce documents an EPUB reader refuses to open,
  and a file that fails to parse also takes every table-of-contents link that
  points into it down with it (~104 of them, twice over, in nav.xhtml and
  toc.ncx). Both are EPUB-only repairs: nothing here changes HTML or PDF, and
  nothing changes what a reader sees.

  1. Stray <figure> wrappers. A Mermaid block with no `%%| label:` makes
     Quarto emit a bare <figure class=''> ... </figure> pair as raw HTML
     around output that already contains its own complete figure. Pandoc puts
     each tag in its own paragraph, so the EPUB gets <p><figure></p>: a block
     element inside a paragraph, never closed within it. Drop the redundant
     wrapper; the real figure inside it is untouched.
     Giving those 15 diagrams a `%%| label: fig-...` would fix it at the
     source too, but that also numbers and captions them in every format,
     which is an editorial change rather than a build fix.

  2. Orphaned <figcaption>. Those same Mermaid cells put their caption in a
     separate paragraph as raw <figcaption> tags, which are only legal inside
     the <figure> that case 1 removes. Rewrite them to a span so the caption
     text still shows and the paragraph stays valid.

  3. Comments containing "--". Several commented-out ASCII tables (01-prob.qmd
     around line 1119, 03-bl.qmd around line 728) use runs of hyphens as rules.
     XML forbids "--" inside a comment. Comments carry nothing a reader needs,
     so strip them from the EPUB entirely.
]]

if not FORMAT:match("epub") then
  return {}
end

local function is_html(el)
  return el.format == "html" or el.format == "html4" or el.format == "html5"
end

-- A raw inline that is nothing but a <figure> open or close tag: the stray
-- wrapper from case 1. Matched exactly so a raw inline carrying real markup
-- is never discarded.
local function is_bare_figure_tag(text)
  local t = text:match("^%s*(.-)%s*$")
  return t:match("^<figure[^>]*>$") ~= nil or t == "</figure>"
end

local function fixup(el)
  if not is_html(el) then return nil end
  if is_bare_figure_tag(el.text) then return {} end
  local text = el.text:gsub("<!%-%-.-%-%->", "")
  text = text:gsub("<figcaption[^>]*>", '<span class="figure-caption">')
             :gsub("</figcaption>", "</span>")
  if text:match("^%s*$") then return {} end
  if text == el.text then return nil end
  el.text = text
  return el
end

return { { RawInline = fixup, RawBlock = fixup } }
