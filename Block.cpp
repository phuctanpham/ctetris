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
        " I   I   I   I  ",
        "    IIII        "
    };
    updateShape();
}

// OBlock
OBlock::OBlock() {
    std::string s = "     OO  OO     ";
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = s[i*4 + j];
        }
    }
}

// TBlock
TBlock::TBlock() {
    shapes = {
        " T  TTT         ",
        " T   TT  T      ",
        "    TTT  T      ",
        " T  TT   T      "
    };
    updateShape();
}

// SBlock
SBlock::SBlock() {
    shapes = {
        " SS SS          ",
        " S   SS   S     "
    };
    updateShape();
}

// ZBlock
ZBlock::ZBlock() {
    shapes = {
        " Z   ZZ   Z     ",
        "ZZ   ZZ         "
    };
    updateShape();
}

// JBlock
JBlock::JBlock() {
    shapes = {
        " J  JJJ         ",
        "JJ   J   J      ",
        "    JJJ   J     ",
        " J   J  JJ      "
    };
    updateShape();
}

// LBlock
LBlock::LBlock() {
    shapes = {
        " L  LLL         ",
        " L   L   LL     ",
        "    LLL L       ",
        "LL   L   L      "
    };
    updateShape();
}