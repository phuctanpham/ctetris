cmake_minimum_required(VERSION 3.10)
project(gameStory)
set(CMAKE_CXX_STANDARD 17)

add_executable(gameStory app.cpp)
target_include_directories(gameStory PRIVATE include)
