#!/usr/bin/env python3
"""Which chunk needs which earlier chunk, found statically (nothing is run), and the checks the code chunk work relies on.

  chunkdeps.py deps STEM                       table of chunks (in book order) with the names they define and the earlier definitions they use
  chunkdeps.py closure STEM ID[,ID...] [--no-rng]   the chunks that must also stop running (and be shown from cached results) when the given ones stop running
  chunkdeps.py check STEM|--all                what the files say now: evaluated chunks and inline expressions that use a name whose last definition sits in a chunk
                                               with eval: false (UNDEFINED, or STALE when an older evaluated definition exists), and RNG-SHIFT warnings
  ID is FILE:LINE as printed by deps (for example 03-bl.qmd:721), a label, or the chunk number printed by deps.

A "chunk" here is every executable r or python chunk in the chapter with the includes of ex/*.qmd expanded, solutions inside showsln divs included (knitr
evaluates them). Inline `r ...` expressions of the prose count as uses. Names inside formulas and data frame verbs (columns) are reported as uses, so a
warning can be a false alarm when a column has the name of an object a frozen chunk defines; read the chunk before acting.
"""
import argparse
import ast
import builtins
import json
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, 'chunks'))
import chunkmap as cm  # noqa: E402

B = cm.B
STEMS = ['00-intro', '01-prob', '02-bayes', '03-bl', '04-dec', '05-ab', '06-hyp', '07-sp', '08-gp', '09-rl', '10-data', '11-pattern', '12-regression', '13-logistic',
         '14-tree', '15-forecasting', '16-select', '17-theoryai', '18-nn', '19-theorydl', '20-sgd', '21-qnn', '22-cnn', '23-nlp', '24-llm', '25-robots', 'appendix-linalg']
INLINE_R = re.compile(r'`r\s+([^`]+)`')
INLINE_PY = re.compile(r'`\{python\}\s+([^`]+)`')
PY_RNG = re.compile(r'\b(np\.random\.(?!seed)\w+|random\.(?!seed)\w+|torch\.(rand|randn|randint|randperm|normal|manual_seed_)\w*|default_rng|rng\.\w+|train_test_split|shuffle|dropout|Dropout|\.fit\(|KMeans|RandomForest|DataLoader|nn\.init|jax\.random\.(?!PRNGKey)\w+)')
PY_SEED = re.compile(r'(np\.random\.seed|random\.seed|torch\.manual_seed|tf\.random\.set_seed|jax\.random\.PRNGKey|default_rng\(\s*\d|random_state\s*=\s*\d|seed_everything)')
BUILTINS = set(dir(builtins))


def doc_items(stem):
    """chunks and inline expressions in book order; each item: dict(kind, id, file, line, lang, label, code, eval, echo, include, solution)"""
    lines = cm.expand('WORKTREE', f'{stem}.qmd')
    chunks = cm.chunks_of(lines)
    by_pos = {(c['file'], c['line']): c for c in chunks}
    sols = {}
    items = []
    in_comment, fence = False, None
    for text, f, n in lines:
        if f not in sols:
            sols[f] = cm.solution_ranges(f)
        is_sol = any(a <= n <= b for a, b in sols[f])
        if fence:
            if re.match(r'^\s*' + re.escape(fence[0]) + '{%d,}\\s*$' % len(fence), text):
                fence = None
            continue
        if in_comment:
            if '-->' in text:
                in_comment = False
            continue
        if '<!--' in text:
            if '-->' not in text.split('<!--', 1)[1]:
                in_comment = True
            text = re.sub(r'<!--.*?-->', '', text)
        m = cm.OPEN.match(text) or re.match(r'^\s*(`{3,}|~{3,})', text)
        if m:
            c = by_pos.get((f, n))
            fence_chars = re.match(r'^\s*(`{3,}|~{3,})', text).group(1)
            fence = fence_chars
            if c and c['lang'].lower() in ('r', 'python'):
                echo, ev, inc = cm.effective(c)
                items.append(dict(kind='chunk', id=f"{os.path.basename(f)}:{n}", file=f, line=n, lang=c['lang'].lower(), label=c['label'], code=c['code'], eval=ev, echo=echo,
                                  include=inc, solution=is_sol, opts=c['opts']))
            continue
        for k, mm in enumerate(INLINE_R.finditer(text)):
            items.append(dict(kind='inline', id=f"{os.path.basename(f)}:{n}#i{k}", file=f, line=n, lang='r', label=None, code=mm.group(1), eval=True, echo=False, include=True,
                              solution=is_sol, opts={}))
        for k, mm in enumerate(INLINE_PY.finditer(text)):
            items.append(dict(kind='inline', id=f"{os.path.basename(f)}:{n}#p{k}", file=f, line=n, lang='python', label=None, code=mm.group(1), eval=True, echo=False, include=True,
                              solution=is_sol, opts={}))
    return items


