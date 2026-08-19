#!/data/data/com.termux/files/usr/bin/bash

set -e

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

cd "$ROOT"

echo "=========================================="
echo " SarVita Arc - BRAND SCANNER"
echo "=========================================="
echo
echo "Project: $ROOT"
echo

echo "[1/6] Git status"
git status --short
echo

echo "[2/6] Project name occurrences"
grep -Rni \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=data \
  --exclude-dir=public/lib \
  --exclude-dir=tests \
  --exclude='*.min.js' \
  --exclude='*.map' \
  -E 'SillyTavern|sillytavern|silly-tavern' \
  . | head -200 || true

echo
echo "[3/6] package.json identity"
python - <<'PY'
import json

with open("package.json", encoding="utf-8") as f:
    p = json.load(f)

print("name       :", p.get("name"))
print("version    :", p.get("version"))
print("description:", p.get("description"))
print("homepage   :", p.get("homepage"))
print("repository :", p.get("repository"))
PY

echo
echo "[4/6] HTML branding"
grep -Rni \
  --exclude-dir=.git \
  --exclude-dir=node_modules \
  --exclude-dir=data \
  --exclude-dir=tests \
  -E '<title>|Welcome to SillyTavern|SillyTavern is aimed' \
  public 2>/dev/null | head -100 || true

echo
echo "[5/6] Arabic translation"
python - <<'PY'
import json

path = "public/locales/ar-sa.json"

with open(path, encoding="utf-8") as f:
    data = json.load(f)

count = 0

def scan(obj):
    global count

    if isinstance(obj, dict):
        for value in obj.values():
            scan(value)

    elif isinstance(obj, list):
        for value in obj:
            scan(value)

    elif isinstance(obj, str):
        if "SillyTavern" in obj or "sillytavern" in obj:
            count += 1

scan(data)

print("Remaining SillyTavern strings in Arabic:", count)
PY

echo
echo "[6/6] Branding assets"
echo

find public -maxdepth 3 -type f \
  \( -iname '*logo*' \
  -o -iname '*icon*' \
  -o -iname '*favicon*' \
  -o -iname '*.png' \
  -o -iname '*.jpg' \
  -o -iname '*.jpeg' \
  -o -iname '*.webp' \
  \) \
  2>/dev/null | head -150

echo
echo "=========================================="
echo " Scan completed"
echo "=========================================="
