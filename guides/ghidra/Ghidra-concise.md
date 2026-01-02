# The Ultimate Guide to Using Ghidra for Reverse Engineering

## Introduction

Ghidra is a software reverse engineering (SRE) framework created by the National Security Agency (NSA). It includes a suite of full-featured, high-end software analysis tools that enable users to analyze compiled code on a variety of platforms including Windows, macOS, and Linux.

This guide covers the essentials of installation, the interface, the analysis workflow, and specifically highlights the major advancements introduced in Ghidra 10.

## Table of Contents

1. [Installation & Setup](#installation--setup)
2. [The Ghidra Interface](#the-ghidra-interface)
3. [Basic Workflow](#basic-workflow)
4. [The Power of the Decompiler](#the-power-of-the-decompiler)
5. [Ghidra 10: The Debugger](#ghidra-10-the-debugger)
6. [Step-by-Step Exercise: Solving a Simple Crackme](#step-by-step-exercise-solving-a-simple-crackme)

---

## Installation & Setup

### Prerequisites

- **Java Development Kit (JDK):** Ghidra requires JDK 17 or later (for newer versions).
  - Download [Eclipse Temurin JDK 17](https://adoptium.net/) or [Amazon Corretto](https://aws.amazon.com/corretto/).

### Steps

1. Download the latest version of Ghidra from the [official release page](https://github.com/NationalSecurityAgency/ghidra/releases).
2. Extract the zip file to a desired location (e.g., `/opt/ghidra` or `C:\Tools\ghidra`).
3. Launch Ghidra:
   - **Windows:** Run `ghidraRun.bat`.
   - **Linux/macOS:** Run `./ghidraRun`.

---

## The Ghidra Interface

When you first launch Ghidra, you are greeted by the **Project Manager**. This is where you organize your work.

### Key Components

1. **Tool Chest:** Contains the tools available (CodeBrowser, Debugger, Version Tracking).
2. **Project Window:** Displays your active project and file structure.
3. **CodeBrowser:** The main workspace where 90% of reverse engineering happens. It consists of:
   - **Program Tree:** Hierarchical view of the binary sections (.text, .data, etc.).
   - **Symbol Tree:** List of imports, exports, functions, and labels.
   - **Listing View:** The assembly code (Disassembly).
   - **Decompiler:** High-level C pseudo-code representation.

---

## Basic Workflow

### 1. Creating a Project

Go to `File -> New Project`. Choose "Non-Shared Project" for local work. Select a directory and name it.

### 2. Importing a File

- Drag and drop your target binary (e.g., `crackme.exe` or `malware.bin`) into the Project Window.
- Ghidra will attempt to detect the format (PE, ELF, Mach-O) and language (x86, ARM, MIPS).
- Click "OK" to import. The file will appear in your file list.

### 3. Auto-Analysis

Double-click the file to open it in the **CodeBrowser**. You will be prompted to analyze the file.

- Click **Yes**.
- Keep the default options selected (ASCII Strings, Function Start Search, Stack Analysis, etc.) and click **Analyze**.
- _Tip:_ Watch the bottom right corner for the progress bar. Wait until it finishes.

---

## The Power of the Decompiler

The Decompiler is Ghidra's "killer feature." It translates assembly instructions into human-readable C code.

### Navigation Shortcuts

- **`G`**: Go to address.
- **`L`**: Retype a variable or function return type.
- **`N`**: Rename a variable or function.
- **``**: Add a comment.
- **`Ctrl+L`**: Retype a struct field.

### Improving Decompilation

The raw decompilation is rarely perfect. You must refine it:

1. **Rename Variables:** If you see `iVar1`, figure out what it does and rename it to `counter` or `flag`.
2. **Retype Data:** If a function takes `long param_1` but you know it's a `char *`, press `Ctrl+L` on the parameter and change it to `char *`. The decompiler will instantly update the logic to reflect string operations.
3. **Create Structures:** Right-click in the "Data Type Manager", create a new struct, and apply it to memory locations to clean up pointer arithmetic.

---

## Ghidra 10: The Debugger

The most significant addition in Ghidra 10 was the **Ghidra Debugger**. Previously, analysts had to use static analysis in Ghidra and switch to x64dbg or GDB for dynamic analysis.

### Integration Features

- **Unified View:** The Debugger allows you to trace execution _inside_ the static listing. As you step in the debugger, the highlight moves in your static disassembly and decompilation windows.
- **Mapping:** It automatically maps the running process memory to the static import file.
- **Backends:** It supports GDB (Linux), WinDbg (Windows), and dbgeng.

### How to use it

1. Open the **Debugger** tool from the Tool Chest (instead of CodeBrowser).
2. Open your program.
3. In the "Targets" window, click the "Connect" or "Launch" icon.
4. Select the appropriate agent (e.g., GDB via SSH, local GDB, or local Windows debug).

---

## Step-by-Step Exercise: Solving a Simple Crackme

Let's walk through a theoretical "password check" exercise.

### Scenario

You have a binary `login_app` that asks for a password.

### Step 1: Find the Entry Point

1. Open `login_app` in Ghidra.
2. Run Analysis.
3. Look at the **Symbol Tree** -> **Exports** -> `entry` (or `main` if symbols exist).

### Step 2: Locate Strings

1. Go to `Window -> Defined Strings`.
2. Filter for "Password". You see "Enter Password:".
3. Double-click the string to go to its location in memory.
4. Look for **XREFS** (Cross References) on the right of the instruction. This tells you _where_ this string is used.
5. Double-click the XREF to jump to the code that prints "Enter Password".

### Step 3: Analyze the Logic

1. In the Decompiler view for that function, look for a call that takes user input (like `scanf` or `fgets`).
2. Look for a comparison immediately following the input.

   - _Example C code generated by Ghidra:_

     ```c
     printf("Enter Password:");
     scanf("%s", local_18);
     iVar1 = strcmp(local_18, "SuperSecret123");
     if (iVar1 == 0) {
         puts("Access Granted");
     }
     ```

3. In this example, the password is clearly visible in the `strcmp` function: **SuperSecret123**.

### Step 4: Patching (Bypassing the check)

If the password was hashed, we might want to just bypass the check.

1. In the **Listing View** (Assembly), find the jump instruction (e.g., `JZ` or `JNZ`) corresponding to the `if` statement.
2. Right-click the instruction -> **Patch Instruction**.
3. Change `JZ` (Jump if Zero) to `JMP` (Unconditional Jump) or `NOP` (No Operation), depending on the logic.
4. The Decompiler will update to show the logic flow has changed.
