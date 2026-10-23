#!/usr/bin/env python3
"""Write the computing exercises of the book as Jupyter notebooks, one per chapter and language, and a README that lists them: exercises/NN-stem.ipynb, or exercises/NN-stem-R.ipynb and exercises/NN-stem-Python.ipynb when the chapter has computing exercises in both languages, and exercises/README.md.

  notebooks.py [--out-dir exercises]
  notebooks.py --check [--out-dir exercises]

Source: the exercise file that a chapter includes (the line {{< include ./ex/FILE >}} of NN-stem.qmd), so the notebook is named by the chapter, as the files of code/ are. Its Computing section holds the exercises; the Pen-and-Pencil ones stay in the book. Everything in a content-hidden showsln solution div is dropped: the notebooks carry no solutions. Exercises are numbered as Quarto numbers them, by position in the exercise file (pen-and-pencil first), so the heading is Exercise N.k with N the chapter number. The language of an exercise comes from the code chunks of its statement and its solution (no exercise mixes the two); an exercise without code goes to the majority language of its chapter.

A notebook starts with a title cell (chapter, source, licenses, an Open in Colab badge) and a setup code cell (it installs the R packages or lists the Python modules that the exercises use, and downloads data.zip of the release when an exercise reads data/). Then each exercise gets a Markdown cell with the statement, a code cell for each code chunk of the statement at its place, and an empty code cell for the answer. The statement is converted for Jupyter, Colab and GitHub: the book macros of misc/preamble.tex are expanded inside math, cross-references become plain text (Section 13.3, Chapter 22, Equation 8.3, Table 7.1, Exercise 8.4, Example 4.4) with the numbers of the rendered book, citations become author-year text from BayesBook.bib, lettered items (a), b)) become paragraphs, images point to raw.githubusercontent.com, and Pandoc and Quarto attributes, comments and fences are removed.

The numbers of sections, equations, tables, examples and exercises are read from the HTML of the rendered book in _book/. Run the script again after the final render of the book, because the numbers change when the authors cut or move content. The script stops with a message when a label cannot be resolved or when _book/ is missing.

--check writes nothing. It parses the sources again and verifies the notebooks: every computing exercise is in the notebook of its chapter and language with the number and title of the sources and of the _book HTML, there is no leftover syntax of Quarto (:::, {#, @sec-, @eq-, @tbl-, @exr-, @fig-, book macros), no solution text, no em dash, no output, no dollar sign that is neither escaped nor part of a math span (Jupyter would pair it with a later one), no pipe table with rows of different lengths, and every notebook passes nbformat validation (a structural check when nbformat is not installed).
"""
import argparse
import html
import json
import os
import re
import sys
import urllib.parse
from collections import Counter
from dataclasses import dataclass, field

HERE = os.path.dirname(os.path.abspath(__file__))
B = os.path.dirname(os.path.dirname(HERE))
REPO = 'VadimSokolov/bayes_ai_deep_learning'
SITE = f'https://github.com/{REPO}'
RAW = f'https://raw.githubusercontent.com/{REPO}/main/'
BLOB = f'{SITE}/blob/main/'
COLAB = f'https://colab.research.google.com/github/{REPO}/blob/main/exercises/'
BADGE = 'https://colab.research.google.com/assets/colab-badge.svg'
DATA_ZIP = f'{SITE}/releases/latest/download/data.zip'
BOOK = 'Bayes, Artificial Intelligence, and Deep Learning: Foundations of Data Science'
EM = '\u2014'
DASH3 = '-' * 3

LANG_NAME = {'r': 'R', 'python': 'Python'}
KERNEL = {
    'r': ({'name': 'ir', 'display_name': 'R', 'language': 'R'},
          {'name': 'R', 'codemirror_mode': 'r', 'file_extension': '.r', 'mimetype': 'text/x-r-source', 'pygments_lexer': 'r'}),
    'python': ({'name': 'python3', 'display_name': 'Python 3', 'language': 'python'},
               {'name': 'python', 'codemirror_mode': {'name': 'ipython', 'version': 3}, 'file_extension': '.py', 'mimetype': 'text/x-python',
                'nbconvert_exporter': 'python', 'pygments_lexer': 'ipython3'}),
}
# R packages that come with R itself and are never installed
R_BASE = {'base', 'compiler', 'datasets', 'grDevices', 'graphics', 'grid', 'methods', 'parallel', 'splines', 'stats', 'stats4', 'tcltk', 'tools', 'utils'}
# Python modules that Colab has installed (googlecolab/backend-info, pip-freeze.txt, read on 19 October 2026); a module that is neither here nor in the standard library gets a %pip install
COLAB_PY = {'altair', 'arviz', 'bokeh', 'cv2', 'cvxpy', 'datasets', 'einops', 'flax', 'gym', 'gymnasium', 'h5py', 'huggingface_hub', 'jax', 'jaxlib', 'joblib', 'keras', 'lightgbm', 'lxml',
            'matplotlib', 'networkx', 'nltk', 'numba', 'numpy', 'openai', 'optax', 'pandas', 'peft', 'PIL', 'plotly', 'polars', 'pyarrow', 'pymc', 'pytensor', 'pytz', 'requests', 'scipy',
            'seaborn', 'sentence_transformers', 'sentencepiece', 'shap', 'skimage', 'sklearn', 'spacy', 'statsmodels', 'sympy', 'tensorflow', 'tensorflow_probability', 'textblob',
            'tiktoken', 'tokenizers', 'torch', 'torchaudio', 'torchvision', 'tqdm', 'transformers', 'umap', 'wordcloud', 'xgboost', 'yaml'}
PIP_NAME = {'sklearn': 'scikit-learn', 'cv2': 'opencv-python', 'PIL': 'pillow', 'yaml': 'pyyaml', 'bs4': 'beautifulsoup4', 'skimage': 'scikit-image', 'umap': 'umap-learn',
            'sentence_transformers': 'sentence-transformers', 'huggingface_hub': 'huggingface-hub', 'tensorflow_probability': 'tensorflow-probability', 'google': 'google-genai'}
STDLIB = getattr(sys, 'stdlib_module_names', {'abc', 'argparse', 'collections', 'copy', 'csv', 'dataclasses', 'datetime', 'functools', 'glob', 'gzip', 'heapq', 'itertools', 'json', 'math',
                                              'os', 'pathlib', 'pickle', 'random', 're', 'statistics', 'string', 'struct', 'sys', 'time', 'typing', 'urllib', 'zipfile'})
XREF_KINDS = ('sec', 'eq', 'tbl', 'fig', 'exr', 'exm', 'thm', 'lem', 'cor', 'prp', 'cnj', 'def', 'alg', 'lst')
XREF_RE = '|'.join(XREF_KINDS)
KEY_RE = r'[A-Za-z0-9_](?:[A-Za-z0-9_]|[:.#$%&\-+?<>~/](?=[A-Za-z0-9_]))*'

PH0, PH1 = '\ue000', '\ue001'  # placeholders of math and code spans in the text that is converted
FM0, FM1 = '\ue002', '\ue003'  # marks of a plain code fence that stays in the text


def read(path):
    with open(path, encoding='utf-8') as f:
        return f.read()


class Fail(Exception):
    pass


# ==================================================================================================== sources: chapters and exercises

@dataclass
class Exercise:
    stem: str
    number: int
    k: int
    label: str
    line: int
    section: str
    raw: list = field(default_factory=list)      # statement lines: (kind, line), kind text, open, code or close
    sol_raw: list = field(default_factory=list)  # the same for the solution
    title: str = ''
    items: list = field(default_factory=list)    # statement: ('md', [lines]) or ('code', lang, [lines])
    lang: str = None                             # r, python or None (no code)

    @property
    def where(self):
        return f'ex file of {self.stem}, line {self.line}'

    def code(self, solution=True):
        """the code of the statement chunks and, with solution, of the solution chunks, as one string"""
        parts = [''.join(l + '\n' for l in it[2]) for it in self.items if it[0] == 'code']
        if solution:
            parts += [''.join(l + '\n' for l in chunk) for chunk in chunks_of(self.sol_raw)]
        return '\n'.join(parts)

    def prose(self):
        return '\n'.join('\n'.join(it[1]) for it in self.items if it[0] == 'md')


