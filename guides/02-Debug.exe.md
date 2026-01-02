# The Iron Curtain of the 8086: A Definitive Guide to DEBUG.EXE

## 1. Introduction: The Bare-Metal Interface

In the archaeology of personal computing, few artifacts possess the enduring mystique and utilitarian brutality of `DEBUG.EXE`. For over three decades, this line-oriented debugger served as the primary instrument for system interrogation and manipulation within the IBM PC ecosystem. Born in the nascent days of the 16-bit revolution, it provided a raw, unvarnished [window into the machine's soul](https://thestarman.pcministry.com/asm/debug/debug.htm), allowing operators to bypass the abstractions of the operating system and interact directly with memory, CPU registers, and hardware input/output ports.

To the modern developer, accustomed to integrated development environments (IDEs) with graphical interfaces, real-time syntax checking, and symbolic debugging, `DEBUG` appears arcane, even hostile. It lacks safety rails; it offers no confirmation dialogs; its error messages are cryptically terse. Yet, it was this very minimalism that defined its power. A skilled operator could use `DEBUG` to patch a binary executable, recover a corrupted Master Boot Record (MBR), manipulate the CMOS RAM to clear a forgotten password, or write a functional program from scratch—all without a compiler or a text editor.

This report presents an exhaustive technical and historical analysis of `DEBUG.EXE`. We will trace its lineage from the 86-DOS prototype to its final inclusion in the 32-bit subsystems of Windows, dissect its command set with granular precision, and explore the advanced techniques of direct hardware manipulation that made it a legend among the "superuser" caste of the DOS era.

## 2. Historical Origins and the 16-Bit Transition

### 2.1 The CP/M Legacy and 86-DOS

The conceptual roots of `DEBUG` lie in the 8-bit era of the 1970s. Before the dominance of the IBM PC, the standard operating system for business microcomputers was CP/M (Control Program/Monitor), created by Gary Kildall of Digital Research. CP/M included a tool called `DDT` (Dynamic Debugging Tool), which allowed programmers to load, inspect, and modify programs for the Intel 8080 and Zilog Z80 processors.

In 1980, Tim Paterson of Seattle Computer Products (SCP) began developing a new operating system for the Intel 8086, a 16-bit processor that was incompatible with existing 8-bit CP/M software. This system, originally named QDOS (Quick and Dirty Operating System) and([http://www.os2museum.com/wp/86-dos-was-an-original/](http://www.os2museum.com/wp/86-dos-was-an-original/)), was designed to facilitate the porting of CP/M applications to the new architecture. To aid in this transition, Paterson required a native debugger.

Paterson’s creation, initially embedded in a ROM chip on SCP's hardware, was([https://thestarman.pcministry.com/asm/debug/debug.htm](https://thestarman.pcministry.com/asm/debug/debug.htm)) to ensure familiarity for developers. It adopted the same single-letter command structure—`D` for Dump, `G` for Go, `T` for Trace—establishing a command syntax that would persist for forty years. However, unlike `DDT`, which was written in the high-level PL/M language, Paterson wrote the 86-DOS debugger entirely in 8086 assembly language. This decision was driven by the necessity of the time: [no high-level compilers existed for the 8086](http://www.os2museum.com/wp/86-dos-was-an-original/) when development began.

### 2.2 The Microsoft Acquisition and PC DOS 1.00

When IBM sought an operating system for its forthcoming Personal Computer, Microsoft acquired 86-DOS from SCP and rebranded it as MS-DOS (and PC DOS for IBM). Paterson’s debugger was included in the package as `DEBUG.COM`. Released with PC DOS 1.00 in 1981, it was [one of the few pieces of system software available at launch](https://thestarman.pcministry.com/asm/debug/debug.htm).

At this stage, `DEBUG` was a "monitor" program. It allowed for memory inspection and basic execution control, but it lacked the ability to assemble instructions. Programmers wishing to patch code had to manually calculate the hexadecimal opcodes (machine language) and enter them byte-by-byte—a painstaking process that required an intimate knowledge of the 8086 instruction encoding.

### 2.3 Evolutionary Milestones

The utility evolved in lockstep with the operating system, gaining capabilities that reflected the growing complexity of the PC platform.

#### DOS 2.0: The Assembler Revolution

The release of DOS 2.0 marked a paradigm shift with the [introduction of the **A** (Assemble) command](https://thestarman.pcministry.com/asm/debug/debug.htm). This feature transformed `DEBUG` from a passive inspection tool into a lightweight development environment. Users could now type standard assembly mnemonics (e.g., `MOV AX, CS`), and `DEBUG` would translate them into machine code in real-time. This effectively democratized low-level programming; any user with a DOS disk had a free assembler at their disposal.

#### DOS 3.0: Refined Control

As software grew larger and relied more on system interrupts, single-stepping through code became tedious. DOS 3.0 [introduced the **P** (Proceed) command](https://thestarman.pcministry.com/asm/debug/debug.htm). Unlike **T** (Trace), which stepped _into_ every subroutine call and interrupt, **P** executed the call as a single atomic operation. This allowed developers to skip over lengthy BIOS or DOS routines and focus on their own code logic.

#### DOS 4.0: Breaking the 640KB Barrier

With the introduction of the Expanded Memory Specification (EMS) to bypass the 640KB RAM limit of the 8086 real mode, `DEBUG` gained a [suite of commands to manage expanded memory pages](https://thestarman.pcministry.com/asm/debug/debug.htm): **XA** (Allocate), **XD** (Deallocate), **XM** (Map), and **XS** (Status). While obscure to the average user, these commands were vital for developers optimizing memory-hungry applications like Lotus 1-2-3.

#### DOS 5.0 and Beyond

In DOS 5.0, the file format changed from a memory-image `.COM` file to a relocatable `.EXE` file, renaming the utility `DEBUG.EXE`. This version also introduced a [rudimentary help listing](https://thestarman.pcministry.com/asm/debug/debug.htm) (accessed via `?`), a concession to the increasing complexity of the tool.

### 2.4 The Windows Decline

The transition to Windows NT and its successors (2000, XP) placed `DEBUG` in a precarious position. These operating systems ran on the Protected Mode of the x86 processor, which forbids direct hardware access. To maintain compatibility, Microsoft included `DEBUG.EXE` running inside the([https://thestarman.pcministry.com/asm/debug/debug.htm](https://thestarman.pcministry.com/asm/debug/debug.htm)). While it retained its utility for manipulating files, its ability to read/write absolute disk sectors and interact with hardware ports was virtualized or blocked entirely to preserve system stability.

Finally, with the advent of the x64 architecture, support for 16-bit "Real Mode" applications was excised from the Windows kernel. As a result, `DEBUG.EXE` is([https://superuser.com/questions/510671/is-there-debug-exe-equivalent-for-windows7](https://superuser.com/questions/510671/is-there-debug-exe-equivalent-for-windows7)) (Vista, 7, 8, 10, 11), marking the end of its ubiquity.

## 3. The Architecture of Real Mode Debugging

To master `DEBUG` is to master the Intel 8086 architecture. The utility operates entirely within "Real Mode," a processor state characterized by a specific memory model and direct hardware addressing.

### 3.1 The Segmented Memory Model

The defining characteristic of the 8086 is its segmented memory. The processor has a 20-bit address bus, allowing it to address 1 MB ($2^{20}$ bytes) of memory. However, its internal registers are only 16 bits wide, capable of addressing only 64 KB ($2^{16}$ bytes).

To reconcile this, memory is divided into **Segments**. An address is defined by two 16-bit values: the **Segment** and the **Offset**, typically written as `XXXX:YYYY`. The physical address is calculated by shifting the segment four bits to the left (multiplying by 16) and adding the offset:

$$\text{Physical Address} = (\text{Segment} \times 16) + \text{Offset}$$

For example, the logical address `04BA:0100` translates to:
$$04BA0_{16} + 0100_{16} = 04CA0_{16}$$

This "Segment:Offset" notation is ubiquitous in `DEBUG`. When the utility launches, it initializes the segment registers to point to the first available block of free memory. The code segment (CS), data segment (DS), stack segment (SS), and extra segment (ES) are typically set to the same value for `.COM` programs, creating a "Tiny" memory model where code and data share the same 64KB space.

### 3.2 The Register Set

`DEBUG` provides direct visibility and control over the CPU's registers via the **R** command. Understanding these registers is a [prerequisite for any operation](https://thestarman.pcministry.com/asm/debug/debug2.htm).

**Table 1: The 16-Bit x86 Register Set**

| Register | Name            | Primary Function in DEBUG context                                     |
| :------- | :-------------- | :-------------------------------------------------------------------- |
| **AX**   | Accumulator     | Primary arithmetic and logic; Input/Output operations; Return values. |
| **BX**   | Base            | Base pointer for memory access; High-order word of file size.         |
| **CX**   | Count           | Loop counters; Low-order word of file size.                           |
| **DX**   | Data            | I/O port addressing; High-order word for multiplication/division.     |
| **SP**   | Stack Pointer   | Pointer to the top of the stack (grows downwards).                    |
| **BP**   | Base Pointer    | Stack frame base pointer for accessing local variables.               |
| **SI**   | Source Index    | Source pointer for string operations.                                 |
| **DI**   | Dest Index      | Destination pointer for string operations.                            |
| **CS**   | Code Segment    | Segment containing the currently executing instructions.              |
| **DS**   | Data Segment    | Default segment for data variables.                                   |
| **SS**   | Stack Segment   | Segment containing the stack.                                         |
| **ES**   | Extra Segment   | Auxiliary segment; Critical for INT 13h disk buffer pointers.         |
| **IP**   | Instruction Ptr | Offset of the _next_ instruction to be executed.                      |
| **FL**   | Flags           | Status indicators (Zero, Carry, Overflow, Sign, etc.).                |

The Flag register is displayed in `DEBUG` using a unique two-letter code system rather than binary bits. For example, the **Zero Flag (ZF)** is([https://thestarman.pcministry.com/asm/debug/debug2.htm](https://thestarman.pcministry.com/asm/debug/debug2.htm)), and `NZ` (Not Zero) if clear.

### 3.3 The Program Segment Prefix (PSP)

When `DEBUG` loads a program or starts, DOS creates a 256-byte (100h) structure at the beginning of the memory segment called the Program Segment Prefix (PSP). This structure contains command-line arguments, termination addresses, and file control blocks. Because the PSP occupies the first 256 bytes, executable code in `.COM` files always begins at offset **0100h**. This is why the((([http://bitsavers.trailing-edge.com/pdf/microsoft/msdos_2.0/MS-DOS_2.0_DEBUG.pdf](http://bitsavers.trailing-edge.com/pdf/microsoft/msdos_2.0/MS-DOS_2.0_DEBUG.pdf)))).

## 4. Comprehensive Command Reference

The interface of `DEBUG` is famously austere: a simple hyphen (`-`) prompt. Commands are single characters, case-insensitive, followed by hexadecimal parameters.

### 4.1 Memory Inspection and Manipulation

#### D - Dump

The **Dump** command displays the contents of memory in both hexadecimal and ASCII. This is the primary mechanism for inspecting binaries, searching for strings, or verifying patches.

- **Syntax:** `-d [address][range]`
- **Behavior:** If no address is specified, `DEBUG` dumps 128 bytes starting from the current dump pointer.
- **Insight:** The ASCII display on the right side of the dump replaces non-printable control characters with dots (`.`). This is essential for [spotting text strings embedded within binary code](https://thestarman.pcministry.com/asm/debug/debug2.htm).

#### E - Enter

The **Enter** command allows for the modification of memory. It has two modes:

1.  **List Mode:** `-e address list` writes a sequence of bytes immediately.
    - **Example:** `-e 100 B4 09 CD 21` writes the machine code for "Print String" to address CS:0100.
2.  **Interactive Mode:** `-e address` displays the current byte and waits for input. Pressing `SPACE` accepts the change and moves to the next byte; pressing `ENTER` terminates the edit.

- **Usage:** This is the [standard method for "patching" code](https://thestarman.pcministry.com/asm/debug/debug2.htm)—modifying a specific instruction (e.g., changing a conditional jump `JZ` to a forced jump `JMP`) to alter program behavior.

#### F - Fill

The **Fill** command populates a memory range with a repeated pattern.

- **Syntax:** `-f range list`
- \*_Example:_ `-f 100 200 00` zeros out memory from offset 100 to 200. This is often used to clear buffers before loading data to [ensure clean reads](https://thestarman.pcministry.com/asm/debug/debug2.htm).

#### S - Search

The **Search** command scans a memory range for a specific sequence of bytes or an ASCII string.

- **Syntax:** `-s range list`
- **Example:** `-s 100 FFFF "Error"` searches the entire segment for the string "Error". This is a powerful reverse-engineering technique to locate the code routines responsible for generating specific error messages.

#### M - Move

The **Move** command copies a block of memory from one location to another.

- **Syntax:** `-m range address`
- **Example:** `-m 100 110 500` copies the 16 bytes from 100-110 to offset 500.
- **Technical Note:** The move is "smart"—it [handles overlapping ranges correctly](https://thestarman.pcministry.com/asm/debug/debug2.htm), ensuring data isn't corrupted if the source and destination overlap.

### 4.2 Execution and Flow Control

#### G - Go

The **Go** command transfers control to the program in memory.

- **Syntax:** `-g [=address][breakpoints]`
- **Mechanism:** `DEBUG` works by inserting a specific opcode, `CC` (INT 3), at the breakpoint addresses specified. When the processor hits `CC`, it triggers an interrupt that returns control to the debugger.
- **Usage:** `-g=100 105` starts execution at 100h and sets a breakpoint at 105h. If the breakpoint is not reached (e.g., due to a jump), the [program will continue running indefinitely](https://thestarman.pcministry.com/asm/debug/debug2.htm).

#### T - Trace

The **Trace** command executes a single CPU instruction and then stops, displaying the register state.

- **Syntax:** `-t [=address][count]`
- **Mechanism:** This command utilizes the **Trap Flag (TF)** in the flags register. When TF is set, the CPU generates an INT 1 exception after every instruction.
- **Insight:** Tracing is essential for understanding algorithms or malware. However, tracing into DOS interrupts (like INT 21) is dangerous, as you will find yourself stepping through the operating system's kernel code, which can be thousands of instructions long.

#### P - Proceed

The **Proceed** command is a variation of Trace that treats subroutine calls (`CALL`) and interrupts (`INT`) as single instructions.

- **Usage:** This is the [preferred method for debugging high-level logic](https://thestarman.pcministry.com/asm/debug/debug2.htm). If the instruction pointer is at `CALL 0500`, typing `P` will execute the entire subroutine at 0500 and stop at the next instruction in the current routine. This avoids getting lost in nested library code.

### 4.3 The Assembler and Disassembler

#### A - Assemble

The **Assemble** command is arguably `DEBUG`'s most potent feature. It invokes a line-by-line mini-assembler.

- **Syntax:** `-a [address]`
- **Limitations:** It does not support labels (e.g., you cannot say `JMP START`; you must say `JMP 0100`). It does not support variable names. All operands must be absolute addresses or registers.
- **Significance:** This allowed users to write executable programs without buying a compiler. Many((([http://bitsavers.trailing-edge.com/pdf/microsoft/msdos_2.0/MS-DOS_2.0_DEBUG.pdf](http://bitsavers.trailing-edge.com/pdf/microsoft/msdos_2.0/MS-DOS_2.0_DEBUG.pdf)))) were originally written directly in `DEBUG`.

#### U - Unassemble

The **Unassemble** (Disassemble) command decodes binary machine language back into assembly mnemonics.

- **Syntax:** `-u [range]`
- **Usage:** This is the primary tool for reverse engineering. By unassembling code, a researcher can reconstruct the logic of a program for which the source code is unavailable.

## 5. Advanced Hardware Interaction: The I/O Ports

In the DOS era, the operating system was a thin layer. Performance-critical applications often bypassed DOS to talk directly to hardware via **I/O Ports**. The 8086 architecture has a separate 64KB address space for I/O ports, accessed via the `IN` and `OUT` instructions. `DEBUG` exposes these via the **I** and **O** commands.

### 5.1 Input and Output Commands

- **I (Input):** Reads a byte from a port. `-i port`.
- **O (Output):** Writes a byte to a port. `-o port byte`.

### 5.2 Case Study: The Programmable Interval Timer (PIT) and PC Speaker

A classic use of `DEBUG` was controlling the PC Speaker. The speaker is controlled by the interaction of the PIT (Port 40h-43h) and the System Control Port B (Port 61h).

To generate a tone, one must:

1.  **Configure the PIT (Channel 2):** Channel 2 is connected to the speaker. We send a command byte `B6` to the command register `43`. `B6` (binary `10110110`) selects Channel 2, sets access mode to "lo/hi byte", and operating mode to "Square Wave".
    -o 43 B6
2.  **Set the Frequency:** The PIT runs at 1.19318 MHz. The frequency divisor is calculated as $1193180 / \text{Frequency}$. For 1000 Hz, the divisor is roughly 1193 ($04A9_{16}$). We write the low byte ($A9$) then the high byte ($04$) to the channel data port `42`.
    -o 42 A9
    -o 42 04
3.  **Enable the Speaker:** Port `61` controls the gate. Bit 0 connects the PIT to the speaker; Bit 1 enables the speaker data. We must read the current state, set these two bits, and write it back.
    -i 61
    (Assume return value is 4C)
    -o 61 4F ; 4C OR 03 = 4F
    _Result:_ The speaker emits a 1000Hz square wave.
4.  **Silence:** To stop, we [clear the lower two bits](https://fenixfox-studios.com/content/pc_speaker/).
    -o 61 4C

### 5.3 Case Study: CMOS RAM Password Reset

The BIOS configuration (CMOS) is stored in a battery-backed RAM chip (typically the Motorola MC146818). It is accessed via an Index Port (`70`) and a Data Port (`71`).
A common "hack" to clear a forgotten BIOS password is to corrupt the CMOS checksum. The BIOS checks the integrity of the CMOS data at boot; if the checksum is invalid, it resets all settings to default, [clearing the password](https://forum.porteus.org/viewtopic.php?t=5523).

**The Procedure:**
-o 70 10 ; Select CMOS register 10h (Floppy drive type)
-o 71 AA ; Write arbitrary data (AAh) to it
-q ; Quit
By writing data without updating the checksum register, the data becomes inconsistent. On the next reboot, the BIOS reports "CMOS Checksum Error - Defaults Loaded," and [the password is gone](https://www.bleepingcomputer.com/forums/t/617188/resetting-the-bios-supervisor-password-with-debug-command/).

## 6. Mass Storage: Absolute Disk Access

`DEBUG`'s ability to read and write raw disk sectors makes it a forensic tool of immense power—and a weapon of mass destruction for data.

### 6.1 Logical vs. Physical Access

It is crucial to distinguish between DOS Logical Volumes and BIOS Physical Disks.

- **The L (Load) Command:** `-l address drive start count`.
  - Here, `drive` is logical: `0`=A:, `1`=B:, `2`=C:.
  - `start` is the logical sector number within that partition. Sector 0 of Drive C: is the **Volume Boot Record (VBR)** of the C: partition, _not_ the Master Boot Record of the [hard disk](http://bitsavers.trailing-edge.com/pdf/microsoft/msdos_2.0/MS-DOS_2.0_DEBUG.pdf).

### 6.2 The Master Boot Record (MBR)

The MBR is the first sector (Cylinder 0, Head 0, Sector 1) of the physical hard disk. It contains the bootstrap loader code and the **Partition Table**. Since the MBR exists _outside_ of any partition, the standard `L` command (which operates on partitions) often cannot access it directly in later versions of DOS/Windows which abstract hardware access.

To read the MBR, one must bypass DOS and call the([https://pcrepairclass.tripod.com/cgi-bin/datarec1/dbgreadmbr.html](https://pcrepairclass.tripod.com/cgi-bin/datarec1/dbgreadmbr.html)).

#### Reading the MBR via Assembly Script

We will write a small assembly program in `DEBUG` to read the MBR of the first hard drive (BIOS Drive ID `80h`) into memory at offset `200`.

**Step 1: Enter Assembly Mode**
-a 100
**Step 2: Input the Code**

```assembly
MOV AX, 0201    ; AH=02 (Read Sectors), AL=01 (Count=1)
MOV BX, 0200    ; ES:BX Buffer Address (Where to load data)
MOV CX, 0001    ; CH=00 (Cyl 0), CL=01 (Sector 1)
MOV DX, 0080    ; DH=00 (Head 0), DL=80 (Drive 80h - First HDD)
INT 13          ; Invoke BIOS Disk Service
INT 3           ; Breakpoint (Stop execution)
```

**Step 3: Execute**
-g=100
When the `INT 3` triggers, the MBR is loaded at offset `200`.

**Step 4: Analyze the Partition Table**
The partition table is located at the end of the MBR, specifically at offset `1BE` to `1FD` within the sector. Since we loaded the sector to `200`, the table starts at `200 + 1BE = 3BE`.
-d 3BE
This dump reveals the raw hex defining the drive's partitions. Bytes `55 AA` at offset `3FE` (end of sector) are the((([https://thestarman.pcministry.com/asm/mbr/W7MBR.htm](https://thestarman.pcministry.com/asm/mbr/W7MBR.htm)))) to recognize the disk as bootable.

### 6.3 The "Sector 0" Catastrophe

A frequent error among novices involves the **W** (Write) command.

- To write a file to disk: `-n filename.com`, set `BX:CX` to size, then `-w`.
- To write to a sector: `-w address drive start count`.
  If a user forgets to name the file (`-n`) and types `-w 0 0 1`, expecting to "write the file," `DEBUG` may interpret this as an absolute sector write to Drive A: (Drive 0), Sector 0. This overwrites the boot sector of the floppy disk with the contents of memory, [rendering the disk unreadable](https://comp.lang.asm.x86.narkive.com/4B2jxv6B/oh-god-what-have-i-done-debug-exe).

## 7. Scripting and Automation: The "Input Redirection" Technique

Before the internet, distributing binary patches for software was difficult. You couldn't email a `.EXE` file easily over 300-baud modems. The solution was the `DEBUG` script—a text file containing the keystrokes to drive `DEBUG` to create a binary file.

### 7.1 Anatomy of a Creation Script

To [automate the creation of a program](https://www.ikigames.com/2020/01/hello-world-with-debug/) (e.g., `HELLO.COM`), a text file (let's call it `BUILD.SCR`) is prepared:

```text
A 100
MOV AH, 09          ; DOS Function: Print String
MOV DX, 0109        ; Address of string (Offset 109)
INT 21              ; Call DOS
MOV AX, 4C00        ; DOS Function: Exit
INT 21              ; Call DOS
DB 'Hello World!$'  ; The data string (Offset 109)

N HELLO.COM         ; Set the filename
R CX                ; Select CX register
16                  ; Set value (22 bytes = 16 hex)
W                   ; Write to disk
Q                   ; Quit
```

This script contains all the inputs a user would type interactively. The `DB` directive enters the string bytes directly. `R CX` sets the file size (since `.COM` files use `BX:CX` for size, and the program is small, BX remains 0).

### 7.2 Execution via Redirection

The user applies the script using standard DOS input redirection:

```bash
C:\> DEBUG < BUILD.SCR
```

`DEBUG` reads the file as if it were keyboard input, executes the commands, and generates `HELLO.COM` instantly. This technique was used extensively in magazines like _PC Magazine_ to [distribute utilities in print form](https://www.asmirvine.com/debug/Debug_Tutorial.pdf), which readers would type in and assemble.

## 8. The Windows Era, NTVDM, and the End of the Line

### 8.1 The NTVDM Sandbox

With Windows NT, 2000, and XP, the operating system kernel moved to Protected Mode. It could no longer allow applications like `DEBUG` to access hardware ports or physical memory directly, as this would compromise system stability and security.
To support legacy DOS applications, Microsoft utilized the NTVDM (NT Virtual DOS Machine). NTVDM trapped hardware access attempts.

- **Memory:** `DEBUG` could still inspect the virtual 1MB memory space of the NTVDM, but this was isolated from the physical RAM of the machine.
- **Disk:** Direct sector writes (using `W` with sector arguments) to hard drives were blocked. Attempts to write to the MBR via INT 13h would simply fail or be ignored by the virtualization layer.
- **Ports:** Reading/Writing ports like the CMOS (`70h`) often returned dummy values or had no effect.

### 8.2 The 64-Bit Extinction

The NTVDM relies on the Virtual 8086 mode of the x86 processor. In the x86-64 (Long Mode) architecture used by 64-bit Windows, Virtual 8086 mode is not available. Consequently, Microsoft removed the NTVDM entirely from 64-bit versions of Windows (Vista x64, Win7 x64, etc.).
`DEBUG.EXE` was removed from the distribution. Typing `debug` in a modern Command Prompt returns `'debug' is not recognized as an internal or external command`.

## 9. Modern Alternatives and Clones

For professionals and enthusiasts who still require these capabilities, the spirit of `DEBUG` lives on through emulation and clones.

### 9.1 DOSBox

DOSBox is an emulator designed for running DOS games, but it includes a built-in `DEBUG` command. This implementation is excellent for testing logic but operates within a completely emulated hardware environment. Writing to the "MBR" in DOSBox only modifies the virtual disk image file, not the physical drive.

### 9.2 FreeDOS Debug

The FreeDOS project maintains an open-source clone of `DEBUG`. It is largely compatible but introduces minor behavioral differences. For instance, the FreeDOS version [does not automatically print a newline after each step](https://sourceforge.net/p/freedos/bugs/374/) in a trace, which allows for denser screen output but may confuse users accustomed to the Microsoft layout.

### 9.3 Enhanced DEBUG (DebugX)

The most robust modern alternative is **DebugX** (Enhanced Debug). It extends the classic feature set significantly:

- **32-Bit Support:** Unlike the original,([https://www.pcjs.org/software/pcx86/util/other/enhdebug/1.32b/](https://www.pcjs.org/software/pcx86/util/other/enhdebug/1.32b/)) (EAX, EBX, etc.), making it useful for debugging software that uses the 80386+ instruction set.
- **DPMI Support:** It can debug DOS Protected Mode Interface applications, bridging the gap between real mode and protected mode.
- **Scripting:** It features an enhanced scripting language, reducing the need for external redirection tricks.

## 10. Conclusion

`DEBUG.EXE` was a product of a specific moment in computing history—a time when the hardware was simple enough to be understood in its entirety by a single person, and the operating system was permissive enough to allow complete control. It was a tool of rugged utility, demanding absolute precision and offering infinite capability in return.

While it has been superseded by sophisticated debuggers and safeguarded operating systems, `DEBUG` remains the gold standard for understanding the low-level operation of the x86 platform. To use `DEBUG` is to touch the bare metal of the machine, to speak the language of the processor without translation. For the historian, the reverse engineer, and the system programmer, it remains not just a tool, but a fundamental skill—the ability to look into the matrix of memory and see the reality underneath.

---

**Appendix A: Reference Tables**

**Table 2: Common BIOS Interrupts for Debugging**

| Interrupt   | Function          | Usage in DEBUG                                     |
| :---------- | :---------------- | :------------------------------------------------- |
| **INT 10h** | Video Services    | Set video mode, cursor position, write characters. |
| **INT 13h** | Disk Services     | Read/Write absolute sectors (MBR/Boot Sector).     |
| **INT 16h** | Keyboard Services | Read key presses (blocking/non-blocking).          |
| **INT 21h** | DOS Services      | File I/O, Print String, Terminate Program.         |
| **INT 3**   | Breakpoint        | The opcode `CC` used by DEBUG to stop execution.   |

**Table 3: Common Debug Error Indicators**

| Error  | Meaning              | Context                                                            |
| :----- | :------------------- | :----------------------------------------------------------------- |
| **BF** | Bad Flag             | Invalid flag code entered during Register edit.                    |
| **BP** | Too many breakpoints | More than 10 breakpoints set (G command).                          |
| **BR** | Bad Register         | Invalid register name entered.                                     |
| **DF** | Double Flag          | A flag code appears twice in one entry.                            |
| **?**  | Syntax Error         | The catch-all error. Command not recognized or parameters invalid. |
