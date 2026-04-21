cmake_minimum_required(VERSION 3.10)
project(gameStory)
set(CMAKE_CXX_STANDARD 17)

# SFML 3.0 yêu cầu phải liệt kê components ngay tại đây
find_package(SFML 3.0 REQUIRED COMPONENTS graphics window system)

include_directories(include)
add_executable(gameStory app.cpp)

# Lưu ý: SFML 3 dùng namespace viết hoa chữ cái đầu (SFML::Graphics)
target_link_libraries(gameStory SFML::Graphics SFML::Window SFML::System)