def chunks_of(raw):
    """code of the chunks (fenced blocks) of raw lines [(kind, line)]: a list of line lists, with #| option lines dropped; and only the ones that start with {lang}"""
    out = []
    cur = None
    for kind, line in raw:
        if kind == 'open':
            cur = [] if re.match(r'^\s*[`~]{3,}\s*\{', line) else None
        elif kind == 'code' and cur is not None:
            if not line.lstrip().startswith('#|'):
                cur.append(line)
        elif kind == 'close' and cur is not None:
            out.append(trim(cur))
            cur = None
    return out


def langs_of(raw):
    out = []
    for kind, line in raw:
        if kind == 'open':
            m = re.match(r'^\s*[`~]{3,}\s*\{\s*([A-Za-z]+)', line)
            if m:
                out.append(m.group(1).lower())
    return out


def trim(lines):
    lines = [l.rstrip() for l in lines]
    while lines and not lines[0].strip():
        lines.pop(0)
    while lines and not lines[-1].strip():
        lines.pop()
    return lines


def chapter_map():
    """{exercise file: chapter stem} from the include lines of the chapter files NN-stem.qmd"""
    out = {}
    for name in sorted(os.listdir(B)):
        if re.match(r'^\d\d-[^/]*\.qmd$', name):
            for m in re.finditer(r'\{\{<\s*include\s+\./ex/(\S+?)\s*>\}\}', read(os.path.join(B, name))):
                if m.group(1) in out:
                    raise Fail(f'{m.group(1)} is included by {out[m.group(1)]} and by {name[:-4]}')
                out[m.group(1)] = name[:-4]
    return out


def chapter_title(stem):
    fence = False
    for line in read(os.path.join(B, stem + '.qmd')).split('\n'):
        if re.match(r'^\s*(```|~~~)', line):
            fence = not fence
        elif not fence:
            m = re.match(r'^#\s+(.*?)\s*$', line)
            if m:
                return re.sub(r'\s*\{[^{}]*\}\s*$', '', m.group(1)).strip()
    raise Fail(f'{stem}.qmd has no heading of level 1')


def div_kind(attrs):
    if re.search(r'#exr-', attrs):
        return 'exercise'
    if 'content-hidden' in attrs and 'showsln' in attrs:
        return 'wrapper' if 'when-format' in attrs else 'solution'
    if 'content-visible' in attrs and 'when-format' in attrs:
        return 'pointer'
    return 'other'


def parse_exercises(fname, stem):
    """all exercises of an exercise file, in order, with statement and solution lines separated. Fenced divs nest, a closing ::: closes the innermost one, colons in code are ignored."""
    path = os.path.join(B, 'ex', fname)
    number = int(stem[:2])
    stack = []
    section = None
    fence = None
    out = []
    cur = None
    for no, line in enumerate(read(path).split('\n'), 1):
        in_sol = 'solution' in stack
        if fence is not None:
            m = re.match(r'^\s*(`{3,}|~{3,})\s*$', line)
            closing = bool(m) and m.group(1)[0] == fence[0] and len(m.group(1)) >= fence[1]
            if cur is not None:
                (cur.sol_raw if in_sol else cur.raw).append(('close' if closing else 'code', line))
            if closing:
                fence = None
            continue
        m = re.match(r'^\s*(`{3,}|~{3,})', line)
        if m:
            fence = (m.group(1)[0], len(m.group(1)))
            if cur is not None:
                (cur.sol_raw if in_sol else cur.raw).append(('open', line))
            continue
        m = re.match(r'^(:{3,})\s*(.*?)\s*$', line)
        if m:
            if m.group(2):
                kind = div_kind(m.group(2))
                if kind == 'exercise':
                    if cur is not None:
                        raise Fail(f'ex/{fname}:{no}: an exercise inside an exercise')
                    if section is None:
                        raise Fail(f'ex/{fname}:{no}: an exercise before the Pen-and-Pencil or Computing heading')
                    label = re.search(r'#(exr-[A-Za-z0-9_:.\-]*)', m.group(2)).group(1)
                    cur = Exercise(stem, number, len(out) + 1, label, no, section)
                    out.append(cur)
                stack.append(kind)
            else:
                if not stack:
                    raise Fail(f'ex/{fname}:{no}: a closing ::: without an open div')
                if stack.pop() == 'exercise':
                    cur = None
            continue
        m = re.match(r'^###\s+(Pen-and-Pencil|Computing)\b', line)
        if m and cur is None:
            section = 'pen' if m.group(1).startswith('Pen') else 'comp'
            continue
        if cur is not None:
            (cur.sol_raw if in_sol else cur.raw).append(('text', line))
    if stack or fence is not None:
        raise Fail(f'ex/{fname}: unbalanced fenced divs or code fences at the end of the file')
    for ex in out:
        build_items(ex, fname)
    return out


def build_items(ex, fname):
    """split the statement into Markdown text and code chunks; take the title"""
    items = []
    md = []
    i = 0
    raw = ex.raw
    while i < len(raw):
        kind, line = raw[i]
        if kind == 'open':
            j = i + 1
            body = []
            while j < len(raw) and raw[j][0] == 'code':
                body.append(raw[j][1])
                j += 1
            if j >= len(raw) or raw[j][0] != 'close':
                raise Fail(f'ex/{fname}: unclosed code fence in {ex.label} (line {ex.line})')
            m = re.match(r'^\s*[`~]{3,}\s*\{\s*([A-Za-z]+)[^}]*\}\s*$', line)
            if m:
                if md:
                    items.append(['md', md])
                    md = []
                items.append(['code', m.group(1).lower(), trim([l for l in body if not l.lstrip().startswith('#|')])])
            else:
                md.append(FM0 + '\n'.join([line] + body + [raw[j][1]]) + FM1)
            i = j + 1
        else:
            md.append(line)
            i += 1
    if md:
        items.append(['md', md])
    # the title: the first non-blank line of the first text, ## Title
    first = items[0] if items and items[0][0] == 'md' else None
    if first is None:
        raise Fail(f'ex/{fname}: {ex.label} (line {ex.line}) has no title')
    while first[1] and not first[1][0].strip():
        first[1].pop(0)
    m = re.match(r'^##\s+(.*?)\s*$', first[1][0]) if first[1] else None
    if not m:
        raise Fail(f'ex/{fname}: {ex.label} (line {ex.line}) does not start with a ## title')
    ex.title = re.sub(r'\s*\{[#.][^{}]*\}\s*$', '', m.group(1))
    first[1].pop(0)
    ex.items = [tuple(it) for it in items]
    ex.items = [it for it in ex.items if not (it[0] == 'md' and not ''.join(it[1]).strip()) and not (it[0] == 'code' and not it[2])]
    langs = set(langs_of(ex.raw)) | set(langs_of(ex.sol_raw))
    langs &= set(LANG_NAME)
    if len(langs) > 1:
        raise Fail(f'ex/{fname}: {ex.label} (line {ex.line}) mixes languages: {sorted(langs)}')
    ex.lang = langs.pop() if langs else None


def load_sources():
    """-> (chapters {stem: dict(number, title, exfile)}, exercises [Exercise] of all sections in book order)"""
    cmap = chapter_map()
    files = sorted(f for f in os.listdir(os.path.join(B, 'ex')) if f.endswith('-ex.qmd'))
    for f in files:
        if f not in cmap:
            raise Fail(f'ex/{f} is not included by any chapter')
    chapters = {}
    exercises = []
    for f in sorted(cmap, key=lambda f: cmap[f]):
        stem = cmap[f]
        chapters[stem] = dict(number=int(stem[:2]), title=chapter_title(stem), exfile=f)
        exercises += parse_exercises(f, stem)
    return chapters, exercises


