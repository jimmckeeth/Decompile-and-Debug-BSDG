; FLIPFONT.ASM
; A 16-bit DOS .COM program to flip VGA fonts upside down.
; Compatible with TASM, MASM, or WASM.

.MODEL TINY
.CODE
ORG 100h

START:
    ; --- STEP 1: UNLOCK VIDEO MEMORY ---
    
    cli             ; Disable interrupts to protect the VGA port operations

    ; Sequencer: Enable writing to Plane 2 (Font Data)
    mov dx, 03C4h   ; Sequencer Index Port
    mov ax, 0402h   ; Index 02h (Map Mask), Data 04h (Plane 2)
    out dx, ax

    ; Sequencer: Enable Sequential Addressing (Linear memory access)
    mov ax, 0604h   ; Index 04h (Memory Mode), Data 06h
    out dx, ax

    ; Graphics Controller: Enable reading from Plane 2
    mov dx, 03CEh   ; Graphics Controller Index Port
    mov ax, 0204h   ; Index 04h (Read Map Select), Data 02h
    out dx, ax

    ; Graphics Controller: Set Mode 0
    mov ax, 0005h   ; Index 05h (Mode Register), Data 00h
    out dx, ax

    ; Graphics Controller: Map memory to A0000h
    mov ax, 0006h   ; Index 06h (Misc Register), Data 00h
    out dx, ax


    ; --- STEP 2: FLIP THE BITS ---

    mov ax, 0A000h  ; Point ES segment to VGA memory
    mov es, ax
    xor di, di      ; DI = 0 (Start of font memory)
    
    mov cx, 256     ; Loop counter: 256 characters
    
CHAR_LOOP:
    push cx         ; Save char counter
    mov cx, 8       ; Loop counter: 8 lines (top half of char)
    
    mov si, di      ; SI points to the TOP line
    lea bx, [di+15] ; BX points to the BOTTOM line (Offset + 15)

LINE_LOOP:
    ; Swap the byte at [SI] with the byte at [BX]
    mov al, es:[si]     ; Load top byte
    xchg al, es:[bx]    ; Swap with bottom byte
    mov es:[si], al     ; Store bottom byte at top
    
    inc si              ; Move SI down
    dec bx              ; Move BX up
    loop LINE_LOOP

    add di, 32      ; Move to next character (32 bytes per char)
    pop cx          ; Restore char counter
    loop CHAR_LOOP


    ; --- STEP 3: RESTORE VIDEO STATE ---

    ; Sequencer: Restore standard plane write (Planes 0 & 1)
    mov dx, 03C4h
    mov ax, 0302h
    out dx, ax

    ; Sequencer: Restore Odd/Even addressing
    mov ax, 0204h
    out dx, ax

    ; Graphics: Restore Read Map to Plane 0
    mov dx, 03CEh
    mov ax, 0004h
    out dx, ax

    ; Graphics: Restore Odd/Even Mode
    mov ax, 1005h
    out dx, ax

    ; Graphics: Map memory back to B8000 (Color Text Mode)
    mov ax, 0E06h
    out dx, ax

    sti             ; Re-enable interrupts

    ; --- EXIT TO DOS ---
    mov ax, 4C00h
    int 21h

END START