def py_deps(code):
    out = dict(defs=[], uses=[], libs=[], r_uses=[], events=[], error='')
    try:
        tree = ast.parse(code)
    except SyntaxError as e:
        out['error'] = f'{e.msg} line {e.lineno}'
        return out
    defs, uses, libs, r_uses = set(), set(), set(), set()

    def target_names(t):
        if isinstance(t, ast.Name):
            return [t.id]
        if isinstance(t, (ast.Tuple, ast.List)):
            return [n for e in t.elts for n in target_names(e)]
        if isinstance(t, ast.Starred):
            return target_names(t.value)
        return []

    def scan(node, local):
        """local: names bound in enclosing function scopes"""
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef, ast.Lambda)):
            if not isinstance(node, ast.Lambda):
                defs.add(node.name)
                for d in node.decorator_list:
                    scan(d, local)
            args = node.args
            names = {a.arg for a in args.args + args.kwonlyargs + getattr(args, 'posonlyargs', [])}
            if args.vararg:
                names.add(args.vararg.arg)
            if args.kwarg:
                names.add(args.kwarg.arg)
            for d in args.defaults + [x for x in args.kw_defaults if x is not None]:
                scan(d, local)
            body = [node.body] if isinstance(node, ast.Lambda) else node.body
            inner = set(local) | names
            for st in body:  # names assigned inside the function are local too
                for sub in ast.walk(st):
                    if isinstance(sub, ast.Name) and isinstance(sub.ctx, ast.Store):
                        inner.add(sub.id)
            for st in body:
                scan(st, inner)
            return
        if isinstance(node, ast.ClassDef):
            defs.add(node.name)
            for st in node.body:
                scan(st, local)
            return
        if isinstance(node, (ast.ListComp, ast.SetComp, ast.GeneratorExp, ast.DictComp)):
            inner = set(local)
            for g in node.generators:
                inner |= set(target_names(g.target))
            for g in node.generators:
                scan(g.iter, local)
                for i in g.ifs:
                    scan(i, inner)
            for fld in ('elt', 'key', 'value'):
                if hasattr(node, fld):
                    scan(getattr(node, fld), inner)
            return
        if isinstance(node, ast.Import):
            for a in node.names:
                nm = (a.asname or a.name.split('.')[0])
                defs.add(nm)
                libs.add(a.name.split('.')[0])
            return
        if isinstance(node, ast.ImportFrom):
            for a in node.names:
                defs.add(a.asname or a.name)
            libs.add((node.module or '').split('.')[0])
            return
        if isinstance(node, ast.Attribute) and isinstance(node.value, ast.Name) and node.value.id == 'r' and 'r' not in local:
            r_uses.add(node.attr)
        if isinstance(node, ast.Name):
            if isinstance(node.ctx, ast.Store):
                if not local:
                    defs.add(node.id)
            elif node.id not in local and node.id not in BUILTINS:
                uses.add(node.id)
            return
        for child in ast.iter_child_nodes(node):
            scan(child, local)

    for st in tree.body:
        scan(st, set())
    defs_in = set(defs)
    aug = {s.target.id for s in ast.walk(tree) if isinstance(s, ast.AugAssign) and isinstance(s.target, ast.Name)}
    out['defs'] = sorted(defs)
    out['uses'] = sorted((uses - defs_in) | aug)
    out['libs'] = sorted(libs)
    out['r_uses'] = sorted(r_uses)
    # events in text order
    ev = []
    for m in re.finditer(PY_SEED.pattern + '|' + PY_RNG.pattern, code):
        ev.append('seed' if PY_SEED.match(m.group(0)) else 'rng')
    out['events'] = ev
    return out