def plan(chapters, exercises):
    """computing exercises grouped into notebooks: {name: dict(stem, lang, exercises)}; also fixes the language of the exercises without code (majority of the chapter)"""
    out = {}
    for stem in chapters:
        comp = [e for e in exercises if e.stem == stem and e.section == 'comp']
        if not comp:
            continue
        count = Counter(e.lang for e in comp if e.lang)
        majority = max(sorted(count), key=lambda l: count[l]) if count else 'r'
        langs = sorted({e.lang or majority for e in comp}, key=lambda l: (l != 'r', l))
        for lang in langs:
            name = stem if len(langs) == 1 else f'{stem}-{LANG_NAME[lang]}'
            out[name] = dict(stem=stem, lang=lang, exercises=[e for e in comp if (e.lang or majority) == lang], split=len(langs) > 1)
    return out


# ==================================================================================================== numbers of the rendered book

def book_dir():
    d = os.path.join(B, '_book')
    if not os.path.isdir(d) or not any(f.endswith('.html') for f in os.listdir(d)):
        raise Fail('_book/ has no HTML: render the book (quarto render --to html) before running this script, because the numbers of sections, equations, tables and exercises come from it')
    return d


def html_text(s):
    s = re.sub(r'<span class="math inline">\\\((.*?)\\\)</span>', lambda m: '$' + html.unescape(m.group(1)) + '$', s, flags=re.S)
    s = html.unescape(re.sub(r'<[^>]+>', '', s))
    return re.sub(r'\s+', ' ', s.replace('\xa0', ' ')).strip()


def book_numbers():
    """-> (labels {label: 'Section 13.3'}, exercises {stem: [(id, 'N.k', title)]}) read from the HTML of _book/"""
    d = book_dir()
    labels = {}
    exercises = {}
    theorem = re.compile(r'<div id="((?:exr|exm|thm|lem|cor|prp|cnj|def|alg)-[^"]*)" class="theorem[^"]*">\s*<p><span class="theorem-title"><strong>(.*?)</strong>', re.S)
    for fn in sorted(os.listdir(d)):
        if not fn.endswith('.html'):
            continue
        h = read(os.path.join(d, fn))
        for m in re.finditer(r'<section id="(sec-[^"]+)" class="(level\d)[^"]*"(?: data-number="([^"]*)")?', h):
            if m.group(3):
                labels[m.group(1)] = ('Chapter ' if m.group(2) == 'level1' else 'Section ') + m.group(3)
        for m in re.finditer(r'<span id="(sec-[^"]+)" class="quarto-section-identifier">(?:<span class="chapter-number">([^<]*)</span>|Appendix ([A-Z]))', h):
            labels[m.group(1)] = 'Chapter ' + m.group(2) if m.group(2) else 'Appendix ' + m.group(3)
        for m in re.finditer(r'<span id="(eq-[^"]+)"><span class="math display">(.*?)</span></span>', h, re.S):
            t = re.search(r'\\tag\{([^}]*)\}', m.group(2))
            if t:
                labels[m.group(1)] = 'Equation ' + t.group(1)
        for m in re.finditer(r'<div id="((?:tbl|fig|lst)-[^"]+)" class="quarto-float[^"]*"[^>]*>', h):
            c = re.search(r'<figcaption[^>]*>\s*(Table|Figure|Listing)(?:&nbsp;|\s)([A-Z]?[\d.]*\d)', h[m.end():m.end() + 6000])
            if c:
                labels[m.group(1)] = f'{c.group(1)} {c.group(2)}'
        for m in theorem.finditer(h):
            t = html_text(m.group(2))
            p = re.match(r'^(\w+) ([A-Z]?[\d.]*\d)(?: \((.*)\))?$', t, re.S)
            if not p:
                raise Fail(f'_book/{fn}: cannot read the title of {m.group(1)}: {t}')
            if m.group(1) != p.group(1)[:3].lower() + '-' and not m.group(1).endswith('-'):
                labels[m.group(1)] = f'{p.group(1)} {p.group(2)}'
            if m.group(1).startswith('exr-'):
                exercises.setdefault(fn[:-5], []).append((m.group(1), p.group(2), p.group(3) or ''))
    return labels, exercises


def book_mismatches(chapters, exercises, html_ex):
    """the differences between the exercises of the sources and the ones of the rendered book (count, id, number): a list of messages. A difference means that _book/ is older than the sources, and then the numbers of the cross-references are older too"""
    out = []
    for stem in chapters:
        src = [e for e in exercises if e.stem == stem]
        h = html_ex.get(stem, [])
        if len(h) != len(src):
            out.append(f'{stem}: {len(src)} exercises in the sources, {len(h)} in _book/{stem}.html')
            continue
        for e, (hid, num, _) in zip(src, h):
            if num != f'{e.number}.{e.k}' or hid != e.label:
                out.append(f'{stem}: exercise {e.label} is {e.number}.{e.k} in the sources and {hid} {num} in _book/{stem}.html')
    return out


def stale_chapters(chapters):
    """the sources (chapter file or exercise file) that are newer than the chapter's page in _book/. The numbers of sections, equations,
    tables and examples that the cross-references take from that page may then be out of date, which book_mismatches cannot see"""
    out = []
    for stem, ch in chapters.items():
        page = os.path.join(B, '_book', f'{stem}.html')
        if not os.path.exists(page):
            continue
        for src in (f'{stem}.qmd', f'ex/{ch["exfile"]}'):
            if os.path.getmtime(os.path.join(B, src)) > os.path.getmtime(page):
                out.append(f'{src} is newer than _book/{stem}.html')
    return out


# ==================================================================================================== bibliography

def bib_entry(key):
    src = read(os.path.join(B, 'BayesBook.bib'))
    m = re.search(r'@\w+\s*\{\s*' + re.escape(key) + r'\s*,', src)
    if not m:
        raise Fail(f'citation @{key}: no entry in BayesBook.bib')
    start = src.index('{', m.start())
    body, _ = read_group(src, start)
    return body


def bib_field(entry, name):
    m = re.search(r'(?im)^\s*' + name + r'\s*=\s*', entry)
    if not m:
        return None
    i = m.end()
    if entry[i] == '{':
        return read_group(entry, i)[0]
    if entry[i] == '"':
        return entry[i + 1:entry.index('"', i + 1)]
    return re.match(r'[^,\n]*', entry[i:]).group(0).strip()


def surname(name):
    name = name.strip()
    if ',' in name:
        name = name.split(',')[0]
    elif not (name.startswith('{') and name.endswith('}')):
        name = name.split()[-1]
    name = re.sub(r'\\["\'`^~=.]\{?(\w)\}?', r'\1', name)
    return name.strip('{} ')


def author_year(key):
    """the author-year text of a key, as the book prints it in text: one to three authors by name, four or more as 'First et al.'"""
    e = bib_entry(key)
    au = bib_field(e, 'author') or bib_field(e, 'editor')
    yr = bib_field(e, 'year') or (bib_field(e, 'date') or '')[:4]
    if not au or not re.match(r'^\d{4}', yr or ''):
        raise Fail(f'citation @{key}: no author or year in BayesBook.bib')
    names = [surname(a) for a in re.split(r'\s+and\s+', re.sub(r'\s+', ' ', au))]
    if len(names) == 1:
        who = names[0]
    elif len(names) == 2:
        who = f'{names[0]} and {names[1]}'
    elif len(names) == 3:
        who = f'{names[0]}, {names[1]}, and {names[2]}'
    else:
        who = f'{names[0]} et al.'
    return who, yr[:4]


# ==================================================================================================== macros of misc/preamble.tex

def read_group(s, i, open_c='{', close_c='}'):
    """s[i] is open_c: (content, index after the closing char); backslash escapes are skipped and the other brackets nest"""
    assert s[i] == open_c
    depth = 0
    j = i
    while j < len(s):
        c = s[j]
        if c == '\\':
            j += 2
            continue
        if c == '{' and open_c != '{':
            j = read_group(s, j)[1]
            continue
        if c == open_c:
            depth += 1
        elif c == close_c:
            depth -= 1
            if depth == 0:
                return s[i + 1:j], j + 1
        j += 1
    raise Fail(f'unbalanced {open_c} in: {s[i:i + 60]}')


