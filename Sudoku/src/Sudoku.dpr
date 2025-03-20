program Sudoku;

uses
  Forms,
  frmSudoku in 'frmSudoku.pas' {FormMain},
  Solver in 'Solver.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
