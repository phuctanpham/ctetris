cmake_minimum_required(VERSION 3.10)
project(gameCore)

set(CMAKE_CXX_STANDARD 17)

# Find SFML 3
find_package(SFML 3 COMPONENTS graphics window system REQUIRED)

include_directories(include)

add_executable(gameCore app.cpp)

target_link_libraries(gameCore sfml-graphics sfml-window sfml-system)
