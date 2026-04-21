// phucpt: app/src/gameStory/app.cpp
#include <iostream>
#include <thread>
#include <chrono>
#include <fstream>
#include <vector>
#include <string>
#include <cstdlib>
#include "include/layout.h"

using namespace std;

// gameconsole-tao-giao-dien-169-00
// Thiết lập layout console 9:16
void setupLayout() {
#ifdef _WIN32
	// Windows: dùng system("mode con: cols=36 lines=64")
	system("mode con: cols=36 lines=64");
#else
	// macOS/Linux: dùng ANSI escape code
	cout << "\033[8;64;36t";
#endif
}

// gameconsole-logo-intro-01
// Hiển thị logo UIT với hiệu ứng và âm thanh
void showLogoIntro() {
	// Hiệu ứng fade-in đơn giản bằng text
	vector<string> logo = {
		"  _   _ _____ ",
		" | | | |_   _|", 
		" | |_| | | |  ",
		" |  _  | | |  ",
		" |_| |_| |_|  ",
		"   U N I V   ",
		"   I T      "
	};
	for (int i = 0; i < logo.size(); ++i) {
		cout << string((FRAME_WIDTH - logo[i].size())/2, ' ') << logo[i] << endl;
		this_thread::sleep_for(chrono::milliseconds(200));
	}
	// Phát âm thanh nếu có file mp4 (macOS: open, Linux: xdg-open, Windows: start)
#ifdef __APPLE__
	system("open ./gameStory_logo.mp4 &");
#elif defined(_WIN32)
	system("start gameStory_logo.mp4");
#else
	system("xdg-open ./gameStory_logo.mp4 &");
#endif
}

// gamestory-loading-bar-02
// Loading bar hiệu ứng theo thời gian logo
void showLoadingBar(int duration_ms = 2000) {
	int width = FRAME_WIDTH - 8;
	cout << "\n" << string((FRAME_WIDTH-width)/2, ' ') << "[";
	cout.flush();
	for (int i = 0; i < width; ++i) {
		cout << "=";
		cout.flush();
		this_thread::sleep_for(chrono::milliseconds(duration_ms/width));
	}
	cout << "]\n";
}

int main() {
	setupLayout();
	showLogoIntro();
	showLoadingBar();
	// ...
	return 0;
}
