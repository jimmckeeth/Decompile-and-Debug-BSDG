# Debug.exe Overview

`DEBUG.EXE` (`DEBUG.COM` before MS-DOS 3) is a line-oriented debugger available as an external command in 86-DOS, MS-DOS, early versions of Windows and the 16-bit/32-bit versions of related operating systems

`DEBUG` can act as an assembler, disassembler, or hex dump program allowing users to interactively examine memory contents (in assembly language, hexadecimal or ASCII), make changes, and selectively execute COM, EXE and other file types. It also has several subcommands which are used to access specific disk sectors, I/O ports and memory addresses. [[Wikipedia](https://en.wikipedia.org/wiki/Debug_(command))]

## Usage

```dos
C:\>debug /?
```

Using the /? command line switch reports the usage:

> Runs **`Debug`**, a program testing and editing tool.
>
> `DEBUG [[drive:][path]filename [testfile-parameters]]`
>
> `[drive:][path]filename` Specifies the file you want to test.
> `[testfile-parameters]]` Specifies command-line information required by the file you want to test.
>
> After Debug starts, type **`?`** to display a list of _debugging commands_.

### List of Debugging Commands

| function   | cmd | arguments                                  |
| ---------- | --- | ------------------------------------------ |
| assemble   | `A` | `[address]`                                |
| compare    | `C` | `range address`                            |
| dump       | `D` | `[range]`                                  |
| enter      | `E` | `address [list]`                           |
| fill       | `F` | `range list`                               |
| go         | `G` | `[=address] [addresses]`                   |
| hex        | `H` | `value1 value2`                            |
| input      | `I` | `port`                                     |
| load       | `L` | `[address] [drive] [firstsector] [number]` |
| move       | `M` | `range address`                            |
| name       | `N` | `[pathname] [arglist]`                     |
| output     | `O` | `port byte`                                |
| proceed    | `P` | `[=address] [number]`                      |
| quit       | `Q` |                                            |
| register   | `R` | `[register]`                               |
| search     | `S` | `range list`                               |
| trace      | `T` | `[=address] [value]`                       |
| unassemble | `U` | `[range]`                                  |
| write      | `W` | `[address] [drive] [firstsector] [number]` |

| function | cmd | arguments |
|-------------------------------|---|----|
| allocate expanded memory | `XA` | `[#pages]` |
| deallocate expanded memory | `XD` | `[handle]` |
| map expanded memory pages | `XM` | `[Lpage] [Ppage] [handle]` |
| display expanded memory status | `XS` | |

### Registers

The `r` command displays the current registers

```text
-r
AX=0000 BX=0000 CX=0000 DX=0000 SP=FFEE BP=0000 SI=0000 DI=0000  
DS=2A63 ES=2A63 SS=2A63 CS=2A63 IP=0100 NV UP EI PL NZ NA PO NC
2A63:0100 0F DB 0F
```

### Dump

Just a dump of what is currently in memory.

```text
-d
2A63:0100 0F 00 B9 8A FF F3 AE 47-61 03 1F 8B C3 48 12 B1 .......Ga....H..
2A63:0110 04 8B C6 F7 0A 0A D0 D3-48 DA 2B D0 34 00 52 2A ........H.+.4.R\*
2A63:0120 00 DB D2 D3 E0 03 F0 8E-DA 8B C7 16 C2 B6 01 16 ................
2A63:0130 C0 16 F8 8E C2 AC 8A D0-00 00 4E AD 8B C8 46 8A ..........N...F.
2A63:0140 C2 24 FE 3C B0 75 05 AC-F3 AA A0 0A EB 06 3C B2 .$.<.u........<.
2A63:0150 75 6D 6D 13 A8 01 50 14-74 B1 BE 32 01 8D 8B 1E umm...P.t..2....
2A63:0160 8E FC 12 A8 33 D2 29 E3-13 8B C2 03 C3 69 02 00 ....3.)......i..
2A63:0170 0B F8 83 FF FF 74 11 26-01 1D E2 F3 81 00 94 FA .....t.&........
```

### Unassemble

This is the disassembly of what happens to be in memory since we didn't load anything.

```text
-u
2A63:0100 0F DB 0F  
2A63:0101 00B98AFF ADD [BX+DI+FF8A],BH  
2A63:0105 F3 REPZ   
2A63:0106 AE SCASB   
2A63:0107 47 INC DI  
2A63:0108 61 DB 61  
2A63:0109 031F ADD BX,[BX]  
2A63:010B 8BC3 MOV AX,BX  
2A63:010D 48 DEC AX  
2A63:010E 12B1048B ADC DH,[BX+DI+8B04]  
2A63:0112 C6F70A MOV BH,0A  
2A63:0115 0AD0 OR DL,AL  
2A63:0117 D348DA ROR WORD PTR [BX+SI-26],CL  
2A63:011A 2BD0 SUB DX,AX  
2A63:011C 3400 XOR AL,00  
2A63:011E 52 PUSH DX  
2A63:011F 2A00 SUB AL,[BX+SI]
```

### Display Expanded Memory Status

If EMS is enabled

```text
-xs
Handle 0000 has 0018 pages allocated

Physical page 04 = Frame segment 4000
Physical page 05 = Frame segment 4400
Physical page 06 = Frame segment 4800
Physical page 07 = Frame segment 4C00
Physical page 08 = Frame segment 5000
Physical page 09 = Frame segment 5400
Physical page 0A = Frame segment 5800
Physical page 0B = Frame segment 5C00
Physical page 0C = Frame segment 6000
Physical page 0D = Frame segment 6400
Physical page 0E = Frame segment 6800
Physical page 0F = Frame segment 6C00
Physical page 10 = Frame segment 7000
Physical page 11 = Frame segment 7400
Physical page 12 = Frame segment 7800
Physical page 13 = Frame segment 7C00
Physical page 14 = Frame segment 8000
Physical page 15 = Frame segment 8400
Physical page 16 = Frame segment 8800
Physical page 17 = Frame segment 8C00
Physical page 18 = Frame segment 9000
Physical page 19 = Frame segment 9400
Physical page 1A = Frame segment 9800
Physical page 1B = Frame segment 9C00
Physical page 00 = Frame segment D000
Physical page 01 = Frame segment D400
Physical page 02 = Frame segment D800
Physical page 03 = Frame segment DC00

A8 of a total 7D4 EMS pages have been allocated
1 of a total 40 EMS handles have been allocated
```
