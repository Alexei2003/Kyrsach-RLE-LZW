Unit MainForm;

Interface

Uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ActnList, Mask, ImgList, ExtCtrls, jpeg;

Type
  TInd=(ENG, RUS, GER);

  TMForm=Class(TForm)
    actMainForm: TActionList;
    btnLZWComp: TBitBtn;
    btnLZ77Comp: TBitBtn;
    btnRLEComp: TBitBtn;
    dlgInpFile: TOpenDialog;
    dlgOutFile: TSaveDialog;
    actRLEComp: TAction;
    txt1: TStaticText;
    actInpFile: TAction;
    actOutFile: TAction;
    edtInp: TEdit;
    edtOut: TEdit;
    actLZWComp: TAction;
    actLZ77Comp: TAction;
    actDecomp: TAction;
    btnDecomp: TBitBtn;
    actChangeLanguage: TAction;
    btnChangeLanguage: TBitBtn;
    ilLanguage: TImageList;
    imgLanguage: TImage;
    btnHelp: TBitBtn;
    actHelp: TAction;
    Action1: TAction;
    Procedure actInpFileExecute(Sender: TObject);
    Procedure actOutFileExecute(Sender: TObject);
    Procedure actRLECompExecute(Sender: TObject);
    Procedure actLZWCompExecute(Sender: TObject);
    Procedure actLZ77CompExecute(Sender: TObject);
    Procedure actDecompExecute(Sender: TObject);
    Procedure actChangeLanguageExecute(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure FormClose(Sender: TObject; Var Action: TCloseAction);
    Procedure actHelpExecute(Sender: TObject);
  Private
    SInp, SOut: String;
    Ind: TInd;
    StrError: String;
  Public
  End;

Var
  MForm: TMForm;

Implementation

Uses
  RLE, LZW, LZ77, Base, AuthorizationForm, TextForm;


{$R *.dfm}

Procedure TMForm.actInpFileExecute(Sender: TObject);
Begin
  dlgInpFile.Execute;
  SInp:=dlgInpFile.FileName;
End;

Procedure TMForm.actOutFileExecute(Sender: TObject);
Begin
  dlgOutFile.Execute;
  SOut:=dlgOutFile.FileName;
End;

Procedure TMForm.actRLECompExecute(Sender: TObject);
Begin
  actInpFileExecute(Self);
  edtInp.Text:=SInp;
  actOutFileExecute(Self);
  If (SInp<>'') And (SOut<>'') Then
  Begin
    WriteTypeFile(SInp, SOut, 'RLE');
    edtOut.Text:=SOut;

    RLECompress(SInp, SOut);
    SInp:='';
    SOut:='';
    edtInp.Text:=SInp;
    edtOut.Text:=SOut;
    ShowMessage('Fin');
  End
  Else
  Begin
    ShowMessage(StrError);
  End;
End;

Procedure TMForm.actLZWCompExecute(Sender: TObject);
Begin
  actInpFileExecute(Self);
  edtInp.Text:=SInp;
  actOutFileExecute(Self);
  If (SInp<>'') And (SOut<>'') Then
  Begin
    WriteTypeFile(SInp, SOut, 'LZW');
    edtOut.Text:=SOut;

    LZWCompress(SInp, SOut);
    SInp:='';
    SOut:='';
    edtInp.Text:=SInp;
    edtOut.Text:=SOut;
    ShowMessage('Fin');
  End
  Else
  Begin
    ShowMessage(StrError);
  End;
End;

Procedure TMForm.actLZ77CompExecute(Sender: TObject);
Begin
  actInpFileExecute(Self);
  edtInp.Text:=SInp;
  actOutFileExecute(Self);
  If (SInp<>'') And (SOut<>'') Then
  Begin
    WriteTypeFile(SInp, SOut, 'LZ7');
    edtOut.Text:=SOut;

    LZ77Compress(SInp, SOut);
    SInp:='';
    SOut:='';
    edtInp.Text:=SInp;
    edtOut.Text:=SOut;
    ShowMessage('Fin');
  End
  Else
  Begin
    ShowMessage(StrError);
  End;
End;

Procedure TMForm.actDecompExecute(Sender: TObject);
Var
  TypeFile: String;
Begin
  actInpFileExecute(Self);
  edtInp.Text:=SInp;
  actOutFileExecute(Self);
  If (SInp<>'') And (SOut<>'') Then
  Begin
    ReadTypeFile(SInp, SOut);
    edtOut.Text:=SOut;

    TypeFile:=Copy(SInp, Length(SInp)-2, 3);
    If TypeFile='RLE' Then
      RLEDecompress(SInp, SOut)
    Else
    Begin
      If TypeFile='LZW' Then
        LZWDecompress(SInp, SOut)
      Else
      Begin
        If TypeFile='LZ7' Then
          LZ77Decompress(SInp, SOut)
      End;
    End;
    SInp:='';
    SOut:='';
    edtInp.Text:=SInp;
    edtOut.Text:=SOut;
    ShowMessage('Fin');
  End
  Else
  Begin
    ShowMessage(StrError);
  End;
End;

Procedure TMForm.actChangeLanguageExecute(Sender: TObject);
Type
  TLanguage=Record
    StrMainWin: String;
    StrLabel: String;
    StrDecomp: String;
    StrError: String;
  End;
Const
  LengENG: TLanguage = (
    StrMainWin: 'Main window';
    StrLabel: 'Decompression';
    StrDecomp: 'Compression';
    StrError: 'No file specified'
  );
  LengRUS: TLanguage = (
    StrMainWin: 'Главное окно';
    StrLabel: 'Разжатие';
    StrDecomp: 'Сжатие ';
    StrError: 'Не указан файл'
  );
  LengGER: TLanguage = (
    StrMainWin: 'Hauptfenster';
    StrLabel: 'Entpacken';
    StrDecomp: 'Komprimierung';
    StrError: 'Keine datei angegeben'
  );
  FlagCountry: Array[0..2] Of String = ('Flag/gb.jpg', 'Flag/ru.jpg', 'Flag/de.jpg');
Var
  Language: TLanguage;
Begin
  Case Ind Of
    ENG:
      Language:=LengENG;
    RUS:
      Language:=LengRUS;
    GER:
      Language:=LengGER;
  End;
  Caption:=Language.StrMainWin;
  actDecomp.Caption:=Language.StrLabel;
  txt1.Caption:=Language.StrDecomp;
  StrError:=Language.StrError;
  imgLanguage.Picture.LoadFromFile(FlagCountry[Ord(Ind)]);
  If Ind=High(TInd) Then
    Ind:=Low(TInd)
  Else
    Ind:=Succ(Ind);
End;

Procedure TMForm.FormCreate(Sender: TObject);
Begin
  Ind:=ENG;
  actChangeLanguageExecute(MForm);
End;

Procedure TMForm.FormClose(Sender: TObject; Var Action: TCloseAction);
Begin
  AForm.Close;

End;

Procedure TMForm.actHelpExecute(Sender: TObject);
Begin
  HForm.Show;
End;

End.

