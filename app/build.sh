#!/bin/sh
# Tap lenh build tich hop -- SDL3 native + WASM (auto setup emsdk)
set -e

echo "================================================="
echo "  ctetris -- Build Script (SDL3)"
echo "================================================="

# Phien ban emsdk da kiem chung tuong thich voi SDL3 native port
EMSDK_VERSION="3.1.72"
EMSDK_DIR="${HOME}/emsdk"

# --- Tu dong dam bao nanosvg headers (single-header lib cho gameStory) ---
ensure_nanosvg() {
    INCLUDE_DIR="src/gameStory/include"
    NANOSVG_BASE_URL="https://raw.githubusercontent.com/memononen/nanosvg/master/src"
    mkdir -p "$INCLUDE_DIR"

    if ! command -v curl >/dev/null 2>&1; then
        echo "[LOI] Thieu cong cu 'curl' de tai nanosvg headers."
        echo "      macOS: curl co san  |  Ubuntu: sudo apt-get install curl"
        exit 1
    fi

    if [ ! -s "$INCLUDE_DIR/nanosvg.h" ]; then
        echo "Thieu nanosvg.h -- dang tai ve $INCLUDE_DIR/ ..."
        if ! curl -fsSL -o "$INCLUDE_DIR/nanosvg.h" "$NANOSVG_BASE_URL/nanosvg.h"; then
            echo "[LOI] Khong tai duoc nanosvg.h."
            rm -f "$INCLUDE_DIR/nanosvg.h"
            exit 1
        fi
    fi

    if [ ! -s "$INCLUDE_DIR/nanosvgrast.h" ]; then
        echo "Thieu nanosvgrast.h -- dang tai ve $INCLUDE_DIR/ ..."
        if ! curl -fsSL -o "$INCLUDE_DIR/nanosvgrast.h" "$NANOSVG_BASE_URL/nanosvgrast.h"; then
            echo "[LOI] Khong tai duoc nanosvgrast.h."
            rm -f "$INCLUDE_DIR/nanosvgrast.h"
            exit 1
        fi
    fi
}

ensure_nanosvg

# --- Tu dong sinh gameStory_logo_svg.h tu gameStory_logo.svg ---
generate_logo_header() {
    SVG_FILE="src/gameStory/gameStory_logo.svg"
    HEADER_FILE="src/gameStory/include/gameStory_logo_svg.h"

    if [ ! -f "$SVG_FILE" ]; then
        echo "[LOI] Khong tim thay $SVG_FILE"
        exit 1
    fi

    # Skip neu header da moi hon SVG (giong cach make tinh dependency)
    if [ -f "$HEADER_FILE" ] && [ "$HEADER_FILE" -nt "$SVG_FILE" ]; then
        return 0
    fi

    echo "Sinh $HEADER_FILE tu $SVG_FILE ..."
    {
        echo "#pragma once"
        echo "// File nay duoc sinh tu dong tu gameStory_logo.svg boi build.sh"
        echo "// KHONG sua tay -- moi thay doi se bi ghi de o lan build tiep theo."
        echo "static const char* LOGO_SVG_DATA = R\"SVG_RAW_LOGO("
        cat "$SVG_FILE"
        echo ")SVG_RAW_LOGO\";"
    } > "$HEADER_FILE"
}

generate_logo_header

# Helper: kiem tra cong cu, fail-fast neu thieu
require_tool() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "[LOI] Thieu cong cu '$1'."
        echo "      $2"
        exit 1
    fi
}

