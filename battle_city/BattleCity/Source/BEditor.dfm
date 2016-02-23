object Form2: TForm2
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'BattleCity Map Editor'
  ClientHeight = 421
  ClientWidth = 649
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = MainMenu1
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 512
    Height = 384
    BevelOuter = bvNone
    TabOrder = 0
    OnMouseDown = Panel1MouseDown
    OnMouseMove = Panel1MouseMove
    OnMouseUp = Panel1MouseUp
  end
  object RadioButton1: TRadioButton
    Left = 521
    Top = 32
    Width = 113
    Height = 17
    Caption = 'SinglePlayer'
    Checked = True
    TabOrder = 1
    TabStop = True
    OnClick = RadioButton1Click
  end
  object RadioButton2: TRadioButton
    Left = 521
    Top = 55
    Width = 113
    Height = 17
    Caption = 'Multyplayer'
    TabOrder = 2
    OnClick = RadioButton2Click
  end
  object ComboBox1: TComboBox
    Left = 521
    Top = 77
    Width = 116
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      'SIMPLE1 =0 ;'
      'SIMPLE2 = 1;'
      'WATER = 2;'
      'WEB1=3;'
      'WEB2=4;'
      'STRONG1=5;'
      'STRONG2=6;'
      'EAGLE1 = 7;'
      'EAGLE2 = 8;'
      'COMST= 9'
      'P1ST = 10;'
      'P2ST = 11')
  end
  object Panel2: TPanel
    Left = 521
    Top = 104
    Width = 113
    Height = 33
    Caption = #1056#1072#1079#1084#1077#1088' '#1103#1095#1077#1077#1082
    TabOrder = 4
    OnClick = Panel2Click
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 616
    Top = 368
  end
  object SaveDialog1: TSaveDialog
    DefaultExt = 'map'
    Title = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1088#1090#1091
    Left = 584
  end
  object MainMenu1: TMainMenu
    Left = 616
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N7: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100
        OnClick = N7Click
      end
      object N2: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        ShortCut = 16467
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
        ShortCut = 16463
        OnClick = N3Click
      end
      object N8: TMenuItem
        Caption = '-'
      end
      object N4: TMenuItem
        Caption = #1042#1099#1093#1086#1076
        ShortCut = 16472
        OnClick = N4Click
      end
    end
    object N5: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object N6: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      end
    end
  end
  object OpenDialog1: TOpenDialog
    DefaultExt = 'map'
    Left = 552
  end
end
