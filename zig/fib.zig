const std = @import("std");

pub fn main() !void {
    var a: u64 = 0;
    var b: u64 = 1;
    var count: u64 = 0;

    const stdout = std.io.getStdOut();

    try stdout.print("Fibonacci Sequence:\n", .{});

    while (count < 10) : (count += 1) {
        try stdout.print("{d}\n", .{a});
        const next = a + b;
        a = b;
        b = next;
    }
}