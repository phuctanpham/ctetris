#include "Blocks.h"
#include <cstring>

Block::Block() {
    memset(shape, ' ', sizeof(shape));
}

// RotatableBlock implementation
void RotatableBlock::updateShape() {
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[rotation][i*4 + j];
        }
    }
}

void RotatableBlock::rotate() {
    rotation = (rotation + 1) % shapes.size();
    updateShape();
}

// IBlock
IBlock::IBlock() {
    shapes = {
        " I  \n I  \n I  \n I  ",
        "    \nIIII\n    \n    "
    };
    updateShape();
}

// OBlock
OBlock::OBlock() {
    std::string s = "    \n OO \n OO \n    ";
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = s[i*4 + j];
        }
    }
}

// TBlock
TBlock::TBlock() {
    shapes = {
        " T  \nTTT \n    \n    ",
        " T  \n TT \n T  \n    ",
        "    \nTTT \n T  \n    ",
        " T  \nTT  \n T  \n    "
    };
    updateShape();
}

// SBlock
SBlock::SBlock() {
    shapes = {
        " SS \nSS  \n    \n    ",
        " S  \n SS \n  S \n    "
    };
    updateShape();
}

// ZBlock
ZBlock::ZBlock() {
    shapes = {
        " Z  \n ZZ \n  Z \n    ",
        "ZZ  \n ZZ \n    \n    "
    };
    updateShape();
}

// JBlock
JBlock::JBlock() {
    shapes = {
        " J  \nJJJ \n    \n    ",
        "JJ  \n J  \n J  \n    ",
        "    \nJJJ \n  J \n    ",
        " J  \n J  \nJJ  \n    "
    };
    updateShape();
}

// LBlock
LBlock::LBlock() {
    shapes = {
        " L  \nLLL \n    \n    ",
        " L  \n L  \n LL \n    ",
        "    \nLLL \nL   \n    ",
        "LL  \n L  \n L  \n    "
    };
    updateShape();
}