#!/usr/bin/env python3
"""Map every executable chunk of a chapter to its frozen output, using the tree of the baseline ref (the sources the frozen results were made from).

  chunkmap.py STEM [--ref REF] [--json OUT]      print a table of chunks with echo, eval, include, output kinds; write JSON if asked
  chunkmap.py --all --out DIR                    one JSON per chapter into DIR

How the mapping works. Quarto emits one top level cell div (class .cell) for every executable chunk except those with include: false, in order. So the
chunks with include other than false of the expanded source (includes of ex/*.qmd and misc/common.qmd expanded in place) and the cells of the frozen
markdown (_freeze/STEM/execute-results/html.json) pair up by position. The pairing is checked by comparing the first code line of every chunk that
echoes its code with the code fence of its cell; a count or code mismatch is reported and the chapter is left unmapped.
"""
import argparse
import glob
import json
import os
import re
import subprocess
import sys

B = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
REF_DEFAULT = 'refs/baseline/pre-fixes-20261017'
OPEN = re.compile(r'^(?P<ind>\s*)(?P<fence>`{3,}|~{3,})\s*\{(?P<lang>=?[A-Za-z0-9_.+-]+)(?P<rest>.*)\}\s*$')
FENCE = re.compile(r'^(\s*)(`{3,}|~{3,})(.*)$')
TRUE = {'true', 'yes', 'TRUE', 'T', 'True'}
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))


def git_show(ref, path):
    r = subprocess.run(['git', '-C', B, 'show', f'{ref}:{path}'], capture_output=True, text=True)
    if r.returncode != 0:
        return None
    return r.stdout


def expand(ref, path, depth=0):
    """lines of the file with {{< include >}} expanded; each item is (text, origin_file, origin_line); ref 'WORKTREE' reads the files on disk"""
    txt = None if ref == 'WORKTREE' else git_show(ref, path)
    if txt is None:
        txt = open(os.path.join(B, path), encoding='utf-8').read()
    out = []
    for n, l in enumerate(txt.split('\n'), 1):
        m = re.match(r'^\s*\{\{<\s*include\s+(\S+)\s*>\}\}\s*$', l)
        if m and depth < 3:
            p = os.path.normpath(m.group(1))
            out += expand(ref, p, depth + 1)
        else:
            out.append((l, path, n))
    return out


def split_header(rest):
    parts, buf, depth, q = [], '', 0, None
    for ch in rest:
        if q:
            buf += ch
            if ch == q:
                q = None
            continue
        if ch in '"\'':
            q = ch
            buf += ch
        elif ch in '([{':
            depth += 1
            buf += ch
        elif ch in ')]}':
            depth -= 1
            buf += ch
        elif ch == ',' and depth == 0:
            parts.append(buf.strip())
            buf = ''
        else:
            buf += ch
    parts.append(buf.strip())
    label, opts = None, {}
    for i, p in enumerate(x for x in parts if x):
        if '=' in p:
            k, v = p.split('=', 1)
            opts[k.strip()] = v.strip().strip('"\'')
        elif i == 0:
            label = p.strip()
    return label, opts


def heading_index(lines):
    """for every line, the index of the last Markdown heading (1 to 4 #) before it that is outside code fences and HTML comments"""
    out, cur, fence, comment = [], -1, None, False
    for idx, (txt, _, _) in enumerate(lines):
        out.append(cur)
        if comment:
            if '-->' in txt:
                comment = False
            continue
        if '<!--' in txt and '-->' not in txt.split('<!--', 1)[1]:
            comment = True
            continue
        m = re.match(r'^\s*(`{3,}|~{3,})', txt)
        if fence:
            if m and m.group(1)[0] == fence[0] and len(m.group(1)) >= len(fence) and not txt.strip().strip('`~'):
                fence = None
        elif m:
            fence = m.group(1)
        elif re.match(r'^#{1,4} ', txt):
            cur = idx
    return out


