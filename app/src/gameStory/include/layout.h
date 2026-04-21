#pragma once
#include <SFML/Graphics.hpp>

namespace layout {
    // Khởi tạo cửa sổ với tỷ lệ 9:16
    inline sf::RenderWindow create916Window(int height = 720) {
        int width = height * 9 / 16;
        return sf::RenderWindow(sf::VideoMode(width, height), "GameStory 9:16", sf::Style::Close);
    }
}
#ifndef LAYOUT_H
#define LAYOUT_H

// Đảm bảo khung hình 9:16 cho ứng dụng console
// Sử dụng macro để xác định kích thước chuẩn
#define FRAME_WIDTH  36   // 9x4
#define FRAME_HEIGHT 64   // 16x4

// Hàm thiết lập layout console (tùy nền tảng)
void setupLayout();

#endif // LAYOUT_H
