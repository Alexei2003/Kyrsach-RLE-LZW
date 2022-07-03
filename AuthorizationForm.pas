Unit AuthorizationForm;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Mask, Buttons, ActnList;

Type
  TInd=(ENG, RUS, GER);

  TAForm=Class(TForm)
    txtLogin: TStaticText;
    txtPassword: TStaticText;
    btnInput: TBitBtn;
    actlstAForm: TActionList;
    actInp: TAction;
    edtLogin: TEdit;
    edtPassword: TEdit;
    Procedure actInpExecute(Sender: TObject);
  Private
    Ind: TInd;
    StrGood, StrBad: String;
  Public
    { Public declarations }
  End;

Var
  AForm: TAForm;

Implementation

uses MainForm;

{$R *.dfm}

Procedure TAForm.actInpExecute(Sender: TObject);
Type
  TSpisok=Record
    Login: String[10];
    Password: String[10];
  End;
Var
  F: File Of TSpisok;
  Data: TSpisok;
  Good: Boolean;
  StrGood, StrBad: String;
Begin
  StrBad:='Incorrect';
  AssignFile(F, 'User/data.usp');
  Reset(F);
  Good:=False;
  While Not Eof(F) Do
  Begin
    Read(F, Data);
    While Length(edtLogin.Text)<10 Do
    Begin
      edtLogin.Text:=edtLogin.Text+' ';
    End;
    While Length(edtPassword.Text)<10 Do
    Begin
      edtPassword.Text:=edtPassword.Text+' ';
    End;
    If (Data.Login=edtLogin.Text) And (Data.Password=edtPassword.Text) Then
      Good:=True;
  End;
  CloseFile(F);

  If Good Then
  Begin
    MForm.show;
    AForm.Hide
  End
  Else
    ShowMessage(StrBad);
End;

End.