def chunks_of(lines):
    res, i, comment = [], 0, False
    heads = heading_index(lines)
    while i < len(lines):
        l = lines[i][0]
        if '<!--' in l and '-->' not in l.split('<!--', 1)[1]:
            comment = True
        if comment:
            if '-->' in l:
                comment = False
            i += 1
            continue
        m = OPEN.match(l)
        if m:
            fence = m.group('fence')
            j = i + 1
            close = re.compile(r'^\s*' + re.escape(fence[0]) + '{%d,}\\s*$' % len(fence))
            while j < len(lines) and not close.match(lines[j][0]):
                j += 1
            lang = m.group('lang')
            label, opts = split_header(m.group('rest'))
            code = []
            for k in range(i + 1, j):
                bs = lines[k][0].strip()
                if bs.startswith('#|'):
                    kv = bs[2:].strip()
                    if ':' in kv:
                        a, b = kv.split(':', 1)
                        a, b = a.strip(), b.strip()
                        if a == 'label':
                            label = b.strip('"\'')
                        else:
                            opts[a] = b
                    continue
                code.append(lines[k][0])
            if lang.lower() in ('r', 'python'):
                b = i - 1
                while b >= 0 and (not lines[b][0].strip() or lines[b][0].strip().startswith(('```', ':::'))):
                    b -= 1
                a2 = j + 1
                while a2 < len(lines) and (not lines[a2][0].strip() or lines[a2][0].strip().startswith(':::')):
                    a2 += 1
                h = heads[i]
                res.append(dict(lang=lang, label=label, opts=opts, code='\n'.join(code), file=lines[i][1], line=lines[i][2], end=lines[j][2] if j < len(lines) else lines[i][2],
                                before=lines[b][0].strip()[:200] if b >= 0 else '', after=lines[a2][0].strip()[:200] if a2 < len(lines) else '',
                                heading=lines[h][0].strip()[:90] if h >= 0 else ''))
            i = j + 1
            continue
        i += 1
    return res


def truthy(v):
    return str(v).strip().strip('"\'') in TRUE


def effective(c):
    o = c['opts']
    echo = (truthy(o['echo']) or o.get('echo') == 'fenced') if 'echo' in o else False
    ev = not (('eval' in o) and not truthy(o['eval']))
    inc = not (('include' in o) and not truthy(o['include']))
    return echo, ev, inc


def echo_kind(c):
    """shown, hidden, or partial (echo given as a selection of expressions: echo=c(1,2), echo=-1, echo=2)"""
    v = c['opts'].get('echo')
    if v is None:
        return 'hidden'
    if truthy(v) or v == 'fenced':
        return 'shown'
    if re.match(r'^(-?c\(.*\)|-?\d+(:-?\d+)?)$', str(v).strip()):
        return 'partial'
    return 'hidden'


def solution_ranges(path):
    """line ranges of showsln divs (hidden exercise solutions) in a file on disk. A div hidden only in some formats
    (when-format, such as the computing exercises that the PDF leaves out) is not a solution."""
    p = os.path.join(B, path)
    if not os.path.exists(p):
        return []
    lines = open(p, encoding='utf-8').read().split('\n')
    out, depth, start = [], 0, None
    for i, l in enumerate(lines, 1):
        s = l.strip()
        if (re.match(r'^:{3,}\s*\{.*content-hidden.*showsln.*\}', s) and 'when-format' not in s) or re.match(r'^:{3,}\s*content-hidden', s):
            if depth == 0:
                start = i
            depth += 1
        elif depth > 0 and re.match(r'^:{3,}\s*\S', s):
            depth += 1
        elif depth > 0 and re.match(r'^:{3,}\s*$', s):
            depth -= 1
            if depth == 0:
                out.append((start, i))
    return out


def frozen_cells(md):
    """top level cells (not inside another cell) as (first line, last line, inside a solution: a content-hidden div
    that is not limited to some formats by when-format)"""
    lines = md.split('\n')
    hid = lambda a: 'content-hidden' in a and 'when-format' not in a
    stack, cells, cur, cur_hidden, fence = [], [], None, False, None
    for i, l in enumerate(lines):
        if fence:
            m = FENCE.match(l)
            if m and m.group(2)[0] == fence[0] and len(m.group(2)) >= len(fence) and not m.group(3).strip():
                fence = None
            continue
        m = FENCE.match(l)
        if m:
            fence = m.group(2)
            continue
        s = l.strip()
        if re.match(r'^:{3,}\s*$', s):
            if stack:
                kind, _ = stack.pop()
                if kind == 'outer' and cur is not None:
                    cells.append((cur, i, cur_hidden))
                    cur = None
        elif re.match(r'^:{3,}\s*\S', s):
            attrs = s.lstrip(':').strip()
            is_cell = bool(re.search(r'(^|[\s{])\.cell(?=[\s}])', attrs))
            inside = any(k in ('outer', 'cell') for k, _ in stack)
            if is_cell and not inside:
                cur_hidden = any(hid(a) for _, a in stack) or hid(attrs)
                stack.append(('outer', attrs))
                cur = i
            elif is_cell:
                stack.append(('cell', attrs))
            else:
                stack.append(('div', attrs))
    return cells, lines


