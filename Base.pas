Unit Base;

Interface

Procedure NoCheckingSize(Var FSize: Int64; Var Size: Integer);

Procedure DefaultVocabulary(Var P1, P2);

Procedure CleanMem(Const P1);

Procedure ReadFileAsSpisokOneWay(Var P1; Const Max: Word; Const F: File; Var FSize: Int64);

Procedure ReadFileAsSpisokTwoWay(Var P1; Const Max: Word; Const F: File; Var FSize: Int64);

Procedure IncSpisokOneWay(Var P1; Const I: Word);

Procedure IncSpisokTwoWay(Var P1; Const I: Word);

Procedure WriteTypeFile(Const SDecomp: String; Var SComp: String; Const S: String);

Procedure ReadTypeFile(Const SComp: String; Var SDecomp: String);

Implementation

Const
  Max = 10000;

Type
  TMass=Array Of Byte;

  TUkazatel=^TVocabulary;

  TVocabulary=Record
    Next: TUkazatel;
    Ind: Word;
    Str: TMass;
  End;

Procedure NoCheckingSize(Var FSize: Int64; Var Size: Integer);
Begin
  If FSize>Max Then
  Begin
    FSize:=FSize-Max;
    Size:=Max;
  End
  Else
  Begin
    Size:=FSize;
    FSize:=0;
  End;
End;

Procedure DefaultVocabulary(Var P1, P2);
Var
  Head: TUkazatel Absolute P1;
  Now: TUkazatel Absolute P2;
  Pred: TUkazatel;
  I: Integer;
Begin
  New(Head);
  Pred:=Head;
  SetLength(Pred.Str, 1);
  Pred.Str[0]:=0;
  Pred.Ind:=0;
  For I:=1 To 255 Do
  Begin
    New(Now);
    SetLength(Now.Str, 1);
    Now.Str[0]:=I;
    Now.Ind:=I;
    Pred.Next:=Now;
    Pred:=Now;
  End;
  Now.Next:=nil;
End;

Procedure CleanMem(Const P1);
Var
  Head: TUkazatel Absolute P1;
  Clear, Now: TUkazatel;
Begin
  Clear:=Head;
  While Clear<>nil Do
  Begin
    Now:=Clear;
    Clear:=Clear.Next;
    Dispose(Now);
  End;
End;

Type
  TUkazatel2=^TSpisok;

  TSpisok=Record
    Next: TUkazatel2;
    Addr: Boolean;
    Elem: Byte;
  End;

Procedure ReadFileAsSpisokOneWay(Var P1; Const Max: Word; Const F: File; Var FSize: Int64);
Var
  Pred: TUkazatel2 Absolute P1;
  Now: TUkazatel2;
  I: Word;
Begin
  I:=1;
  While (I<=Max) And (FSize>-1) Do
  Begin
    New(Now);
    Now.Addr:=False;
    Seek(F, FSize);
    BlockRead(F, Now.Elem, 1);
    Pred.Next:=Now;
    Pred:=Now;
    Dec(FSize);
    Inc(I);
  End;
  If Pred.Next<>Nil Then
  Begin
    Pred:=Now;
    Pred.Next:=Nil;
  End;
End;

Type
  TUkazatel3=^TSpisok2;

  TSpisok2=Record
    Next, Pred: TUkazatel3;
    Addr: Boolean;
    Elem: Byte;
  End;

Procedure ReadFileAsSpisokTwoWay(Var P1; Const Max: Word; Const F: File; Var FSize: Int64);
Var
  Pred: TUkazatel3 Absolute P1;
  Now: TUkazatel3;
  I: Word;
Begin
  I:=1;
  While (I<=Max) And (FSize>-1) Do
  Begin
    New(Now);
    Now.Addr:=False;
    Seek(F, FSize);
    BlockRead(F, Now.Elem, 1);
    Pred.Pred:=Now;
    Now.Next:=Pred;
    Pred:=Now;
    Dec(FSize);
    Inc(I);
  End;
  Pred:=Now;
  Now.Pred:=Nil;
End;

Procedure IncSpisokOneWay(Var P1; Const I: Word);
Var
  J: Word;
  Now: TUkazatel2 Absolute P1;
Begin
  For J:=1 To I Do
  Begin
    Now:=Now.Next;
  End;
End;

Procedure IncSpisokTwoWay(Var P1; Const I: Word);
Var
  J: Word;
  Now: TUkazatel3 Absolute P1;
Begin
  For J:=1 To I Do
  Begin
    Now:=Now.Next;
  End;
End;

Procedure FindElem(Const S: String; Var Start: Word; Var Len: Byte);
Begin
  Start:=Length(S);
  Len:=1;
  While (S[Start-1]<>'.') And (Len<=4) Do
  Begin
    Inc(Len);
    Dec(Start);
  End;
  If Len>4 Then
    Len:=0;
End;

Procedure WriteTypeFile(Const SDecomp: String; Var SComp: String; Const S: String);
Var
  F: File;
  Len1, Len2: Byte;
  Start1, Start2: Word;
Begin
  FindElem(SComp, Start2, Len2);
  If Len2=0 Then
    SComp:=SComp+'.'
  Else
    Delete(SComp, Start2, Len2);
  SComp:=SComp+S;

  AssignFile(F, SComp);
  Rewrite(F, 1);
  FindElem(SDecomp, Start1, Len1);

  BlockWrite(F, Len1, 1);
  BlockWrite(F, SDecomp[Start1], Len1);

  CloseFile(F);
End;

Procedure ReadTypeFile(Const SComp: String; Var SDecomp: String);
Var
  F: File;
  Len1, Len2: Byte;
  Start1, Start2: Word;
  S: String;
  Ch: Char;
  I: Byte;
Begin
  AssignFile(F, SComp);
  Reset(F, 1);
  FindElem(SDecomp, Start1, Len1);
  If Len1=0 Then
    SDecomp:=SDecomp+'.'
  Else
    Delete(SDecomp, Start1, Len1);

  BlockRead(F, Len2, 1);
  S:='';
  For I:=1 To Len2 Do
  Begin
    BlockRead(F, Ch, 1);
    S:=S+Ch;
  End;
  SDecomp:=SDecomp+S;

  CloseFile(F);
End;

End.

