#pragma once
#include <SFML/Graphics.hpp>

namespace layout {
    inline sf::RenderWindow create916Window(int height) {
        int width = height * 9 / 16;
        sf::ContextSettings settings;
        settings.antiAliasingLevel = 0;
        return sf::RenderWindow(
            sf::VideoMode(sf::Vector2u(width, height)),
            "GameStory 9:16",
            sf::State::Windowed,
            settings
        );
    }
}
