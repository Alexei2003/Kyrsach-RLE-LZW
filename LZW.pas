Unit LZW;

Interface

Uses
  Windows;

Procedure LZWCompress(Const SInp, SOut: String);

Procedure LZWDecompress(Const SInp, SOut: String);

Implementation

Uses
  Base;

Const
  Max = 65535;
  LenInd = 2;

Type
  SizeData=Word;

  TMass=Array Of Byte;

  TMassW=Array Of SizeData;

  TUkazatel=^TVocabulary;

  TVocabulary=Record
    Next: TUkazatel;
    Ind: SizeData;
    Str: TMass;
  End;

Procedure LZWCompress(Const SInp, SOut: String);
Var
  FInp, FOut: File;
  FSize: Int64;
  Size: Integer;
  FBuff, MBuff: TMass;
  Len: Integer;
  Len2: Byte;
  I, J: Integer;
  PredInd: SizeData;
  Equal, First: Boolean;
  Head, Now, Clear, Fin: TUkazatel;
Begin
  AssignFile(FInp, SInp);
  AssignFile(FOut, SOut);
  Reset(FInp, 1);
  Reset(FOut, 1);
  BlockRead(FOut, Len2, 1);

  Len2:=Len2+1+((Len2+1) Mod 2);
  FSize:=FileSize(FInp);
  Reset(FOut, LenInd);
  Seek(FOut, (Len2 Div lenInd));
  DefaultVocabulary(Head, Clear);
  Len:=1;

  Fin:=Clear;
  First:=True;
  While FSize<>0 Do
  Begin
    NoCheckingSize(FSize, Size);
    SetLength(FBuff, Size);
    BlockRead(FInp, FBuff[0], Size);
    Begin
      I:=0;
      SetLength(MBuff, Len);
      While I<=Size-1 Do
      Begin
        Now:=Head;
        MBuff[Length(MBuff)-1]:=FBuff[I];
        Equal:=False;
        Repeat
          If Length(MBuff)=Length(Now.Str) Then
          Begin
            Equal:=True;
            J:=0;
            Repeat
              If (MBuff[J]<>Now.Str[J]) Then
              Begin
                Equal:=False;
              End;
              Inc(J);
            Until (J=Length(MBuff)) Or Not (Equal);
          End;
          If Equal Then
            PredInd:=Now.Ind
          Else
          Begin
            Now:=Now.Next;
          End;
        Until (Now=nil) Or (Equal);

        If Equal Then
        Begin
          If Eof(FInp) And (I=Size-1) Then
          Begin
            BlockWrite(FOut, PredInd, 1);
          End;
          Inc(I);
          SetLength(MBuff, Length(MBuff)+1);
        End
        Else
        Begin
          If First Then
          Begin
            New(Now);
            Now.Next:=nil;
          End
          Else
          Begin
            Now:=Fin.Next;
          End;
          Now.Ind:=Fin.Ind+1;
          Now.Str:=MBuff;
          Fin.Next:=Now;

          If Fin.Ind=Max-1 Then
          Begin
            Fin:=Clear;
            First:=False;
          End
          Else
            Fin:=Fin.Next;

          BlockWrite(FOut, PredInd, 1);
          SetLength(MBuff, 1);
        End;
      End;
      Len:=Length(MBuff);
    End;
  End;
  CleanMem(Head);
  CloseFile(FInp);
  CloseFile(FOut);
End;

Procedure LZWDecompress(Const SInp, SOut: String);
Var
  FInp, FOut: File;
  FSize: Int64;
  Size: Integer;
  FBuff: TMassW;
  I: Integer;
  Len: Byte;
  Equal, First: Boolean;
  Head, Now, Fin, SavePos, Clear, PredInd: TUkazatel;
Begin
  AssignFile(FInp, SInp);
  AssignFile(FOut, SOut);
  Reset(FInp, 1);
  BlockRead(FInp, Len, 1);
  Len:=Len+1+((Len+1) Mod 2);
  FSize:=FileSize(FInp)-(Len);
  Reset(FInp, LenInd);
  Seek(FInp, (Len Div LenInd));

  Rewrite(FOut, 1);
  DefaultVocabulary(Head, Clear);
  SavePos:=nil;

  Fin:=Clear;
  First:=True;
  While FSize<>0 Do
  Begin
    NoCheckingSize(FSize, Size);

    Size:=Size Div LenInd;

    SetLength(FBuff, Size);
    BlockRead(FInp, FBuff[0], Size);
    Begin
      I:=0;
      While I<=Size-1 Do
      Begin
        Now:=Head;
        Equal:=False;

        Repeat
          If FBuff[I]=Now.Ind Then
          Begin
            If SavePos<>nil Then
              SavePos.Str[Length(SavePos.Str)-1]:=Now.Str[0];
            BlockWrite(FOut, Now.Str[0], Length(Now.Str));
            PredInd:=Now;
            Equal:=True;
          End
          Else
            Now:=Now.Next;
        Until Equal;

        If First Then
        Begin
          New(Now);
          Now.Next:=nil;
        End
        Else
        Begin
          Now:=Fin.Next;
        End;
        Now.Ind:=Fin.Ind+1;
        Now.Str:=PredInd.Str;
        Fin.Next:=Now;

        If Fin.Ind=Max-1 Then
        Begin
          Fin:=Clear;
          First:=False;
        End
        Else
          Fin:=Fin.Next;

        SetLength(Now.Str, (Length(Now.Str)+1));
        SavePos:=Now;

        Inc(I);
      End;
    End;
  End;
  CleanMem(Head);
  CloseFile(FInp);
  CloseFile(FOut);
End;

End.

