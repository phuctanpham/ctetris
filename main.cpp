#include <iostream>
#include <cstdlib>
#include <ctime>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/select.h>
#include "Blocks.h"

using namespace std;
#define H 20
#define W 15
char board[H][W] = {};

int x, y;
Block* currentBlock;
struct termios oldTermios;

Block* createRandomBlock() {
    int r = rand() % 7;
    switch (r) {
        case 0: return new IBlock();
        case 1: return new OBlock();
        case 2: return new TBlock();
        case 3: return new SBlock();
        case 4: return new ZBlock();
        case 5: return new JBlock();
        case 6: return new LBlock();
    }
    return nullptr;
}

bool canMove(int dx, int dy) {
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            if (currentBlock->shape[i][j] != ' ') {
                int xt = x + j + dx;
                int yt = y + i + dy;
                if (xt < 1 || xt >= W-1 || yt >= H-1) return false;
                if (board[yt][xt] != ' ') return false;
            }
    return true;
}

bool canRotate() {
    Block* tmp = currentBlock->clone();
    tmp->rotate();
    bool fits = true;
    for (int i = 0; i < 4 && fits; i++)
        for (int j = 0; j < 4 && fits; j++)
            if (tmp->shape[i][j] != ' ') {
                int xt = x + j;
                int yt = y + i;
                if (xt < 1 || xt >= W-1 || yt >= H-1) fits = false;
                else if (board[yt][xt] != ' ') fits = false;
            }
    delete tmp;
    return fits;
}

void block2Board() {
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            if (currentBlock->shape[i][j] != ' ')
                board[y+i][x+j] = currentBlock->shape[i][j];
}

void boardDelBlock() {
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            if (currentBlock->shape[i][j] != ' ')
                board[y+i][x+j] = ' ';
}

void initBoard() {
    for (int i = 0; i < H; i++)
        for (int j = 0; j < W; j++)
            if (i == 0 || i == H-1 || j == 0 || j == W-1) board[i][j] = '#';
            else board[i][j] = ' ';
}

int removeLine() {
    int linesRemoved = 0;
    for (int i = H-2; i > 0; i--) {
        bool full = true;
        for (int j = 1; j < W-1; j++) {
            if (board[i][j] == ' ') {
                full = false;
                break;
            }
        }
        if (full) {
            linesRemoved++;
            for (int k = i; k > 1; k--)
                for (int j = 1; j < W-1; j++)
                    board[k][j] = board[k-1][j];
            for (int j = 1; j < W-1; j++)
                board[1][j] = ' ';
            i++; // re-check this row after shifting down
        }
    }
    return linesRemoved;
}

void draw() {
    system("clear");
    for (int i = 0; i < H; i++, cout<<endl)
        for (int j = 0; j < W; j++) {
            if (board[i][j] == ' ') cout<<"  ";
            else cout<<"██";
        }
}

void initTerminal() {
    tcgetattr(STDIN_FILENO, &oldTermios);
    struct termios newTermios = oldTermios;
    newTermios.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newTermios);
    fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);
}

void resetTerminal() {
    tcsetattr(STDIN_FILENO, TCSANOW, &oldTermios);
}

bool kbhit() {
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds);
    struct timeval tv = {0, 0};
    return select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv) > 0;
}

char getch() {
    char c = 0;
    read(STDIN_FILENO, &c, 1);
    return c;
}

void sleepMs(int ms) {
    usleep(ms * 1000);
}

int main() {
    srand(time(0));
    initTerminal();
    initBoard();
    x = 5; y = 1; currentBlock = createRandomBlock();
    int speed = 500;
    while (1) {
        boardDelBlock();
        if (kbhit()) {
            char c = getch();
            if (c == 'a' && canMove(-1, 0)) x--;
            if (c == 'd' && canMove( 1, 0)) x++;
            if (c == 'w' && canRotate()) currentBlock->rotate();
            if (c == 'x' && canMove( 0, 1)) y++;
            if (c == 'q') break;
        }
        if (canMove(0, 1)) y++;
        else {
            block2Board();
            removeLine();
            delete currentBlock;
            x = 5; y = 1; currentBlock = createRandomBlock();
        }
        block2Board();
        draw();
        sleepMs(speed);
    }
    resetTerminal();
    delete currentBlock;
    return 0;
}
