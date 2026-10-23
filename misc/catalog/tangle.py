#!/usr/bin/env python3
"""Write the code of a chapter as stand-alone files, one per language: code/NN-topic.R and code/NN-topic.py.

  tangle.py STEM [--out-dir code] [--solutions-dir DIR] [--check]
  tangle.py --all [--out-dir code] [--solutions-dir DIR] [--check]

All executable chunks of the chapter, in book order, hidden ones included. A chunk that the book does not run (eval: false) is commented out, as knitr::purl() does, so that the file runs
from top to bottom. Two exceptions stay active: a chunk whose output the book shows from results/ (the display chunk after it calls cached_fig, cached_text or cached_md), which is the
computation behind the stored output, and a chunk that defines names an active chunk after it uses and no active chunk before that one defines (for example the chunk that loads the
model which the cached chunks need). Chunks inside showsln solution divs (the exercise solutions, which the
printed book does not show) are not written to the public folder; with --solutions-dir they go to STEM-solutions.R / .py there. The setup chunk of misc/common.qmd is
replaced by `source("code/common.R")` in the R file. Files are meant to be run from the book folder, and read their data from data/.
--check parses every file it writes (R with parse(), Python with ast).
"""
import argparse
import ast
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, 'chunks'))
import chunkdeps as cd  # noqa: E402
import chunkmap as cm  # noqa: E402

B = cm.B
STEMS = ['00-intro', '01-prob', '02-bayes', '03-bl', '04-dec', '05-ab', '06-hyp', '07-sp', '08-gp', '09-rl', '10-data', '11-pattern', '12-regression', '13-logistic',
         '14-tree', '15-forecasting', '16-select', '17-theoryai', '18-nn', '19-theorydl', '20-sgd', '21-qnn', '22-cnn', '23-nlp', '24-llm', '25-robots', 'appendix-linalg']


def title_of(stem):
    for l in open(os.path.join(B, stem + '.qmd'), encoding='utf-8'):
        m = re.match(r'^#\s+(.*?)(\s*\{.*\})?\s*$', l)
        if m:
            return m.group(1).strip()
    return stem


def packages(code, lang):
    out = set()
    if lang == 'r':
        out |= set(re.findall(r'(?:library|require)\(\s*["\']?([A-Za-z][A-Za-z0-9.]*)', code))
        out |= set(re.findall(r'\b([A-Za-z][A-Za-z0-9.]+)::', code))
    else:
        out |= set(m.split('.')[0] for m in re.findall(r'^\s*import\s+([A-Za-z_][A-Za-z0-9_.]*)', code, re.M))
        out |= set(m.split('.')[0] for m in re.findall(r'^\s*from\s+([A-Za-z_][A-Za-z0-9_.]*)\s+import', code, re.M))
    return out


def is_false(v):
    return v is not None and str(v).strip().strip('"\'') in ('false', 'F', 'FALSE', 'no', 'False')


def cached_names(all_chunks, group):
    """for a chunk that is not run (eval false), the results/ files that the display chunk after it shows: {id(chunk): 'STEM/NAME-*'}"""
    out = {}
    for i, c in enumerate(all_chunks):
        if not is_false(c['opts'].get('purl')):
            continue
        names = re.findall(r'cached_(?:fig|text|md)\(\s*["\']([^"\']+)["\']', c['code'])
        if not names:
            continue
        j = i - 1
        while j >= 0 and not (all_chunks[j] in group):
            j -= 1
        if j >= 0:
            out[id(all_chunks[j])] = ', '.join(f'{n}-*' for n in dict.fromkeys(names))
    return out


def needed_inactive(group, cached, deps):
    """the chunks that the book does not run, with no stored output, but that the file needs: ids of the chunks that define a name an active chunk after them uses
    when no active chunk before that use defines it (repeated, because a chunk brought back can use names of an earlier one)"""
    def dep(c):
        return deps.get((c['file'], c['line']), {})
    active = {id(c) for c in group if not is_false(c['opts'].get('eval')) or id(c) in cached}
    needed = set()
    changed = True
    while changed:
        changed = False
        defined = set()
        for k, c in enumerate(group):
            if id(c) not in active:
                continue
            if any(id(e) in active and dep(e).get('loads') for e in group[:k + 1]):
                defined |= set(dep(c).get('defs', []))
                continue  # a load() of an .RData file may bring the objects: not decidable here (as in chunkdeps.py check)
            for name in sorted(set(dep(c).get('uses', [])) - defined):
                for e in reversed(group[:k]):
                    if id(e) not in active and name in dep(e).get('defs', []):
                        active.add(id(e))
                        needed.add(id(e))
                        changed = True
                        break
            defined |= set(dep(c).get('defs', []))
    return needed


def cross_language(stem, lang, code, body):
    """a note when the chunks of this language use objects of the chunks of the other language (reticulate: py$x in R, r.x in Python)"""
    if lang == 'r':
        names = sorted(set(re.findall(r'\bpy\$([A-Za-z_]\w*)', code)))
        if names:
            return f'# Uses objects made by the Python code of the chapter (py$): ' + ', '.join(names) + f'. Run code/{stem}.py first or through reticulate.'
    else:
        r_code = '\n'.join(c['code'] for c in body['r'])
        names = sorted(n for n in set(re.findall(r'\br\.([A-Za-z_]\w*)', code)) if re.search(r'(^|\n)\s*' + re.escape(n) + r'\s*(<-|=)', r_code))
        if names:
            return f'# Uses objects made by the R code of the chapter (r.): ' + ', '.join(names) + f'. Run code/{stem}.R first or through reticulate.'
    return ''


