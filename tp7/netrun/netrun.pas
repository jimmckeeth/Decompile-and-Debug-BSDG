{ 
  NETRUN.PAS - Turbo Pascal 7
  Simulates a cyberpunk hacking interface with animated effects.
  MS-DOS 6.22 compatible, tested in VirtualBox.
  -------------------------------------------------
  Jim McKeeth - 2026
  https://github.com/jimmckeeth/decompile-and-debug
  GPLv3 License
}

{$Q-,R-}
program NetRun;

uses Crt, CyberFX, CyberSec;

const
  MenuColor = LightGreen;
  HeaderColor = LightCyan;

var
  Choice: Char;
  Running: Boolean;

procedure DecryptEffect(X, Y: Byte; Target: String);
var
  Current: String;
  I, K: Integer;
begin
  Current := '';
  for I := 1 to Length(Target) do Current := Current + ' ';
  for I := 1 to Length(Target) do
  begin
    for K := 1 to 5 do
    begin
      Current[I] := Chr(Random(26) + 65);
      FastWrite(X, Y, Current, MenuColor);
      Delay(15);
    end;
    Current[I] := Target[I];
    FastWrite(X, Y, Current, MenuColor);
  end;
end;

procedure ShowHeader;
begin
  FastWrite(2, 2,  '  _   _ _____ _____ ____  _   _ _   _ ', HeaderColor);
  FastWrite(2, 3,  ' | \ | | ____|_   _|  _ \| | | | \ | |', HeaderColor);
  FastWrite(2, 4,  ' |  \| |  _|   | | | |_) | | | |  \| |', HeaderColor);
  FastWrite(2, 5,  ' | |\  | |___  | | |  _ <| |_| | |\  |', HeaderColor);
  FastWrite(2, 6,  ' |_| \_|_____| |_| |_| \_\\___/|_| \_|', HeaderColor);
  FastWrite(2, 8,  ' :: GIBSON MAINFRAME INTERFACE v7.0 ::', LightGray);
  FastWrite(2, 9,  ' -------------------------------------', DarkGray);
end;

{ NEW: Sequential Lock-In Brute Force Effect }
procedure SimHack;
const
  TargetPass: String = 'OVERRIDE_CONFIRMED';
  HexChars: array[0..15] of Char = '0123456789ABCDEF';
var
  CurrentPass: String;
  I, K, J: Integer;
begin
  ClrScr;
  DrawFrame(10, 8, 70, 18, Red);
  FastWrite(30, 10, 'BRUTE FORCE ATTACK', LightRed);
  
  { Initialize empty mask }
  CurrentPass := '';
  for I := 1 to Length(TargetPass) do CurrentPass := CurrentPass + Char(176); { Blocks }

  { Main Loop: Iterate through each character of the password }
  for I := 1 to Length(TargetPass) do
  begin
    { Cycling Animation for the current digit }
    for K := 1 to 8 do { How many times to cycle before locking }
    begin
      { 1. Update the 'active' character with random noise }
      CurrentPass[I] := Chr(Random(93) + 33);
      
      { 2. Draw the password status }
      FastWrite(31, 13, CurrentPass, LightGreen);
      
      { 3. Draw some fake scrolling hex below for atmosphere }
      FastWrite(12, 16, 'HEX: ' + HexChars[Random(16)] + HexChars[Random(16)] + ' ' +
                        HexChars[Random(16)] + HexChars[Random(16)] + ' ' +
                        HexChars[Random(16)] + HexChars[Random(16)], DarkGray);

      Delay(40);
      
      { Exit early if key pressed }
      if KeyPressed then 
      begin
        ReadKey; 
        Exit; 
      end;
    end;
    
    { Lock in the correct character }
    CurrentPass[I] := TargetPass[I];
    FastWrite(31, 13, CurrentPass, White); { Flash white when locked }
    Delay(50);
    FastWrite(31, 13, CurrentPass, LightGreen);
  end;
  
  FastWrite(30, 10, 'ACCESS GRANTED    ', LightGreen + Blink);
  Delay(1000);
end;

procedure MainMenu;
begin
  ClrScr;
  ShowHeader;
  DrawFrame(20, 12, 60, 20, LightBlue);
  
  FastWrite(25, 14, '[1] INITIATE MATRIX UPLINK', White);
  FastWrite(25, 15, '[2] BRUTE FORCE PASSWORD', White);
  FastWrite(25, 16, '[3] SIGNAL SCRAMBLER (Hold)', White);
  FastWrite(25, 18, '[X] JACK OUT', LightRed);
  
  GotoXY(25, 22); 
  Write('COMMAND > ');
end;

begin
  TextMode(CO80);
  ClrScr;
  CursorOff;
  
  if ExecuteLogin then
  begin
    DecryptEffect(30, 12, 'ESTABLISHING CONNECTION...');
    Delay(500);
    
    { Runs Matrix rain until any key is pressed }
    MatrixRain(60000); 
    
    Running := True;
    while Running do
    begin
      MainMenu;
      Choice := ReadKey;
      Choice := UpCase(Choice);
      
      case Choice of
        '1': MatrixRain(60000); { Will exit on keypress }
        '2': SimHack;
        '3': StaticNoise; { Runs while holding '3' }
        'X': Running := False;
      end;
    end;
  end;
  
  ClrScr;
  CursorOn;
  TextColor(LightGray);
  WriteLn('Connection Terminated.');
end.