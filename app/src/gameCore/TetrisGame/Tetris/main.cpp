#include <SFML/Graphics.hpp>
#include <optional>

const int M = 20;
const int N = 10;
const int BLOCK_SIZE = 32;

int field[M][N] = { 0 };
struct Point { int x, y; } a[4], b[4];

int figures[7][4] = {
    {1,3,5,7}, {2,4,5,7}, {3,5,4,6}, {3,5,4,7}, {2,3,5,7}, {3,5,7,6}, {2,3,4,5}
};

bool check() {
    for (int i = 0; i < 4; i++) {
        if (a[i].x < 0 || a[i].x >= N || a[i].y >= M) return false;
        else if (field[a[i].y][a[i].x]) return false;
    }
    return true;
}

int main()
{
    sf::RenderWindow window(sf::VideoMode({ 800, 720 }), "Hoc SFML - Buoc 4: Ma Tran Xoay");
    float offsetX = (800 - N * BLOCK_SIZE) / 2.0f;
    float offsetY = (720 - M * BLOCK_SIZE) / 2.0f + 20.0f;

    sf::RectangleShape gridCell({ (float)BLOCK_SIZE, (float)BLOCK_SIZE });
    gridCell.setFillColor(sf::Color::Transparent);
    gridCell.setOutlineThickness(-1.f);
    gridCell.setOutlineColor(sf::Color(255, 255, 255, 40));

    sf::RectangleShape blockCell({ (float)BLOCK_SIZE, (float)BLOCK_SIZE });
    blockCell.setFillColor(sf::Color::Yellow);
    blockCell.setOutlineThickness(-1.f);
    blockCell.setOutlineColor(sf::Color(255, 255, 255, 80));

    // Dùng khối chữ L (Index 4) để test phép xoay cho rõ ràng
    int blockType = 4;
    for (int i = 0; i < 4; i++) {
        a[i].x = figures[blockType][i] % 2 + 4;
        a[i].y = figures[blockType][i] / 2;
    }

    int dx = 0;
    bool rotate = false; // Cờ hiệu lệnh xoay
    float timer = 0, delay = 0.3f;
    sf::Clock clock;

    while (window.isOpen())
    {
        float time = clock.restart().asSeconds();
        timer += time;

        while (const auto event = window.pollEvent())
        {
            if (event->is<sf::Event::Closed>()) window.close();

            if (const auto* keyEvent = event->getIf<sf::Event::KeyPressed>()) {
                // Thêm Scancode bắt phím Lên và W để kích hoạt cờ xoay
                if (keyEvent->scancode == sf::Keyboard::Scancode::Up || keyEvent->scancode == sf::Keyboard::Scancode::W)
                    rotate = true;
                else if (keyEvent->scancode == sf::Keyboard::Scancode::Left || keyEvent->scancode == sf::Keyboard::Scancode::A)
                    dx = -1;
                else if (keyEvent->scancode == sf::Keyboard::Scancode::Right || keyEvent->scancode == sf::Keyboard::Scancode::D)
                    dx = 1;
            }
        }

        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Scancode::Down) || sf::Keyboard::isKeyPressed(sf::Keyboard::Scancode::S)) delay = 0.05f;
        else delay = 0.3f;

        // --- Di chuyển ngang ---
        if (dx != 0) {
            for (int i = 0; i < 4; i++) { b[i] = a[i]; a[i].x += dx; }
            if (!check()) for (int i = 0; i < 4; i++) a[i] = b[i];
            dx = 0;
        }

        // ================= THỰC THI PHÉP XOAY =================
        if (rotate) {
            Point p = a[1]; // Lấy mảnh thứ 2 làm tâm
            for (int i = 0; i < 4; i++) {
                b[i] = a[i]; // Sao lưu trước khi biến đổi

                // Công thức nhân ma trận xoay
                int deltaX = a[i].y - p.y;
                int deltaY = a[i].x - p.x;

                a[i].x = p.x - deltaX;
                a[i].y = p.y + deltaY;
            }
            // Nếu xoay xong mà đâm vào tường -> Hoàn tác
            if (!check()) for (int i = 0; i < 4; i++) a[i] = b[i];

            rotate = false; // Tắt cờ
        }

        // --- Rơi tự động ---
        if (timer > delay) {
            for (int i = 0; i < 4; i++) { b[i] = a[i]; a[i].y += 1; }
            if (!check()) for (int i = 0; i < 4; i++) a[i] = b[i];
            timer = 0;
        }

        // ================= VẼ GIAO DIỆN =================
        window.clear(sf::Color(40, 40, 40));

        sf::RectangleShape boardBg({ (float)N * BLOCK_SIZE, (float)M * BLOCK_SIZE });
        boardBg.setFillColor(sf::Color::Black);
        boardBg.setPosition({ offsetX, offsetY });
        window.draw(boardBg);

        for (int i = 0; i < M; i++) {
            for (int j = 0; j < N; j++) {
                gridCell.setPosition({ offsetX + j * BLOCK_SIZE, offsetY + i * BLOCK_SIZE });
                window.draw(gridCell);
            }
        }

        for (int i = 0; i < 4; i++) {
            float pixelX = offsetX + a[i].x * BLOCK_SIZE;
            float pixelY = offsetY + a[i].y * BLOCK_SIZE;
            blockCell.setPosition({ pixelX, pixelY });
            window.draw(blockCell);
        }

        window.display();
    }

    return 0;
}