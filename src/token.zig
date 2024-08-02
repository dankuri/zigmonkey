const std = @import("std");

pub const Token = struct {
    type: Type,
    literal: []const u8 = "",

    const keywords = std.StaticStringMap(Token.Type).initComptime(.{
        .{ "fn", .function },
        .{ "let", .let },
        .{ "true", .true_ },
        .{ "false", .false_ },
        .{ "if", .if_ },
        .{ "else", .else_ },
        .{ "return", .return_ },
    });

    pub fn lookup_ident(ident: []const u8) Token.Type {
        return (keywords.get(ident)) orelse .ident;
    }

    pub const Type = enum {
        illegal,
        eof,

        // identifiers & literals
        ident,
        int,

        // operators
        assign,
        plus,
        minus,
        bang,
        asterisk,
        slash,

        lt,
        gt,
        eq,
        not_eq,

        // delimiters
        comma,
        semicolon,

        lparen,
        rparen,
        lbrace,
        rbrace,

        // keywords
        function,
        let,
        true_,
        false_,
        if_,
        else_,
        return_,
    };
};
