#!/data/data/com.termux/files/usr/bin/bash

set -Eeuo pipefail

PROJECT_ROOT="$HOME/SarVita/SillyTavern"
PUBLIC="$PROJECT_ROOT/public"

BRANDING="$PUBLIC/img/branding/sarvita-arc"
ICONS="$BRANDING/icons"
MAIN="$BRANDING/main"
GALLERY="$BRANDING/gallery"

CSS="$PUBLIC/css/sarvita-arc-brand.css"
BOOT_JS="$PUBLIC/scripts/sarvita-arc-boot.js"
MANIFEST="$PUBLIC/manifest.json"
INDEX="$PUBLIC/index.html"

TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$PROJECT_ROOT/tools/branding/backup-before-final-$TIMESTAMP"

MAIN_URL="https://i.imgur.com/drzlubD.jpeg"

GALLERY_URLS=(
"https://i.imgur.com/B43TLWQ.jpeg"
"https://i.imgur.com/KzO4gaK.jpeg"
"https://i.imgur.com/X2lQZft.jpeg"
"https://i.imgur.com/r5Q9q0B.jpeg"
"https://i.imgur.com/Dx6d5Ae.jpeg"
"https://i.imgur.com/teg46Tj.jpeg"
"https://i.imgur.com/vmxe0eR.jpeg"
"https://i.imgur.com/EGpspb6.jpeg"
"https://i.imgur.com/GC8PfZv.jpeg"
"https://i.imgur.com/uVXnxpe.jpeg"
"https://i.imgur.com/JHIJWDz.jpeg"
"https://i.imgur.com/aizT6hz.jpeg"
"https://i.imgur.com/kAV8E53.jpeg"
"https://i.imgur.com/rB5aPZ2.jpeg"
"https://i.imgur.com/5iDGBcl.jpeg"
"https://i.imgur.com/DKvcFCg.jpeg"
"https://i.imgur.com/tjF39aV.jpeg"
"https://i.imgur.com/KJ4LE9K.jpeg"
"https://i.imgur.com/af8Qp9o.jpeg"
"https://i.imgur.com/0GYiWuT.jpeg"
"https://i.imgur.com/BTtNtFF.jpeg"
"https://i.imgur.com/Jy37vPJ.jpeg"
"https://i.imgur.com/RYweuD9.jpeg"
"https://i.imgur.com/xfdG16L.jpeg"
"https://i.imgur.com/oha5smM.jpeg"
)

echo
echo "=================================================="
echo "        SarVita Arc — FINAL BRANDING"
echo "=================================================="
echo

cd "$PROJECT_ROOT"

command -v curl >/dev/null 2>&1 || {
    echo "ERROR: curl غير مثبت."
    exit 1
}

command -v python >/dev/null 2>&1 || {
    echo "ERROR: python غير مثبت."
    exit 1
}

if command -v magick >/dev/null 2>&1; then
    MAGICK="magick"
elif command -v convert >/dev/null 2>&1; then
    MAGICK="convert"
else
    echo "ERROR: ImageMagick غير مثبت."
    exit 1
fi

echo "[1/12] Creating backup..."

mkdir -p "$BACKUP"

if [ -d "$PUBLIC/img/branding" ]; then
    cp -a "$PUBLIC/img/branding" "$BACKUP/branding"
fi

if [ -f "$INDEX" ]; then
    cp "$INDEX" "$BACKUP/index.html"
fi

if [ -f "$MANIFEST" ]; then
    cp "$MANIFEST" "$BACKUP/manifest.json"
fi

if [ -f "$CSS" ]; then
    cp "$CSS" "$BACKUP/sarvita-arc-brand.css"
fi

if [ -f "$BOOT_JS" ]; then
    cp "$BOOT_JS" "$BACKUP/sarvita-arc-boot.js"
fi

echo "Backup:"
echo "$BACKUP"
echo

TMP="$(mktemp -d)"

cleanup() {
    rm -rf "$TMP"
}

trap cleanup EXIT

echo "[2/12] Downloading main image..."

curl -L \
    --fail \
    --silent \
    --show-error \
    --retry 3 \
    --connect-timeout 20 \
    "$MAIN_URL" \
    -o "$TMP/main.jpeg"

test -s "$TMP/main.jpeg"

echo "Main image downloaded."

echo
echo "[3/12] Downloading gallery..."

mkdir -p "$TMP/gallery"

INDEX_NUM=1

