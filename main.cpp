#include <iostream>
#include <ctime>
#include <unistd.h>
#include <termios.h>
#include <fcntl.h>
#include <sys/select.h>
#include <algorithm>

using namespace std;
#define H 20
#define W 15
char board[H][W] = {};
char currentPiece[4][4];

class Blocks {
public:
    char shape[4][4];
    
    Blocks() {
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                shape[i][j] = ' ';
    }
};

int x, y, b;
Blocks blocks[16] = {
    {{{' ','I',' ',' '},
      {' ','I',' ',' '},
      {' ','I',' ',' '},
      {' ','I',' ',' '}}},
    {{{' ','I',' ',' '},
      {' ','I',' ',' '},
      {' ','I',' ',' '},
      {' ','I',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {'I','I','I','I'},
      {' ',' ',' ',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','O','O',' '},
      {' ','O','O',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','T',' ',' '},
      {'T','T','T',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ','S','S',' '},
      {'S','S',' ',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {'Z','Z',' ',' '},
      {' ','Z','Z',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {'J',' ',' ',' '},
      {'J','J','J',' '},
      {' ',' ',' ',' '}}},
    {{{' ',' ',' ',' '},
      {' ',' ','L',' '},
      {'L','L','L',' '},
      {' ',' ',' ',' '}}}
};
void rotateMatrixCCW(const char src[4][4], char dst[4][4]){
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            dst[i][j] = src[j][3 - i];
}

void buildCurrentPiece(){
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            currentPiece[i][j] = shapes[shapeOffsets[blockType] + rotationIndex][i][j];
}

bool canMove(int dx, int dy){
    for (int i = 0; i < 4; i++ )
        for (int j = 0; j < 4; j++ )
            if (blocks[b].shape[i][j] != ' ') {
                int xt = x + j + dx;
                int yt = y + i + dy;
                if (xt < 1 || xt >= W-1 || yt >= H-1 ) return false;
                if (board[yt][xt] != ' ') return false;
            }
    return true;
}

bool canRotate(){
    char rotated[4][4];
    rotateMatrixCCW(currentPiece, rotated);
    for (int i = 0; i < 4; i++ )
        for (int j = 0; j < 4; j++ )
            if (rotated[i][j] != ' ') {
                int xt = x + j;
                int yt = y + i;
                if (xt < 1 || xt >= W-1 || yt >= H-1 ) return false;
                if (board[yt][xt] != ' ') return false;
            }
    return true;
}

void rotateBlock(){
    char tmp[4][4];
    rotateMatrixCCW(currentPiece, tmp);
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            currentPiece[i][j] = tmp[i][j];
    rotationIndex = (rotationIndex + 1) % rotationCount[blockType];
}

void block2Board(){
    for (int i = 0; i < 4; i++ )
        for (int j = 0; j < 4; j++ )
            if (blocks[b].shape[i][j] != ' ')
                board[y+i][x+j] = blocks[b].shape[i][j];
}

void boardDelBlock(){
    for (int i = 0; i < 4; i++ )
        for (int j = 0; j < 4; j++ )
            if (blocks[b].shape[i][j] != ' ')
                board[y+i][x+j] = ' ';
}
void initBoard(){
    for (int i = 0 ; i < H ; i++)
        for (int j = 0 ; j < W ; j++)
            if (i == 0 || i == H-1 || j ==0 || j == W-1) board[i][j] = '#';
            else board[i][j] = ' ';
}
int removeLine(){
    int linesRemoved = 0;
    for (int i = H-2; i > 0; i--) {
        bool full = true;
        for (int j = 1; j < W-1; j++) {
            if (board[i][j] == ' ') {
    for (int i = H-2; i > 0; i--){
        bool full = true;
        for (int j = 1; j < W-1; j++){
            if (board[i][j] == ' '){
                full = false;
                break;
            }
        }
        if (full) {
            linesRemoved++;
            for (int k = i; k > 1; k--) {
                for (int j = 1; j < W-1; j++) {
                    board[k][j] = board[k-1][j];
                }
            }
            for (int j = 1; j < W-1; j++) {
                board[1][j] = ' ';
            }
        if (full){
            for (int k = i; k > 1; k--)
                for (int j = 1; j < W-1; j++)
                    board[k][j] = board[k-1][j];
            for (int j = 1; j < W-1; j++)
                board[1][j] = ' ';
            i++;
        }
    }
    return linesRemoved;
}
void draw(){
    system("clear");

    for (int i = 0 ; i < H ; i++, cout<<endl)
        for (int j = 0 ; j < W ; j++) {
            if (board[i][j] == ' ') cout<<"  ";
            else cout<<"██";
        }
}

void initTerminal(){
    tcgetattr(STDIN_FILENO, &oldTermios);
    struct termios newTermios = oldTermios;
    newTermios.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newTermios);
    fcntl(STDIN_FILENO, F_SETFL, O_NONBLOCK);
}

void resetTerminal(){
    tcsetattr(STDIN_FILENO, TCSANOW, &oldTermios);
}

bool kbhit(){
    fd_set fds;
    FD_ZERO(&fds);
    FD_SET(STDIN_FILENO, &fds);
    struct timeval tv = {0, 0};
    return select(STDIN_FILENO + 1, &fds, NULL, NULL, &tv) > 0;
}

char getch(){
    char c = 0;
    read(STDIN_FILENO, &c, 1);
    return c;
}

void sleepMs(int ms){
    usleep(ms * 1000);
}

int main()
{
    srand(time(0));
    initTerminal();
    blockType = rand() % 7;
    rotationIndex = rand() % rotationCount[blockType];
    buildCurrentPiece();
    x = 5; y = 0;
    initBoard();
    int speed = 500;
    while (1){
        boardDelBlock();
        if (kbhit()){
            char c = getch();
            if (c == 'a' && canMove(-1,0)) x--;
            if (c == 'd' && canMove( 1,0)) x++;
            if (c == 'w' && canRotate()) rotateBlock();
            if (c == 'x' && canMove( 0,1)) y++;
            if (c == 'q') break;
        }
        if (canMove(0,1)) y++;
        else{
            block2Board();
            removeLine();
            x = 5; y = 0; b = rand()%7;
        }
        block2Board();
        draw();
        sleepMs(speed);
    }
    resetTerminal();
    return 0;
}