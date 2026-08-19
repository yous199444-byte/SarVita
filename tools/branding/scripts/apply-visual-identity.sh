#!/data/data/com.termux/files/usr/bin/bash

set -e

ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$ROOT"

ASSET_DIR="public/img/branding/sarvita-arc"
MAIN_DIR="$ASSET_DIR/main"
ICON_DIR="$ASSET_DIR/icons"
GALLERY_DIR="$ASSET_DIR/gallery"
CSS_DIR="public/css"

echo "=== SarVita Arc Visual Identity ==="

mkdir -p "$MAIN_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$GALLERY_DIR"
mkdir -p "$CSS_DIR"

echo "[1/7] Installing image tools..."

pkg install -y imagemagick curl >/dev/null 2>&1 || true

echo "[2/7] Downloading main image..."

curl -L --fail --silent --show-error \
"https://i.imgur.com/drzlubD.jpeg" \
-o "$MAIN_DIR/sarvita-arc-main.jpeg"

echo "[3/7] Downloading gallery..."

declare -a IMAGES=(
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

i=1

for URL in "${IMAGES[@]}"; do
    NUM=$(printf "%02d" "$i")

    echo "Downloading image $NUM/25..."

    curl -L --fail --silent --show-error \
    "$URL" \
    -o "$GALLERY_DIR/image-${NUM}.jpeg"

    i=$((i+1))
done

echo "[4/7] Creating application icons..."

convert "$MAIN_DIR/sarvita-arc-main.jpeg" \
    -auto-orient \
    -resize "1200x1200^" \
    -gravity center \
    -extent 1200x1200 \
    "$MAIN_DIR/sarvita-arc-square.png"

for SIZE in 57 72 96 114 144 152 180 192 256 384 512 1024; do

    echo "Creating icon ${SIZE}x${SIZE}..."

    convert "$MAIN_DIR/sarvita-arc-square.png" \
        -resize "${SIZE}x${SIZE}" \
        "$ICON_DIR/icon-${SIZE}x${SIZE}.png"

done

echo "[5/7] Creating favicon..."

convert "$MAIN_DIR/sarvita-arc-square.png" \
    -resize 16x16 \
    "$ICON_DIR/favicon-16x16.png"

convert "$MAIN_DIR/sarvita-arc-square.png" \
    -resize 32x32 \
    "$ICON_DIR/favicon-32x32.png"

convert "$MAIN_DIR/sarvita-arc-square.png" \
    -resize 48x48 \
    "$ICON_DIR/favicon-48x48.png"

convert "$MAIN_DIR/sarvita-arc-square.png" \
    -resize 180x180 \
    "$ICON_DIR/apple-touch-icon.png"

echo "[6/7] Creating optimized gallery sizes..."

for FILE in "$GALLERY_DIR"/image-*.jpeg; do

    NAME="$(basename "$FILE" .jpeg)"

    convert "$FILE" \
        -auto-orient \
        -resize "320x320^" \
        -gravity center \
        -extent 320x320 \
        -quality 82 \
        "$GALLERY_DIR/${NAME}-320.jpg"

    convert "$FILE" \
        -auto-orient \
        -resize "640x640^" \
        -gravity center \
        -extent 640x640 \
        -quality 85 \
        "$GALLERY_DIR/${NAME}-640.jpg"

    convert "$FILE" \
        -auto-orient \
        -resize "1024x1024^" \
        -gravity center \
        -extent 1024x1024 \
        -quality 88 \
        "$GALLERY_DIR/${NAME}-1024.jpg"

done

echo "[7/7] Creating SarVita Arc animated visual layer..."

cat > "$CSS_DIR/sarvita-arc-brand.css" <<'CSS'

/* =========================================================
   SarVita Arc Visual Identity
   ========================================================= */

:root {
    --sarvita-bg-1: #090711;
    --sarvita-bg-2: #171024;
    --sarvita-bg-3: #29153b;
    --sarvita-glow-1: rgba(170, 90, 255, 0.22);
    --sarvita-glow-2: rgba(255, 80, 180, 0.18);
    --sarvita-glow-3: rgba(80, 150, 255, 0.16);
}

/* Animated application background */

body {
    background:
        radial-gradient(
            circle at 15% 20%,
            var(--sarvita-glow-1),
            transparent 32%
        ),
        radial-gradient(
            circle at 85% 30%,
            var(--sarvita-glow-2),
            transparent 34%
        ),
        radial-gradient(
            circle at 50% 90%,
            var(--sarvita-glow-3),
            transparent 36%
        ),
        linear-gradient(
            135deg,
            var(--sarvita-bg-1),
            var(--sarvita-bg-2),
            var(--sarvita-bg-3),
            var(--sarvita-bg-1)
        );

    background-size:
        180% 180%,
        170% 170%,
        190% 190%,
        400% 400%;

    animation: sarvitaAnimatedBackground 18s ease-in-out infinite;

    min-height: 100vh;
}

@keyframes sarvitaAnimatedBackground {

    0% {
        background-position:
            0% 0%,
            100% 0%,
            50% 100%,
            0% 50%;
    }

    25% {
        background-position:
            60% 20%,
            30% 70%,
            80% 30%,
            50% 0%;
    }

    50% {
        background-position:
            100% 80%,
            0% 50%,
            20% 0%,
            100% 50%;
    }

    75% {
        background-position:
            40% 100%,
            80% 20%,
            0% 80%,
            50% 100%;
    }

    100% {
        background-position:
            0% 0%,
            100% 0%,
            50% 100%,
            0% 50%;
    }
}

/* Main SarVita Arc visual */

.sarvita-arc-main-visual {
    position: relative;
    overflow: hidden;
    border-radius: 24px;
    isolation: isolate;
    box-shadow:
        0 20px 70px rgba(0, 0, 0, 0.55),
        0 0 60px rgba(170, 90, 255, 0.18);
}

.sarvita-arc-main-visual::before {
    content: "";
    position: absolute;
    inset: -30%;
    z-index: -1;

    background:
        radial-gradient(
            circle at 20% 30%,
            rgba(170, 90, 255, 0.30),
            transparent 30%
        ),
        radial-gradient(
            circle at 80% 70%,
            rgba(255, 80, 180, 0.24),
            transparent 30%
        ),
        linear-gradient(
            120deg,
            rgba(20, 10, 40, 0.8),
            rgba(100, 40, 130, 0.55),
            rgba(20, 10, 40, 0.8)
        );

    animation: sarvitaGlowMove 14s ease-in-out infinite alternate;
}

@keyframes sarvitaGlowMove {

    0% {
        transform: translate3d(-4%, -3%, 0) rotate(0deg);
    }

    50% {
        transform: translate3d(5%, 4%, 0) rotate(2deg);
    }

    100% {
        transform: translate3d(-2%, 5%, 0) rotate(-2deg);
    }
}

/* Main image */

.sarvita-arc-main-image {
    display: block;
    width: 100%;
    height: auto;
    object-fit: cover;
}

/* Gallery */

.sarvita-arc-gallery {
    display: grid;
    grid-template-columns: repeat(
        auto-fit,
        minmax(180px, 1fr)
    );
    gap: 14px;
}

.sarvita-arc-gallery img {
    width: 100%;
    aspect-ratio: 1 / 1;
    object-fit: cover;
    border-radius: 18px;
    transition:
        transform 0.35s ease,
        filter 0.35s ease,
        box-shadow 0.35s ease;
}

.sarvita-arc-gallery img:hover {
    transform: translateY(-4px) scale(1.025);
    filter: brightness(1.08) saturate(1.08);
    box-shadow:
        0 14px 40px rgba(0, 0, 0, 0.45),
        0 0 25px rgba(170, 90, 255, 0.20);
}

/* Respect reduced-motion preference */

@media (prefers-reduced-motion: reduce) {

    body,
    .sarvita-arc-main-visual::before {
        animation: none !important;
    }

    .sarvita-arc-gallery img {
        transition: none !important;
    }
}

CSS

echo ""
echo "=============================================="
echo "SarVita Arc visual identity completed."
echo "=============================================="
echo ""
echo "Main image:"
echo "$MAIN_DIR/sarvita-arc-main.jpeg"
echo ""
echo "Icons:"
echo "$ICON_DIR"
echo ""
echo "Gallery:"
echo "$GALLERY_DIR"
echo ""
echo "CSS:"
echo "$CSS_DIR/sarvita-arc-brand.css"
echo ""

