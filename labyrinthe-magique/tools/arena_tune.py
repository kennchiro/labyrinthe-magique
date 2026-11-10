"""Règle `ArenaRules.VIGOR` sur la matrice de l'arène (qui bat qui en 1 contre 1).

    python3 tools/arena_tune.py GAIN [taux.json]

Lance `tools/arena_matrix.sh 8`, puis multiplie la vigueur de chaque héros par 2^((0,5 - victoires) x GAIN),
entre 0,4 et 4,0, et la réécrit dans `src/arena/arena_rules.gd`. `taux.json` ({id: 0..1}) saute la matrice.
GAIN 1,4 pour dégrossir, 0,8 pour finir : à gain fort, ça oscille (la Peste de 84 à 18 %, 2026-11-10).
"""
import re, subprocess, sys, json
import os
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
RULES = ROOT + "/src/arena/arena_rules.gd"
gain = float(sys.argv[1])
seed_rates = sys.argv[2] if len(sys.argv) > 2 else None

def read_vigor():
    s = open(RULES, encoding="utf-8").read()
    m = re.search(r"const VIGOR := \{(.*?)\}", s, re.S)
    out = {}
    for k, v in re.findall(r'"([a-z_]+)":\s*([0-9.]+)', m.group(1)):
        out[k] = float(v)
    return out

def write_vigor(v):
    s = open(RULES, encoding="utf-8").read()
    items = sorted(v.items())
    lines = []
    row = []
    for k, x in items:
        if abs(x - 1.0) < 0.005:
            continue
        row.append('"%s": %.2f' % (k, x))
        if len(row) == 5:
            lines.append("\t" + ", ".join(row) + ",")
            row = []
    if row:
        lines.append("\t" + ", ".join(row) + ",")
    body = "{\n" + "\n".join(lines) + "\n}" if lines else "{}"
    s = re.sub(r"const VIGOR := \{.*?\}", "const VIGOR := " + body, s, count=1, flags=re.S)
    open(RULES, "w", encoding="utf-8").write(s)

if seed_rates:
    rates = json.load(open(seed_rates))
else:
    out = subprocess.run([ROOT + "/tools/arena_matrix.sh", "8"], capture_output=True, text=True).stdout
    rates = {}
    for line in out.splitlines():
        m = re.match(r"(\S+)\s+(\d+) %", line)
        if m:
            rates[m.group(1)] = int(m.group(2)) / 100.0
    print(out)
vigor = read_vigor()
for k, w in rates.items():
    vigor[k] = max(0.4, min(4.0, vigor.get(k, 1.0) * 2 ** ((0.5 - w) * gain)))
write_vigor(vigor)
print(json.dumps({k: round(v, 2) for k, v in sorted(vigor.items())}))
