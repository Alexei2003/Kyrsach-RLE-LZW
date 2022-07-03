Program Project2;

uses
  Forms,
  MainForm in 'MainForm.pas' {MForm},
  Base in 'Base.pas',
  RLE in 'RLE.pas',
  LZW in 'LZW.pas',
  LZ77 in 'LZ77.pas',
  AuthorizationForm in 'AuthorizationForm.pas' {AForm},
  TextForm in 'TextForm.pas' {HForm};

{$R *.res}

Begin
  Application.Initialize;
  Application.CreateForm(TAForm, AForm);
  Application.CreateForm(TMForm, MForm);
  Application.CreateForm(THForm, HForm);
  Application.Run;
End.

