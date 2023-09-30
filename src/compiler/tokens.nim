import tables

type NoliTokenType* = enum
    Number,
    Identifier,
    Equals,
    OpenParen,
    CloseParen,
    BinOp,
    Let,

type NoliToken* = object
    value*: string
    kind*: NoliTokenType

const NOLI_KEYWORDS*: Table[string, NoliTokenType] = {
    "let": NoliTokenType.Let,
}.toTable()