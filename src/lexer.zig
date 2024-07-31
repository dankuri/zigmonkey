const std = @import("std");
const Token = @import("token.zig").Token;
const expectEqual = std.testing.expectEqual;
const expectEqualStrings = std.testing.expectEqualStrings;

pub const Lexer = struct {
    input: []const u8,
    position: usize = 0,
    read_position: usize = 0,
    ch: u8 = 0,

    pub fn init(input: []const u8) Lexer {
        var lexer = Lexer{ .input = input };
        lexer.readChar();

        return lexer;
    }

    pub fn nextToken(self: *Lexer) Token {
        const token = switch (self.ch) {
            '=' => Token{ .type = .assign, .literal = "=" },
            ';' => Token{ .type = .semicolon, .literal = ";" },
            '(' => Token{ .type = .lparen, .literal = "(" },
            ')' => Token{ .type = .rparen, .literal = ")" },
            ',' => Token{ .type = .comma, .literal = "," },
            '+' => Token{ .type = .plus, .literal = "+" },
            '{' => Token{ .type = .lbrace, .literal = "{" },
            '}' => Token{ .type = .rbrace, .literal = "}" },
            else => Token{ .type = .eof },
        };

        self.readChar();
        return token;
    }

    fn readChar(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }
};

test "lexer" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x,y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
    ;

    var lexer = Lexer.init(input);
    // try expectEqual(token.Token.assign, lexer.nextToken());
    const test_tokens = [_]Token{
        .{ .type = .let, .literal = "let" },
        .{ .type = .ident, .literal = "five" },
        .{ .type = .assign, .literal = "=" },
        .{ .type = .int, .literal = "5" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .let, .literal = "let" },
        .{ .type = .ident, .literal = "ten" },
        .{ .type = .assign, .literal = "=" },
        .{ .type = .int, .literal = "10" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .let, .literal = "let" },
        .{ .type = .ident, .literal = "add" },
        .{ .type = .assign, .literal = "=" },
        .{ .type = .function, .literal = "fn" },
        .{ .type = .lparen, .literal = "(" },
        .{ .type = .ident, .literal = "x" },
        .{ .type = .comma, .literal = "," },
        .{ .type = .ident, .literal = "y" },
        .{ .type = .rparen, .literal = ")" },
        .{ .type = .lbrace, .literal = "{" },
        .{ .type = .ident, .literal = "x" },
        .{ .type = .plus, .literal = "+" },
        .{ .type = .ident, .literal = "y" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .rbrace, .literal = "}" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .let, .literal = "let" },
        .{ .type = .ident, .literal = "result" },
        .{ .type = .assign, .literal = "=" },
        .{ .type = .ident, .literal = "add" },
        .{ .type = .lparen, .literal = "(" },
        .{ .type = .ident, .literal = "five" },
        .{ .type = .comma, .literal = "," },
        .{ .type = .ident, .literal = "ten" },
        .{ .type = .rparen, .literal = ")" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .eof },
    };

    for (test_tokens) |test_token| {
        const token = lexer.nextToken();
        try expectEqual(test_token.type, token.type);
        try expectEqualStrings(test_token.literal, token.literal);
    }
}