for URL in "${GALLERY_URLS[@]}"; do

    FILE="$TMP/gallery/gallery-$(printf '%02d' "$INDEX_NUM").jpeg"

    echo "[$INDEX_NUM/${#GALLERY_URLS[@]}] $URL"

    curl -L \
        --fail \
        --silent \
        --show-error \
        --retry 3 \
        --connect-timeout 20 \
        "$URL" \
        -o "$FILE"

    test -s "$FILE"

    INDEX_NUM=$((INDEX_NUM + 1))
done

echo
echo "All gallery images downloaded."
echo

echo "[4/12] Removing old branding images..."

rm -rf "$PUBLIC/img/branding"

mkdir -p "$ICONS"
mkdir -p "$MAIN"
mkdir -p "$GALLERY"

cp "$TMP/main.jpeg" "$MAIN/sarvita-arc-main.jpeg"

cp "$TMP/main.jpeg" \
   "$BRANDING/sarvita-arc-primary.jpeg"

cp "$TMP/gallery/"*.jpeg "$GALLERY/"

echo "Old branding removed and new branding installed."

echo
echo "[5/12] Creating main visual assets..."

"$MAGICK" "$TMP/main.jpeg" \
    -auto-orient \
    -resize "1600x1600>" \
    "$MAIN/sarvita-arc-main.jpeg"

"$MAGICK" "$TMP/main.jpeg" \
    -auto-orient \
    -resize "1200x1200^" \
    -gravity center \
    -extent 1200x1200 \
    "$MAIN/sarvita-arc-main-square.png"

"$MAGICK" "$TMP/main.jpeg" \
    -auto-orient \
    -resize "1920x1080^" \
    -gravity center \
    -extent 1920x1080 \
    "$MAIN/sarvita-arc-main-wide.jpeg"

echo "Main visual assets created."

echo
echo "[6/12] Creating all application icons..."

ICON_SIZES=(
16
32
48
57
72
96
114
144
152
180
192
256
384
512
)

for SIZE in "${ICON_SIZES[@]}"; do

    echo "Creating ${SIZE}x${SIZE}"

    "$MAGICK" "$TMP/main.jpeg" \
        -auto-orient \
        -resize "${SIZE}x${SIZE}^" \
        -gravity center \
        -extent "${SIZE}x${SIZE}" \
        -strip \
        "$ICONS/icon-${SIZE}x${SIZE}.png"

done

echo
echo "[7/12] Creating favicon and Apple icon..."

cp "$ICONS/icon-16x16.png" \
   "$ICONS/favicon-16x16.png"

cp "$ICONS/icon-32x32.png" \
   "$ICONS/favicon-32x32.png"

cp "$ICONS/icon-48x48.png" \
   "$ICONS/favicon-48x48.png"

cp "$ICONS/icon-180x180.png" \
   "$ICONS/apple-touch-icon.png"

cp "$ICONS/icon-192x192.png" \
   "$ICONS/pwa-192x192.png"

cp "$ICONS/icon-512x512.png" \
   "$ICONS/pwa-512x512.png"

echo "Icons completed."

echo
echo "[8/12] Creating SarVita Arc visual CSS..."

mkdir -p "$PUBLIC/css"

cat > "$CSS" <<'EOF'
/* =========================================================
   SarVita Arc — Complete Visual Identity
   ========================================================= */

:root {
    --sarvita-bg-1: #050509;
    --sarvita-bg-2: #0b0714;
    --sarvita-bg-3: #170b24;

    --sarvita-primary: #c43cff;
    --sarvita-secondary: #7c3cff;
    --sarvita-accent: #ff3cac;

    --sarvita-text: #f7f3ff;
    --sarvita-muted: #aaa1b8;

    --sarvita-glow-1: rgba(196, 60, 255, .25);
    --sarvita-glow-2: rgba(255, 60, 172, .20);
    --sarvita-glow-3: rgba(124, 60, 255, .20);

    --sarvita-border: rgba(196, 60, 255, .24);
}

/* =========================================================
   GLOBAL
   ========================================================= */

html,
body {
    background:
        radial-gradient(
            circle at 15% 20%,
            var(--sarvita-glow-1),
            transparent 30%
        ),
        radial-gradient(
            circle at 85% 25%,
            var(--sarvita-glow-2),
            transparent 30%
        ),
        radial-gradient(
            circle at 50% 90%,
            var(--sarvita-glow-3),
            transparent 35%
        ),
        linear-gradient(
            135deg,
            var(--sarvita-bg-1),
            var(--sarvita-bg-2),
            var(--sarvita-bg-3),
            var(--sarvita-bg-1)
        ) !important;

    color: var(--sarvita-text);
}

