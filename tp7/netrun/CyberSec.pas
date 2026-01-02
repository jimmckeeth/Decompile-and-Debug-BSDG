{
  CyberSec.PAS - Turbo Pascal 7
  Provides login screen for netrun.pas.
  MS-DOS 6.22 compatible, tested in VirtualBox.
  -------------------------------------------------
  Jim McKeeth - 2026
  https://github.com/jimmckeeth/decompile-and-debug
  GPLv3 License
}

unit CyberSec;

interface

uses Crt, CyberFX;

{$Q-,R-} { Disable overflow/range checks }

function ExecuteLogin: Boolean;

implementation

{ Visual effect: Flashes the screen a specific color briefly }
procedure FlashScreen(Color: Byte);
begin
  TextBackground(Color);
  ClrScr;
  Delay(50);
  TextBackground(Black);
  ClrScr;
end;

{ Custom text input that handles Backspace and masks characters }
function GetSecureInput(X, Y, MaxLen: Byte): String;
var
  InputStr: String;
  Ch: Char;
begin
  InputStr := '';
  repeat
    Ch := ReadKey;
    
    if (Ch = #8) then { Backspace }
    begin
      if Length(InputStr) > 0 then
      begin
        { Erase character from screen }
        FastWrite(X + Length(InputStr) - 1, Y, ' ', Black);
        { Delete from string }
        Delete(InputStr, Length(InputStr), 1);
      end;
    end
    else if (Ch <> #13) and (Length(InputStr) < MaxLen) then
    begin
      { Filter for printable characters only }
      if (Ch >= #32) and (Ch <= #126) then
      begin
        InputStr := InputStr + Ch;
        { Cyberpunk feel: Print a solid block or random char instead of * }
        FastWrite(X + Length(InputStr) - 1, Y, #219, LightGreen); 
      end;
    end;
    
  until Ch = #13; { Enter key }
  GetSecureInput := InputStr;
end;

function ExecuteLogin: Boolean;
var
  Attempts: Integer;
  Password: String;
  Success: Boolean;
begin
  Success := False;
  Attempts := 0;
  
  repeat
    CursorOff;
    ClrScr;
    
    { Draw the Security Box }
    DrawFrame(20, 8, 60, 16, LightRed);
    FastWrite(28, 8, ' SECURITY GATEWAY v9.0 ', Red);
    
    FastWrite(25, 10, 'USER:    ADMIN', LightGray);
    FastWrite(25, 12, 'PASS:    [          ]', LightGray);
    FastWrite(25, 14, 'STATUS:  LOCKED', DarkGray);
    
    { Get Input }
    GotoXY(35, 12);
    Password := GetSecureInput(35, 12, 10);
    
    { Hardcoded Password - Case Insensitive }
    if (UpCase(Password[1]) = 'G') and 
       (UpCase(Password[2]) = 'I') and
       (UpCase(Password[3]) = 'B') and
       (UpCase(Password[4]) = 'S') and
       (UpCase(Password[5]) = 'O') and
       (UpCase(Password[6]) = 'N') then
    begin
      Success := True;
      FastWrite(34, 14, 'ACCESS GRANTED', LightGreen + Blink);
      Delay(800);
      FlashScreen(Green);
    end
    else
    begin
      Inc(Attempts);
      FastWrite(34, 14, 'ACCESS DENIED ', LightRed + Blink);
      
      { Failure Effect }
      Delay(500);
      FlashScreen(Red);
      StaticNoise; { From CyberFX }
      
      if Attempts >= 3 then
      begin
        ClrScr;
        FastWrite(30, 12, 'SYSTEM LOCKDOWN INITIATED', Red);
        Delay(2000);
        Halt; { Hard exit to DOS }
      end;
    end;
    
  until Success;
  
  ExecuteLogin := True;
end;

end.