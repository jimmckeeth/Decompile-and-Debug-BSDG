const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    
    // "Retro Hacker" aesthetic: simple math, complex output
    const width = 80;
    const height = 40;
    
    // Complex number boundaries
    const min_re = -2.0;
    const max_re = 1.0;
    const min_im = -1.2;
    const max_im = 1.2;

    var y: usize = 0;
    while (y < height) : (y += 1) {
        var x: usize = 0;
        while (x < width) : (x += 1) {
            // Map pixel coordinate to complex plane
            const cr = min_re + (max_re - min_re) * @as(f64, @floatFromInt(x)) / @as(f64, @floatFromInt(width));
            const ci = min_im + (max_im - min_im) * @as(f64, @floatFromInt(y)) / @as(f64, @floatFromInt(height));

            var zr: f64 = 0.0;
            var zi: f64 = 0.0;
            var iter: usize = 0;
            const max_iter = 50;

            // The hot loop - great for viewing Assembly/LLVM IR
            while (zr * zr + zi * zi <= 4.0 and iter < max_iter) {
                const temp = zr * zr - zi * zi + cr;
                zi = 2.0 * zr * zi + ci;
                zr = temp;
                iter += 1;
            }

            // Color mapping
            if (iter == max_iter) {
                try stdout.print(" ", .{});
            } else {
                // ANSI color escape sequence based on iteration count
                const color = 31 + (iter % 6); 
                try stdout.print("\x1b[{d}m*\x1b[0m", .{color});
            }
        }
        try stdout.print("\n", .{});
    }
}