#include <iostream>
#include <conio.h>
#include <cstdlib>
#include <ctime>
#include "Blocks.h"

using namespace std;
#define H 20
#define W 15
char board[H][W] = {};

int x, y;
Block* currentBlock;

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
bool canMove(int dx, int dy){
    for (int i = 0; i < 4; i++ )
        for (int j = 0; j < 4; j++ )
            if (currentBlock->shape[i][j] != ' ') {
                int xt = x + j + dx;
                int yt = y + i + dy;
                if (xt < 1 || xt >= W-1 || yt >= H-1 ) return false;
                if (board[yt][xt] != ' ') return false;
            }
    return true;
}
void block2Board(){
    for (int i = 0; i < 4; i++ )
        for (int j = 0; j < 4; j++ )
            if (currentBlock->shape[i][j] != ' ')
                board[y+i][x+j] = currentBlock->shape[i][j];
}
void boardDelBlock(){
    for (int i = 0; i < 4; i++ )
        for (int j = 0; j < 4; j++ )
            if (currentBlock->shape[i][j] != ' ')
                board[y+i][x+j] = ' ';
}
void initBoard(){
    for (int i = 0 ; i < H ; i++)
        for (int j = 0 ; j < W ; j++)
            if (i == 0 || i == H-1 || j ==0 || j == W-1) board[i][j] = '#';
            else board[i][j] = ' ';
}
void removeLine(){
    for (int i = H-2; i > 0; i--) {
        bool full = true;
        for (int j = 1; j < W-1; j++) {
            if (board[i][j] == ' ') {
                full = false;
                break;
            }
        }
        if (full) {
            for (int k = i; k > 1; k--) {
                for (int j = 1; j < W-1; j++) {
                    board[k][j] = board[k-1][j];
                }
            }
            for (int j = 1; j < W-1; j++) {
                board[1][j] = ' ';
            }
            i++;
        }
    }
}
void draw(){
    system("cls");

    for (int i = 0 ; i < H ; i++, cout<<endl)
        for (int j = 0 ; j < W ; j++) {
            if (board[i][j] == ' ') cout<<"  ";
            else cout<<"██";
        }
}

int main()
{
    srand(time(0));
    x = 5; y = 0; currentBlock = createRandomBlock();
    initBoard();
    while (1){
        boardDelBlock();
        if (kbhit()){
            char c = getch();
            if (c == 'a' && canMove(-1,0)) x--;
            if (c == 'd' && canMove( 1,0)) x++;
            if (c == 'x' && canMove( 0,1)) y++;
            if (c == 'w') {
                currentBlock->rotate();
                if (!canMove(0,0)) currentBlock->rotate(); // revert if can't rotate
            }
            if (c == 'q') break;
        }
        if (canMove(0,1)) y++;
        else{
            block2Board();
            removeLine();
            delete currentBlock;
            x = 5; y = 0; currentBlock = createRandomBlock();
        }
        block2Board();
        draw();
        _sleep(500);
    }
    delete currentBlock;
    return 0;
}