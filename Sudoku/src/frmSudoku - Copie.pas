unit frmSudoku;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, Gauges, StdCtrls, ExtCtrls, Menus, Solver;

const
  cNumberChar = ['0' .. '9'];

type
  TFormMain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    bClear: TButton;
    bSave: TButton;
    bLoad: TButton;
    bPlay: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Panel3: TPanel;
    Label7: TLabel;
    gridSudoku: TStringGrid;
    bPause: TButton;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    Timer1: TTimer;
    Label8: TLabel;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Memo1: TMemo;
    Panel8: TPanel;
    bDigit1: TButton;
    bDigit2: TButton;
    bDigit3: TButton;
    bDigit4: TButton;
    bDigit5: TButton;
    bDigit6: TButton;
    bDigit7: TButton;
    bDigit8: TButton;
    bDigit9: TButton;
    bDelNumber: TButton;
    bSolve: TButton;
    procedure bClearClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bPlayClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure bSaveClick(Sender: TObject);
    procedure bLoadClick(Sender: TObject);
    procedure btnNumberClick(Sender: TObject);
    procedure bDelNumberClick(Sender: TObject);
    procedure bPauseClick(Sender: TObject);
    procedure gridSudokuSelectCell(Sender: TObject; ACol, ARow: Integer;
      var CanSelect: Boolean);
    procedure gridSudokuDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure bSolveClick(Sender: TObject);
  private
    FSolver: TSudokuSolver;
    FCol, FRow: Integer;
    FCurrentDigit: string;
    FButton: array [1 .. 9] of TButton;
    function GridToString(aLine: Boolean): string;
    procedure StringToGrid(aString: string);
    procedure CreateGrid(aMissing: integer);
    { Private declarations }
  public
    { Public declarations }
    Time, prov: Integer;
    Number: 1 .. 9;
    Jeu: Boolean;
    Tableau: array [9 .. 9, 9 .. 9] of Integer;
    Pozicije, Provera: array [0 .. 9, 0 .. 9] of char;
    MemoString: string;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

procedure TFormMain.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  Timer1.Enabled := False;
  Jeu := False;
  for i := 1 to 9 do
    FButton[i] := (FindComponent('bDigit' + IntToStr(i)) as TButton);
  FSolver := TSudokuSolver.Create;
  FCol := 0;
  FRow := 0;
end;

procedure TFormMain.bClearClick(Sender: TObject);
var
  i, j: Integer;
begin
  for i := 0 to 8 do
    for j := 0 to 8 do
    begin
      gridSudoku.Cells[i, j] := '';
      Provera[i, j] := '0';
    end;
  Timer1.Enabled := False;
  Jeu := False;
end;

procedure TFormMain.bPlayClick(Sender: TObject);
var
  i, j, prov: Integer;
  k: char;
begin
  Timer1.Enabled := true;
  bClear.Enabled := False;
  bSave.Enabled := False;
  bLoad.Enabled := False;
  bPlay.Enabled := False;
  Time := 0;
  Jeu := true;
  prov := 0;
  for i := 0 to 8 do
    for j := 0 to 8 do
    begin
      Pozicije[j, i] := '-';
      Provera[j, i] := #0;
      for k := '1' to '9' do
        if gridSudoku.Cells[j, i] = k then
        begin
          Pozicije[j, i] := 'x';
          Provera[j, i] := k;
        end;
      if gridSudoku.Cells[i, j] = '' then
      else
        prov := prov + 1;
    end;
  if prov = 81 then
  begin
    Timer1.Enabled := False;
    ShowMessage('Tu as gagn� !');
  end;
end;

procedure TFormMain.Timer1Timer(Sender: TObject);
begin
  Time := Time + Timer1.Interval;
  Label8.Caption := IntToStr(Time div 1000) + ' s';
end;

function TFormMain.GridToString(aLine: Boolean): string;
var
  i, j: Integer;
begin
  result := '';
  for i := 0 to 8 do
  begin
    for j := 0 to 8 do
    begin
      if (gridSudoku.Cells[j, i] <> '') and
        (gridSudoku.Cells[j, i].Chars[0] in cNumberChar) then
        result := result + gridSudoku.Cells[j, i]
      else
        result := result + '0';
    end;
    if aLine then
      result := result + #13#10;
  end;