def read_macros():
    """{name: (number of arguments, default of the first one or None, body)} from the \\newcommand and \\DeclareMathOperator lines of misc/preamble.tex"""
    src = re.sub(r'(?m)(?<!\\)%.*$', '', read(os.path.join(B, 'misc', 'preamble.tex')))
    macros = {}
    for m in re.finditer(r'\\newcommand\s*\{\\([A-Za-z]+)\}\s*(?:\[(\d)\])?\s*(?:\[([^\]]*)\])?\s*(?=\{)', src):
        macros[m.group(1)] = (int(m.group(2) or 0), m.group(3), read_group(src, m.end())[0])
    for m in re.finditer(r'\\DeclareMathOperator(\*?)\s*\{\\([A-Za-z]+)\}\s*(?=\{)', src):
        macros[m.group(2)] = (0, None, '\\operatorname' + m.group(1) + '{' + read_group(src, m.end())[0] + '}')
    if not macros:
        raise Fail('misc/preamble.tex defines no macro')
    return macros


def expand_macros(math, macros):
    """expand the book macros in a piece of math, arguments with nested braces included"""
    out = []
    i = 0
    n = len(math)
    while i < n:
        if math[i] != '\\':
            out.append(math[i])
            i += 1
            continue
        m = re.match(r'\\([A-Za-z]+)', math[i:])
        if not m:
            out.append(math[i:i + 2])
            i += 2
            continue
        name = m.group(1)
        j = i + m.end()
        if name not in macros:
            out.append(math[i:j])
            i = j
            continue
        nargs, default, body = macros[name]
        args = []
        k = j
        if nargs:
            if default is not None:
                k2 = k
                while k2 < n and math[k2] == ' ':
                    k2 += 1
                if k2 < n and math[k2] == '[':
                    opt, k = read_group(math, k2, '[', ']')
                else:
                    opt = default
                args.append(opt)
            for _ in range(nargs - len(args)):
                while k < n and math[k] == ' ':
                    k += 1
                if k >= n:
                    raise Fail(f'\\{name} without argument in: {math[:80]}')
                if math[k] == '{':
                    a, k = read_group(math, k)
                else:
                    t = re.match(r'\\[A-Za-z]+|\\.|.', math[k:], re.S).group(0)
                    a, k = t, k + len(t)
                args.append(a)
        args = [expand_macros(a, macros) for a in args]
        for idx, a in enumerate(args, 1):
            if a == '':
                body = body.replace('_{#%d}' % idx, '')
        out.append(re.sub(r'#(\d)', lambda mm: args[int(mm.group(1)) - 1], body))
        i = k
    return ''.join(out)


# ==================================================================================================== Markdown conversion

def tokenize(text):
    """replace math and code spans by placeholders: (text, store) with store[i] = (kind, source), kind imath, dmath, code or fence. Escapes are skipped, a code span ends in the same paragraph, inline math follows the rules of Pandoc, and a dollar sign that opens no math is escaped"""
    out = []
    store = []
    i = 0
    n = len(text)

    def add(kind, s):
        store.append((kind, s))
        return PH0 + str(len(store) - 1) + PH1

    def para_end(i):
        m = re.search(r'\n[ \t]*\n', text[i:])
        return i + m.start() if m else n

    while i < n:
        c = text[i]
        if c == FM0:
            j = text.index(FM1, i)
            out.append(add('fence', text[i + 1:j]))
            i = j + 1
        elif c == '\\':
            out.append(text[i:i + 2])
            i += 2
        elif c == '`':
            j = i
            while j < n and text[j] == '`':
                j += 1
            run = j - i
            limit = para_end(i)
            k = j
            end = None
            while True:
                k = text.find('`', k, limit)
                if k < 0:
                    break
                e = k
                while e < n and text[e] == '`':
                    e += 1
                if e - k == run:
                    end = e
                    break
                k = e
            if end is None:
                out.append(text[i:j])
                i = j
            else:
                out.append(add('code', text[i:end]))
                i = end
        elif c == '$':
            if text.startswith('$$', i):
                k = i + 2
                end = -1
                while k < n - 1:
                    if text[k] == '\\':
                        k += 2
                    elif text.startswith('$$', k):
                        end = k
                        break
                    else:
                        k += 1
                if end < 0:
                    out.append('\\$\\$')  # a dollar sign that opens no math is text: escaped, so that Jupyter does not pair it with a later one
                    i += 2
                else:
                    out.append(add('dmath', text[i:end + 2]))
                    i = end + 2
                continue
            if i + 1 >= n or text[i + 1].isspace():
                out.append('\\$')
                i += 1
                continue
            limit = para_end(i)
            k = i + 1
            end = -1
            while k < limit:
                ch = text[k]
                if ch == '\\':
                    k += 2
                    continue
                if ch == '$':
                    if text[k - 1].isspace():
                        break
                    if k + 1 < n and text[k + 1].isdigit():
                        k += 1
                        continue
                    end = k
                    break
                k += 1
            if end < 0:
                out.append('\\$')
                i += 1
            else:
                out.append(add('imath', text[i:end + 1]))
                i = end + 1
        else:
            out.append(c)
            i += 1
    return ''.join(out), store


def restore(text, store, macros):
    def one(m):
        kind, s = store[int(m.group(1))]
        if kind in ('imath', 'dmath'):
            return expand_macros(s, macros)
        return s
    prev = None
    while prev != text:  # a placeholder can sit inside the source of another one (a math span in an image caption)
        prev, text = text, re.sub(PH0 + r'(\d+)' + PH1, one, text)
    return text


ORD_RE = re.compile(r'^(?P<ind> {0,3})(?P<mark>\((?P<l1>[a-z]|[ivx]+)\)|(?P<l2>[a-z]|[ivx]+)[.)])(?P<sp> +)(?P<rest>\S.*)$')
BUL_RE = re.compile(r'^(?P<ind> {0,3})(?P<mark>[-*+])(?P<sp> +)(?P<rest>\S.*)$')
ROMAN = ['i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix', 'x', 'xi', 'xii', 'xiii', 'xiv', 'xv', 'xvi', 'xvii', 'xviii', 'xix', 'xx']


def successor(label, roman):
    if label in ROMAN and (roman or len(label) > 1):
        return ROMAN[ROMAN.index(label) + 1]
    return chr(ord(label) + 1)


def indent_of(l):
    return len(l) - len(l.lstrip(' '))


def next_label(raw, state, roman, stats):
    """the label shown for an item written with label raw: a label that repeats the one of the previous item ((a) (a) (a)) counts on, as Pandoc numbers the items of a list"""
    if state and state[0] == raw:
        stats['renumbered items'] += 1
        return successor(state[1], roman)
    return raw


def label_text(m, label):
    return f'({label})' if m.group('l1') else label + m.group('mark')[-1]


def collect_item(lines, i):
    """the lines of the list item that starts at lines[i]: the following indented lines, the lines that continue it without a blank line, and what comes after blank lines when it is indented"""
    ind = indent_of(lines[i])
    n = len(lines)
    j = i + 1
    while j < n:
        l2 = lines[j]
        if not l2.strip():
            k = j
            while k < n and not lines[k].strip():
                k += 1
            if k < n and indent_of(lines[k]) >= 2 and indent_of(lines[k]) > ind:
                j = k
                continue
            break
        if indent_of(l2) <= ind and (ORD_RE.match(l2) or BUL_RE.match(l2)):
            break
        j += 1
    return lines[i:j], j


