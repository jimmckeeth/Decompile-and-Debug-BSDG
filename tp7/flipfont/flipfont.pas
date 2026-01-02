program FlipFont;

{ 
  FLIPFONT.PAS - Turbo Pascal 7
  Recreates the classic "upside down" DOS text effect.
  Tested for MS-DOS 6.22 on VirtualBox.
}

uses Dos, Crt, Ascii;

const
  { VGA Register Ports }
  SC_INDEX = $3C4;  { Sequencer Index }
  SC_DATA  = $3C5;  { Sequencer Data }
  GC_INDEX = $3CE;  { Graphics Controller Index }
  GC_DATA  = $3CF;  { Graphics Controller Data }
  
  { The font is manipulated at this segment }
  FONT_SEG = $A000; 

var
  charIdx   : Integer;
  lineIdx   : Integer;
  charOffset: Word;
  tempByte  : Byte;

begin
  PrintAsciiTable;

  Writeln('Accessing VGA Plane 2 to flip font data...');

  { --- STEP 1: ENABLE ACCESS TO FONT MEMORY --- }
  
  { Disable interrupts to prevent screen flicker or corruption 
    while we mess with the video card registers }
  Asm cli End;

  { SEQUENCER: Enable writing to Plane 2 (where font data lives) }
  PortW[SC_INDEX] := $0402; { Index 02h (Map Mask), Data 04h (Plane 2) }

  { SEQUENCER: Enable Sequential Addressing (disable Odd/Even addressing)
    This makes the memory linear so we can read the font bytes straight. }
  PortW[SC_INDEX] := $0604; { Index 04h (Mem Mode), Data 06h }

  { GRAPHICS: Enable reading from Plane 2 }
  PortW[GC_INDEX] := $0204; { Index 04h (Read Map), Data 02h }

  { GRAPHICS: Set Mode 0 (Write Mode 0, Read Mode 0) }
  PortW[GC_INDEX] := $0005; { Index 05h (Mode), Data 00h }

  { GRAPHICS: Misc - Map memory to A0000 segment }
  PortW[GC_INDEX] := $0006; { Index 06h (Misc), Data 00h }


  { --- STEP 2: FLIP THE BITS --- }

  { Loop through all 256 ASCII characters }
  for charIdx := 0 to 255 do
  begin
    { In VGA memory, every character is allocated 32 bytes, 
      even though standard text mode only uses the first 16 bytes. }
    charOffset := charIdx * 32;

    { We only flip the first 16 lines (standard 8x16 VGA font).
      We loop 0 to 7 (the top half) and swap with the bottom half. }
    for lineIdx := 0 to 7 do
    begin
      { Read the top line }
      tempByte := Mem[FONT_SEG : charOffset + lineIdx];

      { Move bottom line to top position }
      Mem[FONT_SEG : charOffset + lineIdx] := 
          Mem[FONT_SEG : charOffset + (15 - lineIdx)];

      { Move saved top line to bottom position }
      Mem[FONT_SEG : charOffset + (15 - lineIdx)] := tempByte;
    end;
    delay(10);
  end;


  { --- STEP 3: RESTORE STANDARD TEXT MODE --- }

  { SEQUENCER: Restore write to Planes 0 & 1 (Character & Attribute) }
  PortW[SC_INDEX] := $0302; 

  { SEQUENCER: Restore Odd/Even Addressing }
  PortW[SC_INDEX] := $0204;

  { GRAPHICS: Restore read from Plane 0 }
  PortW[GC_INDEX] := $0004;

  { GRAPHICS: Restore Odd/Even Mode }
  PortW[GC_INDEX] := $1005;

  { GRAPHICS: Misc - Map memory back to B8000 (Color Text Mode) }
  PortW[GC_INDEX] := $0E06;

  { Re-enable interrupts }
  Asm sti End;
  
  Writeln('Done. Run again to restore.');
end.