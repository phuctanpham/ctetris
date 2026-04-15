#include <SFML/Graphics.hpp>
#include <optional>

const int M = 20; // Số hàng (chiều cao ma trận)
const int N = 10; // Số cột (chiều rộng ma trận)
const int BLOCK_SIZE = 32; // Kích thước 1 ô vuông là 32x32 pixel

// mảng lưu các khối gạch đã rơi xuống
int field[M][N] = { 0 };
// Thêm mảng b để làm bản sao lưu hoàn tác (Rollback)
struct Point { int x, y; } a[4], b[4];
// 2. Mảng nén hình dáng 7 khối gạch
int figures[7][4] = {
    {1, 3, 5, 7}, // I
    {2, 4, 5, 7}, // Z
    {3, 5, 4, 6}, // S
    {3, 5, 4, 7}, // T
    {2, 3, 5, 7}, // L
    {3, 5, 7, 6}, // J
    {2, 3, 4, 5}  // O
};

// ================= THUẬT TOÁN KIỂM TRA VA CHẠM =================
bool check() {
    for (int i = 0; i < 4; i++) {
        // Kiểm tra xem có vượt quá biên Trái (< 0), Phải (>= N) hoặc Đáy (>= M) không
        if (a[i].x < 0 || a[i].x >= N || a[i].y >= M) return false;

        // Kiểm tra xem vị trí mới có bị đè lên khối gạch cũ nào dưới đáy không
        else if (field[a[i].y][a[i].x]) return false;
    }
    return true; // Hợp lệ, cho phép đi qua
}

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

    // Cọ vẽ cho khối gạch đang hiển thị
    sf::RectangleShape blockCell({ (float)BLOCK_SIZE, (float)BLOCK_SIZE });
    blockCell.setFillColor(sf::Color::Yellow); // Đặt màu vàng cho khối O
    blockCell.setOutlineThickness(-1.f);
    blockCell.setOutlineColor(sf::Color(255, 255, 255, 80));

    // ================= XỬ LÝ DỮ LIỆU KHỐI =================
    // Khối O nằm ở vị trí thứ 6 trong mảng (index = 6)
    int blockType = 6;

    // Giải nén 4 con số thành 4 tọa độ x, y
    for (int i = 0; i < 4; i++) {
        a[i].x = figures[blockType][i] % 2;
        a[i].y = figures[blockType][i] / 2;

        // Cộng thêm 4 vào X để đẩy khối gạch ra chính giữa chiều ngang bảng game (10 cột)
        a[i].x += 4;
    }
    int dx = 0;                    // Biến hướng di chuyển ngang (-1 trái, 1 phải)
    float timer = 0, delay = 0.3f; // Bộ đếm thời gian cho khối rơi tự động
    sf::Clock clock;
    // ================= VÒNG LẶP GAME (GAME LOOP) =================
    while (window.isOpen())
    {
        // Tính toán delta time (thời gian trôi qua giữa 2 khung hình)
        float time = clock.restart().asSeconds();
        timer += time;
        // A. XỬ LÝ SỰ KIỆN (Input từ hệ điều hành)
        while (const auto event = window.pollEvent())
        {
            if (event->is<sf::Event::Closed>())
                window.close();
            // SỬ DỤNG SCANCODE THAY VÌ KEYCODE ĐỂ XUYÊN QUA UNIKEY
            if (const auto* keyEvent = event->getIf<sf::Event::KeyPressed>()) {
                if (keyEvent->scancode == sf::Keyboard::Scancode::Left || keyEvent->scancode == sf::Keyboard::Scancode::A)
                    dx = -1;
                else if (keyEvent->scancode == sf::Keyboard::Scancode::Right || keyEvent->scancode == sf::Keyboard::Scancode::D)
                    dx = 1;
            }
        }
        // 2. XỬ LÝ SỰ KIỆN PHÍM ĐANG BỊ GIỮ (Cho việc rơi nhanh)
        // Nếu đè mũi tên XUỐNG hoặc phím S, giảm delay xuống 0.05 giây để rơi vèo vèo
        // Đổi phím S ở dòng này thành Scancode luôn
        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Scancode::Down) || sf::Keyboard::isKeyPressed(sf::Keyboard::Scancode::S)) {
            delay = 0.05f;
        }
        else {
            delay = 0.3f;
        }
        // ================= THỰC THI DI CHUYỂN =================
        // A. Di chuyển ngang
        if (dx != 0) {
            for (int i = 0; i < 4; i++) { b[i] = a[i]; a[i].x += dx; } // Thử đi
            if (!check()) { // Nếu đập tường
                for (int i = 0; i < 4; i++) a[i] = b[i]; // Lùi lại
            }
            dx = 0; // Chạy xong thì reset lệnh di chuyển
        }

        // B. Rơi tự động dọc theo trục Y
        if (timer > delay) {
            for (int i = 0; i < 4; i++) { b[i] = a[i]; a[i].y += 1; } // Thử rơi
            if (!check()) { // Nếu chạm đáy
                for (int i = 0; i < 4; i++) a[i] = b[i]; // Đứng im lại
            }
            timer = 0; // Reset bộ đếm thời gian
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
        // Vẽ 4 phần tử của khối gạch O
        for (int i = 0; i < 4; i++) {
            float pixelX = offsetX + a[i].x * BLOCK_SIZE;
            float pixelY = offsetY + a[i].y * BLOCK_SIZE;

            blockCell.setPosition({ pixelX, pixelY });
            window.draw(blockCell);
        }

        // B3. Đẩy hình ảnh đã vẽ lên màn hình
        window.display();
    }

    return 0;
}