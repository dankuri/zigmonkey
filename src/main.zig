const std = @import("std");
const Lexer = @import("lexer.zig").Lexer;
const Token = @import("token.zig").Token;

var gp = std.heap.GeneralPurposeAllocator(.{}){};
const gpa = gp.allocator();

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const stdin = std.io.getStdIn().reader();

    try stdout.print("Welcome to Monkey REPL in Zig!\n", .{});
    // repl
    while (true) {
        try stdout.print(">> ", .{});

        if (try stdin.readUntilDelimiterOrEofAlloc(gpa, '\n', 1024)) |input| {
            var lexer = Lexer.init(input);
            var token = lexer.next_token();
            while (token.type != Token.Type.eof) : (token = lexer.next_token()) {
                try stdout.print("Token: type = {s}, literal = \"{s}\"\n", .{ @tagName(token.type), token.literal });
            }
        } else {
            break;
        }
    }
}
