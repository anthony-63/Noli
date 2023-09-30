type TokenType* = enum
    Number,
    Identifier,
    Equals,
    OpenParen,
    CloseParen,
    BinOp,
    Let,

type Token* = object
    value: string
    kind: TokenType