#!/bin/sh
# build.sh - Cross-platform build helper for gameStory (sh/bash/zsh compatible)

#!/bin/sh
# build.sh - Cross-platform build helper for gameStory (sh/bash/zsh compatible)

set -e

echo "Select target platform to build for:"
echo "1) Ubuntu (Linux)"
echo "2) macOS"
printf "Enter choice [1-2]: "
read platform

if [[ "$platform" == "1" ]]; then
    TARGET="Ubuntu"
elif [[ "$platform" == "2" ]]; then
    install_brew_deps_if_needed() {
        BREW_DEPS=(bison flac libogg pkgconf cmake freetype libpng sfml doxygen giflib libvorbis)
        MISSING_DEPS=()
        for dep in "${BREW_DEPS[@]}"; do
            if ! brew list --formula | grep -q "^$dep$"; then
                MISSING_DEPS+=("$dep")
            fi
        done
        if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
            echo "Các thư viện sau chưa được cài đặt qua brew: ${MISSING_DEPS[*]}"
            read -p "Bạn có muốn cài đặt các thư viện này không? [y/N]: " install_brew_deps
            if [[ "$install_brew_deps" =~ ^[Yy]$ ]]; then
                brew install ${MISSING_DEPS[*]}
            else
                echo "Aborting build."
                exit 1
            fi
        fi
    }
    TARGET="macOS"
    # Danh sách các thư viện cần kiểm tra
    BREW_DEPS=(bison flac libogg pkgconf cmake freetype libpng sfml doxygen giflib libvorbis)
    MISSING_DEPS=()
    for dep in "${BREW_DEPS[@]}"; do
        if ! brew list --formula | grep -q "^$dep$"; then
            MISSING_DEPS+=("$dep")
        fi
        install_brew_deps_if_needed
            exit 1
        fi
    fi
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Ensure build directory exists
if [ -d "build" ]; then
    read -p "Thư mục build đã tồn tại. Bạn có muốn xoá thư mục build cũ không? [y/N]: " remove_build
    if [[ "$remove_build" =~ ^[Yy]$ ]]; then
        echo "Đang xoá thư mục build cũ..."
        rm -rf build
        echo "Đã xoá thư mục build cũ."
    fi
fi
if [ ! -d "build" ]; then
    echo "Tạo thư mục build..."
    mkdir build
fi

cd build


echo "Running CMake for $TARGET..."
cmake ..

echo "Building..."
make

# Show how to run the executable

# Function to check command existence
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check SFML version and location
check_sfml_version() {
    local version=""
    local config_paths=(
        "/usr/local/lib/cmake/SFML/SFMLConfigVersion.cmake"
        "/usr/lib/cmake/SFML/SFMLConfigVersion.cmake"
        "/opt/homebrew/lib/cmake/SFML/SFMLConfigVersion.cmake"
    )
    if command_exists pkg-config; then
        version=$(pkg-config --modversion sfml-all 2>/dev/null || true)
    fi
    for path in "${config_paths[@]}"; do
        if [ -f "$path" ]; then
            version_file=$(grep "set(SFML_VERSION" "$path" | grep -o '[0-9]\.[0-9]\.[0-9]')
            if [ -n "$version_file" ]; then
                version="$version_file"
                break
            fi
        fi
    done
    if [[ "$version" == 3.* ]]; then
        echo "SFML version 3.x detected: $version"
        return 0
    elif [[ -n "$version" ]]; then
        echo "SFML version $version detected (not 3.x)."
        read -p "Do you want to clean up the old SFML version and reinstall SFML 3? [y/N]: " cleanup
        if [[ "$cleanup" =~ ^[Yy]$ ]]; then
            echo "Cleaning up old SFML..."
            sudo rm -rf /usr/local/lib/cmake/SFML /usr/local/include/SFML /usr/local/lib/libsfml* /usr/lib/cmake/SFML /usr/lib/libsfml* /opt/homebrew/lib/cmake/SFML /opt/homebrew/include/SFML /opt/homebrew/lib/libsfml*
            return 1
        else
            echo "Aborting build."
            exit 1
        fi
    else
        echo "SFML not found."
        read -p "Do you want to install SFML 3? [y/N]: " install_sfml
        if [[ "$install_sfml" =~ ^[Yy]$ ]]; then
            return 1
        else
            echo "Aborting build."
            exit 1
        fi
    fi
}

check_sfml_version || {
    echo "Updating apt..."
    sudo apt update
    if ! command_exists cmake; then
        echo "Installing cmake..."
        sudo apt install -y cmake
    fi
    sudo apt install -y g++ libx11-dev libxrandr-dev libudev-dev libopengl-dev libflac-dev libvorbis-dev libopenal-dev libfreetype-dev libxcursor-dev libxi-dev libgl1-mesa-dev libmbedtls-dev libogg-dev libssh2-1-dev libharfbuzz-dev libgif-dev
    if ! command_exists git; then
        echo "Installing git..."
        sudo apt install -y git
    fi
    TMP_SFML_DIR="$HOME/SFML"
    if [ ! -d "$TMP_SFML_DIR" ]; then
        git clone https://github.com/SFML/SFML.git "$TMP_SFML_DIR"
    fi
    cd "$TMP_SFML_DIR"
    git fetch --all
    git checkout master
    git pull
    mkdir -p build && cd build
    rm -rf *
    cmake .. -DCMAKE_BUILD_TYPE=Release
    make -j$(nproc)
    sudo make install
    sudo ldconfig
    cd -
}

echo "To run the executable, use:"
echo "  ./build/gameStory"