/* Animated color atmosphere */

body::before {
    content: "";
    position: fixed;

    inset: -35%;

    z-index: -1;

    pointer-events: none;

    background:
        radial-gradient(
            circle at 25% 30%,
            rgba(196, 60, 255, .18),
            transparent 25%
        ),
        radial-gradient(
            circle at 75% 30%,
            rgba(255, 60, 172, .14),
            transparent 25%
        ),
        radial-gradient(
            circle at 50% 80%,
            rgba(124, 60, 255, .14),
            transparent 30%
        );

    filter: blur(75px);

    animation:
        sarvitaAtmosphere 18s
        ease-in-out
        infinite
        alternate;
}

@keyframes sarvitaAtmosphere {

    0% {
        transform:
            translate3d(-4%, -3%, 0)
            scale(1);
    }

    50% {
        transform:
            translate3d(4%, 3%, 0)
            scale(1.10);
    }

    100% {
        transform:
            translate3d(-2%, 4%, 0)
            scale(1.05);
    }
}

/* =========================================================
   PANELS
   ========================================================= */

.drawer-content,
.popup,
.menu,
.dialog,
.modal,
#chat,
#left-nav-panel,
#right-nav-panel {

    background:
        linear-gradient(
            145deg,
            rgba(20, 12, 32, .94),
            rgba(7, 6, 12, .96)
        ) !important;

    border-color:
        var(--sarvita-border) !important;
}

/* =========================================================
   BUTTONS
   ========================================================= */

button,
.menu_button,
input[type="button"],
input[type="submit"] {

    transition:
        transform .18s ease,
        box-shadow .18s ease,
        border-color .18s ease;
}

button:hover,
.menu_button:hover {

    transform:
        translateY(-1px);

    box-shadow:
        0 0 20px
        rgba(196, 60, 255, .22);
}

/* =========================================================
   INPUTS
   ========================================================= */

input,
textarea,
select {

    border-color:
        rgba(196, 60, 255, .22) !important;
}

input:focus,
textarea:focus,
select:focus {

    border-color:
        var(--sarvita-primary) !important;

    box-shadow:
        0 0 0 2px
        rgba(196, 60, 255, .10),
        0 0 22px
        rgba(196, 60, 255, .18) !important;
}

/* =========================================================
   LINKS
   ========================================================= */

a {
    color: #d98aff;
}

a:hover {
    color: #ff74c4;
}

/* =========================================================
   SCROLLBAR
   ========================================================= */

::-webkit-scrollbar {
    width: 8px;
    height: 8px;
}

::-webkit-scrollbar-track {
    background:
        rgba(0, 0, 0, .25);
}

::-webkit-scrollbar-thumb {

    background:
        linear-gradient(
            180deg,
            var(--sarvita-primary),
            var(--sarvita-accent)
        );

    border-radius: 10px;
}

/* =========================================================
   SELECTION
   ========================================================= */

::selection {
    background:
        rgba(196, 60, 255, .35);

    color: white;
}

/* =========================================================
   SARVITA BOOT SCREEN
   ========================================================= */

#sarvita-arc-boot {

    position: fixed;

    inset: 0;

    z-index: 2147483647;

    display: flex;

    align-items: center;

    justify-content: center;

    overflow: hidden;

    background:
        linear-gradient(
            135deg,
            #050509,
            #0b0714,
            #170b24,
            #050509
        );

    background-size:
        300% 300%;

    animation:
        sarvitaBootGradient
        12s
        ease
        infinite;
}

#sarvita-arc-boot::before {

    content: "";

    position: absolute;

    width: 80vmax;
    height: 80vmax;

    border-radius: 50%;

    background:
        radial-gradient(
            circle,
            rgba(196, 60, 255, .22),
            rgba(255, 60, 172, .10),
            transparent 68%
        );

    filter:
        blur(45px);

    animation:
        sarvitaBootGlow
        8s
        ease-in-out
        infinite
        alternate;
}

#sarvita-arc-boot-content {

    position: relative;

    z-index: 2;

    display: flex;

    flex-direction: column;

    align-items: center;

    justify-content: center;

    gap: 28px;

    width: min(86vw, 520px);

    text-align: center;
}

