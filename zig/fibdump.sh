#!/bin/bash

# Define the source file
SOURCE="fib.zig"
# Define the output files
LL_OUTPUT="fib.ll"
OBJ_OUTPUT="fib.o"

echo "--- 1. Creating Fibonacci Zig Source Code ---"
cat <<EOF > $SOURCE
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
EOF
echo "Created $SOURCE"

echo "--- 2. Generating LLVM IR ---"
# Compile to generate LLVM IR
zig build-obj $SOURCE --emit-llvm-ir $LL_OUTPUT
echo "Generated LLVM IR: $LL_OUTPUT"

echo "--- 3. Compiling to Object File ---"
# Compile to object file (using ReleaseSmall for optimized view)
zig build-obj $SOURCE -O ReleaseSmall -c -o $OBJ_OUTPUT
echo "Generated Object File: $OBJ_OUTPUT"

echo "--- 4. Generating Interleaved Assembly with objdump ---"
# Generate interleaved assembly
objdump -S $OBJ_OUTPUT > fib_assembly.txt
echo "Generated interleaved assembly in fib_assembly.txt"

echo "--- Process Complete ---"
echo "Artifacts created: $LL_OUTPUT, $OBJ_OUTPUT, and fib_assembly.txt"