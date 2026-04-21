#include <iostream>
#include <windows.h>
using namespace std;

// Di chuyển con trỏ đến (x, y)
void gotoXY(int x, int y) {
    COORD coord;
    coord.X = x;
    coord.Y = y;
    SetConsoleCursorPosition(GetStdHandle(STD_OUTPUT_HANDLE), coord);
}

int main() {
    HANDLE hConsole = GetStdHandle(STD_OUTPUT_HANDLE);
    CONSOLE_SCREEN_BUFFER_INFO csbi;
    GetConsoleScreenBufferInfo(hConsole, &csbi);
    SetConsoleTextAttribute(hConsole, 10);

    int width = csbi.srWindow.Right - csbi.srWindow.Left + 1;
    int height = csbi.srWindow.Bottom - csbi.srWindow.Top + 1;

    string text[] = {
        "TTTTTT  EEEEEE  TTTTTT  RRRRR   IIIIII  SSSSSS",
        "  TT    EE        TT    RR   RR    II    SS    ",
        "  TT    EEEEE     TT    RRRRRR     II    SSSSS ",
        "  TT    EE        TT    RR  RR     II        SS",
        "  TT    EEEEEE    TT    RR   RR  IIIIII  SSSSSS"
    };

    int textHeight = 5;
    int startY = height / 2 - textHeight / 2;

    for (int i = 0; i < textHeight; i++) {
        int textWidth = text[i].length();
        int startX = width / 2 - textWidth / 2;
        gotoXY(startX, startY + i);
        cout << text[i];
    }

    // In dòng "Press any key..." bên dưới
    string msg = "Press any key to start...";
    gotoXY(width / 2 - msg.length() / 2, startY + textHeight + 2);
    cout << msg;

    cin.get();
    return 0;
}