def analyze(items):
    r_items = [it for it in items if it['lang'] == 'r']
    res = {}
    if r_items:
        with tempfile.TemporaryDirectory() as td:
            fi, fo = os.path.join(td, 'in.json'), os.path.join(td, 'out.json')
            json.dump([dict(id=it['id'], code=it['code']) for it in r_items], open(fi, 'w'))
            p = subprocess.run(['Rscript', os.path.join(HERE, 'chunks', 'rdeps.R'), fi, fo], capture_output=True, text=True)
            if p.returncode != 0:
                sys.exit('rdeps.R failed: ' + p.stderr[-400:])
            for d in json.load(open(fo)):
                res[d['id']] = dict(defs=d['defs'], uses=d['uses'], libs=d['libs'], loads=d.get('loads', []), py_uses=d['py_uses'], py_defs=d['py_defs'], events=d['events'],
                                    error=(d['error'][0] if d['error'] else ''))
    for it in items:
        if it['lang'] == 'python':
            r = py_deps(it['code'])
            res[it['id']] = dict(defs=r['defs'], uses=r['uses'], libs=r['libs'], r_uses=r['r_uses'], events=r['events'], error=r['error'])
    for it in items:
        it['deps'] = res.get(it['id'], dict(defs=[], uses=[], libs=[], events=[], error='not analysed'))
    return items


def namespace(it, name_kind):
    """name_kind 'def' or 'use' -> list of (namespace, name) pairs; cross-language access maps to the other language's namespace"""
    d = it['deps']
    if it['lang'] == 'r':
        defs = [('r', n) for n in d['defs']] + [('python', n) for n in d.get('py_defs', [])]
        uses = [('r', n) for n in d['uses']] + [('python', n) for n in d.get('py_uses', [])]
    else:
        defs = [('python', n) for n in d['defs']]
        uses = [('python', n) for n in d['uses']] + [('r', n) for n in d.get('r_uses', [])]
    return defs if name_kind == 'def' else uses


def find(items, key):
    body = [it for it in items]
    for it in body:
        if it['id'] == key or it['label'] == key:
            return it
    if key.isdigit():
        chunks = [it for it in items if it['kind'] == 'chunk']
        if 1 <= int(key) <= len(chunks):
            return chunks[int(key) - 1]
    sys.exit(f'no chunk {key}')


def run_events(items, frozen):
    """RNG shift: evaluated chunks that draw random numbers without a seed of their own after a frozen chunk that also draws them, since the last seed"""
    warn = []
    seeded = False          # an earlier chunk (original semantics) set a seed and nothing has reseeded since
    tainted = []            # frozen chunks with rng events since the last seed
    for it in items:
        ev = it['deps'].get('events', [])
        if not ev:
            continue
        is_frozen = it['id'] in frozen or not it['eval']
        first_is_seed = ev[0] == 'seed'
        if first_is_seed:
            seeded, tainted = True, []
            if is_frozen:
                continue
            if 'rng' not in ev:
                continue
        if not is_frozen and 'rng' in ev and not first_is_seed and seeded and tainted:
            warn.append((it, list(tainted)))
        if is_frozen and 'rng' in ev:
            tainted.append(it)
        if 'seed' in ev and not first_is_seed:
            seeded, tainted = True, []
    return warn


