cmake_minimum_required(VERSION 3.10)
project(gameStory)
set(CMAKE_CXX_STANDARD 17)

# SFML
find_package(SFML 3.0 REQUIRED)

include_directories(include)
add_executable(gameStory app.cpp)
target_link_libraries(gameStory SFML::Graphics SFML::Window SFML::System)
