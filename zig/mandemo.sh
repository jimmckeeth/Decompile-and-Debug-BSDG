#!/bin/bash

# Configuration
SOURCE_FILE="mandelbrot.zig"
EXE_NAME="mandelbrot"
OBJ_NAME="mandelbrot.o"
IR_NAME="mandelbrot.ll"
DUMP_NAME="mandelbrot_asm.txt"

# Colors for output
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${CYAN}--- Zig Compilation Demo Pipeline ---${NC}"

# 1. Clean previous artifacts
rm -f "$EXE_NAME" "$OBJ_NAME" "$IR_NAME" "$DUMP_NAME"

# 2. Emit LLVM Intermediate Representation (IR)
# We use -ReleaseFast for cleaner IR logic
echo -e "${YELLOW}Step 1: Generating LLVM IR ($IR_NAME)...${NC}"
zig build-obj "$SOURCE_FILE" -femit-llvm-ir="$IR_NAME" -O ReleaseFast
if [ $? -ne 0 ]; then echo "Error generating IR"; exit 1; fi

# 3. Compile Object File with Debug Info
# -g is required so objdump can map source lines to assembly
echo -e "${YELLOW}Step 2: Compiling Object File with Debug Symbols ($OBJ_NAME)...${NC}"
zig build-obj "$SOURCE_FILE" -femit-bin="$OBJ_NAME" -g
if [ $? -ne 0 ]; then echo "Error generating Object file"; exit 1; fi

# 4. Create the Executable
echo -e "${YELLOW}Step 3: Building Final Executable ($EXE_NAME)...${NC}"
zig build-exe "$SOURCE_FILE" -O ReleaseFast
if [ $? -ne 0 ]; then echo "Error building executable"; exit 1; fi

# 5. Generate Interleaved Assembly
# zig objdump wraps the llvm-objdump utility
echo -e "${YELLOW}Step 4: Generating Interleaved Assembly ($DUMP_NAME)...${NC}"
zig objdump -d -S --no-show-raw-insn "$OBJ_NAME" > "$DUMP_NAME"

echo -e "\n${GREEN}--- Build Complete! ---${NC}"
echo "Artifacts generated:"
echo " 1. $IR_NAME      (The LLVM Intermediate Representation)"
echo " 2. $DUMP_NAME (Assembly interleaved with Zig source)"
echo " 3. $EXE_NAME     (The runnable program)"
echo -e "\n${MAGENTA}Running the program now for effect...${NC}\n"

# 6. Run the demo
sleep 1
./"$EXE_NAME"