def cell_info(lines, a, b, code=''):
    """what a frozen cell shows. With collapse on, the output of a chunk whose code is shown sits inside the code fence as lines starting with '##';
    those lines are split off as text output (a '##' line that is also a line of the chunk's own code is a comment, not output)."""
    body = lines[a + 1:b]
    own = set(x.strip() for x in code.split('\n'))
    info = dict(code_shown=False, text=[], figures=[], tables=0, stderr=0, other_display=0, collapsed=False)
    i = 0
    while i < len(body):
        l = body[i]
        m = FENCE.match(l)
        if m:
            fence = m.group(2)
            j = i + 1
            blk = []
            while j < len(body):
                mm = FENCE.match(body[j])
                if mm and mm.group(2)[0] == fence[0] and len(mm.group(2)) >= len(fence) and not mm.group(3).strip():
                    break
                blk.append(body[j])
                j += 1
            head = m.group(3).strip()
            if 'cell-code' in head:
                info['code_shown'] = True
                outl = [x for x in blk if x.startswith('##') and x.strip() not in own]
                if outl:
                    info['collapsed'] = True
                    info['text'].append([re.sub(r'^## ?', '', x) for x in outl])
            else:
                info['text'].append([re.sub(r'^## ?', '', x) for x in blk])
            i = j + 1
            continue
        if re.match(r'^!\[', l.strip()):
            fm = re.match(r'^!\[(.*?)\]\((.*?)\)(\{.*\})?', l.strip())
            if fm:
                info['figures'].append(dict(caption=fm.group(1)[:80], path=fm.group(2), attrs=(fm.group(3) or '')[:80]))
        elif re.match(r'^\|.*\|\s*$', l.strip()):
            if not (i > 0 and re.match(r'^\|.*\|\s*$', body[i - 1].strip())):
                info['tables'] += 1
        elif 'cell-output-stderr' in l:
            info['stderr'] += 1
        elif '<table' in l or '<div' in l:
            info['other_display'] += 1
        i += 1
    return info


def build(stem, ref):
    src = expand(ref, f'{stem}.qmd')
    ch = chunks_of(src)
    for k, c in enumerate(ch):
        c['n'] = k
        c['echo'], c['eval'], c['include'] = effective(c)
    fz = os.path.join(B, '_freeze', stem, 'execute-results', 'html.json')
    md = json.load(open(fz))['result']['markdown']
    cells, flines = frozen_cells(md)
    emitting = [c for c in ch if c['include']]
    report = dict(stem=stem, chunks=len(ch), emitting=len(emitting), cells=len(cells), mapped=False, mismatches=[])
    if len(emitting) == len(cells):
        ok = True
        for c, cell in zip(emitting, cells):
            info = cell_info(flines, cell[0], cell[1], c['code'])
            c['out'] = info
            c['solution'] = bool(cell[2])
            first = next((x.strip() for x in c['code'].split('\n') if x.strip()), '')
            body = '\n'.join(flines[cell[0]:cell[1]])
            if c['echo'] and first and first[:40] not in body:
                report['mismatches'].append(f"{c['file']}:{c['line']} first code line not in its cell")
                ok = False
        report['mapped'] = ok or len(report['mismatches']) <= 2
    return ch, report


def head(code, n=6):
    ls = [x for x in code.split('\n') if x.strip()]
    return '\n'.join(x[:110] for x in ls[:n]) + ('\n...' if len(ls) > n else '')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('stem', nargs='?')
    ap.add_argument('--ref', default=REF_DEFAULT)
    ap.add_argument('--json')
    ap.add_argument('--all', action='store_true')
    ap.add_argument('--out')
    a = ap.parse_args()
    stems = [os.path.basename(os.path.dirname(os.path.dirname(p))) for p in sorted(glob.glob(B + '/_freeze/*/execute-results/html.json'))] if a.all else [a.stem]
    for stem in stems:
        ch, rep = build(stem, a.ref)
        if a.out:
            os.makedirs(a.out, exist_ok=True)
            json.dump(dict(report=rep, chunks=ch), open(os.path.join(a.out, stem + '.json'), 'w'), indent=1)
        elif a.json:
            json.dump(dict(report=rep, chunks=ch), open(a.json, 'w'), indent=1)
        print(f"{stem:18s} chunks {rep['chunks']:3d}  emitting {rep['emitting']:3d}  cells {rep['cells']:3d}  mapped {rep['mapped']}  {'; '.join(rep['mismatches'][:3])}")
        if not a.all and not a.out and not a.json:
            for c in ch:
                o = c.get('out')
                kinds = ''
                if o:
                    kinds = f"text={len(o['text'])} fig={len(o['figures'])} tab={o['tables']}" + (' SOL' if c.get('solution') else '')
                print(f"{c['file'].split('/')[-1]}:{c['line']:<5d} {c['lang']:6s} {str(c['label'] or '-'):26s} echo={int(c['echo'])} eval={int(c['eval'])} inc={int(c['include'])} {kinds}")


if __name__ == '__main__':
    main()
