#!/bin/sh
# Sinh app icon (PNG/ICNS/ICO) tu file SVG nguon.
# Tools support theo thu tu uu tien: rsvg-convert > magick > convert > inkscape
# Neu khong co tool nao -> bo qua silent (build van chay).
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_SVG="${1:-$SCRIPT_DIR/../src/gameStory/gameStory_logo.svg}"
OUT_DIR="${2:-$SCRIPT_DIR}"

if [ ! -f "$SOURCE_SVG" ]; then
    echo "[ICON] SVG nguon khong ton tai: $SOURCE_SVG -- bo qua."
    exit 0
fi

# Tu dong detect rasterizer
RASTERIZE=""
if command -v rsvg-convert >/dev/null 2>&1; then RASTERIZE="rsvg"
elif command -v magick      >/dev/null 2>&1; then RASTERIZE="magick"
elif command -v convert     >/dev/null 2>&1; then RASTERIZE="convert"
elif command -v inkscape    >/dev/null 2>&1; then RASTERIZE="inkscape"
fi

if [ -z "$RASTERIZE" ]; then
    echo "[ICON] Khong tim thay rsvg-convert / ImageMagick / Inkscape."
    echo "       De co app icon, cai mot trong cac tool sau:"
    echo "         macOS  : brew install librsvg"
    echo "         Ubuntu : sudo apt install librsvg2-bin"
    echo "         Windows: choco install rsvg-convert"
    echo "       Bo qua sinh icon -- build van se thanh cong."
    exit 0
fi

mkdir -p "$OUT_DIR"

# Helper: rasterize SVG -> PNG
svg_to_png() {
    src="$1"; size="$2"; dst="$3"
    case "$RASTERIZE" in
        rsvg)     rsvg-convert -w "$size" -h "$size" "$src" -o "$dst" ;;
        magick)   magick -background none -size "${size}x${size}" "$src" -resize "${size}x${size}" "$dst" ;;
        convert)  convert -background none -size "${size}x${size}" "$src" -resize "${size}x${size}" "$dst" ;;
        inkscape) inkscape -w "$size" -h "$size" "$src" -o "$dst" ;;
    esac
}

echo "[ICON] Generate icons tu $SOURCE_SVG (rasterizer: $RASTERIZE) ..."

# PNG cho PWA + Linux desktop
svg_to_png "$SOURCE_SVG" 192  "$OUT_DIR/icon-192.png"
svg_to_png "$SOURCE_SVG" 512  "$OUT_DIR/icon-512.png"
svg_to_png "$SOURCE_SVG" 1024 "$OUT_DIR/icon-1024.png"

# ICO cho Windows: dong nhieu kich thuoc vao 1 file (chi ImageMagick lam duoc)
if [ "$RASTERIZE" = "magick" ] || [ "$RASTERIZE" = "convert" ]; then
    TOOL="$RASTERIZE"
    for s in 16 32 48 64 128 256; do
        svg_to_png "$SOURCE_SVG" "$s" "$OUT_DIR/_tmp_${s}.png"
    done
    "$TOOL" "$OUT_DIR"/_tmp_16.png "$OUT_DIR"/_tmp_32.png \
            "$OUT_DIR"/_tmp_48.png "$OUT_DIR"/_tmp_64.png \
            "$OUT_DIR"/_tmp_128.png "$OUT_DIR"/_tmp_256.png \
            "$OUT_DIR/icon.ico"
    rm -f "$OUT_DIR"/_tmp_*.png
    echo "[ICON] Da sinh icon.ico"
else
    echo "[ICON] Bo qua icon.ico (yeu cau ImageMagick)."
fi

# ICNS cho macOS: dung iconutil + cac kich thuoc chuan cua Apple
if [ "$(uname -s)" = "Darwin" ]; then
    ICONSET="$OUT_DIR/icon.iconset"
    rm -rf "$ICONSET"
    mkdir -p "$ICONSET"
    svg_to_png "$SOURCE_SVG" 16   "$ICONSET/icon_16x16.png"
    svg_to_png "$SOURCE_SVG" 32   "$ICONSET/icon_16x16@2x.png"
    svg_to_png "$SOURCE_SVG" 32   "$ICONSET/icon_32x32.png"
    svg_to_png "$SOURCE_SVG" 64   "$ICONSET/icon_32x32@2x.png"
    svg_to_png "$SOURCE_SVG" 128  "$ICONSET/icon_128x128.png"
    svg_to_png "$SOURCE_SVG" 256  "$ICONSET/icon_128x128@2x.png"
    svg_to_png "$SOURCE_SVG" 256  "$ICONSET/icon_256x256.png"
    svg_to_png "$SOURCE_SVG" 512  "$ICONSET/icon_256x256@2x.png"
    svg_to_png "$SOURCE_SVG" 512  "$ICONSET/icon_512x512.png"
    svg_to_png "$SOURCE_SVG" 1024 "$ICONSET/icon_512x512@2x.png"
    iconutil -c icns "$ICONSET" -o "$OUT_DIR/icon.icns"
    rm -rf "$ICONSET"
    echo "[ICON] Da sinh icon.icns"
fi

echo "[ICON] Hoan tat -- xem $OUT_DIR"