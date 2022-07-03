Unit LZ77;

Interface

Uses
  Windows;

Procedure LZ77Compress(Const SInp, SOut: String);

Procedure LZ77Decompress(Const SInp, SOut: String);

Implementation

Uses
  Base;

Const
  Win = 20;
  MaxLen = 16;
  SBuff = 60;
  SizeByte = 256;

Type
  Ukazatel=^TSpisok;

  TSpisok=Record
    Next: Ukazatel;
    Addr: Boolean;
    Elem: Byte;
  End;

Procedure LZ77Compress(Const SInp, SOut: String);
Var
  FInp, FOut: File;
  FSize: Int64;
  I, N: Byte;
  Len: Byte;
  J, Buff: Word;
  WinStart, WinFin, WinNow, WinSave, Pred, Now, Save: Ukazatel;
Begin
  AssignFile(FInp, SInp);
  AssignFile(FOut, SOut);
  Reset(FInp, 1);
  Reset(FOut, 1);
  BlockRead(FOut, Len, 1);
  Seek(FOut, Len+1);

  New(WinStart);
  FSize:=FileSize(FInp)-1;

  Now:=WinStart;
  ReadFileAsSpisokOneWay(Now, Win, FInp, FSize);
  WinFin:=Now;
  Buff:=SBuff;
  ReadFileAsSpisokOneWay(Now, Buff, FInp, FSize);
  WinSave:=WinStart;
  IncSpisokOneWay(WinStart, 1);
  Dispose(WinSave);

  Repeat
    For I:=0 To Win-1 Do
    Begin
      Now:=WinFin.Next;
      WinNow:=WinStart;
      While Now<>nil Do
      Begin
        If Now.Addr Then
          IncSpisokOneWay(Now, 3);

        If (Now<>Nil) And (Now.Elem=WinNow.Elem) Then
        Begin
          Save:=Now;
          WinSave:=WinNow;
          N:=0;
          While (Now<>nil) And (Not Now.Addr) And (Now.Elem=WinNow.Elem) And (WinNow<>WinFin.Next) And (N<=MaxLen-1) Do
          Begin
            Inc(N);
            Now:=Now.Next;
            WinNow:=WinNow.Next;
          End;
          WinNow:=WinSave;
          If N>3 Then
          Begin
            Save.Addr:=True;
            Save.Elem:=N;
            IncSpisokOneWay(Save, 2);
            Save.Elem:=I;
            Now:=Save;
            Now:=Now.Next;
            For J:=1 To N-3 Do
            Begin
              Pred:=Now;
              IncSpisokOneWay(Now, 1);
              Dispose(Pred);
            End;
            Save.Next:=Now;
            Now:=Save;
          End;
        End;
        If (Now<>Nil) Then
          Now:=Now.Next;
      End;
    End;

    Pred:=WinFin;
    For I:=1 To 2 Do
    Begin
      New(Now);
      Now.Next:=Pred.Next;
      Pred.Next:=Now;
      Now.Elem:=0;
      Now.Addr:=False;
      Pred:=Now;
      Now:=Now.Next;
    End;
    Pred:=WinFin.Next;
    Now:=Pred;
    IncSpisokOneWay(Now, 2);
    N:=2;
    J:=1;
    While Now<>Nil Do
    Begin
      If Now.Addr Then
      Begin
        Pred.Elem:=Pred.Elem+(N Div SizeByte)*(MaxLen);
        Pred:=Pred.Next;
        Pred.Elem:=N Mod SizeByte;
        Pred:=Now;
        Now.Addr:=False;
        IncSpisokOneWay(Now, J);
        N:=J;
        J:=2;
      End;
      Inc(N);
      Now:=Now.Next;
    End;
    Pred:=Pred.Next;
    Pred.Elem:=0;

    For I:=1 To (Win Div 2) Do
    Begin
      BlockWrite(FOut, WinStart.Elem, 1);
      Now:=WinStart;
      WinStart:=WinStart.Next;
      WinFin:=WinFin.Next;
      Dispose(Now);
    End;

    Buff:=1;
    Now:=WinFin.Next;
    If Now<>Nil Then
      While Now.Next<>Nil Do
      Begin
        Now:=Now.Next;
        Inc(Buff);
      End;

    ReadFileAsSpisokOneWay(Now, SBuff-Buff, FInp, FSize);

    Buff:=1;
    Now:=WinFin.Next;
    If Now<>Nil Then
      While Now.Next<>Nil Do
      Begin
        Now:=Now.Next;
        Inc(Buff);
      End;

  Until Buff<=(Win Div 2)+1+(Len+1);

  Now:=WinStart;
  While Now<>WinFin.Next Do
  Begin
    BlockWrite(FOut, Now.Elem, 1);
    Now:=Now.Next;
  End;

  J:=0;
  While Now<>Nil Do
  Begin
    BlockWrite(FOut, Now.Elem, 1);
    Now:=Now.Next;
    Inc(J);
  End;
  BlockWrite(FOut, J, 1);

