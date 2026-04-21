cmake_minimum_required(VERSION 3.10)
project(gameStory)
set(CMAKE_CXX_STANDARD 17)

# SFML
find_package(SFML 3.0 REQUIRED COMPONENTS graphics window system)

include_directories(include)
add_executable(gameStory app.cpp)
target_link_libraries(gameStory sfml-graphics sfml-window sfml-system)
