cmake_minimum_required(VERSION 3.10)
project(gameConsole)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (APPLE)
    message(STATUS "Configuring gameConsole for macOS")
    find_package(SFML 3 REQUIRED COMPONENTS Graphics Window System Audio)
elseif (UNIX)
    message(STATUS "Configuring gameConsole for Linux")
    find_package(SFML 3 REQUIRED COMPONENTS Graphics Window System Audio)
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

add_executable(gameConsole app.cpp)
target_include_directories(gameConsole PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/include)
target_link_libraries(gameConsole PRIVATE SFML::Graphics SFML::Window SFML::System SFML::Audio)

add_custom_command(TARGET gameConsole POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_CURRENT_SOURCE_DIR}/gameConsole_board.json
        $<TARGET_FILE_DIR:gameConsole>/gameConsole_board.json
)