def convert_lists(lines, stats):
    """Pandoc lists of letters ((a), a), a., (i)) are not lists in Jupyter, Colab or GitHub: each item becomes a paragraph that starts with its label, the items nested under an item become bullets that carry their label, and bullet lists stay."""
    out = []
    n = len(lines)
    i = 0
    state = None  # (label as written, label shown) of the previous item of the list
    in_list = in_bullets = False

    def blank():
        if out and out[-1].strip():
            out.append('')

    while i < n:
        line = lines[i]
        mo = ORD_RE.match(line)
        if mo and (i == 0 or not lines[i - 1].strip() or in_list):
            item, j = collect_item(lines, i)
            ind = len(mo.group('ind'))
            raw = mo.group('l1') or mo.group('l2')
            label = next_label(raw, state, False, stats)
            state = (raw, label)
            blocks = [['p', [mo.group('rest').strip()]]]  # paragraphs and nested items of the body
            fresh = False
            sub = None
            for l2 in item[1:]:
                if not l2.strip():
                    fresh = True
                    continue
                s2 = l2.lstrip(' ')
                sm, sb = ORD_RE.match(s2), BUL_RE.match(s2)
                if indent_of(l2) > ind and sm:
                    sraw = sm.group('l1') or sm.group('l2')
                    slabel = next_label(sraw, sub, True, stats)
                    sub = (sraw, slabel)
                    blocks.append(['item', [f'- {label_text(sm, slabel)} {sm.group("rest").strip()}']])
                    fresh = False
                elif indent_of(l2) > ind and sb:
                    blocks.append(['item', [f'- {sb.group("rest").strip()}']])
                    fresh = False
                elif blocks[-1][0] == 'item' and not fresh:
                    blocks[-1][1].append('  ' + s2.strip())
                elif fresh:
                    blocks.append(['p', [s2.strip()]])
                    fresh = False
                else:
                    blocks[-1][1].append(s2.strip())
            blank()
            out.append(f'{label_text(mo, label)} {blocks[0][1][0]}')
            out.extend(blocks[0][1][1:])
            prev = 'p'
            for kind, ls in blocks[1:]:
                if kind == 'p' or prev != 'item':
                    out.append('')
                out.extend(ls)
                prev = kind
            out.append('')
            stats['lettered items'] += 1
            in_list = True
            in_bullets = False
            i = j
            continue
        if BUL_RE.match(line):
            if out and out[-1].strip() and not in_bullets:
                out.append('')
                if not in_list:
                    stats['bullet lists without a blank line before'] += 1
            out.append(line)
            state = None
            in_list = in_bullets = True
            i += 1
            continue
        out.append(line)
        if line.strip():
            if not (in_bullets and i > 0 and lines[i - 1].strip()):  # a line that continues a bullet item without a blank line keeps the list
                in_list = in_bullets = False
                state = None
        i += 1
    return out


def convert_tables(lines, stats):
    """pipe tables: drop a stray backtick after the last pipe, drop empty rows, write delimiter rows without three hyphens (the book never writes an em dash or its ASCII form), blank lines around"""
    out = []
    i = 0
    n = len(lines)
    while i < n:
        if not lines[i].lstrip().startswith('|'):
            out.append(lines[i])
            i += 1
            continue
        j = i
        while j < n and lines[j].lstrip().startswith('|'):
            j += 1
        rows = []
        for l in lines[i:j]:
            l = re.sub(r'(\|)[ \t]*`+[ \t]*$', r'\1', l.strip())
            cells = [c.strip() for c in re.split(r'(?<!\\)\|', l.strip().strip('|'))] if l.strip() != '|' else ['']
            rows.append(cells)
        if len(rows) < 2 or not all(re.match(r'^:?-+:?$', c) for c in rows[1]):
            raise Fail('a pipe table without a delimiter row after the header: ' + lines[i][:80])
        if out and out[-1].strip():
            out.append('')
        for r, cells in enumerate(rows):
            if r == 1:
                cells = [(':--:' if c.startswith(':') and c.endswith(':') else ':--' if c.startswith(':') else '--:' if c.endswith(':') else '--') for c in cells]
            elif r > 1 and not any(cells):
                stats['empty table rows'] += 1
                continue
            out.append('| ' + ' | '.join(cells) + ' |')
        out.append('')
        stats['tables'] += 1
        i = j
    return out


def xref_text(key, labels, where):
    if key not in labels:
        raise Fail(f'{where}: the label @{key} is not in the rendered book (_book/). Render the book again, or check the label')
    return labels[key]


def convert_inline(text, ctx):
    """cross-references, citations, images, links, attributes and typography of text in which math and code are placeholders"""
    labels, where, stats = ctx['labels'], ctx['where'], ctx['stats']

    # [@key; @key] groups
    def group(m):
        inner = m.group(1)
        if re.match(r'\]\(', text[m.end():m.end() + 2]) or False:
            return m.group(0)
        items = [s.strip() for s in inner.split(';')]
        parts = []
        kinds = set()
        for it in items:
            mm = re.match(r'^(?P<pre>.*?)(?<![A-Za-z0-9_])(?P<neg>-?)@(?P<key>' + KEY_RE + r')(?P<suf>.*)$', it)
            if not mm:
                return m.group(0)
            key = mm.group('key')
            if re.match(r'(?:' + XREF_RE + r')-', key):
                kinds.add('x')
                t = xref_text(key, labels, where)
                stats['cross-references'] += 1
                parts.append((mm.group('pre') + (t.split(' ', 1)[1] if mm.group('neg') else t) + mm.group('suf')).strip())
            else:
                kinds.add('c')
                who, yr = author_year(key)
                stats['citations'] += 1
                parts.append((mm.group('pre') + (yr if mm.group('neg') else f'{who} {yr}') + mm.group('suf')).strip())
        if kinds == {'x'}:
            return '; '.join(parts)
        if kinds == {'c'}:
            return '(' + '; '.join(parts) + ')'
        raise Fail(f'{where}: a bracket mixes cross-references and citations: {m.group(0)}')

    text = re.sub(r'\[([^\[\]]*@[^\[\]]*)\]', group, text)

    def single(m):
        key = m.group(1)
        if re.match(r'(?:' + XREF_RE + r')-', key):
            stats['cross-references'] += 1
            return xref_text(key, labels, where)
        who, yr = author_year(key)
        stats['citations'] += 1
        return f'{who} ({yr})'

    text = re.sub(r'(?<![A-Za-z0-9_@])@(' + KEY_RE + ')', single, text)

    def image(m):
        url = m.group('url')
        if not re.match(r'^[a-z][a-z0-9+.\-]*:', url):
            url = RAW + urllib.parse.quote(url.lstrip('./'))
            stats['images'] += 1
        return f'![{m.group("alt")}]({url})'

    text = re.sub(r'!\[(?P<alt>[^\]]*)\]\((?P<url>[^)\s]+)(?:\s+"[^"]*")?\)(?:\{[^{}]*\})?', image, text)

    def link(m):
        url = m.group('url')
        if not re.match(r'^([a-z][a-z0-9+.\-]*:|#)', url):
            url = BLOB + urllib.parse.quote(url.lstrip('./'))
        return f'[{m.group("t")}]({url})'

    text = re.sub(r'(?<!!)\[(?P<t>[^\[\]]+)\]\((?P<url>[^)\s]+)\)(?:\{[^{}]*\})?', link, text)
    text = re.sub(r'\[([^\[\]]*)\]\{[^{}]*\}', r'\1', text)  # a Pandoc span with attributes keeps its text
    text = re.sub(r'(?<=\w)--(?=\w)', '\u2013', text)  # Pandoc turns -- into an en dash
    text = re.sub(r'\\([\[\]()])', r'\1', text)  # escaped brackets would start math in Jupyter
    return text


def convert_md(lines, ctx, blocks=True):
    """a statement text (list of lines) as Markdown for a notebook cell"""
    text = '\n'.join(lines)
    parts = re.split('(' + FM0 + '.*?' + FM1 + ')', text, flags=re.S)
    parts[::2] = [re.sub(r'<!--.*?-->', '', re.sub(r'\{\{<.*?>\}\}', '', p, flags=re.S), flags=re.S) for p in parts[::2]]
    text = ''.join(parts)
    ptext, store = tokenize(text)
    ls = ptext.split('\n')
    if blocks:
        ls = convert_tables(ls, ctx['stats'])
        ls = convert_lists(ls, ctx['stats'])
    ptext = convert_inline('\n'.join(ls), ctx)
    text = restore(ptext, store, ctx['macros'])
    text = '\n'.join(l.rstrip() for l in text.split('\n'))
    return re.sub(r'\n{3,}', '\n\n', text).strip('\n')


# ==================================================================================================== notebooks

def r_packages(code):
    """the packages that R code needs: library(x), require(x) and x::f. A package that the code only probes with requireNamespace(), as an optional one with a fallback, is not installed"""
    pk = set(re.findall(r'\b(?:library|require)\(\s*["\']?([A-Za-z][A-Za-z0-9.]*)', code))
    pk |= set(re.findall(r'\b([A-Za-z][A-Za-z0-9.]*)::', code))
    return sorted(pk - R_BASE, key=str.lower)


