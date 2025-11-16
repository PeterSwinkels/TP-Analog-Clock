{$A+}
{$B-}
{$G+}
{$N+}
{$Q-}
program AnalogClockProgram;
uses Crt, Dos, Graph;

const DEGREES_PER_RADIAN: double = 180 / PI;

type
  TimeRec = record
    Hours: integer;
    Minutes: integer;
    Seconds: integer;
  end;

procedure AdvanceTime(var CurrentTime: TimeRec);
begin
  if CurrentTime.Seconds < 59 then
  begin
    inc(CurrentTime.Seconds);
  end
  else
  begin
    CurrentTime.Seconds := 0;
    if CurrentTime.Minutes < 59 then
    begin
      inc(CurrentTime.Minutes);
    end
    else
    begin
      CurrentTime.Minutes := 0;
      if CurrentTime.Hours < 12 then
      begin
        inc(CurrentTime.Hours);
      end
      else
      begin
        CurrentTime.Hours := 0;
      end;
    end;
  end;
end;

procedure DrawHand(Degrees: integer; Length: integer; HandColor: word);
var
  Radian: double;
  x: integer;
  y: integer;
begin
  SetColor(HandColor);
  Radian := Degrees / DEGREES_PER_RADIAN;
  x := Round((Sin(Radian) * Length)) + 320;
  y := Round((Cos(Radian) * Length)) + 240;
  Line(320, 240, x, y);
end;

procedure DrawClock(var CurrentTime: TimeRec);
var
  Degrees: integer;
  MarkStart: integer;
  Radian: double;
  x1: integer;
  y1: integer;
  x2: integer;
  y2: integer;
begin
  SetColor(Yellow);

  Degrees := 0;
  while Degrees < 360 do
  begin
    Degrees := Degrees + 30;
    Radian := Degrees / DEGREES_PER_RADIAN;
    if Degrees mod 90 = 0 then MarkStart := 100 else MarkStart := 125;
    x1 := Round((Sin(Radian) * MarkStart)) + 320;
    y1 := Round((Cos(Radian) * MarkStart)) + 240;
    x2 := Round((Sin(Radian) * 150)) + 320;
    y2 := Round((Cos(Radian) * 150)) + 240;
    Line(x1, y1, x2, y2);
  end;

  Degrees := (180 - (CurrentTime.Hours * 30)) - Round(CurrentTime.Minutes / 2);
  DrawHand(Degrees, 70, Green);

  Degrees := (180 - (CurrentTime.Minutes * 6));
  DrawHand(Degrees, 140, Green);

  Degrees := (180 - (CurrentTime.Seconds * 6));
  DrawHand(Degrees, 140, Red);

  SetColor(Blue);
  Circle(320, 240, 150);
  SetColor(White);
  Circle(320, 240, 4);
end;

procedure DisplayInformation;
begin
  SetColor(Cyan);
  OutTextXY(8, 8, 'Analog Clock v1.00 - by: Peter Swinkels, ***2025***');
  OutTextXY(8, 16, 'ESC = Quit   A/a = Adjust hours/minutes.');
end;

procedure EraseHands(CurrentTime: TimeRec);
var
  Degrees: integer;
begin
  Degrees := (180 - (CurrentTime.Hours * 30)) - Round(CurrentTime.Minutes / 2);
  DrawHand(Degrees, 70, Black);

  Degrees := (180 - (CurrentTime.Minutes * 6));
  DrawHand(Degrees, 140, Black);

  Degrees := (180 - (CurrentTime.Seconds * 6));
  DrawHand(Degrees, 140, Black);
end;

procedure Main(CurrentTime: TimeRec);
var
  Dummy: word;
  KeyStroke: char;
  PreviousSeconds: word;
  Seconds: word;
begin
  DisplayInformation;
  DrawClock(CurrentTime);
  Seconds := 0;

  while true do
  begin
    PreviousSeconds := Seconds;
    GetTime(Dummy, Dummy, Seconds, Dummy);
    if Seconds <> PreviousSeconds then
    begin
      EraseHands(CurrentTime);
      AdvanceTime(CurrentTime);
      DrawClock(CurrentTime);
    end;
    KeyStroke := #0;
    if KeyPressed then KeyStroke := ReadKey;
    case KeyStroke of
      #27:
        Break;
      'A':
      begin
        EraseHands(CurrentTime);
        if CurrentTime.Hours < 12 then
        begin
          inc(CurrentTime.Hours)
        end
        else
        begin
          CurrentTime.Hours := 0;
        end;
        DrawClock(CurrentTime);
      end;
      'a':
      begin
        EraseHands(CurrentTime);
        if CurrentTime.Minutes < 59 then
        begin
          inc(CurrentTime.Minutes)
        end
        else
        begin
          CurrentTime.Minutes := 0;
        end;
        DrawClock(CurrentTime);
      end;
    end;
  end;
end;

var
  CurrentTime: TimeRec;
  Dummy: word;
  GraphicsDriver: integer;
  GraphicsMode: integer;
  GraphicsResult: integer;
  Hours: word;
  Minutes: word;
  Seconds: word;
begin
  GraphicsDriver := Detect;
  InitGraph(GraphicsDriver, GraphicsMode, '');
  GraphicsResult := GraphResult;

  if GraphicsResult = grOk then
  begin
    if (GetMaxX = 639) and (GetMaxY = 479) then
    begin
      GetTime(Hours, Minutes, Seconds, Dummy);
      if Hours > 12 then Hours := Hours - 12;
      CurrentTime.Hours := integer(Hours);
      CurrentTime.Minutes := integer(Minutes);
      CurrentTime.Seconds := integer(Seconds);
      Main(CurrentTime);
      CloseGraph;
    end
    else
    begin
      CloseGraph;
      WriteLn('640x480 16 color VGA required.');
    end;
  end
  else
  begin
    WriteLn(GraphErrorMsg(GraphicsResult));
    Halt;
  end
end.

