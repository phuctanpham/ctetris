cmake_minimum_required(VERSION 3.10)
project(gameStory)
set(CMAKE_CXX_STANDARD 17)

# Platform-specific settings
if (APPLE)
    message(STATUS "Configuring for macOS")
    find_package(SFML 3 REQUIRED COMPONENTS Graphics Window System)
    find_path(GIF_INCLUDE_DIR gif_lib.h HINTS /usr/local/include /opt/homebrew/include)
    find_library(GIF_LIBRARY NAMES gif HINTS /usr/local/lib /opt/homebrew/lib)
    if(NOT GIF_INCLUDE_DIR OR NOT GIF_LIBRARY)
        message(FATAL_ERROR "giflib not found. Run: brew install giflib")
    endif()
elseif (WIN32)
    message(STATUS "Configuring for Windows")
    find_package(SFML 3 REQUIRED COMPONENTS Graphics Window System)
    find_path(GIF_INCLUDE_DIR gif_lib.h)
    find_library(GIF_LIBRARY NAMES gif)
    if(NOT GIF_INCLUDE_DIR OR NOT GIF_LIBRARY)
        message(FATAL_ERROR "giflib not found. Please install giflib for Windows.")
    endif()
elseif (UNIX)
    message(STATUS "Configuring for Linux")
    set(SFML_STATIC_LIBRARIES ON)
    find_package(SFML 3 REQUIRED COMPONENTS Graphics Window System)
    find_path(GIF_INCLUDE_DIR gif_lib.h HINTS /usr/include /usr/local/include)
    find_library(GIF_LIBRARY NAMES gif HINTS /usr/lib /usr/local/lib)
    if(NOT GIF_INCLUDE_DIR OR NOT GIF_LIBRARY)
        message(FATAL_ERROR "giflib not found. Run: sudo apt install libgif-dev")
    endif()
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

include_directories(include ${GIF_INCLUDE_DIR})
add_executable(gameStory app.cpp)
target_link_libraries(gameStory SFML::Graphics SFML::Window SFML::System ${GIF_LIBRARY})

add_custom_command(TARGET gameStory POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_SOURCE_DIR}/gameStory_intro.gif
        $<TARGET_FILE_DIR:gameStory>/gameStory_intro.gif
)