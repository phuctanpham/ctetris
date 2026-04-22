#!/bin/sh
# build.sh - Cross-platform build helper for gameStory (sh/bash/zsh compatible)

set -e

echo "Select target platform to build for:"
echo "1) macOS"
echo "2) Windows"
echo "3) Linux"
printf "Enter choice [1-3]: "
read platform

case "$platform" in
    1)
        TARGET="macOS"
        ;;
    2)
        TARGET="Windows"
        ;;
    3)
        TARGET="Linux"
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

# Ensure build directory exists
if [ ! -d "build" ]; then
    echo "Creating build directory..."
    mkdir build
fi

cd build

echo "Running CMake for $TARGET..."
if [ "$TARGET" = "Windows" ]; then
    cmake -G "Unix Makefiles" -DCMAKE_SYSTEM_NAME=Windows ..
else
    cmake ..
fi

echo "Building..."
make

# Show how to run the executable
if [ "$TARGET" = "Windows" ]; then
    echo "To run the executable, double-click the .exe file in the build directory or run:"
    echo "  ./build/gameStory.exe"
else
    echo "To run the executable, use:"
    echo "  ./build/gameStory"
fi
