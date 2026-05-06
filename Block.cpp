#include "Blocks.h"
#include <cstring>

Block::Block() {
    memset(shape, ' ', sizeof(shape));
}

IBlock::IBlock() : rotation(0) {
    shapes = {
        " I  \n I  \n I  \n I  ",
        "    \nIIII\n    \n    "
    };
    // Initialize shape with first rotation
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[0][i*4 + j];
        }
    }
}

void IBlock::rotate() {
    rotation = (rotation + 1) % 2;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[rotation][i*4 + j];
        }
    }
}

OBlock::OBlock() {
    std::string s = "    \n OO \n OO \n    ";
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = s[i*4 + j];
        }
    }
}

TBlock::TBlock() : rotation(0) {
    shapes = {
        " T  \nTTT \n    \n    ",
        " T  \n TT \n T  \n    ",
        "    \nTTT \n T  \n    ",
        " T  \nTT  \n T  \n    "
    };
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[0][i*4 + j];
        }
    }
}

void TBlock::rotate() {
    rotation = (rotation + 1) % 4;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[rotation][i*4 + j];
        }
    }
}

SBlock::SBlock() : rotation(0) {
    shapes = {
        " SS \nSS  \n    \n    ",
        " S  \n SS \n  S \n    "
    };
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[0][i*4 + j];
        }
    }
}

void SBlock::rotate() {
    rotation = (rotation + 1) % 2;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[rotation][i*4 + j];
        }
    }
}

ZBlock::ZBlock() : rotation(0) {
    shapes = {
        " Z  \n ZZ \n  Z \n    ",
        "ZZ  \n ZZ \n    \n    "
    };
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[0][i*4 + j];
        }
    }
}

void ZBlock::rotate() {
    rotation = (rotation + 1) % 2;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[rotation][i*4 + j];
        }
    }
}

JBlock::JBlock() : rotation(0) {
    shapes = {
        " J  \nJJJ \n    \n    ",
        "JJ  \n J  \n J  \n    ",
        "    \nJJJ \n  J \n    ",
        " J  \n J  \nJJ  \n    "
    };
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[0][i*4 + j];
        }
    }
}

void JBlock::rotate() {
    rotation = (rotation + 1) % 4;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[rotation][i*4 + j];
        }
    }
}

LBlock::LBlock() : rotation(0) {
    shapes = {
        " L  \nLLL \n    \n    ",
        " L  \n L  \n LL \n    ",
        "    \nLLL \nL   \n    ",
        "LL  \n L  \n L  \n    "
    };
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[0][i*4 + j];
        }
    }
}

void LBlock::rotate() {
    rotation = (rotation + 1) % 4;
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 4; j++) {
            shape[i][j] = shapes[rotation][i*4 + j];
        }
    }
}