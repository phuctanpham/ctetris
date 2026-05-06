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

class IBlock : public Block {
private:
    int rotation;
    std::vector<std::string> shapes;
public:
    IBlock();
    void rotate() override;
    Block* clone() const override { return new IBlock(*this); }
};

class OBlock : public Block {
public:
    OBlock();
    void rotate() override {} // O block doesn't rotate
    Block* clone() const override { return new OBlock(*this); }
};

class TBlock : public Block {
private:
    int rotation;
    std::vector<std::string> shapes;
public:
    TBlock();
    void rotate() override;
    Block* clone() const override { return new TBlock(*this); }
};

class SBlock : public Block {
private:
    int rotation;
    std::vector<std::string> shapes;
public:
    SBlock();
    void rotate() override;
    Block* clone() const override { return new SBlock(*this); }
};

class ZBlock : public Block {
private:
    int rotation;
    std::vector<std::string> shapes;
public:
    ZBlock();
    void rotate() override;
    Block* clone() const override { return new ZBlock(*this); }
};

class JBlock : public Block {
private:
    int rotation;
    std::vector<std::string> shapes;
public:
    JBlock();
    void rotate() override;
    Block* clone() const override { return new JBlock(*this); }
};

class LBlock : public Block {
private:
    int rotation;
    std::vector<std::string> shapes;
public:
    LBlock();
    void rotate() override;
    Block* clone() const override { return new LBlock(*this); }
};

#endif
