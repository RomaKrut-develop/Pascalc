program Pascalc;
uses
  Graph, Crt, Dos;

var
  gd, gm: Integer;
  ch: Char;
  Num1, Num2, Result: Real;
  Operation: Char;
  DisplayStr: string[15];
  Code: Integer;
  X, Y: Integer;
  regs: Registers;
  mouseX, mouseY, mouseButtons: Word;

{ Button builder }
procedure DrawButton(x1, y1, x2, y2: Integer; text: string; color: Integer);
begin
  SetFillStyle(SolidFill, color);
  Bar(x1, y1, x2, y2);
  SetColor(White);
  Rectangle(x1, y1, x2, y2);
  OutTextXY(x1 + (x2-x1) div 2 - TextWidth(text) div 2,
            y1 + (y2-y1) div 2 - TextHeight(text) div 2, text);
end;

{ Mouse functions }
procedure InitMouse;
begin
  regs.AX := 0;
  Intr($33, regs);
  if regs.AX <> $FFFF then
  begin
    CloseGraph;
    Writeln('Mouse not detected!');
    Halt(1);
  end;
end;

procedure ShowMouse;
begin
  regs.AX := 1;
  Intr($33, regs);
end;

procedure HideMouse;
begin
  regs.AX := 2;
  Intr($33, regs);
end;

procedure GetMouseState(var x, y, buttons: Word);
begin
  regs.AX := 3;
  Intr($33, regs);
  x := regs.CX;
  y := regs.DX;
  buttons := regs.BX;
end;

function MouseOverButton(x1, y1, x2, y2, mouseX, mouseY: Integer): Boolean;
begin
  MouseOverButton := (mouseX >= x1) and (mouseX <= x2) and
                     (mouseY >= y1) and (mouseY <= y2);
end;

procedure HandleButtonPress(button: string);
var
  TempStr: string;
  btnChar: Char;
  
begin
  if Length(button) = 1 then
  begin
    btnChar := button[1];
    
    if btnChar in ['0'..'9'] then
    begin
      if (DisplayStr = '0') or (Length(DisplayStr) >= 15) then
        DisplayStr := btnChar
      else
        DisplayStr := DisplayStr + btnChar;
      SetFillStyle(SolidFill, LightGray);
      Bar(60, 70, 260, 90);
      OutTextXY(60, 70, DisplayStr);
    end
    else if btnChar in ['+', '-', '*', '/'] then
    begin
      Val(DisplayStr, Num1, Code);
      Operation := btnChar;
      DisplayStr := '0';
      OutTextXY(60, 70, DisplayStr);
    end
    else if btnChar = '=' then
    begin
      Val(DisplayStr, Num2, Code);
      case Operation of
        '+': Result := Num1 + Num2;
        '-': Result := Num1 - Num2;
        '*': Result := Num1 * Num2;
        '/': 
          if Num2 <> 0 then
            Result := Num1 / Num2
          else
          begin
            DisplayStr := 'Error';
            Result := 0;
          end;
      end;
      
      Str(Result:0:6, TempStr);
      
      { Removing extra 0 after float }
      if Pos('.', TempStr) > 0 then
      begin
        while (Length(TempStr) > 0) and (TempStr[Length(TempStr)] = '0') do
          Delete(TempStr, Length(TempStr), 1);
        if (Length(TempStr) > 0) and (TempStr[Length(TempStr)] = '.') then
          Delete(TempStr, Length(TempStr), 1);
      end;
      
      DisplayStr := TempStr;
      SetFillStyle(SolidFill, LightGray);
      Bar(60, 70, 260, 90);
      OutTextXY(60, 70, DisplayStr);
    end
    else if UpCase(btnChar) = 'C' then
    begin
      DisplayStr := '0';
      SetFillStyle(SolidFill, LightGray);
      Bar(60, 70, 260, 90);
      OutTextXY(60, 70, DisplayStr);
    end;
  end;
end;

