#!/data/data/com.termux/files/usr/bin/bash

set -e

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

cd "$ROOT"

echo "=========================================="
echo " SarVita Arc - BRAND VERIFICATION"
echo "=========================================="
echo

echo "[1] package.json"
python - <<'PY'
import json

with open("package.json", encoding="utf-8") as f:
    data = json.load(f)

print("name:", data.get("name"))
print("version:", data.get("version"))
PY

echo
echo "[2] HTML title"
grep -n '<title>' public/index.html || true

echo
echo "[3] Arabic locale validation"
python -m json.tool public/locales/ar-sa.json >/dev/null

echo "Arabic JSON: OK"

echo
echo "[4] Remaining branding strings"

grep -Rni \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=data \
  --exclude-dir=tests \
  --exclude-dir=public/lib \
  --exclude='*.min.js' \
  --exclude='*.map' \
  -E 'SillyTavern|sillytavern|silly-tavern' \
  public/index.html \
  public/locales/ar-sa.json \
  package.json \
  package-lock.json \
  2>/dev/null || true

echo
echo "[5] Important technical identifiers"

grep -Rni \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=data \
  --exclude-dir=tests \
  -E 'SillyTavern\.getContext|SILLYTAVERN_PORT|sillytavern-transformers' \
  public src package.json \
  2>/dev/null | head -50 || true

echo
echo "[6] Git status"
git status --short

echo
echo "=========================================="
echo " Verification completed"
echo "=========================================="