end;

procedure TFormMain.StringToGrid(aString: string);
var
  i, j: Integer;
begin
  aString := StringReplace(aString, #13#10, '', [rfReplaceAll]);
  for i := 0 to 8 do
    for j := 0 to 8 do
    begin
      Provera[i, j] := aString[i * 9 + j + 1];
      if Provera[i, j] <> '0' then
        gridSudoku.Cells[i, j] := Provera[i, j]
      else
        gridSudoku.Cells[i, j] := '';
    end;
end;

procedure TFormMain.bSaveClick(Sender: TObject);
var
  i, j: Integer;
begin
  Memo1.Lines.Clear;
  Memo1.Lines.Add(GridToString(true));
  if SaveDialog1.Execute then
    Memo1.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TFormMain.bSolveClick(Sender: TObject);
begin
  FSolver.Solve(GridToString(False));
  StringToGrid(FSolver.Solution);
  FSolver.Solve(GridToString(False));
  StringToGrid(FSolver.Solution);
end;

procedure TFormMain.bLoadClick(Sender: TObject);
var
  i, j: Integer;
begin
  Memo1.Lines.Clear;
  if OpenDialog1.Execute then
    Memo1.Lines.LoadFromFile(OpenDialog1.FileName)
  else
    Exit;
  StringToGrid(Memo1.Lines.Text);
end;

procedure TFormMain.gridSudokuSelectCell(Sender: TObject; ACol, ARow: Integer;
  var CanSelect: Boolean);

  procedure ButtonState(i, j: Integer);
  begin
    if gridSudoku.Cells[j, i] <> '' then
      FButton[StrToInt(gridSudoku.Cells[j, i].Chars[0])].Enabled := False;
  end;

var
  i, j: Integer;
  cDigit: string;
  stop: Boolean;
begin
  for i := 1 to 9 do
    FButton[i].Enabled := true;

  bDelNumber.Enabled := true;
  stop := False;
  for i := 0 to 8 do
  begin
    for j := 1 to 9 do
    begin
      cDigit := IntToStr(j);
      with gridSudoku do
      begin
        if (Cells[ACol, i] = cDigit) or (Cells[i, ARow] = cDigit) then
        begin
          FButton[j].Enabled := False;
          stop := true;
          break;
        end;
      end;
    end;
    if stop then
      break;
  end;

  if (ARow = 0) or (ARow = 1) or (ARow = 2) then
  begin
    if (ACol = 0) or (ACol = 1) or (ACol = 2) then
    begin
      for i := 0 to 2 do
        for j := 0 to 2 do
        begin
          ButtonState(i, j);
        end;
    end;
    if (ACol = 3) or (ACol = 4) or (ACol = 5) then
    begin
      for i := 0 to 2 do
        for j := 3 to 5 do
        begin
          ButtonState(i, j);
        end;
    end;
    if (ACol = 6) or (ACol = 7) or (ACol = 8) then
    begin
      for i := 0 to 2 do
        for j := 6 to 8 do
        begin
          ButtonState(i, j);
        end;
    end;
  end;
  if (ARow = 3) or (ARow = 4) or (ARow = 5) then
  begin
    if (ACol = 0) or (ACol = 1) or (ACol = 2) then
    begin
      for i := 3 to 5 do
        for j := 0 to 2 do
        begin
          ButtonState(i, j);
        end;
    end;
    if (ACol = 3) or (ACol = 4) or (ACol = 5) then
    begin
      for i := 3 to 5 do
        for j := 3 to 5 do
        begin
          ButtonState(i, j);
        end;
    end;
    if (ACol = 6) or (ACol = 7) or (ACol = 8) then
    begin
      for i := 3 to 5 do
        for j := 6 to 8 do
        begin
          ButtonState(i, j);
        end;
    end;
  end;
  if (ARow = 6) or (ARow = 7) or (ARow = 8) then
  begin
    if (ACol = 0) or (ACol = 1) or (ACol = 2) then
    begin
      for i := 6 to 8 do
        for j := 0 to 2 do
        begin
          ButtonState(i, j);
        end;
    end;
    if (ACol = 3) or (ACol = 4) or (ACol = 5) then
    begin
      for i := 6 to 8 do
        for j := 3 to 5 do
        begin
          ButtonState(i, j);
        end;
    end;
    if (ACol = 6) or (ACol = 7) or (ACol = 8) then
    begin
      for i := 6 to 8 do
        for j := 6 to 8 do
        begin
          ButtonState(i, j);
        end;
    end;
  end;
  if Pozicije[ACol, ARow] = 'x' then
  begin
    for i := 1 to 9 do
      FButton[i].Enabled := False;
    bDelNumber.Enabled := False;
  end;
  FCol := ACol;
  FRow := ARow;
  FCurrentDigit := gridSudoku.Cells[ACol, ARow];
  gridSudoku.Repaint;
end;

procedure TFormMain.btnNumberClick(Sender: TObject);
var
  i, j: Integer;
  n: char;
begin
  n := char(48 + (Sender as TButton).Tag);
  Provera[FCol, FRow] := n;
  FCurrentDigit := n;
  gridSudoku.Cells[FCol, FRow] := n;
  if Jeu = true then
  begin
    prov := 0;
    for i := 0 to 8 do
      for j := 0 to 8 do
        if gridSudoku.Cells[i, j] = '' then
        else
          prov := prov + 1;
    if prov = 81 then
    begin
      Timer1.Enabled := False;
      ShowMessage('Tu as gagn� !');
    end;
  end;
  gridSudoku.Repaint;
end;

procedure TFormMain.bDelNumberClick(Sender: TObject);
begin
  gridSudoku.Cells[gridSudoku.Col, gridSudoku.Row] := '';
  Provera[gridSudoku.Col, gridSudoku.Row] := #0;
end;

procedure TFormMain.bPauseClick(Sender: TObject);
var
  i, j: Integer;
begin
  // Jeu := False;
  // Timer1.Enabled := False;
  // Label8.Caption := '';
  // bClear.Enabled := true;
  // bSave.Enabled := true;
  // bLoad.Enabled := true;
  // bPlay.Enabled := true;
  // for i := 0 to 8 do
  // for j := 0 to 8 do
  // Pozicije[j, i] := '-';

  CreateGrid(20);
end;

procedure TFormMain.CreateGrid(aMissing: integer);
var
  i, j: Integer;
  str: string;
  p: Integer;
begin
  str := '';
  for i := 1 to 81 do
    str := str + '0';

  p := random(81) + 1;
  str[p] := char(48 + random(9) + 1);

  FSolver.Solve(str);
  str := FSolver.Solution;
  i := 0;
  repeat
    p := random(81) + 1;
    if str[p] <> '0' then
    begin
      str[p] := '0';
      inc(i);
    end;
  until (i = aMissing);

  StringToGrid(str);
end;

procedure TFormMain.gridSudokuDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  // if Jeu = true then
  with Sender as TStringGrid do
    with Canvas do
    begin
      if Pozicije[ACol, ARow] = 'x' then
      begin
        Font.Color := clWhite;
        Brush.Color := clActiveCaption;
      end;
      if Provera[ACol, ARow] in cNumberChar then
      begin
        Font.Color := clBlack;
        Brush.Color := clWhite;
      end;

      if (FCol = ACol) or (FRow = ARow) then
        Brush.Color := RGB(226, 235, 243); // clCream;

      if (FCurrentDigit <> '') and (FCurrentDigit = gridSudoku.Cells[ACol, ARow])
      then
        Brush.Color := RGB(187, 222, 251); // clWebLightCyan;

      if (FCol = ACol) and (FRow = ARow) then
        Brush.Color := RGB(187, 222, 251); // clWebLightCyan;

      // for i := '1' to '9' do
      // if Pozicije[ACol, ARow] = 'x' then
      // begin
      // Font.Color := clWhite;
      // Brush.Color := clActiveCaption;
      // end;
      // if Provera[ACol, ARow] = i then
      // begin
      // Font.Color := clBlack;
      // Brush.Color := clWhite;
      // end;
      FillRect(Rect);
      if Provera[ACol, ARow] = '0' then
        TextOut(Rect.Left + 20, Rect.Top + 8, '')
      else
        TextOut(Rect.Left + 20, Rect.Top + 8, Provera[ACol, ARow]);
    end;
end;

end.