#sarvita-arc-boot-image {

    width: min(68vw, 340px);

    max-height: 46vh;

    object-fit: contain;

    border-radius: 28px;

    box-shadow:
        0 0 35px
        rgba(196, 60, 255, .30),
        0 0 90px
        rgba(255, 60, 172, .15);

    animation:
        sarvitaBootImage
        5s
        ease-in-out
        infinite
        alternate;
}

#sarvita-arc-boot-brand {

    font-size: clamp(28px, 7vw, 52px);

    font-weight: 800;

    letter-spacing: .08em;

    color: white;

    text-shadow:
        0 0 20px
        rgba(196, 60, 255, .55),
        0 0 50px
        rgba(255, 60, 172, .25);
}

#sarvita-arc-boot-status {

    font-size: 16px;

    color:
        rgba(255,255,255,.72);

    letter-spacing:
        .18em;
}

@keyframes sarvitaBootGradient {

    0% {
        background-position:
            0% 50%;
    }

    50% {
        background-position:
            100% 50%;
    }

    100% {
        background-position:
            0% 50%;
    }
}

@keyframes sarvitaBootGlow {

    from {
        transform:
            translate(-12%, -8%)
            scale(.90);
    }

    to {
        transform:
            translate(12%, 8%)
            scale(1.10);
    }
}

@keyframes sarvitaBootImage {

    from {
        transform:
            translateY(0)
            scale(1);
    }

    to {
        transform:
            translateY(-8px)
            scale(1.035);
    }
}

/* =========================================================
   MOBILE
   ========================================================= */

@media (max-width: 700px) {

    #sarvita-arc-boot-image {

        width:
            min(78vw, 330px);

        border-radius:
            22px;
    }
}
EOF

echo "CSS created."

echo
echo "[9/12] Creating SarVita Arc boot screen..."

mkdir -p "$PUBLIC/scripts"

cat > "$BOOT_JS" <<'EOF'
(function () {
    "use strict";

    const BOOT_ID = "sarvita-arc-boot";

    function createBootScreen() {

        if (document.getElementById(BOOT_ID)) {
            return;
        }

        const boot = document.createElement("div");

        boot.id = BOOT_ID;

        boot.innerHTML = `
            <div id="sarvita-arc-boot-content">

                <img
                    id="sarvita-arc-boot-image"
                    src="/img/branding/sarvita-arc/main/sarvita-arc-main-square.png"
                    alt="SarVita Arc"
                >

                <div id="sarvita-arc-boot-brand">
                    SarVita Arc
                </div>

                <div id="sarvita-arc-boot-status">
                    Initializing...
                </div>

            </div>
        `;

        document.body.appendChild(boot);
    }

    function hideBootScreen() {

        const boot =
            document.getElementById(BOOT_ID);

        if (!boot) {
            return;
        }

        boot.style.transition =
            "opacity .45s ease";

        boot.style.opacity = "0";

        setTimeout(function () {

            if (boot && boot.parentNode) {
                boot.parentNode.removeChild(boot);
            }

        }, 500);
    }

    if (document.readyState === "loading") {

        document.addEventListener(
            "DOMContentLoaded",
            createBootScreen
        );

    } else {

        createBootScreen();
    }

    window.addEventListener(
        "load",
        function () {

            setTimeout(
                hideBootScreen,
                700
            );

        },
        { once: true }
    );

    setTimeout(
        hideBootScreen,
        10000
    );

})();
EOF

echo "Boot screen created."

echo
echo "[10/12] Updating manifest..."

python - "$MANIFEST" <<'PY'
import json
import os
import sys

manifest_path = sys.argv[1]

if os.path.exists(manifest_path):
    with open(manifest_path, "r", encoding="utf-8") as f:
        data = json.load(f)
else:
    data = {}

data["name"] = "SarVita Arc"
data["short_name"] = "SarVita Arc"
data["description"] = "SarVita Arc"
data["start_url"] = "/"
data["display"] = "standalone"
data["theme_color"] = "#0b0714"
data["background_color"] = "#050509"

data["icons"] = [
    {
        "src": "/img/branding/sarvita-arc/icons/icon-192x192.png",
        "sizes": "192x192",
        "type": "image/png",
        "purpose": "any"
    },
    {
        "src": "/img/branding/sarvita-arc/icons/icon-192x192.png",
        "sizes": "192x192",
        "type": "image/png",
        "purpose": "maskable"
    },
    {
        "src": "/img/branding/sarvita-arc/icons/icon-512x512.png",
        "sizes": "512x512",
        "type": "image/png",
        "purpose": "any"
    },
    {
        "src": "/img/branding/sarvita-arc/icons/icon-512x512.png",
        "sizes": "512x512",
        "type": "image/png",
        "purpose": "maskable"
    }
]