{ Main program code }
begin
  { Graphic initialization }
  gd := Detect;
  InitGraph(gd, gm, 'C:\BP\DEMOS');
  if GraphResult <> grOk then
  begin
    Writeln('Problems with graphics!');
    Halt(1);
  end;

  { Initialize mouse }
  InitMouse;
  ShowMouse;

  { Color config }
  SetBkColor(Blue);
  ClearDevice;

  { Display config }
  SetFillStyle(SolidFill, LightGray);
  Bar(50, 50, 270, 100);
  SetColor(Black);
  Rectangle(50, 50, 270, 100);
  DisplayStr := '0';
  OutTextXY(60, 70, DisplayStr);
  SetColor(White);
  { Help text }
  OutTextXY(410, 60, '__Manual__');
  OutTextXY(300, 70, 'Use Mouse or KeyBoard to enter numbers.');
  OutTextXY(300, 80, 'Press c to clear.');
  OutTextXY(300, 90, 'Press ESC to exit');
  OutTextXY(410, 110, 'CD-ROM SOFT');

  { Button mounting }
  DrawButton(50, 120, 100, 170, '7', LightGray);
  DrawButton(110, 120, 160, 170, '8', LightGray);
  DrawButton(170, 120, 220, 170, '9', LightGray);
  DrawButton(230, 120, 270, 170, '/', Yellow);

  DrawButton(50, 180, 100, 230, '4', LightGray);
  DrawButton(110, 180, 160, 230, '5', LightGray);
  DrawButton(170, 180, 220, 230, '6', LightGray);
  DrawButton(230, 180, 270, 230, '*', Yellow);

  DrawButton(50, 240, 100, 290, '1', LightGray);
  DrawButton(110, 240, 160, 290, '2', LightGray);
  DrawButton(170, 240, 220, 290, '3', LightGray);
  DrawButton(230, 240, 270, 290, '-', Yellow);

  DrawButton(50, 300, 100, 350, '0', LightGray);
  DrawButton(110, 300, 160, 350, 'C', Red);
  DrawButton(170, 300, 220, 350, '=', Green);
  DrawButton(230, 300, 270, 350, '+', Yellow);

  { Main cycle }
  repeat
    { Check for mouse events }
    GetMouseState(mouseX, mouseY, mouseButtons);
    
    if (mouseButtons and 1) <> 0 then { Left button pressed }
    begin
      { Wait for button release }
      repeat
        GetMouseState(mouseX, mouseY, mouseButtons);
      until (mouseButtons and 1) = 0;
      
      { Check which button was pressed }
      if MouseOverButton(50, 120, 100, 170, mouseX, mouseY) then HandleButtonPress('7')
      else if MouseOverButton(110, 120, 160, 170, mouseX, mouseY) then HandleButtonPress('8')
      else if MouseOverButton(170, 120, 220, 170, mouseX, mouseY) then HandleButtonPress('9')
      else if MouseOverButton(230, 120, 270, 170, mouseX, mouseY) then HandleButtonPress('/')
      
      else if MouseOverButton(50, 180, 100, 230, mouseX, mouseY) then HandleButtonPress('4')
      else if MouseOverButton(110, 180, 160, 230, mouseX, mouseY) then HandleButtonPress('5')
      else if MouseOverButton(170, 180, 220, 230, mouseX, mouseY) then HandleButtonPress('6')
      else if MouseOverButton(230, 180, 270, 230, mouseX, mouseY) then HandleButtonPress('*')
      
      else if MouseOverButton(50, 240, 100, 290, mouseX, mouseY) then HandleButtonPress('1')
      else if MouseOverButton(110, 240, 160, 290, mouseX, mouseY) then HandleButtonPress('2')
      else if MouseOverButton(170, 240, 220, 290, mouseX, mouseY) then HandleButtonPress('3')
      else if MouseOverButton(230, 240, 270, 290, mouseX, mouseY) then HandleButtonPress('-')
      
      else if MouseOverButton(50, 300, 100, 350, mouseX, mouseY) then HandleButtonPress('0')
      else if MouseOverButton(110, 300, 160, 350, mouseX, mouseY) then HandleButtonPress('C')
      else if MouseOverButton(170, 300, 220, 350, mouseX, mouseY) then HandleButtonPress('=')
      else if MouseOverButton(230, 300, 270, 350, mouseX, mouseY) then HandleButtonPress('+');
    end;

    { Key event }
    if KeyPressed then
    begin
      ch := ReadKey;
      case ch of
        '0'..'9':
          begin
            if (DisplayStr = '0') or (Length(DisplayStr) >= 15) then
              DisplayStr := ch
            else
              DisplayStr := DisplayStr + ch;
            SetFillStyle(SolidFill, LightGray);
            Bar(60, 70, 260, 90);
            OutTextXY(60, 70, DisplayStr);
          end;
        '+', '-', '*', '/':
          begin
            Val(DisplayStr, Num1, Code);
            Operation := ch;
            DisplayStr := '0';
            OutTextXY(60, 70, DisplayStr);
          end;
        #13: { Enter key }
          begin
            Val(DisplayStr, Num2, Code);
            case Operation of
              '+': Result := Num1 + Num2;
              '-': Result := Num1 - Num2;
              '*': Result := Num1 * Num2;
              '/': if Num2 <> 0 then
                     Result := Num1 / Num2
                   else
                   begin
                     DisplayStr := 'Error';
                     Result := 0;
                   end;
            end;
            Str(Result:0:6, DisplayStr);
            { Removing 0 after float }
            while (Length(DisplayStr) > 0) and (DisplayStr[Length(DisplayStr)] = '0') do
              Delete(DisplayStr, Length(DisplayStr), 1);
            if (Length(DisplayStr) > 0) and (DisplayStr[Length(DisplayStr)] = '.') then
              Delete(DisplayStr, Length(DisplayStr), 1);
            SetFillStyle(SolidFill, LightGray);
            Bar(60, 70, 260, 90);
            OutTextXY(60, 70, DisplayStr);
          end;
        'C', 'c':
          begin
            DisplayStr := '0';
            SetFillStyle(SolidFill, LightGray);
            Bar(60, 70, 260, 90);
            OutTextXY(60, 70, DisplayStr);
          end;
      end;
    end;
  until ch = #27; { Press ESC to exit }

  HideMouse;
  CloseGraph;
end.

Детально описываю проблему: Я, использую virtual box oracle. Установлена система Windows XP service pack 3. пишу в программе Bordland Pascal, Tubo Pascal 7.0. При запуске програмы из 'пуск', ВСЕ работает корректно. При комплияции файла и попытке запуска exe файла, появляется cmd на одну секунду, я даже не вижу ошибку