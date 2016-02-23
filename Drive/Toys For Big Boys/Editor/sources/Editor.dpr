program Editor;

uses
  Forms,
  Editor3 in 'Editor3.pas' {Form3},
  core in 'core.pas',
  items in 'items.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
