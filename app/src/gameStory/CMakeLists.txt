cmake_minimum_required(VERSION 3.10)
project(gameStory)
set(CMAKE_CXX_STANDARD 17)

find_package(SFML 2.5 COMPONENTS graphics window system audio REQUIRED)

add_executable(gameStory app.cpp)
target_include_directories(gameStory PRIVATE include)
target_link_libraries(gameStory sfml-graphics sfml-window sfml-system sfml-audio)
