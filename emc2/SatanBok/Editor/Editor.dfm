object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 466
  ClientWidth = 608
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnPaint = FormPaint
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 464
    Top = 153
    Width = 25
    Height = 13
    Caption = 'Scale'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 450
    Height = 450
    TabOrder = 0
    OnMouseDown = Panel1MouseDown
    OnMouseEnter = Panel1MouseEnter
    OnMouseLeave = Panel1MouseLeave
    OnMouseMove = Panel1MouseMove
  end
  object Edit1: TEdit
    Left = 464
    Top = 172
    Width = 55
    Height = 21
    TabOrder = 1
    Text = '1'
  end
  object scale: TUpDown
    Left = 519
    Top = 172
    Width = 17
    Height = 21
    Min = 1
    Position = 10
    TabOrder = 2
    OnClick = scaleClick
  end
  object Button1: TButton
    Left = 462
    Top = 55
    Width = 141
    Height = 25
    Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
    TabOrder = 3
    OnClick = Button1Click
  end
  object Button2: TButton
    Left = 464
    Top = 86
    Width = 139
    Height = 25
    Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
    TabOrder = 4
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 462
    Top = 24
    Width = 141
    Height = 25
    Caption = #1053#1086#1074#1072#1103' '#1082#1072#1088#1090#1072
    TabOrder = 5
    OnClick = Button3Click
  end
  object Button4: TButton
    Left = 553
    Top = 117
    Width = 50
    Height = 25
    Caption = #1042#1099#1093#1086#1076
    TabOrder = 6
    OnClick = Button4Click
  end
  object Memo1: TMemo
    Left = 464
    Top = 248
    Width = 139
    Height = 89
    Lines.Strings = (
      #1050#1072#1082' '#1087#1086#1083#1100#1079#1086#1074#1072#1090#1100#1089#1103' '
      #1088#1077#1076#1072#1082#1090#1086#1088#1086#1084' (:'
      #1048#1090#1072#1082', '#1083#1077#1074#1086#1081' '#1084#1099#1096#1082#1086#1081' '
      #1089#1086#1079#1076#1072#1077#1084' '#1083#1080#1085#1080#1080'. '
      #1044#1091#1084#1072#1102' '#1088#1072#1079#1086#1073#1088#1072#1090#1100#1089#1103' '
      #1073#1091#1076#1077#1090' '#1085#1077' '#1090#1088#1091#1076#1085#1086'. '
      #1063#1090#1086#1073#1099' '#1079#1072#1082#1086#1085#1095#1080#1090#1100' '
      #1084#1085#1086#1075#1086#1091#1075#1086#1083#1100#1085#1080#1082','
      #1085#1072#1078#1080#1084#1072#1077#1090' '#1087#1088#1072#1074#1091#1102' '
      #1084#1099#1096#1082#1091'. '
      #1052#1085#1086#1075#1086#1091#1083#1086#1083#1100#1085#1080#1082#1080
      #1089#1083#1077#1076#1091#1077#1090' '#1089#1086#1079#1076#1072#1074#1072#1090#1100' '
      #1087#1088#1086#1090#1080#1074' '#1095#1072#1089#1086#1074#1086#1081' '
      #1089#1090#1088#1077#1083#1082#1080'.'
      #1047#1077#1083#1077#1085#1099#1077' '#1083#1080#1085#1080#1080', '
      #1080#1089#1093#1086#1076#1103#1097#1080#1077' '#1080#1079' '#1075#1088#1072#1085#1077#1081' '
      '-'
      #1101#1090#1086' '#1085#1086#1088#1084#1072#1083#1080'. '
      #1053#1086#1088#1084#1072#1083#1080' '#1076#1086#1083#1078#1085#1099' '
      #1073#1099#1090#1100' '
      #1085#1072#1087#1088#1072#1074#1083#1077#1085#1099' '#1085#1072#1088#1091#1078#1091', '
      #1077#1089#1083#1080' '#1101#1090#1086' '#1085#1077' '#1090#1072#1082', '#1090#1086
      #1084#1085#1086#1075#1086#1091#1075#1086#1083#1100#1085#1080#1082' '
      #1085#1072#1088#1080#1089#1086#1074#1072#1085' '#1087#1086' '
      #1095#1072#1089#1086#1074#1086#1081' '#1089#1090#1088#1077#1083#1082#1077'. '
      #1055#1088#1072#1074#1086#1081' '#1082#1085#1086#1087#1082#1086#1081' '
      #1084#1099#1096#1080' '#1074#1099#1079#1099#1074#1072#1077#1090#1089#1103' '
      #1082#1086#1085#1090#1077#1082#1089#1090#1085#1086#1077' '#1084#1077#1085#1102'.'
      'Scale - '#1082#1086#1077#1092#1080#1094#1080#1077#1085#1090', '
      #1085#1072' '#1082#1086#1090#1086#1088#1099#1081' '#1073#1091#1076#1091#1090' '
      #1091#1084#1085#1086#1078#1072#1090#1100#1089#1103' '
      #1082#1086#1086#1088#1076#1080#1085#1072#1090#1099' '#1074' '#1080#1075#1088#1077'. '
      #1052#1086#1078#1085#1086' '#1087#1086#1085#1080#1084#1072#1090#1100', '#1082#1072#1082' '
      '"'#1074#1086' '#1089#1082#1086#1083#1100#1082#1086' '#1088#1072#1079' '
      #1082#1072#1088#1090#1072' '#1074' '#1080#1075#1088#1077' '#1073#1086#1083#1100#1096#1077' '
      #1082#1072#1088#1090#1099' '#1074' '#1088#1077#1076#1072#1082#1090#1086#1088#1077'"'
      #1053#1080#1095#1077#1075#1086' '#1089#1083#1086#1078#1085#1086#1075#1086' (:')
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 7
  end
  object menu: TPopupMenu
    Left = 464
    Top = 8
    object N11: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1094#1077#1083#1100
      OnClick = N11Click
    end
    object N6: TMenuItem
      Caption = #1044#1086#1073#1072#1074#1080#1090#1100' '#1059#1073#1080#1081#1094#1091
      OnClick = N6Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #1047#1072#1076#1072#1090#1100' '#1089#1090#1072#1088#1090
      OnClick = N3Click
    end
    object N4: TMenuItem
      Caption = #1047#1072#1076#1072#1090#1100' '#1092#1080#1085#1080#1096
      OnClick = N4Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object N2: TMenuItem
      Caption = #1059#1076#1072#1083#1080#1090#1100' '#1074#1099#1073#1088#1072#1085#1085#1086#1077
      OnClick = N2Click
    end
  end
  object OpenDialog1: TOpenDialog
    Left = 496
    Top = 8
  end
  object SaveDialog1: TSaveDialog
    Left = 528
    Top = 8
  end
end
