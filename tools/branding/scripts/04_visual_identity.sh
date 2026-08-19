#!/data/data/com.termux/files/usr/bin/bash

set -e

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"

cd "$ROOT"

ASSETS="$ROOT/tools/branding/assets"

echo "=========================================="
echo " SarVita Arc - VISUAL IDENTITY"
echo "=========================================="
echo

echo "Expected assets:"
echo
echo "  $ASSETS/logo.png"
echo "  $ASSETS/logo.svg"
echo "  $ASSETS/icon.png"
echo "  $ASSETS/favicon.png"
echo "  $ASSETS/favicon.ico"
echo "  $ASSETS/splash.png"
echo

if [ ! -d "$ASSETS" ]; then
    mkdir -p "$ASSETS"
fi

missing=0

for file in \
    logo.png \
    logo.svg \
    icon.png \
    favicon.png \
    favicon.ico \
    splash.png
do
    if [ -f "$ASSETS/$file" ]; then
        echo "[OK] $file"
    else
        echo "[WAITING] $file"
        missing=1
    fi
done

echo

if [ "$missing" -eq 1 ]; then
    echo "VISUAL IDENTITY NOT APPLIED."
    echo
    echo "Waiting for SarVita Arc image assets."
    echo "Do not modify project image files yet."
    exit 2
fi

echo "All visual assets are available."
echo "Visual replacement phase can now begin."