End;

Procedure LZ77Decompress(Const SInp, SOut: String);
Type
  Ukazatel=^TSpisok;

  TSpisok=Record
    Next, Pred: Ukazatel;
    Addr: Boolean;
    Elem: Byte;
  End;
Var
  FInp, FOut: File;
  FSize: Int64;
  I, N, Numb, Len, Shift: Byte;
  J, Buff, Count: Word;
  WinStart, WinFin, WinNow, WinSave, BuffFin, Pred, Now, Next, Save: Ukazatel;
Begin
  AssignFile(FInp, SInp);
  AssignFile(FOut, SOut);
  Reset(FInp, 1);
  Rewrite(FOut, 1);
  BlockRead(FOut, Len, 1);

  FSize:=FileSize(FInp)-1;

  Seek(FInp, FSize);
  Buff:=0;
  BlockRead(FInp, Buff, 1);
  Dec(FSize);

  New(Now);
  Save:=Now;
  ReadFileAsSpisokTwoWay(Now, Buff+1, FInp, FSize);
  BuffFin:=Save.Pred;
  BuffFin.Next:=Nil;

  Dispose(Save);
  WinFin:=Now;
  ReadFileAsSpisokTwoWay(Now, Win-1, FInp, FSize);
  WinStart:=Now;
  WinStart.Pred:=Nil;

  Repeat
    For I:=1 To (Win Div 2) Do
    Begin
      ReadFileAsSpisokTwoWay(WinStart, 1, FInp, FSize);
    End;

    WinFin:=WinStart;
    IncSpisokTwoWay(WinFin, Win-1);

    Now:=WinFin.Next;
    Count:=(Now.Elem Div MaxLen)*SizeByte;
    Save:=Now;
    Now:=Now.Next;
    Dispose(Save);
    Count:=Count+Now.Elem;
    Save:=Now;
    Now:=Now.Next;
    Dispose(Save);
    WinFin.Next:=Now;
    Now.Pred:=WinFin;

    While Count<>0 Do
    Begin
      IncSpisokTwoWay(Now, Count-2);
      Now.Addr:=True;
      Count:=(Now.Elem Div MaxLen)*SizeByte;
      Now:=Now.Next;
      Count:=Count+Now.Elem;
      Now:=Now.Next;
    End;

    Now:=WinFin.Next;
    While Now<>Nil Do
    Begin
      Save:=Now;
      If Now.Addr Then
      Begin
        Now.Addr:=False;
        Pred:=Now;
        Save:=Now;
        Len:=Now.Elem Mod MaxLen;
        IncSpisokTwoWay(Now, 2);
        Shift:=Now.Elem;
        Next:=Now.Next;

        WinNow:=WinStart;
        IncSpisokTwoWay(WinNow, Shift);
        For J:=1 To 3 Do
        Begin
          Pred.Elem:=WinNow.Elem;
          Pred:=Pred.Next;
          WinNow:=WinNow.Next;
        End;
        Pred:=Save;
        IncSpisokTwoWay(Pred, 2);
        For J:=4 To Len Do
        Begin
          New(Now);
          Now.Elem:=WinNow.Elem;
          Pred.Next:=Now;
          Now.Pred:=Pred;
          Pred:=Now;
          WinNow:=WinNow.Next;
        End;
        Now.Next:=Next;
        If Next<>Nil Then
          Next.Pred:=Now;
      End;
      Now:=Now.Next;
    End;

    Now:=WinFin.Next;
    Buff:=1;
    While Now<>Nil Do
    Begin
      Inc(Buff);
      Now:=Now.Next;
    End;

    If Buff>SBuff Then
    Begin
      For I:=1 To Buff-SBuff Do
      Begin
        BlockWrite(FOut, BuffFin.Elem, 1);
        Next:=BuffFin;
        BuffFin:=BuffFin.Pred;
        BuffFin.Next:=Nil;
        Dispose(Next);
      End;
      BuffFin.Next:=Nil;
    End
  Until FSize=-1+(Len+1);

  While BuffFin<>Nil Do
  Begin
    BlockWrite(FOut, BuffFin.Elem, 1);
    Save:=BuffFin;
    BuffFin:=BuffFin.Pred;
    Dispose(Save);
  End;
End;

End.

