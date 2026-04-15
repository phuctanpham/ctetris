#include <SFML/Graphics.hpp>
#include <optional>

const int M = 20; // Số hàng (chiều cao ma trận)
const int N = 10; // Số cột (chiều rộng ma trận)
const int BLOCK_SIZE = 32; // Kích thước 1 ô vuông là 32x32 pixel

int main()
{
    // 1. Tạo cửa sổ làm việc
    sf::RenderWindow window(sf::VideoMode({ 800, 720 }), "Hoc SFML - Buoc 1: Ve Luoi");

    // 2. Tính toán khoảng lề (Offset) để bảng game nằm giữa màn hình
    // N * BLOCK_SIZE là tổng chiều rộng của bảng game (10 * 32 = 320px)
    float offsetX = (800 - N * BLOCK_SIZE) / 2.0f;

    // M * BLOCK_SIZE là tổng chiều cao của bảng game (20 * 32 = 640px)
    // Cộng thêm 20.0f để đẩy nó xuống dưới một chút cho đẹp
    float offsetY = (720 - M * BLOCK_SIZE) / 2.0f + 20.0f;

    // 3. Khởi tạo "Cọ vẽ" để vẽ các ô vuông
    sf::RectangleShape gridCell({ (float)BLOCK_SIZE, (float)BLOCK_SIZE });
    gridCell.setFillColor(sf::Color::Black); // Lõi màu đen
    gridCell.setOutlineThickness(-1.f);      // Viền thụt vào trong 1px (-1) để các ô không bị đè viền lên nhau
    gridCell.setOutlineColor(sf::Color(255, 255, 255, 40)); // Viền màu trắng, độ trong suốt (Alpha) là 40/255

    // ================= VÒNG LẶP GAME (GAME LOOP) =================
    while (window.isOpen())
    {
        // A. XỬ LÝ SỰ KIỆN (Input từ hệ điều hành)
        while (const auto event = window.pollEvent())
        {
            if (event->is<sf::Event::Closed>())
                window.close();
        }

        // B. VẼ ĐỒ HỌA (Render Pipeline)
        // B1. Xóa sạch khung hình cũ và đổ màu xám đậm (màu nền của app)
        window.clear(sf::Color(40, 40, 40));

        // B2. Vẽ lưới bảng game
        for (int i = 0; i < M; i++) {       // Duyệt từng hàng Y
            for (int j = 0; j < N; j++) {   // Duyệt từng cột X

                // Cập nhật vị trí tọa độ pixel thực tế của ô [i][j]
                float pixelX = offsetX + j * BLOCK_SIZE;
                float pixelY = offsetY + i * BLOCK_SIZE;

                gridCell.setPosition({ pixelX, pixelY });

                // In hình vuông xuống màn hình
                window.draw(gridCell);
            }
        }

        // B3. Đẩy hình ảnh đã vẽ lên màn hình
        window.display();
    }

    return 0;
}