with open(manifest_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=4)

    f.write("\n")

print("manifest.json updated.")
PY

echo
echo "[11/12] Updating index.html..."

python - "$INDEX" <<'PY'
import sys
from pathlib import Path

path = Path(sys.argv[1])

text = path.read_text(encoding="utf-8")

# Title
import re

text = re.sub(
    r"<title>.*?</title>",
    "<title>SarVita Arc</title>",
    text,
    count=1,
    flags=re.DOTALL
)

# Remove previously injected SarVita CSS links
text = re.sub(
    r'\s*<link[^>]+sarvita-arc-brand\.css[^>]*>',
    '',
    text,
    flags=re.IGNORECASE
)

# Remove previous SarVita boot JS
text = re.sub(
    r'\s*<script[^>]+sarvita-arc-boot\.js[^>]*></script>',
    '',
    text,
    flags=re.IGNORECASE
)

# Remove previously injected favicon lines
text = re.sub(
    r'\s*<link[^>]+sarvita-arc/icons/[^>]*>',
    '',
    text,
    flags=re.IGNORECASE
)

head_insert = r'''
    <!-- SarVita Arc Visual Identity -->
    <link rel="stylesheet" href="css/sarvita-arc-brand.css">

    <!-- SarVita Arc Favicons -->
    <link rel="icon" type="image/png" sizes="16x16"
          href="img/branding/sarvita-arc/icons/favicon-16x16.png">

    <link rel="icon" type="image/png" sizes="32x32"
          href="img/branding/sarvita-arc/icons/favicon-32x32.png">

    <link rel="icon" type="image/png" sizes="48x48"
          href="img/branding/sarvita-arc/icons/favicon-48x48.png">

    <link rel="apple-touch-icon"
          href="img/branding/sarvita-arc/icons/apple-touch-icon.png">

    <link rel="manifest"
          href="manifest.json">
'''

text = re.sub(
    r"</head>",
    head_insert + "\n</head>",
    text,
    count=1,
    flags=re.IGNORECASE
)

# Boot script before </body>
boot_script = r'''
    <script src="scripts/sarvita-arc-boot.js"></script>
'''

text = re.sub(
    r"</body>",
    boot_script + "\n</body>",
    text,
    count=1,
    flags=re.IGNORECASE
)

# Replace visible branding strings only
text = text.replace(
    "Welcome to SarVita Arc!",
    "Welcome to SarVita Arc!"
)

text = text.replace(
    "SarVita Arc is aimed at advanced users.",
    "SarVita Arc"
)

path.write_text(text, encoding="utf-8")

print("index.html updated.")
PY

echo
echo "[12/12] Final verification..."

echo
echo "=================================================="
echo "MAIN IMAGE"
echo "=================================================="

find "$MAIN" -maxdepth 1 -type f -print | sort

echo
echo "=================================================="
echo "ICONS"
echo "=================================================="

find "$ICONS" -maxdepth 1 -type f -print | sort

echo
echo "=================================================="
echo "GALLERY"
echo "=================================================="

find "$GALLERY" -maxdepth 1 -type f -print | sort

echo
echo "=================================================="
echo "BRANDING CHECK"
echo "=================================================="

grep -n "<title>" "$INDEX" || true

grep -n "sarvita-arc-brand.css" "$INDEX" || true

grep -n "sarvita-arc-boot.js" "$INDEX" || true

echo
echo "=================================================="
echo "IMAGE COUNT"
echo "=================================================="

echo "Gallery:"
find "$GALLERY" -type f | wc -l

echo "Icons:"
find "$ICONS" -type f | wc -l

echo
echo "=================================================="
echo "GIT CHECK"
echo "=================================================="

git diff --check

echo
echo "=================================================="
echo "SARVITA ARC BRANDING COMPLETED"
echo "=================================================="

echo
echo "Main:"
echo "$MAIN"

echo
echo "Icons:"
echo "$ICONS"

echo
echo "Gallery:"
echo "$GALLERY"

echo
echo "CSS:"
echo "$CSS"

echo
echo "Boot:"
echo "$BOOT_JS"

echo
echo "Backup:"
echo "$BACKUP"

echo
echo "=================================================="
echo "DONE"
echo "=================================================="
