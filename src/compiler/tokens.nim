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
    Type,
    String,
    Native,
    Comma,

type NoliToken* = object
    value*: string
    kind*: NoliTokenType

const NOLI_KEYWORDS*: Table[string, NoliTokenType] = {
    "let": NoliTokenType.Let,
    "null": NoliTokenType.Null,
    "string": NoliTokenType.Type,
    "num": NoliTokenType.Type
}.toTable()

const NOLI_NATIVE_FUNCTIONS*: Table[string, NoliTokenType] = {
    "print": NoliTokenType.Native,
}.toTable()