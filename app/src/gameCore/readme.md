# Tetris C++ (SFML 3.0)

A classic Tetris clone built with C++ and the modern **SFML 3.0.2** multimedia library. This project focuses on clean logic, mathematical rotation matrices, and a modernized 16:9 UI without relying on external image assets for gameplay.

## 🎮 Features
* **Modern Controls:** Supports both Arrow keys and WASD (uses Scancodes to prevent input conflicts with Vietnamese typing software).
* **Algorithmic Rotation:** Uses linear algebra (2D rotation matrix) to rotate blocks around a pivot point instead of hardcoding shape states.
* **Core Mechanics:** Full collision detection, line clearing, scoring system, and Next Block preview.
* **Game States:** Includes Game Over detection and a Restart mechanic.
* **Asset-less Rendering:** Blocks are rendered using `sf::RectangleShape` for a crisp, scalable look.

## 🛠️ Prerequisites
To build and run this project, your environment must meet the following requirements:
* **IDE:** Visual Studio 2026 (or earlier versions like 2022) with the "Desktop development with C++" workload installed.
* **Compiler Standard:** ISO C++17 Standard (Required by SFML 3.0).
* **Architecture:** x64 (64-bit).
* **Library:** [SFML 3.0.2 (Visual C++ 17 - 64-bit)](https://www.sfml-dev.org/download.php).

## 🚀 Setup & Installation

**1. Configure SFML Library**
* Download and extract SFML 3.0.2 to your local drive (e.g., `C:\SFML`).
* Open the project Properties in Visual Studio (`Configuration: Debug`, `Platform: x64`):
  * **C/C++ -> General -> Additional Include Directories:** Add `C:\SFML\include`
  * **Linker -> General -> Additional Library Directories:** Add `C:\SFML\lib`
  * **Linker -> Input -> Additional Dependencies:** Add the following:
    ```text
    sfml-graphics-d.lib
    sfml-window-d.lib
    sfml-system-d.lib
    sfml-audio-d.lib
    ```

**2. Missing DLLs & Font**
For the game to run correctly, ensure the following files are placed in the same directory as your source code (`main.cpp`) or your executable (`.exe`):
* The SFML dynamic libraries from `C:\SFML\bin` (e.g., `sfml-graphics-d-3.dll`, `sfml-window-d-3.dll`, etc.).
* A valid font file named `arial.ttf` (You can copy this from `C:\Windows\Fonts`).

## 🕹️ Controls
* **Left / Right / A / D:** Move block horizontally.
* **Up / W:** Rotate block 90 degrees.
* **Down / S:** Soft drop (speed up falling).
* **R:** Restart the game (only available on the Game Over screen).

## 🧠 Technical Notes for Reviewers
* The block shapes are highly compressed into a 1D array (`figures[7][4]`), representing a 2x4 grid layout.
* The game uses `std::optional` for event polling, adhering to the new SFML 3.0 API changes.