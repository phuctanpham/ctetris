#ifndef LAYOUT_H
#define LAYOUT_H

// Đảm bảo khung hình 9:16 cho ứng dụng console
// Sử dụng macro để xác định kích thước chuẩn
#define FRAME_WIDTH  36   // 9x4
#define FRAME_HEIGHT 64   // 16x4

// Hàm thiết lập layout console (tùy nền tảng)
void setupLayout();

#endif // LAYOUT_H
