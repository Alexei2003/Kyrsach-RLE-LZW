Unit RLE;

Interface

Procedure RLECompress(Const SInp, SOut: String);

Procedure RLEDecompress(Const SInp, SOut: String);

Implementation

Uses
  Base;

Procedure RLECompress(Const SInp, SOut: String);
Var
  FInp, FOut: File;
  FSize: Int64;
  Size: Integer;
  Len: Byte;
  FBuff: Array Of byte;
  Poft, Elem, NoPoft: Byte;
  Buff: ShortInt;
  I: Integer;
Begin
  AssignFile(FInp, SInp);
  AssignFile(FOut, SOut);
  Reset(FInp, 1);

  Reset(FOut, 1);
  BlockRead(FOut, Len, 1);
  Seek(FOut, Len+1);
  FSize:=FileSize(FInp);

  While FSize<>0 Do
  Begin
    NoCheckingSize(FSize, Size);
    SetLength(FBuff, Size);
    BlockRead(FInp, FBuff[0], Size);

    Elem:=FBuff[0];
    Poft:=1;
    NoPoft:=0;

    For I:=1 To Size-1 Do
    Begin
      If Elem=FBuff[I] Then
      Begin
        Inc(Poft);
        If Poft=128 Then
        Begin
          Dec(Poft);
          BlockWrite(FOut, Poft, 1);
          BlockWrite(FOut, Elem, 1);
          Poft:=0;
          If I=Size-1 Then
          Begin
            Poft:=1;
            BlockWrite(FOut, Poft, 1);
            BlockWrite(FOut, Elem, 1);
          End;
        End
        Else
        Begin
          If (Poft=2) And (NoPoft>0) Then
          Begin
            Buff:=1-NoPoft;
            BlockWrite(FOut, Buff, 1);
            BlockWrite(FOut, FBuff[I-NoPoft-1], NoPoft);
            NoPoft:=0;
          End;
          If I=Size-1 Then
          Begin
            Dec(Poft);
            BlockWrite(FOut, Poft, 1);
            BlockWrite(FOut, Elem, 1);
          End;
        End;
      End
      Else
      Begin
        If Poft>1 Then
        Begin
          Dec(Poft);
          BlockWrite(FOut, Poft, 1);
          BlockWrite(FOut, Elem, 1);
          Poft:=1;
          If I=Size-1 Then
          Begin
            Buff:=-NoPoft;
            BlockWrite(FOut, Buff, 1);
            BlockWrite(FOut, FBuff[I-NoPoft], NoPoft+1);
          End;
        End
        Else
        Begin
          Inc(NoPoft);
          If NoPoft=129 Then
          Begin
            Buff:=1-NoPoft;
            BlockWrite(FOut, Buff, 1);
            BlockWrite(FOut, FBuff[I-NoPoft], NoPoft);
            NoPoft:=0;
          End;
          If I=Size-1 Then
          Begin
            Buff:=-NoPoft;
            BlockWrite(FOut, Buff, 1);
            BlockWrite(FOut, FBuff[I-NoPoft], NoPoft+1);
          End;
        End;
        Elem:=FBuff[I];
      End;
    End;
  End;
  CloseFile(FInp);
  CloseFile(FOut);
End;

Procedure RLEDecompress(Const SInp, SOut: String);
Var
  FInp, FOut: File;
  FSize: Int64;
  Size: Integer;
  Len: Byte;
  FBuff: Array Of ShortInt;
  Poft, NoPoft, SaveNoPoft, SavePoft: Byte;
  I, J: Integer;
Begin
  AssignFile(FInp, SInp);
  AssignFile(FOut, SOut);
  Reset(FInp, 1);
  BlockRead(FInp, Len, 1);
  Seek(FInp, Len+1);

  FSize:=FileSize(FInp)-(Len+1);
  Rewrite(FOut, 1);
  SaveNoPoft:=0;
  SavePoft:=0;
  While FSize<>0 Do
  Begin
    NoCheckingSize(FSize, Size);
    SetLength(FBuff, Size);
    BlockRead(FInp, FBuff[0], Size);
    Begin
      SetLength(FBuff, Size);
      I:=0;
      While I<=Size-1 Do
      Begin
        If ((FBuff[I]<=0) Or (SaveNoPoft>0)) And Not (SavePoft>0) Then
        Begin
          If SaveNoPoft>0 Then
          Begin
            BlockWrite(FOut, FBuff[I], SaveNoPoft);
            I:=I+SaveNoPoft;
            SaveNoPoft:=0;
          End
          Else
          Begin
            NoPoft:=1-FBuff[I];
            If (Size-1)<(I+NoPoft) Then
            Begin
              SaveNoPoft:=I+NoPoft-Size+1;
              NoPoft:=NoPoft-SaveNoPoft;
            End;
            If NoPoft>0 Then
            Begin
              BlockWrite(FOut, FBuff[I+1], NoPoft);
              I:=I+NoPoft;
              NoPoft:=0;
            End;
            Inc(I);
          End;
        End
        Else
        Begin
          If SavePoft>0 Then
          Begin
            For J:=1 To SavePoft Do
              BlockWrite(FOut, FBuff[I], 1);
            SavePoft:=0;
            Inc(I);
          End
          Else
          Begin
            Poft:=FBuff[I]+1;
            If Size-1<I+1 Then
            Begin
              SavePoft:=Poft;
              Inc(I);
            End
            Else
            Begin
              For J:=1 To Poft Do
                BlockWrite(FOut, FBuff[I+1], 1);
              Poft:=0;
              I:=I+2;
            End;
          End;
        End;
      End;
    End;
  End;
  CloseFile(FInp);
  CloseFile(FOut);
End;

End.







