#ifndef BLOCKS_H
#define BLOCKS_H

#include <vector>
#include <string>

class Block {
public:
    char shape[4][4];
    Block();
    virtual ~Block() {}
    virtual void rotate() = 0;
    virtual Block* clone() const = 0;
    char getShape(int i, int j) const { return shape[i][j]; }
};

// Base class for rotatableblocks - implements rotation logic
class RotatableBlock : public Block {
protected:
    int rotation;
    std::vector<std::string> shapes;
    
    // Helper method to update shape from shapes vector
    void updateShape();
    
public:
    RotatableBlock() : rotation(0) {}
    virtual ~RotatableBlock() {}
    
    void rotate() override;
};

class IBlock : public RotatableBlock {
public:
    IBlock();
    Block* clone() const override { return new IBlock(*this); }
};

class OBlock : public Block {
public:
    OBlock();
    void rotate() override {} // O block doesn't rotate
    Block* clone() const override { return new OBlock(*this); }
};

class TBlock : public RotatableBlock {
public:
    TBlock();
    Block* clone() const override { return new TBlock(*this); }
};

class SBlock : public RotatableBlock {
public:
    SBlock();
    Block* clone() const override { return new SBlock(*this); }
};

class ZBlock : public RotatableBlock {
public:
    ZBlock();
    Block* clone() const override { return new ZBlock(*this); }
};

class JBlock : public RotatableBlock {
public:
    JBlock();
    Block* clone() const override { return new JBlock(*this); }
};

class LBlock : public RotatableBlock {
public:
    LBlock();
    Block* clone() const override { return new LBlock(*this); }
};

#endif