def r_prose_packages(text):
    """the R packages that the text of a statement names as "`x` package" or "package `x`" (a hint such as "use dskellam of the `skellam` package")"""
    pk = set(re.findall(r'`([A-Za-z][A-Za-z0-9.]*)`\s+package', text)) | set(re.findall(r'\bpackage\s+`([A-Za-z][A-Za-z0-9.]*)`', text))
    return sorted(pk - R_BASE, key=str.lower)


def py_modules(code):
    mods = set()
    for m in re.finditer(r'^[ \t]*import\s+([^\n#]+)', code, re.M):
        for part in m.group(1).split(','):
            mods.add(part.strip().split()[0].split('.')[0])
    for m in re.finditer(r'^[ \t]*from\s+([A-Za-z_][A-Za-z0-9_.]*)\s+import', code, re.M):
        mods.add(m.group(1).split('.')[0])
    return sorted(m for m in mods if m and m not in STDLIB and m != '__future__')


def data_files(text):
    return sorted(set(re.findall(r'(?<![\w/.])data/([A-Za-z0-9_][A-Za-z0-9_.\-]*)', text)))


def wrap_words(words, width=88, indent='  '):
    lines = []
    cur = ''
    for w in words:
        if cur and len(cur) + len(w) + 1 > width:
            lines.append(cur)
            cur = ''
        cur += w if not cur else ' ' + w
    if cur:
        lines.append(cur)
    return ('\n' + indent).join(lines)


def setup_cell(lang, exercises):
    """the source of the setup code cell and the data files that the exercises read"""
    files = data_files('\n'.join(e.code(True) + '\n' + e.prose() for e in exercises))
    src = []
    if lang == 'r':
        # the packages of the code of the statements and solutions, and the ones that the statements name (library(x), x:: or "`x` package" in the text)
        pk = sorted({p for e in exercises for p in r_packages(e.code(True)) + r_packages(e.prose()) + r_prose_packages(e.prose())}, key=str.lower)
        if pk:
            src += ['# Packages that the exercises of this notebook use; the ones that are missing are installed',
                    'pkgs <- c(' + wrap_words(['"' + p + '",' for p in pk]).rstrip(',') + ')',
                    'new <- setdiff(pkgs, rownames(installed.packages()))',
                    'if (length(new) > 0) install.packages(new, repos = "https://cloud.r-project.org")']
        else:
            src += ['# The exercises of this notebook need no package besides base R']
        if files:
            src += ['', '# The exercises read files from data/: download the datasets of the book once',
                    'if (!dir.exists("data")) {',
                    '  options(timeout = max(3600, getOption("timeout")))',
                    f'  download.file("{DATA_ZIP}", "data.zip", mode = "wb")',
                    '  unzip("data.zip")',
                    '  unlink("data.zip")',
                    '}']
    else:
        mods = sorted({m for e in exercises for m in py_modules(e.code(True))})
        need = [m for m in mods if m not in COLAB_PY]
        if not mods:
            src += ['# The exercises of this notebook need no module besides the standard library']
        elif need:
            src += ['# Modules that the exercises of this notebook use: ' + ', '.join(mods) + '. Colab lacks: ' + ', '.join(need),
                    '%pip install -q ' + ' '.join(PIP_NAME.get(m, m) for m in need)]
        else:
            src += ['# Modules that the exercises of this notebook use: ' + ', '.join(mods) + ' (all installed on Colab)']
        if files:
            src += ['', '# The exercises read files from data/: download the datasets of the book once',
                    'import os', 'import urllib.request', 'import zipfile', '',
                    'if not os.path.exists("data"):',
                    f'    urllib.request.urlretrieve("{DATA_ZIP}", "data.zip")',
                    '    zipfile.ZipFile("data.zip").extractall()',
                    '    os.remove("data.zip")']
    return '\n'.join(src), files


def lines_of(text):
    return text.splitlines(True)


def md_cell(cid, text):
    return {'cell_type': 'markdown', 'id': cid, 'metadata': {}, 'source': lines_of(text)}


def code_cell(cid, text):
    return {'cell_type': 'code', 'execution_count': None, 'id': cid, 'metadata': {}, 'outputs': [], 'source': lines_of(text)}


def format_numbers(numbers):
    """['3.6', '3.7', '3.8', '3.10'] as '3.6 to 3.8, 3.10'"""
    pairs = [tuple(int(x) for x in n.split('.')) for n in numbers]
    out = []
    i = 0
    while i < len(pairs):
        j = i
        while j + 1 < len(pairs) and pairs[j + 1] == (pairs[j][0], pairs[j][1] + 1):
            j += 1
        if j - i >= 2:
            out.append(f'{numbers[i]} to {numbers[j]}')
        else:
            out += numbers[i:j + 1]
        i = j + 1
    return ', '.join(out)


def build(chapters, groups, labels, macros, stats):
    """-> {name: notebook dict}, plus an info dict per notebook"""
    notebooks = {}
    info = {}
    for name, g in groups.items():
        stem, lang, exs = g['stem'], g['lang'], g['exercises']
        ch = chapters[stem]
        cells = []
        head = f'# Chapter {ch["number"]}: {ch["title"]}. Computing exercises'
        link = f'{COLAB}{name}.ipynb'
        intro = [head, '',
                 f'These exercises are from *{BOOK}* by Nick Polson and Vadim Sokolov, <{SITE}>. The text is licensed under CC BY 4.0 and the code under the MIT License.']
        code = [f'[`code/{stem}.{e}`]({BLOB}code/{stem}.{e})' for e in ('R', 'py') if os.path.exists(os.path.join(B, 'code', f'{stem}.{e}'))]
        if code:
            intro += ['', f'The code of the chapter, which several exercises refer to, is in {" and ".join(code)}.']
        if g['split']:
            other = 'Python' if lang == 'r' else 'R'
            intro += ['', f'This notebook holds the exercises of the chapter that use {LANG_NAME[lang]}; the ones that use {other} are in [`{stem}-{other}.ipynb`]({COLAB}{stem}-{other}.ipynb).']
        intro += ['', f'[![Open In Colab]({BADGE})]({link})']
        cells.append(md_cell('intro', '\n'.join(intro)))
        setup, files = setup_cell(lang, exs)
        cells.append(code_cell('setup', setup))
        for ex in exs:
            ctx = dict(labels=labels, macros=macros, stats=stats, where=f'ex/{ch["exfile"]}, exercise {ex.label} (line {ex.line})')
            title = convert_md([ex.title], ctx, blocks=False)
            cid = f'ex{ex.number}-{ex.k}'
            pending = [f'## Exercise {ex.number}.{ex.k}: {title}']
            n = 0
            for it in ex.items:
                if it[0] == 'md':
                    text = convert_md(it[1], ctx)
                    if text:
                        pending.append(text)
                else:
                    if pending:
                        cells.append(md_cell(f'{cid}-{n}', '\n\n'.join(pending)))
                        n += 1
                        pending = []
                    cells.append(code_cell(f'{cid}-{n}', '\n'.join(it[2])))
                    stats['code cells'] += 1
                    n += 1
            if pending:
                cells.append(md_cell(f'{cid}-{n}', '\n\n'.join(pending)))
            cells.append(code_cell(f'{cid}-answer', ''))
        kernel, lang_info = KERNEL[lang]
        notebooks[name] = {'cells': cells, 'metadata': {'kernelspec': kernel, 'language_info': lang_info}, 'nbformat': 4, 'nbformat_minor': 5}
        info[name] = dict(stem=stem, number=ch['number'], title=ch['title'], lang=lang, numbers=[f'{e.number}.{e.k}' for e in exs], data=files)
    return notebooks, info


