import tables

type NoliTokenType* = enum
    Number,
    Identifier,
    Equals,
    OpenParen,
    CloseParen,
    BinOp,
    Let,
    Eof,
    Null,

type NoliToken* = object
    value*: string
    kind*: NoliTokenType

const NOLI_KEYWORDS*: Table[string, NoliTokenType] = {
    "let": NoliTokenType.Let,
    "null": NoliTokenType.Null,
}.toTable()