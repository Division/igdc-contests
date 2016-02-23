object Form3: TForm3
  Left = 0
  Top = 0
  Caption = 'Editor'
  ClientHeight = 584
  ClientWidth = 784
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  Menu = MainMenu1
  OldCreateOrder = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnMouseWheelDown = FormMouseWheelDown
  OnMouseWheelUp = FormMouseWheelUp
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 512
    Height = 584
    Align = alClient
    TabOrder = 0
    OnClick = Panel1Click
    OnMouseDown = Panel1MouseDown
    OnMouseMove = Panel1MouseMove
    OnMouseUp = Panel1MouseUp
  end
  object Panel2: TPanel
    Left = 512
    Top = 0
    Width = 272
    Height = 584
    Align = alRight
    TabOrder = 1
    object Label5: TLabel
      Left = 6
      Top = 318
      Width = 98
      Height = 13
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086' '#1082#1088#1091#1075#1086#1074
    end
    object Panel3: TPanel
      Left = 6
      Top = 0
      Width = 257
      Height = 281
      TabOrder = 0
      object Label1: TLabel
        Left = 16
        Top = 8
        Width = 16
        Height = 13
        Caption = '0:0'
      end
      object Label2: TLabel
        Left = 24
        Top = 104
        Width = 75
        Height = 13
        Caption = #1063#1072#1089#1090#1086#1090#1072' '#1090#1086#1095#1077#1082
      end
      object Label3: TLabel
        Left = 24
        Top = 199
        Width = 188
        Height = 13
        Caption = #1059#1075#1086#1083' '#1087#1086#1074#1086#1088#1086#1090#1072' '#1074#1099#1073#1088#1072#1085#1085#1099#1093' '#1086#1073#1098#1077#1082#1090#1086#1074
      end
      object Label4: TLabel
        Left = 24
        Top = 151
        Width = 84
        Height = 13
        Caption = #1058#1086#1083#1097#1080#1085#1072' '#1076#1086#1088#1086#1075#1080
      end
      object RadioButton1: TRadioButton
        Left = 16
        Top = 27
        Width = 169
        Height = 17
        Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1087#1091#1090#1100
        Checked = True
        TabOrder = 0
        TabStop = True
        OnClick = RadioButton1Click
      end
      object RadioButton2: TRadioButton
        Left = 16
        Top = 50
        Width = 169
        Height = 17
        Caption = #1056#1077#1076#1072#1082#1090#1080#1088#1086#1074#1072#1090#1100' '#1086#1073#1098#1077#1082#1090#1099
        TabOrder = 1
        OnClick = RadioButton2Click
      end
      object Button1: TButton
        Left = 119
        Top = 73
        Width = 57
        Height = 25
        Caption = #1059#1076#1072#1083#1080#1090#1100
        TabOrder = 2
        OnClick = Button1Click
      end
      object Button3: TButton
        Left = 15
        Top = 73
        Width = 57
        Height = 25
        Caption = #1055#1086#1074#1086#1088#1086#1090
        TabOrder = 3
        OnClick = Button3Click
      end
      object Edit1: TEdit
        Left = 8
        Top = 120
        Width = 49
        Height = 21
        ReadOnly = True
        TabOrder = 4
        Text = '10'
      end
      object TrackBar1: TTrackBar
        Left = 63
        Top = 120
        Width = 186
        Height = 26
        Max = 50
        Min = 5
        Position = 10
        TabOrder = 5
        TabStop = False
        OnChange = TrackBar1Change
      end
      object cbsel: TCheckBox
        Left = 8
        Top = 254
        Width = 113
        Height = 17
        Caption = #1042#1099#1073#1086#1088' '#1086#1073#1098#1077#1082#1090#1086#1074
        TabOrder = 6
      end
      object TrackBar2: TTrackBar
        Left = 64
        Top = 218
        Width = 185
        Height = 30
        Max = 360
        Frequency = 10
        TabOrder = 7
        TabStop = False
        OnChange = TrackBar2Change
      end
      object Edit2: TEdit
        Left = 9
        Top = 218
        Width = 49
        Height = 21
        ReadOnly = True
        TabOrder = 8
        Text = '0'
      end
      object TrackBar3: TTrackBar
        Left = 64
        Top = 170
        Width = 185
        Height = 30
        Max = 500
        Min = 75
        PageSize = 1
        Frequency = 10
        Position = 150
        TabOrder = 9
        TabStop = False
        OnChange = TrackBar3Change
      end
      object Edit3: TEdit
        Left = 9
        Top = 170
        Width = 49
        Height = 21
        ReadOnly = True
        TabOrder = 10
        Text = '150'
      end
      object Button5: TButton
        Left = 127
        Top = 250
        Width = 90
        Height = 25
        Caption = #1055#1077#1088#1077#1084#1077#1089#1090#1080#1090#1100
        TabOrder = 11
        OnClick = Button5Click
      end
      object wire: TCheckBox
        Left = 191
        Top = 7
        Width = 58
        Height = 17
        Caption = #1057#1077#1090#1082#1072
        TabOrder = 12
      end
    end
    object Button2: TButton
      Left = 87
      Top = 287
      Width = 75
      Height = 25
      Caption = #1042' '#1085#1072#1095#1072#1083#1086
      TabOrder = 1
      OnClick = Button2Click
    end
    object lb1: TListBox
      Left = 6
      Top = 364
      Width = 145
      Height = 220
      ItemHeight = 13
      Items.Strings = (
        #1080#1079#1084#1077#1088#1080#1090#1077#1083#1100
        #1095#1072#1096#1082#1072
        #1095#1072#1089#1099'-'#1082#1072#1083#1077#1085#1076#1072#1088#1100
        #1090#1077#1083#1077#1092#1086#1085
        #1089#1090#1077#1087#1083#1077#1088
        #1089#1082#1088#1077#1087#1082#1072' '#1089#1090#1077#1087#1083#1077#1088#1072
        #1089#1082#1088#1077#1087#1082#1072
        #1089#1080#1075#1072#1088#1077#1090#1072
        #1088#1091#1095#1082#1072
        #1087#1086#1076#1089#1090#1072#1074#1082#1072
        #1087#1072#1095#1082#1072' '#1089#1080#1075#1072#1088#1077#1090
        #1087#1072#1087#1082#1072
        #1085#1086#1078#1085#1080#1094#1099
        #1084#1086#1085#1080#1090#1086#1088
        #1083#1080#1085#1077#1081#1082#1072
        #1083#1072#1089#1090#1080#1082
        #1082#1085#1080#1075#1072
        #1076#1080#1089#1082
        #1073#1091#1084#1072#1075#1072
        #1087#1086#1084#1103#1090#1072#1103' '#1073#1091#1084#1072#1075#1072
        #1082#1091#1073#1080#1082' '#1088#1091#1073#1080#1082#1072
        #1084#1072#1096#1080#1085#1082#1072)
      TabOrder = 2
    end
    object Button4: TButton
      Left = 6
      Top = 287
      Width = 75
      Height = 25
      Caption = #1052#1072#1089#1096#1090#1072#1073' '#1074' 1'
      TabOrder = 3
      OnClick = Button4Click
    end
    object Edit4: TEdit
      Left = 6
      Top = 337
      Width = 67
      Height = 21
      TabOrder = 4
      Text = '3'
    end
    object laps: TUpDown
      Left = 73
      Top = 337
      Width = 16
      Height = 21
      Associate = Edit4
      Min = 1
      Max = 10
      Position = 3
      TabOrder = 5
    end
  end
  object Timer1: TTimer
    Interval = 50
    OnTimer = Timer1Timer
    Left = 736
    Top = 416
  end
  object MainMenu1: TMainMenu
    Left = 704
    Top = 416
    object N1: TMenuItem
      Caption = #1060#1072#1081#1083
      object N2: TMenuItem
        Caption = #1057#1086#1079#1076#1072#1090#1100
        OnClick = N2Click
      end
      object N3: TMenuItem
        Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
        OnClick = N3Click
      end
      object N4: TMenuItem
        Caption = #1047#1072#1075#1088#1091#1079#1080#1090#1100
        OnClick = N4Click
      end
      object N6: TMenuItem
        Caption = '-'
      end
      object N5: TMenuItem
        Caption = #1042#1099#1081#1090#1080
      end
    end
    object N7: TMenuItem
      Caption = #1057#1087#1088#1072#1074#1082#1072
      object N8: TMenuItem
        Caption = #1054' '#1087#1088#1086#1075#1088#1072#1084#1084#1077
      end
    end
  end
  object SaveDialog1: TSaveDialog
    Filter = '*.map|*.map'
    InitialDir = '..\release\data\maps'
    Left = 768
    Top = 416
  end
  object OpenDialog1: TOpenDialog
    Filter = '*.map|*.map'
    InitialDir = '..\release'
    Left = 672
    Top = 416
  end
end
