#!/usr/bin/env bash
set -euo pipefail

# Extract GDG_KOCHI from server.py, sort speaker entries and write JSON + Python mapping.
# Usage:
#   ./scripts/export_speakers.sh [output_dir]
# Defaults to repository root (.) when no arg is provided.

OUT_DIR="${1:-.}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_PY="$SCRIPT_DIR/../server.py"

mkdir -p "$OUT_DIR"

python3 - "$SERVER_PY" "$OUT_DIR" <<'PY'
import ast, json, os, sys

server_path = sys.argv[1]
out_dir = sys.argv[2]

with open(server_path, 'r', encoding='utf-8') as f:
    src = f.read()

# Parse AST and find the GDG_KOCHI assignment
module = ast.parse(src, filename=server_path)
gdg_node = None
for node in module.body:
    if isinstance(node, ast.Assign):
        for target in node.targets:
            if isinstance(target, ast.Name) and target.id == 'GDG_KOCHI':
                gdg_node = node.value
                break
    if gdg_node is not None:
        break

if gdg_node is None:
    print('ERROR: GDG_KOCHI not found in', server_path, file=sys.stderr)
    sys.exit(2)

# Safely evaluate literal (list/dicts)
try:
    gdg_value = ast.literal_eval(gdg_node)
except Exception as e:
    print('ERROR: failed to literal_eval GDG_KOCHI:', e, file=sys.stderr)
    sys.exit(3)

# Normalize and sort by speaker name (None last), case-insensitive
def speaker_key(item):
    sp = item.get('speaker')
    if sp is None:
        return (1, '')
    return (0, sp.lower())

sorted_list = sorted(gdg_value, key=speaker_key)

# Build mapping: speaker -> list of sessions (use title as key for None speakers)
mapping = {}
for sess in sorted_list:
    key = sess.get('speaker') or sess.get('title') or 'Unknown'
    mapping.setdefault(key, []).append(sess)

# Write outputs
os.makedirs(out_dir, exist_ok=True)
json_path = os.path.join(out_dir, 'speakers.json')
py_path = os.path.join(out_dir, 'speakers_dict.py')

with open(json_path, 'w', encoding='utf-8') as jf:
    json.dump(sorted_list, jf, indent=2, ensure_ascii=False)

with open(py_path, 'w', encoding='utf-8') as pf:
    pf.write('# Auto-generated speakers mapping from server.py\n')
    pf.write('from typing import Dict, List, Any\n\n')
    pf.write('SPEAKERS: Dict[str, List[Dict[str, Any]]] = ')
    json.dump(mapping, pf, indent=2, ensure_ascii=False)
    pf.write('\n')

print('Wrote:', json_path)
print('Wrote:', py_path)
PY

echo "Done. Files written to $OUT_DIR/speakers.json and $OUT_DIR/speakers_dict.py"
