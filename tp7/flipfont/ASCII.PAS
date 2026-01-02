unit ascii;

interface

procedure PrintAsciiTable;

implementation

uses Crt;

procedure PrintAsciiTable;
const
  HexChars: array[0..15] of Char = '0123456789ABCDEF';

var
  Row, Col   : Integer;
  ScreenOfs  : Word;
  CharVal    : Byte;

begin
  ClrScr;

  { 1. Print the Top Header (Second digit of Hex) }
  { We leave a small margin on the left }
  Write('   ');
  for Col := 0 to 15 do
    Write(' ', HexChars[Col]);
  Writeln;
  Writeln; { Add a blank line for spacing }

  { 2. Print the Grid }
  for Row := 0 to 15 do
  begin
    { Print the Left Column Header (First digit of Hex) }
    Write(HexChars[Row], '  ');

    { Loop through columns to print the characters }
    for Col := 0 to 15 do
    begin
      CharVal := (Row * 16) + Col;
      
      { Calculate Video Memory Address 
        Formula: ((Line * 80) + Column) * 2 
        
        WhereY is 1-based, so we subtract 1. 
        We are printing at current cursor position + spacing.
        Since we just wrote the header (2 chars) and spacing,
        we calculate the visual offset manually for precision.
      }
      
      {
        Y coordinate: (WhereY - 1)
        X coordinate: 3 (margin) + (Col * 2) 
      }
      ScreenOfs := ((WhereY - 1) * 80 + (3 + (Col * 2))) * 2;

      { Put the Character }
      Mem[$B800 : ScreenOfs] := CharVal;
      
      { Put the Attribute (Color) 
        $0F = White Text on Black Background (High Intensity) 
        $07 = Light Grey on Black (Standard)
      }
      Mem[$B800 : ScreenOfs + 1] := $0F;
    end;

    { Move to the next line on screen }
    Writeln;
  end;
end;

end.