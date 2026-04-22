#!/bin/bash
# Build script for gameCore (macOS/Linux)
set -e
mkdir -p build
cd build
cmake ..
make -j$(sysctl -n hw.ncpu 2>/dev/null || nproc)
cd ..
echo "Build complete. Run ./build/gameCore to start."