def closure(items, start, rng=True):
    frozen = {it['id']: 'chosen' for it in start}
    last_def = {}  # (ns, name) -> item
    for it in items:
        if it['kind'] == 'chunk' and not it['eval'] and it['id'] not in frozen:
            frozen[it['id']] = 'eval: false already'
    for it in items:
        if it['id'] not in frozen:
            for ns_name in namespace(it, 'use'):
                d = last_def.get(ns_name)
                if d is not None and d['id'] in frozen:
                    frozen[it['id']] = f"uses {ns_name[1]} defined in {d['id']}"
                    break
        if it['kind'] == 'chunk':
            for ns_name in namespace(it, 'def'):
                last_def[ns_name] = it
    if rng:
        # a draw without its own seed after a frozen draw shifts: freeze it too, and repeat because that can start a chain
        for _ in range(5):
            added = False
            for it, taint in run_events(items, set(frozen)):
                if it['id'] not in frozen:
                    frozen[it['id']] = f"draws random numbers after frozen {taint[-1]['id']} without a seed of its own"
                    added = True
            if not added:
                break
    return frozen


def check(items):
    problems = []
    last_def, last_eval = {}, {}
    pos = {it['id']: k for k, it in enumerate(items)}
    loaders = [pos[it['id']] for it in items if it['eval'] and it['deps'].get('loads')]
    for it in items:
        evaluated = it['eval']
        if evaluated:
            for ns_name in namespace(it, 'use'):
                d = last_def.get(ns_name)
                if d is not None and not d['eval']:
                    # load("file.RData") in an evaluated chunk before the use can bring the object (the file holds several models at once): not decidable here, no report
                    if any(k < pos[it['id']] for k in loaders):
                        continue
                    kind = 'STALE' if ns_name in last_eval else 'UNDEFINED'
                    problems.append((kind, it, ns_name[1], d))
        if it['kind'] == 'chunk':
            for ns_name in namespace(it, 'def'):
                last_def[ns_name] = it
                if evaluated:
                    last_eval[ns_name] = it
    for it, taint in run_events(items, set()):
        problems.append(('RNG-SHIFT', it, '', taint[-1]))
    return problems


def state(it):
    s = 'inline' if it['kind'] == 'inline' else ('shown' if it['echo'] else 'hidden')
    if not it['eval']:
        s += ' noeval'
    if it['solution']:
        s += ' SOL'
    return s


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('cmd', choices=['deps', 'closure', 'check'])
    ap.add_argument('stem', nargs='?')
    ap.add_argument('ids', nargs='?')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--no-rng', action='store_true')
    a = ap.parse_args()
    if a.cmd == 'check' and (a.all or a.stem == '--all'):
        stems = STEMS
    else:
        stems = [a.stem]
    total = 0
    for stem in stems:
        items = analyze(doc_items(stem))
        if a.cmd == 'deps':
            chunks = [it for it in items if it['kind'] == 'chunk']
            for k, it in enumerate(chunks, 1):
                defined_before = {}
                d = it['deps']
                print(f"{k:3d} {it['id']:22s} {it['lang']:6s} {state(it):14s} label={it['label'] or '-':22s} defs={','.join(d['defs'][:8])}{'...' if len(d['defs']) > 8 else ''} err={d['error']}")
        elif a.cmd == 'closure':
            start = [find(items, x) for x in a.ids.split(',')]
            fr = closure(items, start, rng=not a.no_rng)
            for it in items:
                if it['id'] in fr and fr[it['id']] != 'eval: false already':
                    print(f"{it['id']:24s} {it['lang']:6s} {state(it):12s} {fr[it['id']]}")
        else:
            probs = check(items)
            for kind, it, name, d in probs:
                if kind == 'RNG-SHIFT':
                    print(f"{stem}: RNG-SHIFT {it['id']} draws random numbers without a seed after the frozen {d['id']}")
                else:
                    print(f"{stem}: {kind} {it['id']} ({it['kind']}) uses {name}, last defined in {d['id']} which has eval: false")
            total += len(probs)
            errs = [it for it in items if it['deps'].get('error')]
            for it in errs:
                print(f"{stem}: PARSE-ERROR {it['id']}: {it['deps']['error']}")
                total += 1
    if a.cmd == 'check':
        print(f'{total} problems')
        sys.exit(1 if total else 0)


if __name__ == '__main__':
    main()
