
#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <iostream>
#include "include/layout.h"

// gameconsole-tao-giao-dien-169-00
// Tạo cửa sổ tỷ lệ 9:16
int main() {
	int windowHeight = 720;
	auto window = layout::create916Window(windowHeight);
	window.setFramerateLimit(60);

	// gameconsole-logo-intro-01
	// Hiển thị logo UIT với hiệu ứng fade-in, dùng gameStory_intro.gif
	sf::Texture logoTexture;
	if (!logoTexture.loadFromFile("gameStory_intro.gif")) {
		std::cerr << "Không tìm thấy file gameStory_intro.gif\n";
		return 1;
	}
	sf::Sprite logoSprite(logoTexture);
	float scale = std::min(
		window.getSize().x / (float)logoTexture.getSize().x,
		window.getSize().y / (float)logoTexture.getSize().y
	) * 0.8f;
	logoSprite.setScale(scale, scale);
	logoSprite.setPosition(
		(window.getSize().x - logoTexture.getSize().x * scale) / 2,
		(window.getSize().y - logoTexture.getSize().y * scale) / 2
	);

	// Âm thanh intro (placeholder, không có file thật)
	// sf::Music music;
	// if (music.openFromFile("gameStory_logo_intro.ogg")) music.play();

	// gamestory-loading-bar-02
	// Loading bar chạy theo thời gian hiệu ứng logo
	const float fadeInTime = 2.0f; // giây
	const float loadingTime = 2.0f; // giây
	float alpha = 0;
	sf::Clock clock;
	bool loadingDone = false;

	while (window.isOpen()) {
		sf::Event event;
		while (window.pollEvent(event)) {
			if (event.type == sf::Event::Closed)
				window.close();
		}

		float t = clock.getElapsedTime().asSeconds();
		// Fade-in logo
		if (t < fadeInTime) {
			alpha = (t / fadeInTime) * 255;
		} else {
			alpha = 255;
		}
		logoSprite.setColor(sf::Color(255,255,255, (sf::Uint8)alpha));

		// Loading bar
		float loadingProgress = std::min(1.f, std::max(0.f, (t-fadeInTime)/loadingTime));
		if (loadingProgress >= 1.f) loadingDone = true;

		window.clear(sf::Color::Black);
		window.draw(logoSprite);

		// Vẽ loading bar
		float barWidth = window.getSize().x * 0.6f;
		float barHeight = 20.f;
		float barX = (window.getSize().x - barWidth) / 2;
		float barY = window.getSize().y * 0.8f;
		sf::RectangleShape barBg(sf::Vector2f(barWidth, barHeight));
		barBg.setFillColor(sf::Color(80,80,80));
		barBg.setPosition(barX, barY);
		window.draw(barBg);
		sf::RectangleShape barFg(sf::Vector2f(barWidth * loadingProgress, barHeight));
		barFg.setFillColor(sf::Color(100,200,100));
		barFg.setPosition(barX, barY);
		window.draw(barFg);

		window.display();

		if (loadingDone) break;
	}

	// Kết thúc v1, đóng app
	window.close();
	return 0;
}