def tangle(stem, out_dir, sol_dir):
    chunks = [c for c in cm.chunks_of(cm.expand('WORKTREE', f'{stem}.qmd')) if not c['file'].endswith('common.qmd')]
    all_chunks = chunks
    sols = {}
    body = {'r': [], 'python': []}
    solution = {'r': [], 'python': []}
    for c in chunks:
        f = c['file']
        if f not in sols:
            sols[f] = cm.solution_ranges(f)
        is_sol = any(a <= c['line'] <= b for a, b in sols[f])
        (solution if is_sol else body)[c['lang'].lower()].append(c)
    deps = {(it['file'], it['line']): it['deps'] for it in cd.analyze([i for i in cd.doc_items(stem) if i['kind'] == 'chunk'])}
    written = []
    title = title_of(stem)
    for lang, ext in (('r', 'R'), ('python', 'py')):
        for kind, group, d in (('body', body[lang], out_dir), ('solutions', solution[lang], sol_dir)):
            if not group or not d:
                continue
            code_all = '\n'.join(c['code'] for c in group)
            data = sorted(set(re.findall(r'["\'](data/[A-Za-z0-9_./\-^+]+)["\']', code_all)))
            pk = sorted(p for p in packages(code_all, lang) - {'base', 'stats', 'utils', 'graphics', 'methods', 'grDevices', 'datasets'}
                        if not os.path.exists(os.path.join(B, 'code', p + '.py')))
            cmt = '#'
            name = f'{stem}.{ext}' if kind == 'body' else f'{stem}-solutions.{ext}'
            lines = [f'{cmt} {"Code of chapter" if kind == "body" else "Solution code of the exercises of chapter"}: {title}',
                     f'{cmt} Every {"R" if lang == "r" else "Python"} chunk of the chapter in book order, including the ones the book does not print. Chunks the book does not run are commented out.',
                     f'{cmt} Run from the book folder{": " + ("Rscript code/" if lang == "r" else "python code/") + name if kind == "body" else ""}. Data are read from the data folder.'
                     + (' Figures go to the graphics device (Rplots.pdf under Rscript).' if lang == 'r' else '')]
            if data:
                lines.append(f'{cmt} Data: ' + ', '.join(data))
            if pk:
                lines.append(f'{cmt} Packages: ' + ', '.join(pk))
            other = cross_language(stem, lang, code_all, body)
            if other:
                lines.append(other)
            lines.append('')
            if lang == 'r':
                lines += ['source("code/common.R")', '']
            last_head = None
            group = [c for c in group if not is_false(c['opts'].get('purl'))]
            cached = cached_names(all_chunks, group)
            needed = needed_inactive(group, cached, deps)
            for c in group:
                if c['heading'] != last_head:
                    h = re.sub(r'\s*\{.*\}\s*$', '', c['heading']).lstrip('# ').strip()
                    lines += [f'{cmt} ---- {h} ' + '-' * max(4, 70 - len(h)), '']
                    last_head = c['heading']
                tag = f"{cmt} [{c['label']}]" if c['label'] else None
                if tag:
                    lines.append(tag)
                code = c['code'].strip('\n')
                if is_false(c['opts'].get('eval')):
                    where = cached.get(id(c))
                    if where:
                        why = f'its output is kept in results/{where}'
                    elif id(c) in needed:
                        why = 'it has no output in the book, and it stays active here because the chunks after it use what it defines'
                    else:
                        why = 'it has no output in the book, and it is commented out here: remove the comment marks to run it'
                    lines.append(f'{cmt} (the book does not run this chunk when it builds; {why})')
                    if not where and id(c) not in needed:
                        code = '\n'.join(f'{cmt} {l}' if l.strip() else '' for l in code.split('\n'))
                lines.append(code)
                lines.append('')
            text = '\n'.join(lines).rstrip('\n') + '\n'
            d_out = d
            os.makedirs(d_out, exist_ok=True)
            path = os.path.join(d_out, name)
            open(path, 'w', encoding='utf-8').write(text)
            written.append(path)
    return written


def check(path):
    if path.endswith('.py'):
        try:
            ast.parse(open(path, encoding='utf-8').read())
            return True, ''
        except SyntaxError as e:
            return False, f'{e.msg} line {e.lineno}'
    r = subprocess.run(['Rscript', '-e', f'invisible(parse(file="{path}"))'], capture_output=True, text=True)
    return r.returncode == 0, (r.stderr.strip().splitlines() or [''])[-1][:160]


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('stem', nargs='?')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--out-dir', default=os.path.join(B, 'code'))
    ap.add_argument('--solutions-dir', default='')
    ap.add_argument('--check', action='store_true')
    a = ap.parse_args()
    stems = STEMS if a.all else [a.stem]
    bad = 0
    n = 0
    for s in stems:
        for p in tangle(s, a.out_dir, a.solutions_dir):
            n += 1
            if a.check:
                ok, msg = check(p)
                if not ok:
                    bad += 1
                    print(f'SYNTAX {os.path.relpath(p, B)}: {msg}')
    print(f'{n} files written; {bad} with syntax errors' if a.check else f'{n} files written')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
