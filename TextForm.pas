Unit TextForm;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

Type
  THForm=Class(TForm)
    mmoHelp: TMemo;
    Procedure FormCreate(Sender: TObject);
  Private
    { Private declarations }
  Public
    { Public declarations }
  End;

Var
  HForm: THForm;

Implementation

{$R *.dfm}

Procedure THForm.FormCreate(Sender: TObject);
Var
  F: TextFile;
  S:string;
Begin
  AssignFile(F, 'User/Razrab.txt');
  Reset(F);
  mmoHelp.Lines.Delete(0);
  While Not Eof(F) Do
  Begin
    Readln(F, S);
    mmoHelp.Lines.Add(S);
  End;
End;

End.

