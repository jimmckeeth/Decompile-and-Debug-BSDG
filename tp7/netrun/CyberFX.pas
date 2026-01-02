{
  CYBERFX.PAS - Turbo Pascal 7
  Provides visual effects for netrun.pas.
  MS-DOS 6.22 compatible, tested in VirtualBox.
  -------------------------------------------------
  Jim McKeeth - 2026
  https://github.com/jimmckeeth/decompile-and-debug
  GPLv3 License
}

{$Q-,R-}
unit CyberFX;

interface

uses Crt;

const
  ScreenWidth = 80;
  ScreenHeight = 25;
  VidSeg = $B800;

type
  PVidMem = ^TVidMem;
  TVidMem = array[0..3999] of Byte;

var
  Video: PVidMem;

procedure FastWrite(X, Y: Byte; S: String; Color: Byte);
procedure MatrixRain(Duration: Word);
procedure StaticNoise;
procedure VSync;
procedure DrawFrame(X1, Y1, X2, Y2: Byte; Color: Byte);
procedure CursorOff;
procedure CursorOn;

implementation

procedure CursorOff; assembler;
asm
  mov ah, 01h
  mov ch, 20h
  int 10h
end;

procedure CursorOn; assembler;
asm
  mov ah, 01h
  mov cx, 0607h
  int 10h
end;

procedure VSync; assembler;
asm
  mov dx, 03DAh
@WaitNotVSync:
  in al, dx
  test al, 08h
  jnz @WaitNotVSync
@WaitVSync:
  in al, dx
  test al, 08h
  jz @WaitVSync
end;

procedure FastWrite(X, Y: Byte; S: String; Color: Byte);
var
  I: Integer;
  Offset: Word;
begin
  if (X < 1) or (X > 80) or (Y < 1) or (Y > 25) then Exit;
  Offset := ((Y - 1) * ScreenWidth + (X - 1)) * 2;
  for I := 1 to Length(S) do
  begin
    if Offset > 3998 then Break;
    Video^[Offset] := Ord(S[I]);
    Video^[Offset + 1] := Color;
    Inc(Offset, 2);
  end;
end;

procedure StaticNoise;
begin
  { We use a REPEAT loop to ensure it runs at least once. }
  repeat
    { 1. Draw the noise frame using Assembly }
    asm
      mov ax, VidSeg
      mov es, ax
      xor di, di
      mov cx, 2000
    @Loop:
      in al, 40h   { Get random byte from Timer }
      mov ah, al   { Use it for color too }
      stosw        { Blast it to video memory }
      loop @Loop
    end;
    
    { 2. Small delay so it looks like TV static, not a gray blur }
    Delay(30);

    { 3. Check Hardware Port $60 (Keyboard Controller) 
         If the value is < 128, a key is currently PRESSED.
         If the value is >= 128, a key was just RELEASED. }
  until (Port[$60] >= 128); 
  
  { Clean up: Clear screen and empty the buffer of any auto-repeated keys }
  ClrScr; 
  while KeyPressed do ReadKey;
end;

procedure DrawFrame(X1, Y1, X2, Y2: Byte; Color: Byte);
var
  I: Byte;
begin
  for I := X1 to X2 do
  begin
    FastWrite(I, Y1, #205, Color);
    FastWrite(I, Y2, #205, Color);
  end;
  for I := Y1 to Y2 do
  begin
    FastWrite(X1, I, #186, Color);
    FastWrite(X2, I, #186, Color);
  end;
  FastWrite(X1, Y1, #201, Color);
  FastWrite(X2, Y1, #187, Color);
  FastWrite(X1, Y2, #200, Color);
  FastWrite(X2, Y2, #188, Color);
end;

procedure MatrixRain(Duration: Word);
var
  Col: array[1..ScreenWidth] of Byte;
  I, X: Integer;
  Timer: Word;
begin
  Randomize;
  for I := 1 to ScreenWidth do Col[I] := Random(ScreenHeight) + 1;
  
  Timer := 0;
  repeat
    { EXIT TRIGGER: If user hits a key, stop immediately }
    if KeyPressed then 
    begin
       ReadKey; { Eat the key }
       Break;
    end;

    VSync;
    for X := 1 to ScreenWidth do
    begin
      FastWrite(X, Col[X], ' ', 0);
      Inc(Col[X]);
      if Col[X] > ScreenHeight then Col[X] := 1;
      
      FastWrite(X, Col[X], Chr(33 + Random(200)), White);
      
      if Col[X] > 1 then 
        FastWrite(X, Col[X]-1, Chr(33 + Random(200)), LightGreen);
      if Col[X] > 2 then 
        FastWrite(X, Col[X]-2, Chr(33 + Random(200)), Green);
        
      if Random(50) = 1 then Col[X] := 1;
    end;
    
    Inc(Timer);
    Delay(20); 
  until Timer > Duration;
  ClrScr;
end;

begin
  Video := Ptr(VidSeg, 0);
end.