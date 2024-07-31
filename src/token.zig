pub const Token = struct {
    type: Type,
    literal: []const u8 = "",

    pub const Type = enum {
        illegal,
        eof,

        // identifiers & literals
        ident,
        int,

        // operators
        assign,
        plus,

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
    };
};