def readme(info):
    rows = []
    for name, d in info.items():
        rows.append(f'| {d["number"]} | [{name}.ipynb]({name}.ipynb) | {LANG_NAME[d["lang"]]} | {len(d["numbers"])}: {format_numbers(d["numbers"])} | [![Open In Colab]({BADGE})]({COLAB}{name}.ipynb) |')
    total = sum(len(d['numbers']) for d in info.values())
    text = f"""# Computing exercises

The computing exercises of *{BOOK}* by Nick Polson and Vadim Sokolov, <{SITE}>, as Jupyter notebooks, one per chapter and language. The printed book holds the pen-and-pencil exercises and points here for the computing ones. {total} exercises in {len(info)} notebooks.

Each notebook opens in Google Colab with its badge, and also runs in Jupyter (the R notebooks need the R kernel, IRkernel). The first code cell installs the R packages that the exercises use, or lists the Python modules, and downloads `data.zip` of the latest release of the book when an exercise reads files from `data/`. Then every exercise has its statement as in the book, the starter code that the book gives, and an empty code cell for your answer. The exercises are numbered as in the HTML version of the book: Exercise 8.6 is the sixth exercise of Chapter 8, counting the pen-and-pencil ones first.

The solutions are not included.

| Chapter | Notebook | Language | Exercises | Colab |
|:--|:--|:--|:--|:--|
""" + '\n'.join(rows) + f"""

The notebooks are generated by `misc/catalog/notebooks.py` from the exercise files `ex/*.qmd`, so do not edit them by hand: change the exercise file and run the script again. The script reads the numbers of sections, equations, tables, examples and exercises from the rendered book, so it has to run again after the final render of the book, because the numbers change when content is cut or moved.

The text of the notebooks is licensed under CC BY 4.0 and the code under the MIT License, as the book.
"""
    return text


def write_all(out_dir, notebooks, info):
    os.makedirs(out_dir, exist_ok=True)
    removed = []
    for f in sorted(os.listdir(out_dir)):
        if re.match(r'^\d\d-.*\.ipynb$', f) and f[:-6] not in notebooks:
            os.remove(os.path.join(out_dir, f))
            removed.append(f)
    for name, nb in notebooks.items():
        with open(os.path.join(out_dir, name + '.ipynb'), 'w', encoding='utf-8') as f:
            f.write(json.dumps(nb, indent=1, sort_keys=True, ensure_ascii=False) + '\n')
    with open(os.path.join(out_dir, 'README.md'), 'w', encoding='utf-8') as f:
        f.write(readme(info))
    return removed


# ==================================================================================================== check

LEFTOVER = [(':::', r':::'), ('{#', r'\{#'), ('a cross-reference', r'(?<![A-Za-z0-9_])@(?:' + XREF_RE + r')-'), ('a citation', r'(?<![A-Za-z0-9_$\\`])@[A-Za-z_]'),
            ('a shortcode', r'\{\{<'), ('an HTML comment', r'<!--'), ('a Pandoc attribute', r'\{[.#][A-Za-z]|\{width|\{height|\{fig-'), ('a fence of Quarto', r'^\s*```\s*\{')]
MACRO_LEFT = r'\\(?:{})(?![A-Za-z])'


def stray_dollars(text):
    """True when a Markdown cell holds a dollar sign that is neither escaped nor part of a math span: Jupyter would pair it with a later one and set the text in between as math"""
    text = re.sub(r'(?ms)^(?P<f>`{3,}|~{3,}).*?^(?P=f)[ \t]*$', lambda m: FM0 + m.group(0) + FM1, text)  # a code fence is left alone
    ptext, store = tokenize(text)
    return restore(ptext, store, {}) != text


def table_problems(text):
    """the pipe tables of a Markdown cell that Jupyter would not show as tables: a delimiter row that is not one, a row with another number of cells than the header, or no blank line before the table"""
    text = re.sub(r'(?ms)^(?P<f>`{3,}|~{3,}).*?^(?P=f)[ \t]*$', lambda m: FM0 + m.group(0) + FM1, text)
    ls = tokenize(text)[0].split('\n')
    probs = []
    i = 0
    while i < len(ls):
        if not ls[i].lstrip().startswith('|'):
            i += 1
            continue
        j = i
        while j < len(ls) and ls[j].lstrip().startswith('|'):
            j += 1
        rows = [[c.strip() for c in re.split(r'(?<!\\)\|', l.strip()[1:-1] if l.strip().endswith('|') else l.strip()[1:])] for l in ls[i:j]]
        if i > 0 and ls[i - 1].strip():
            probs.append('a table without a blank line before it')
        if len(rows) < 2 or not all(re.match(r'^:?-+:?$', c) for c in rows[1]):
            probs.append('a table without a delimiter row')
        if any(len(r) != len(rows[0]) for r in rows):
            probs.append('a table with rows of different lengths')
        i = j
    return probs


def validate(nb, name):
    """nbformat validation, or a structural check when nbformat is not installed; -> list of problems"""
    try:
        import nbformat
    except ImportError:
        nbformat = None
    probs = []
    if nbformat is not None:
        try:
            nbformat.validate(nbformat.from_dict(nb))
        except Exception as e:  # noqa: BLE001
            probs.append(f'{name}: nbformat validation failed: {str(e).splitlines()[0][:160]}')
        return probs
    if nb.get('nbformat') != 4 or not isinstance(nb.get('cells'), list) or 'metadata' not in nb:
        probs.append(f'{name}: not a notebook of format 4')
    for i, c in enumerate(nb.get('cells', [])):
        if c.get('cell_type') not in ('markdown', 'code') or 'source' not in c or 'metadata' not in c:
            probs.append(f'{name}: cell {i} has no type, source or metadata')
        if c.get('cell_type') == 'code' and ('outputs' not in c or 'execution_count' not in c):
            probs.append(f'{name}: code cell {i} has no outputs or execution_count')
    return probs


def norm_title(t):
    t = html.unescape(t).replace('\u2019', "'").replace('\u2018', "'").replace('\u201c', '"').replace('\u201d', '"').replace('\u2013', '--').replace('\xa0', ' ')
    return re.sub(r'\s+', ' ', t).strip()


