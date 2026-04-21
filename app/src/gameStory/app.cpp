// phucpt: app/src/gameStory/app.cpp
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <SFML/Window.hpp>
#include <thread>
#include <vector>
#include <string>
#include <filesystem>
#include "include/layout.h"

// gameconsole-tao-giao-dien-169-00
// Thiết lập layout GUI 9:16 (window 720x1280)
void setupLayout(sf::RenderWindow& window) {
	// Đảm bảo cửa sổ đúng tỷ lệ 9:16
	window.setSize(sf::Vector2u(720, 1280));
	window.setView(sf::View(sf::FloatRect(0, 0, 720, 1280)));
}

// gameconsole-logo-intro-01
// Hiển thị logo UIT với hiệu ứng fade-in và phát nhạc
void showLogoIntro(sf::RenderWindow& window, sf::Music& music, float& logoDuration) {
	// Tải logo từ file GIF (gameStory_logo.gif) thành các frame PNG tạm thời
	// SFML không hỗ trợ GIF động trực tiếp, nên cần giải nén các frame trước
	// Để tuân thủ rule 1 file, ta sẽ gọi lệnh hệ thống để giải nén nếu chưa có thư mục frame
	std::vector<sf::Texture> frames;
	std::string frameDir = "gameStory_logo_frames";
	if (!std::filesystem::exists(frameDir)) {
		// Dùng ImageMagick convert để tách frame (yêu cầu đã cài imagemagick)
		std::string cmd = "mkdir -p " + frameDir + " && convert gameStory_logo.gif " + frameDir + "/frame_%03d.png";
		system(cmd.c_str());
	}
	// Load các frame PNG vào vector
	int idx = 0;
	while (true) {
		char buf[256];
		snprintf(buf, sizeof(buf), "%s/frame_%03d.png", frameDir.c_str(), idx);
		if (!std::filesystem::exists(buf)) break;
		sf::Texture tex;
		if (tex.loadFromFile(buf)) frames.push_back(std::move(tex));
		++idx;
	}
	if (frames.empty()) {
		// Nếu không có frame, dùng hình chữ nhật thay thế
		sf::Texture fallback;
		fallback.create(400, 200);
		frames.push_back(std::move(fallback));
	}
	sf::Sprite logoSprite;
	logoSprite.setOrigin(frames[0].getSize().x/2, frames[0].getSize().y/2);
	logoSprite.setPosition(360, 400);

	// Phát nhạc nếu có file gameStory_logo.ogg
	if (music.openFromFile("gameStory_logo.ogg")) {
		music.play();
	}

	// Hiệu ứng phát GIF động (fade-in frame đầu)
	sf::Clock clock;
	logoDuration = std::max(2.5f, frames.size() * 0.08f); // tối thiểu 2.5s, mỗi frame ~80ms
	size_t frameCount = frames.size();
	while (clock.getElapsedTime().asSeconds() < logoDuration) {
		float t = clock.getElapsedTime().asSeconds();
		size_t frameIdx = std::min(frameCount-1, static_cast<size_t>((t/logoDuration)*frameCount));
		logoSprite.setTexture(frames[frameIdx]);
		// Fade-in cho frame đầu tiên
		float alpha = (t < 1.0f) ? std::min(255.f, 255.f * t / 1.0f) : 255.f;
		logoSprite.setColor(sf::Color(255,255,255, static_cast<sf::Uint8>(alpha)));
		window.clear(sf::Color::Black);
		window.draw(logoSprite);
		window.display();
		std::this_thread::sleep_for(std::chrono::milliseconds(16));
	}
}

// gamestory-loading-bar-02
// Loading bar hiệu ứng theo thời gian hiệu ứng logo
void showLoadingBar(sf::RenderWindow& window, float duration) {
	sf::RectangleShape barBg(sf::Vector2f(400, 30));
	barBg.setFillColor(sf::Color(50, 50, 50));
	barBg.setPosition(160, 900);
	sf::RectangleShape bar(sf::Vector2f(0, 30));
	bar.setFillColor(sf::Color(100, 220, 100));
	bar.setPosition(barBg.getPosition());

	sf::Clock clock;
	while (clock.getElapsedTime().asSeconds() < duration) {
		float progress = clock.getElapsedTime().asSeconds() / duration;
		bar.setSize(sf::Vector2f(400 * progress, 30));
		window.clear(sf::Color::Black);
		window.draw(barBg);
		window.draw(bar);
		window.display();
		std::this_thread::sleep_for(std::chrono::milliseconds(16));
	}
	// Hiển thị full bar 0.5s
	bar.setSize(sf::Vector2f(400, 30));
	window.clear(sf::Color::Black);
	window.draw(barBg);
	window.draw(bar);
	window.display();
	std::this_thread::sleep_for(std::chrono::milliseconds(500));
}

int main() {
	// Khởi tạo cửa sổ GUI 9:16
	sf::RenderWindow window(sf::VideoMode(720, 1280), "GameStory Logo Intro", sf::Style::Titlebar | sf::Style::Close);
	setupLayout(window); // gameconsole-tao-giao-dien-169-00

	// Hiển thị logo UIT với hiệu ứng và âm thanh
	sf::Music music;
	float logoDuration = 0.f;
	showLogoIntro(window, music, logoDuration); // gameconsole-logo-intro-01

	// Loading bar hiệu ứng theo thời gian logo
	showLoadingBar(window, logoDuration); // gamestory-loading-bar-02

	// Đợi đóng cửa sổ
	while (window.isOpen()) {
		sf::Event event;
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed)
				window.close();
		}
		std::this_thread::sleep_for(std::chrono::milliseconds(20));
	}
	return 0;
}
