object HForm: THForm
  Left = 1251
  Top = 268
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Help'
  ClientHeight = 574
  ClientWidth = 446
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 106
  TextHeight = 13
  object mmoHelp: TMemo
    Left = 8
    Top = 8
    Width = 425
    Height = 553
    Enabled = False
    Lines.Strings = (
      'mmoHelp')
    TabOrder = 0
  end
end
