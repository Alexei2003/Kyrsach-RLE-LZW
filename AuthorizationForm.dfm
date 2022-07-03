object AForm: TAForm
  Left = 994
  Top = 212
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'AForm'
  ClientHeight = 188
  ClientWidth = 168
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 106
  TextHeight = 13
  object txtLogin: TStaticText
    Left = 24
    Top = 16
    Width = 52
    Height = 29
    Caption = 'Login'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
  end
  object txtPassword: TStaticText
    Left = 24
    Top = 72
    Width = 90
    Height = 29
    Caption = 'Password'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -21
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
  end
  object btnInput: TBitBtn
    Left = 24
    Top = 144
    Width = 121
    Height = 25
    Action = actInp
    Caption = 'Input'
    TabOrder = 2
  end
  object edtLogin: TEdit
    Left = 24
    Top = 48
    Width = 121
    Height = 21
    TabOrder = 3
  end
  object edtPassword: TEdit
    Left = 24
    Top = 104
    Width = 121
    Height = 21
    TabOrder = 4
  end
  object actlstAForm: TActionList
    object actInp: TAction
      Caption = #1042#1093#1086#1076
      OnExecute = actInpExecute
    end
  end
end
