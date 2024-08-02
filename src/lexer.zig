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
        lexer.read_char();

        return lexer;
    }

    pub fn next_token(self: *Lexer) Token {
        self.skip_whitespace();

        var token: Token = undefined;
        switch (self.ch) {
            '=' => {
                if (self.peek_char() == '=') {
                    self.read_char();
                    token = Token{ .type = .eq, .literal = "==" };
                } else {
                    token = Token{ .type = .assign, .literal = "=" };
                }
            },
            '+' => token = Token{ .type = .plus, .literal = "+" },
            '-' => token = Token{ .type = .minus, .literal = "-" },
            '!' => {
                if (self.peek_char() == '=') {
                    self.read_char();
                    token = Token{ .type = .not_eq, .literal = "!=" };
                } else {
                    token = Token{ .type = .bang, .literal = "!" };
                }
            },
            '*' => token = Token{ .type = .asterisk, .literal = "*" },
            '/' => token = Token{ .type = .slash, .literal = "/" },
            '<' => token = Token{ .type = .lt, .literal = "<" },
            '>' => token = Token{ .type = .gt, .literal = ">" },
            ',' => token = Token{ .type = .comma, .literal = "," },
            ';' => token = Token{ .type = .semicolon, .literal = ";" },
            '(' => token = Token{ .type = .lparen, .literal = "(" },
            ')' => token = Token{ .type = .rparen, .literal = ")" },
            '{' => token = Token{ .type = .lbrace, .literal = "{" },
            '}' => token = Token{ .type = .rbrace, .literal = "}" },
            0 => token = Token{ .type = .eof },
            else => {
                if (is_letter(self.ch)) {
                    const lit = self.read_identifier();
                    const token_type = Token.lookup_ident(lit);
                    return Token{ .type = token_type, .literal = lit };
                } else if (std.ascii.isDigit(self.ch)) {
                    const lit = self.read_number();
                    return Token{ .type = .int, .literal = lit };
                }
                token = Token{ .type = .illegal, .literal = &[_]u8{self.ch} };
            },
        }

        self.read_char();
        return token;
    }

    fn peek_char(self: *Lexer) u8 {
        if (self.read_position >= self.input.len) {
            return 0;
        } else {
            return self.input[self.read_position];
        }
    }

    fn read_char(self: *Lexer) void {
        if (self.read_position >= self.input.len) {
            self.ch = 0;
        } else {
            self.ch = self.input[self.read_position];
        }
        self.position = self.read_position;
        self.read_position += 1;
    }

    fn read_number(self: *Lexer) []const u8 {
        const position = self.position;
        while (std.ascii.isDigit(self.ch)) {
            self.read_char();
        }
        return self.input[position..self.position];
    }

    fn read_identifier(self: *Lexer) []const u8 {
        const position = self.position;
        while (is_letter(self.ch)) {
            self.read_char();
        }
        return self.input[position..self.position];
    }

    fn skip_whitespace(self: *Lexer) void {
        while (std.ascii.isWhitespace(self.ch)) {
            self.read_char();
        }
    }
};

fn is_letter(char: u8) bool {
    return std.ascii.isAlphabetic(char) or char == '_';
}

test "lexer" {
    const input =
        \\let five = 5;
        \\let ten = 10;
        \\let add = fn(x,y) {
        \\  x + y;
        \\};
        \\
        \\let result = add(five, ten);
        \\!-/*5;
        \\5 < 10 > 5;
        \\
        \\if (5 < 10) {
        \\  return true;
        \\} else {
        \\  return false;
        \\}
        \\
        \\10 == 10;
        \\10 != 9;
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

        .{ .type = .bang, .literal = "!" },
        .{ .type = .minus, .literal = "-" },
        .{ .type = .slash, .literal = "/" },
        .{ .type = .asterisk, .literal = "*" },
        .{ .type = .int, .literal = "5" },
        .{ .type = .semicolon, .literal = ";" },

        .{ .type = .int, .literal = "5" },
        .{ .type = .lt, .literal = "<" },
        .{ .type = .int, .literal = "10" },
        .{ .type = .gt, .literal = ">" },
        .{ .type = .int, .literal = "5" },
        .{ .type = .semicolon, .literal = ";" },

        //if (5 < 10) {
        //  return true;
        //} else {
        //  return false;
        //}

        .{ .type = .if_, .literal = "if" },
        .{ .type = .lparen, .literal = "(" },
        .{ .type = .int, .literal = "5" },
        .{ .type = .lt, .literal = "<" },
        .{ .type = .int, .literal = "10" },
        .{ .type = .rparen, .literal = ")" },
        .{ .type = .lbrace, .literal = "{" },
        .{ .type = .return_, .literal = "return" },
        .{ .type = .true_, .literal = "true" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .rbrace, .literal = "}" },
        .{ .type = .else_, .literal = "else" },
        .{ .type = .lbrace, .literal = "{" },
        .{ .type = .return_, .literal = "return" },
        .{ .type = .false_, .literal = "false" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .rbrace, .literal = "}" },

        .{ .type = .int, .literal = "10" },
        .{ .type = .eq, .literal = "==" },
        .{ .type = .int, .literal = "10" },
        .{ .type = .semicolon, .literal = ";" },
        .{ .type = .int, .literal = "10" },
        .{ .type = .not_eq, .literal = "!=" },
        .{ .type = .int, .literal = "9" },
        .{ .type = .semicolon, .literal = ";" },

        .{ .type = .eof },
    };

    for (test_tokens) |test_token| {
        const token = lexer.next_token();
        try expectEqual(test_token.type, token.type);
        try expectEqualStrings(test_token.literal, token.literal);
    }
}
