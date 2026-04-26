cmake_minimum_required(VERSION 3.16)
project(ctetris VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Path constants dung khap CMakeLists
set(WEB_DIR    "${CMAKE_CURRENT_SOURCE_DIR}/web")
set(ICONS_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/icons")
set(SOURCE_SVG "${CMAKE_CURRENT_SOURCE_DIR}/src/gameStory/gameStory_logo.svg")

# --- Cau hinh SDL3 theo target ---
# Native: find_package SDL3 da cai san
# WASM: FetchContent + build SDL3 tu source (cờ -sUSE_SDL=3 cua emsdk 3.1.72 khong on dinh)
if(EMSCRIPTEN)
    include(FetchContent)
    set(SDL_SHARED       OFF CACHE BOOL "" FORCE)
    set(SDL_STATIC       ON  CACHE BOOL "" FORCE)
    set(SDL_TEST_LIBRARY OFF CACHE BOOL "" FORCE)
    set(SDL_TESTS        OFF CACHE BOOL "" FORCE)
    set(SDL_INSTALL      OFF CACHE BOOL "" FORCE)
    set(SDL_DISABLE_INSTALL ON CACHE BOOL "" FORCE)
    FetchContent_Declare(
        SDL3
        GIT_REPOSITORY https://github.com/libsdl-org/SDL.git
        GIT_TAG        release-3.2.18
        GIT_SHALLOW    TRUE
    )
    FetchContent_MakeAvailable(SDL3)
else()
    find_package(SDL3 REQUIRED CONFIG)
endif()

# Helper: gan SDL3 vao target
function(link_sdl3 tgt)
    target_link_libraries(${tgt} PRIVATE SDL3::SDL3)
    if(EMSCRIPTEN)
        target_link_options(${tgt} PRIVATE
            "-sALLOW_MEMORY_GROWTH=1"
            "-sASYNCIFY")
        set_target_properties(${tgt} PROPERTIES SUFFIX ".html")
    endif()
endfunction()

# Helper: dung custom HTML shell (clean white bg, mobile-first, PWA-ready)
# Ap cho moi target WASM de UX nhat quan
function(use_clean_shell tgt)
    if(NOT EMSCRIPTEN)
        return()
    endif()
    target_link_options(${tgt} PRIVATE
        "--shell-file=${WEB_DIR}/shell.html"
    )
    set_property(TARGET ${tgt} APPEND PROPERTY LINK_DEPENDS "${WEB_DIR}/shell.html")
endfunction()

# Helper: setup PWA cho ctetris (chi target tich hop moi can)
# Copy manifest, sw.js, favicon, icons sang thu muc build cung HTML
function(setup_pwa tgt)
    if(NOT EMSCRIPTEN)
        return()
    endif()
    foreach(asset manifest.webmanifest sw.js)
        configure_file(
            "${WEB_DIR}/${asset}"
            "${CMAKE_CURRENT_BINARY_DIR}/${asset}"
            COPYONLY
        )
    endforeach()
    if(EXISTS "${SOURCE_SVG}")
        configure_file(
            "${SOURCE_SVG}"
            "${CMAKE_CURRENT_BINARY_DIR}/favicon.svg"
            COPYONLY
        )
    endif()
    foreach(icon icon-192.png icon-512.png)
        if(EXISTS "${ICONS_DIR}/${icon}")
            configure_file(
                "${ICONS_DIR}/${icon}"
                "${CMAKE_CURRENT_BINARY_DIR}/${icon}"
                COPYONLY
            )
        else()
            message(STATUS "[PWA] Thieu ${ICONS_DIR}/${icon} -- chay 'bash icons/gen_icons.sh' truoc.")
        endif()
    endforeach()
endfunction()

# --- Targets doc lap (necessary condition) ---
add_executable(gameStory MACOSX_BUNDLE src/gameStory/app.cpp)
target_compile_definitions(gameStory PRIVATE BUILD_STANDALONE)
target_include_directories(gameStory PRIVATE src/gameStory/include)
link_sdl3(gameStory)
use_clean_shell(gameStory)

add_executable(gameConsole MACOSX_BUNDLE src/gameConsole/app.cpp)
target_compile_definitions(gameConsole PRIVATE BUILD_STANDALONE)
target_include_directories(gameConsole PRIVATE src/gameConsole/include)
link_sdl3(gameConsole)
use_clean_shell(gameConsole)

add_executable(gameCore MACOSX_BUNDLE src/gameCore/app.cpp)
target_compile_definitions(gameCore PRIVATE BUILD_STANDALONE)
target_include_directories(gameCore PRIVATE src/gameCore/include)
link_sdl3(gameCore)
use_clean_shell(gameCore)

# --- Target tich hop ctetris (sufficient condition) ---
add_executable(ctetris MACOSX_BUNDLE
    main.cpp
    src/gameStory/app.cpp
    src/gameConsole/app.cpp
    src/gameCore/app.cpp
)
target_include_directories(ctetris PRIVATE
    src/gameStory/include
    src/gameConsole/include
    src/gameCore/include
)
link_sdl3(ctetris)
use_clean_shell(ctetris)
setup_pwa(ctetris)

# =========================================================
# Native app icons: nhung icon vao .app / .exe / desktop entry
# =========================================================
if(APPLE AND NOT EMSCRIPTEN)
    # macOS: nhung .icns vao bundle Resources/ va tham chieu trong Info.plist
    if(EXISTS "${ICONS_DIR}/icon.icns")
        set_target_properties(ctetris PROPERTIES
            MACOSX_BUNDLE_ICON_FILE "icon.icns"
            MACOSX_BUNDLE_BUNDLE_NAME "cTetris"
            MACOSX_BUNDLE_GUI_IDENTIFIER "com.uit.ctetris"
            MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
            MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
        )
        target_sources(ctetris PRIVATE "${ICONS_DIR}/icon.icns")
        set_source_files_properties("${ICONS_DIR}/icon.icns"
            PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    else()
        message(STATUS "[ICON] Thieu ${ICONS_DIR}/icon.icns -- chay 'bash icons/gen_icons.sh' truoc.")
    endif()
elseif(WIN32)
    # Windows: bien dich .rc thanh resource va link vao .exe
    if(EXISTS "${ICONS_DIR}/icon.ico" AND EXISTS "${ICONS_DIR}/app.rc")
        target_sources(ctetris PRIVATE "${ICONS_DIR}/app.rc")
    else()
        message(STATUS "[ICON] Thieu ${ICONS_DIR}/icon.ico -- chay 'icons\\gen_icons.ps1' truoc.")
    endif()
elseif(UNIX AND NOT APPLE AND NOT EMSCRIPTEN)
    # Linux: copy PNG + sinh .desktop file cho AppImage tooling
    if(EXISTS "${ICONS_DIR}/icon-512.png")
        configure_file(
            "${ICONS_DIR}/icon-512.png"
            "${CMAKE_CURRENT_BINARY_DIR}/ctetris.png"
            COPYONLY
        )
    endif()
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/ctetris.desktop"
"[Desktop Entry]
Type=Application
Name=cTetris
Comment=Classic Tetris game built with SDL3
Exec=ctetris
Icon=ctetris
Categories=Game;
Terminal=false
")
endif()