def check(out_dir):
    probs = []
    notes = []
    chapters, exercises = load_sources()
    probs += [f'{m}: render the book again before the notebooks are published' for m in stale_chapters(chapters)]
    labels, html_ex = book_numbers()
    macros = read_macros()
    groups = plan(chapters, exercises)
    comp = [e for e in exercises if e.section == 'comp']
    # the number of computing exercises, counted independently of the div parser
    n_lines = 0
    for f in sorted(os.listdir(os.path.join(B, 'ex'))):
        if f.endswith('-ex.qmd'):
            txt = read(os.path.join(B, 'ex', f))
            n_lines += len(re.findall(r'(?m)^:{3,}[ \t]*\{#exr-', txt.split('### Computing', 1)[1])) if '### Computing' in txt else 0
    if n_lines != len(comp):
        probs.append(f'the parser found {len(comp)} computing exercises but the exercise files hold {n_lines} #exr- divs after their Computing heading')
    # the numbers of the exercises in the sources against the HTML of the book
    probs += book_mismatches(chapters, exercises, html_ex)
    html_title = {}
    for stem in chapters:
        src = [e for e in exercises if e.stem == stem]
        h = html_ex.get(stem, [])
        if len(h) != len(src):
            continue
        for e, (hid, num, ttl) in zip(src, h):
            html_title[(e.number, e.k)] = ttl
            ctx = dict(labels=labels, macros=macros, stats=Counter(), where=e.where)
            if norm_title(expand_macros(ttl, macros)) != norm_title(convert_md([e.title], ctx, blocks=False)).replace('\u2013', '--') and \
                    norm_title(expand_macros(ttl, macros)) != norm_title(convert_md([e.title], ctx, blocks=False)):
                probs.append(f'{stem}: the title of exercise {e.number}.{e.k} is "{e.title}" in the sources and "{ttl}" in the book')
    # the notebooks
    found = sorted(f[:-6] for f in os.listdir(out_dir) if re.match(r'^\d\d-.*\.ipynb$', f)) if os.path.isdir(out_dir) else []
    if found != sorted(groups):
        probs.append(f'notebooks on disk {sorted(set(found) - set(groups))} are not expected, and {sorted(set(groups) - set(found))} are missing')
    all_heads = []
    ctxn = dict(labels=labels, macros=macros, stats=Counter(), where='check')
    macro_re = re.compile(MACRO_LEFT.format('|'.join(map(re.escape, macros))))
    for name in sorted(set(found) & set(groups)):
        g = groups[name]
        path = os.path.join(out_dir, name + '.ipynb')
        raw = read(path)
        try:
            nb = json.loads(raw)
        except ValueError as e:
            probs.append(f'{name}: not JSON: {e}')
            continue
        probs += validate(nb, name)
        kernel = KERNEL[g['lang']][0]
        if nb.get('metadata', {}).get('kernelspec') != kernel:
            probs.append(f'{name}: kernelspec is not {kernel}')
        cells = nb['cells']
        text_of = lambda c: ''.join(c['source']) if isinstance(c['source'], list) else c['source']  # noqa: E731
        if len(cells) < 3 or cells[0]['cell_type'] != 'markdown' or cells[1]['cell_type'] != 'code':
            probs.append(f'{name}: the notebook does not start with a title cell and a setup cell')
        else:
            ch = chapters[g['stem']]
            t0 = text_of(cells[0])
            if not t0.startswith(f'# Chapter {ch["number"]}: {ch["title"]}. Computing exercises\n'):
                probs.append(f'{name}: wrong title cell')
            for must in (f'{COLAB}{name}.ipynb', BOOK, 'Nick Polson and Vadim Sokolov', 'CC BY 4.0', 'MIT License', SITE):
                if must not in t0:
                    probs.append(f'{name}: the title cell lacks {must}')
            s1 = text_of(cells[1])
            wants_data = bool(data_files('\n'.join(e.code(True) + '\n' + e.prose() for e in g['exercises'])))
            if wants_data != (DATA_ZIP in s1) or ('data/' in s1 and wants_data and 'dir.exists("data")' not in s1 and 'os.path.exists("data")' not in s1):
                probs.append(f'{name}: the setup cell and the use of data/ do not agree')
        heads = []
        stmt_all = set()
        for e in g['exercises']:
            stmt_all |= {l.strip() for it in e.items if it[0] == 'md' for l in it[1]} | {l.strip() for it in e.items if it[0] == 'code' for l in it[2]}
        solution_lines = set()
        for e in g['exercises']:
            for kind, l in e.sol_raw:
                s_ = l.strip()
                if len(re.sub(r'[^A-Za-z0-9]', '', s_)) >= 15 and s_ not in stmt_all:
                    solution_lines.add(s_)
        for i, c in enumerate(cells):
            t = text_of(c)
            if c['cell_type'] == 'code' and (c.get('outputs') or c.get('execution_count') is not None):
                probs.append(f'{name}: code cell {i} has output or an execution count')
            if EM in t or DASH3 in t:
                probs.append(f'{name}: cell {i} has an em dash or {DASH3}')
            if c['cell_type'] == 'markdown':
                m = re.match(r'^## Exercise (\d+)\.(\d+): (.*)', t)
                if m:
                    heads.append((int(m.group(1)), int(m.group(2)), m.group(3).strip()))
                ptext, _ = tokenize(t)
                for what, rx in LEFTOVER:
                    if re.search(rx, ptext, re.M):
                        probs.append(f'{name}: cell {i} has {what} left')
                if macro_re.search(t):
                    probs.append(f'{name}: cell {i} has a book macro left')
                if stray_dollars(t):
                    probs.append(f'{name}: cell {i} has a dollar sign that is neither escaped nor part of math')
                for what in table_problems(t):
                    probs.append(f'{name}: cell {i} has {what}')
                if re.search(r'\*\*Solution|Solution\*\*|^Solution:', t, re.M):
                    probs.append(f'{name}: cell {i} has a solution')
                for im in re.findall(r'!\[[^\]]*\]\(([^)\s]+)\)', t):
                    if im.startswith(RAW):
                        p = os.path.join(B, urllib.parse.unquote(im[len(RAW):]))
                        if not os.path.exists(p):
                            probs.append(f'{name}: image {im} is not in the repository')
                    elif not im.startswith('http'):
                        probs.append(f'{name}: image {im} is not an URL')
            else:
                for what, rx in LEFTOVER[2:4]:
                    if re.search(rx, t) and what == 'a cross-reference':
                        probs.append(f'{name}: code cell {i} has {what} left')
            for ln in t.split('\n'):
                if ln.strip() in solution_lines:
                    probs.append(f'{name}: cell {i} holds a line of a solution: {ln.strip()[:70]}')
        want = [(e.number, e.k, convert_md([e.title], ctxn, blocks=False)) for e in g['exercises']]
        if heads != want:
            probs.append(f'{name}: exercise headings differ from the sources: {sorted(set(heads) ^ set(want))[:3]}')
        for (n, k, t) in heads:
            if (n, k) not in html_title:
                probs.append(f'{name}: Exercise {n}.{k} is not in the book')
        all_heads += heads
        if not cells[-1]['cell_type'] == 'code' or text_of(cells[-1]) != '':
            probs.append(f'{name}: the last cell is not an empty answer cell')
        n_answers = sum(1 for c in cells if c['cell_type'] == 'code' and text_of(c) == '' and c['id'].endswith('-answer'))
        if n_answers != len(g['exercises']):
            probs.append(f'{name}: {n_answers} answer cells for {len(g["exercises"])} exercises')
    if len(all_heads) != len(comp) or len(set((n, k) for n, k, _ in all_heads)) != len(comp):
        probs.append(f'{len(all_heads)} exercises in the notebooks ({len(set((n, k) for n, k, _ in all_heads))} different) but {len(comp)} computing exercises in the sources')
    # README
    rp = os.path.join(out_dir, 'README.md')
    if not os.path.exists(rp):
        probs.append('README.md is missing')
    else:
        r = read(rp)
        if EM in r or DASH3 in r:
            probs.append(f'README.md has an em dash or {DASH3}')
        for name in groups:
            if f'[{name}.ipynb]({name}.ipynb)' not in r:
                probs.append(f'README.md does not list {name}')
        if 'solutions are not included' not in r or 'misc/catalog/notebooks.py' not in r:
            probs.append('README.md lacks the note on solutions or on the generator')
    # the data files that the exercises read must exist
    dd = os.path.join(B, 'data')
    if os.path.isdir(dd):
        for name, g in groups.items():
            for f in data_files('\n'.join(e.code(True) + '\n' + e.prose() for e in g['exercises'])):
                if not os.path.exists(os.path.join(dd, f)):
                    notes.append(f'{name} reads data/{f}, which is not in data/')
    return probs, notes, len(all_heads), len(found)


def main():
    ap = argparse.ArgumentParser(description='Write the computing exercises of the book as Jupyter notebooks (exercises/*.ipynb) and exercises/README.md')
    ap.add_argument('--out-dir', default=os.path.join(B, 'exercises'))
    ap.add_argument('--check', action='store_true', help='verify the notebooks against the sources and the rendered book; write nothing')
    a = ap.parse_args()
    try:
        if a.check:
            probs, notes, n_ex, n_nb = check(a.out_dir)
            for p in probs:
                print('PROBLEM', p)
            for n in notes:
                print('NOTE', n)
            print(f'{n_nb} notebooks, {n_ex} exercises checked; {len(probs)} problems')
            sys.exit(1 if probs else 0)
        chapters, exercises = load_sources()
        labels, html_ex = book_numbers()
        for msg in book_mismatches(chapters, exercises, html_ex):
            print('WARNING _book/ is older than the exercise files, render the book again:', msg)
        for msg in stale_chapters(chapters):
            print('WARNING render the book again before the notebooks are published:', msg)
        macros = read_macros()
        groups = plan(chapters, exercises)
        stats = Counter()
        notebooks, info = build(chapters, groups, labels, macros, stats)
        removed = write_all(a.out_dir, notebooks, info)
    except Fail as e:
        print('ERROR', e)
        sys.exit(2)
    langs = Counter()
    for g in groups.values():
        for e in g['exercises']:
            langs[(e.lang or 'none')] += 1
    n_ex = sum(len(g['exercises']) for g in groups.values())
    print(f'{len(notebooks)} notebooks and README.md written to {os.path.relpath(a.out_dir, B)}; {n_ex} exercises (' + ', '.join(f'{v} {LANG_NAME.get(k, "without code")}' for k, v in sorted(langs.items())) + ')')
    print(', '.join(f'{v} {k}' for k, v in sorted(stats.items())))
    if removed:
        print('removed old notebooks: ' + ', '.join(removed))


if __name__ == '__main__':
    main()
