#include <SFML/Graphics.hpp>
#include <optional>
#include <time.h>
#include <string>

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
    srand((unsigned int)time(0));
    // khởi tạo window
    sf::RenderWindow window(sf::VideoMode({ 800, 720 }), "Hoc SFML - Buoc 7: Game Over");
    float offsetX = (800 - N * BLOCK_SIZE) / 2.0f;
    float offsetY = (720 - M * BLOCK_SIZE) / 2.0f + 20.0f;
    // Bảng 7 màu sắc cho 7 khối (Thêm màu đen ở index 0)
    sf::Color colors[8] = {
        sf::Color::Black,       // 0: Trống
        sf::Color::Cyan,        // 1: I
        sf::Color::Red,         // 2: Z
        sf::Color::Green,       // 3: S
        sf::Color::Magenta,     // 4: T
        sf::Color(255, 165, 0), // 5: L (Cam)
        sf::Color::Blue,        // 6: J
        sf::Color::Yellow       // 7: O
    };
    //vẽ khung lưới
    sf::RectangleShape gridCell({ (float)BLOCK_SIZE, (float)BLOCK_SIZE });
    gridCell.setFillColor(sf::Color::Transparent);
    gridCell.setOutlineThickness(-1.f);
    gridCell.setOutlineColor(sf::Color(255, 255, 255, 40));

    sf::RectangleShape blockCell({ (float)BLOCK_SIZE, (float)BLOCK_SIZE });
    blockCell.setOutlineThickness(-1.f);
    blockCell.setOutlineColor(sf::Color(255, 255, 255, 80));

    // ================= TẢI FONT CHỮ VÀ SETUP TEXT =================
    sf::Font font;
    // Bắt buộc phải có file arial_bold.ttf trong thư mục chứa code
    if (!font.openFromFile("arial_bold.ttf")) {
        //
    }
    // Chữ Game OVer
    sf::Text gameOverText(font);
    gameOverText.setString("GAME OVER\nPress R to Restart");
    gameOverText.setCharacterSize(35);
    gameOverText.setFillColor(sf::Color::Red);
    // Căn ra giữa màn hình
    gameOverText.setPosition({ offsetX - 30.f, offsetY + 200.f });
    // Chữ SCORE bên trái
    sf::Text scoreText(font);
    scoreText.setCharacterSize(28);
    scoreText.setFillColor(sf::Color::White);
    scoreText.setPosition({ 50.f, 100.f }); // Đặt ở góc trái màn hình

    // Chữ NEXT bên phải
    sf::Text nextText(font);
    nextText.setString("NEXT");
    nextText.setCharacterSize(28);
    nextText.setFillColor(sf::Color::White);
    nextText.setPosition({ 600.f, 100.f });

    int score = 0;
    int colorNum = 1;

    // Sinh ra trước khối gạch của "Lượt tiếp theo" (Phòng chờ)
    int nextBlockType = rand() % 7;
    int nextColorNum = nextBlockType + 1;

    int dx = 0;
    bool rotate = false;
    float timer = 0, delay = 0.3f;
    bool isGameOver = false;
    sf::Clock clock;

    // Hàm Lambda (Hàm ẩn) để sinh khối mới cho code gọn gàng
    auto spawnNewBlock = [&]() {
        int n = nextBlockType;
        colorNum = nextColorNum;
        for (int i = 0; i < 4; i++) {
            a[i].x = figures[n][i] % 2 + 4;
            a[i].y = figures[n][i] / 2;
        }
        if (!check()) {
            isGameOver = true;
        }

        // Random khối mới cho lượt sau
        nextBlockType = rand() % 7;
        nextColorNum = nextBlockType + 1;
        };
    spawnNewBlock();

    while (window.isOpen())
    {
        float time = clock.restart().asSeconds();
        timer += time;

        while (const auto event = window.pollEvent())
        {
            if (event->is<sf::Event::Closed>()) window.close();

            if (const auto* keyEvent = event->getIf<sf::Event::KeyPressed>()) {
                // CHO PHÉP NHẤN R ĐỂ RESTART KHI GAME OVER
                if (isGameOver && keyEvent->scancode == sf::Keyboard::Scancode::R) {
                    // Reset ma trận
                    for (int i = 0; i < M; i++)
                        for (int j = 0; j < N; j++)
                            field[i][j] = 0;
                    score = 0;
                    isGameOver = false;
                    spawnNewBlock();
                }
                if (!isGameOver) {
                    if (keyEvent->scancode == sf::Keyboard::Scancode::Up || keyEvent->scancode == sf::Keyboard::Scancode::W)
                        rotate = true;
                    else if (keyEvent->scancode == sf::Keyboard::Scancode::Left || keyEvent->scancode == sf::Keyboard::Scancode::A)
                        dx = -1;
                    else if (keyEvent->scancode == sf::Keyboard::Scancode::Right || keyEvent->scancode == sf::Keyboard::Scancode::D)
                        dx = 1;
                }
                
            }
        }

        if (sf::Keyboard::isKeyPressed(sf::Keyboard::Scancode::Down) || sf::Keyboard::isKeyPressed(sf::Keyboard::Scancode::S)) delay = 0.05f;
        else delay = 0.3f;

        if (!isGameOver) {
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

            // --- Rơi xuống & Chốt gạch ---
            if (timer > delay) {
                for (int i = 0; i < 4; i++) { b[i] = a[i]; a[i].y += 1; }

                // NẾU CHẠM ĐÁY HOẶC GẠCH CŨ
                if (!check()) {
                    // Chép tọa độ cũ (b) vào mảng field, lưu lại mã màu
                    for (int i = 0; i < 4; i++) {
                        field[b[i].y][b[i].x] = colorNum;
                    }
                    // Sinh khối mới
                    spawnNewBlock();
                }
                timer = 0;
            }
            // --- Thuật toán Xóa hàng (Line Clearing) ---
            int linesCleared = 0; // Biến đếm số hàng vừa ăn được
            int k = M - 1; // k trỏ vào hàng dưới cùng
            for (int i = M - 1; i > 0; i--) {
                int count = 0; // Đếm số khối gạch trong hàng i
                for (int j = 0; j < N; j++) {
                    if (field[i][j]) count++;
                    field[k][j] = field[i][j]; // Chép đè dữ liệu từ hàng i xuống hàng k
                }
                // Nếu hàng i chưa đầy (count < 10), ta cho phép hàng k dịch lên trên
                // Nếu hàng i bị đầy, k đứng im để vòng lặp sau chép hàng phía trên đè xuống nó
                if (count < N) {
                    k--;
                }
                else {
                    linesCleared++; // Đánh dấu đã xóa 1 hàng
                };
            }

            if (linesCleared >= 1) {
                score += linesCleared * 100;
            }
        }

        scoreText.setString("SCORE\n" + std::to_string(score));

        // ================= VẼ GIAO DIỆN =================
        window.clear(sf::Color(40, 40, 40));

        // Vẽ UI Chữ
        window.draw(scoreText);
        window.draw(nextText);

        // Vẽ Khối NEXT ở bên phải màn hình
        for (int i = 0; i < 4; i++) {
            float nextX = 600.f + (figures[nextBlockType][i] % 2) * BLOCK_SIZE;
            float nextY = 150.f + (figures[nextBlockType][i] / 2) * BLOCK_SIZE;

            blockCell.setFillColor(colors[nextColorNum]);
            blockCell.setPosition({ nextX, nextY });
            window.draw(blockCell);
        }

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

        // Vẽ CÁC KHỐI ĐÃ CHỐT nằm trong field
        for (int i = 0; i < M; i++) {
            for (int j = 0; j < N; j++) {
                if (field[i][j] == 0) continue; // Ô trống thì bỏ qua

                blockCell.setFillColor(colors[field[i][j]]); // Đổ màu theo mã đã lưu
                blockCell.setPosition({ offsetX + j * BLOCK_SIZE, offsetY + i * BLOCK_SIZE });
                window.draw(blockCell);
            }
        }

        if (!isGameOver) {
            for (int i = 0; i < 4; i++) {
                blockCell.setFillColor(colors[colorNum]);
                blockCell.setPosition({ offsetX + a[i].x * BLOCK_SIZE, offsetY + a[i].y * BLOCK_SIZE });
                window.draw(blockCell);
            }
        }

        // VẼ CHỮ GAME OVER LÊN LỚP TRÊN CÙNG
        if (isGameOver) {
            window.draw(gameOverText);
        }

        window.display();
    }

    return 0;
}