# Helper: dam bao emsdk san sang trong subshell hien tai
# Logic: detect emcmake -> thu source -> prompt cai dat -> clone -> install -> activate -> source -> verify
ensure_emsdk() {
    # Buoc 1: emcmake da co san trong PATH (vi du user da source truoc khi chay build.sh) -> done
    if command -v emcmake >/dev/null 2>&1; then
        echo "[OK] Emscripten da san sang: $(emcc --version 2>/dev/null | head -1)"
        return 0
    fi

    # Buoc 2: thu source emsdk_env.sh neu thu muc emsdk da ton tai (truong hop user
    # da clone+install+activate truoc do nhung mo terminal moi nen PATH bi mat)
    if [ -f "$EMSDK_DIR/emsdk_env.sh" ]; then
        echo "[INFO] Tim thay $EMSDK_DIR, dang source emsdk_env.sh..."
        # shellcheck disable=SC1091
        . "$EMSDK_DIR/emsdk_env.sh" >/dev/null 2>&1 || true
        if command -v emcmake >/dev/null 2>&1; then
            echo "[OK] Emscripten kich hoat: $(emcc --version 2>/dev/null | head -1)"
            return 0
        fi
        echo "[INFO] Source xong nhung van thieu emcmake -- co the chua activate version $EMSDK_VERSION."
    fi

    # Buoc 3: hoi user truoc khi tu dong cai dat (theo rule task.md - khong silent install)
    echo "[INFO] Emscripten chua san sang trong shell hien tai."
    printf "Cai/kich hoat emsdk %s vao %s? [y/N]: " "$EMSDK_VERSION" "$EMSDK_DIR"
    read ans
    case "$ans" in
        [Yy]*) ;;
        *)
            echo ""
            echo "Huy. De cai thu cong:"
            echo "  cd ~ && git clone https://github.com/emscripten-core/emsdk.git"
            echo "  cd ~/emsdk && ./emsdk install $EMSDK_VERSION && ./emsdk activate $EMSDK_VERSION"
            echo "  source ~/emsdk/emsdk_env.sh"
            echo "  cd - && bash build.sh"
            exit 1
            ;;
    esac

    # Buoc 4: clone neu chua co
    if [ ! -d "$EMSDK_DIR" ]; then
        require_tool git "macOS: brew install git  |  Ubuntu: sudo apt-get install git"
        echo "Clone emsdk vao $EMSDK_DIR ..."
        git clone https://github.com/emscripten-core/emsdk.git "$EMSDK_DIR"
    fi

    # Buoc 5: install + activate (idempotent: chay lai khong co tac dung phu)
    echo "Install emsdk $EMSDK_VERSION ..."
    ( cd "$EMSDK_DIR" && ./emsdk install  "$EMSDK_VERSION" )
    echo "Activate emsdk $EMSDK_VERSION ..."
    ( cd "$EMSDK_DIR" && ./emsdk activate "$EMSDK_VERSION" )

    # Buoc 6: source vao subshell hien tai cua build.sh de cap nhat PATH/EMSDK/EM_*
    # shellcheck disable=SC1091
    . "$EMSDK_DIR/emsdk_env.sh"

    # Buoc 7: verify lan cuoi -- neu van thieu thi env script da bi loi
    if ! command -v emcmake >/dev/null 2>&1; then
        echo "[LOI] Khong tim thay emcmake sau khi source $EMSDK_DIR/emsdk_env.sh"
        echo "      Hay kiem tra thu muc $EMSDK_DIR roi chay lai."
        exit 1
    fi
    echo "[OK] Emscripten da san sang: $(emcc --version 2>/dev/null | head -1)"

    # Goi y persist cau hinh de lan sau khoi phai source thu cong moi terminal
    echo ""
    echo "[GOI Y] De lan sau khong phai source thu cong, them dong nay vao ~/.zprofile:"
    echo "        echo 'source \"$EMSDK_DIR/emsdk_env.sh\"' >> ~/.zprofile"
    echo ""
}
# --- Tu dong sinh app icon (PNG/ICNS/ICO) tu SVG ---
# Goi gen_icons.sh -- script tu graceful skip neu khong co rasterizer
if [ -f icons/gen_icons.sh ]; then
    sh icons/gen_icons.sh || true
fi
# --- Hoi target ---
echo "Ban muon build gi?"
echo "  1) Toan bo chuong trinh tich hop (ctetris)"
echo "  2) Rieng gameStory"
echo "  3) Rieng gameConsole"
echo "  4) Rieng gameCore"
printf "Lua chon [1-4]: "; read build_choice

case "$build_choice" in
    2) TARGET="gameStory" ;;
    3) TARGET="gameConsole" ;;
    4) TARGET="gameCore" ;;
    *) TARGET="ctetris" ;;
esac

# --- Hoi nen tang ---
echo "Chon nen tang build:"
echo "  1) Native (macOS / Ubuntu)"
echo "  2) WebAssembly (WASM)"
printf "Lua chon [1-2]: "; read plat_choice

CURRENT_OS=$(uname -s)

# =========== Nhanh WASM ===========
if [ "$plat_choice" = "2" ]; then
    echo "Kiem tra moi truong WASM..."
    require_tool ninja "macOS: brew install ninja  |  Ubuntu: sudo apt-get install ninja-build"
    ensure_emsdk

    BUILD_DIR="build/wasm"
    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"

    echo ""
    echo "[INFO] Lan build WASM dau tien se tai SDL3 source (~10MB) va"
    echo "       build cung -- mat khoang 1-2 phut. Cac lan sau dung cache."
    echo ""
    echo "Cau hinh CMake voi emcmake..."
    emcmake cmake -G Ninja ../..

    echo "Bien dich target: $TARGET ..."
    cmake --build . --target "$TARGET"

    echo ""
    echo "Build WASM thanh cong tai $BUILD_DIR."
    echo "Cach chay tren localhost:"
    echo "  cd $BUILD_DIR && python3 -m http.server 8000"
    echo "  Mo trinh duyet: http://localhost:8000/${TARGET}.html"
    exit 0
fi

# =========== Nhanh Native ===========
if [ "$CURRENT_OS" = "Linux" ]; then
    echo "Kiem tra dependencies cho Linux (SDL3)..."
    if ! command -v cmake >/dev/null 2>&1; then sudo apt-get update && sudo apt-get install -y cmake; fi
    if ! command -v ninja >/dev/null 2>&1; then sudo apt-get install -y ninja-build; fi
    if ! dpkg -s libsdl3-dev >/dev/null 2>&1; then
        echo "[LOI] libsdl3-dev khong co tren apt mac dinh."
        echo "      Build SDL3 thu cong tu: https://github.com/libsdl-org/SDL"
        exit 1
    fi
elif [ "$CURRENT_OS" = "Darwin" ]; then
    echo "Kiem tra dependencies cho macOS (SDL3)..."
    require_tool brew "Cai Homebrew tu https://brew.sh truoc."
    if ! command -v cmake >/dev/null 2>&1; then brew install cmake; fi
    if ! command -v ninja >/dev/null 2>&1; then brew install ninja; fi
    if ! brew list sdl3 >/dev/null 2>&1; then brew install sdl3; fi
fi

BUILD_DIR="build/local"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "Cau hinh CMake..."
cmake -G Ninja ../..

echo "Bien dich Ninja target: $TARGET ..."
ninja "$TARGET"

echo ""
echo "Build thanh cong! Ket qua trong $BUILD_DIR/"
if [ "$CURRENT_OS" = "Darwin" ]; then
    echo "Tren macOS: open $BUILD_DIR/${TARGET}.app"
fi