object rfNoCashGroup: TrfNoCashGroup
  Left = 0
  Top = 0
  Caption = #1042#1080#1076#1099' '#1086#1087#1083#1072#1090
  ClientHeight = 517
  ClientWidth = 421
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBottom: TAdvPanel
    Left = 0
    Top = 464
    Width = 421
    Height = 53
    Align = alBottom
    BevelOuter = bvNone
    Color = 16640730
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 0
    UseDockManager = True
    Version = '2.0.1.0'
    BorderColor = clGray
    Caption.Color = 14059353
    Caption.ColorTo = 9648131
    Caption.Font.Charset = DEFAULT_CHARSET
    Caption.Font.Color = clWhite
    Caption.Font.Height = -11
    Caption.Font.Name = 'MS Sans Serif'
    Caption.Font.Style = []
    Caption.GradientDirection = gdVertical
    Caption.Indent = 2
    Caption.ShadeLight = 255
    CollapsColor = clNone
    CollapsDelay = 0
    ColorTo = 14986888
    ShadowColor = clBlack
    ShadowOffset = 0
    StatusBar.BorderColor = clNone
    StatusBar.BorderStyle = bsSingle
    StatusBar.Font.Charset = DEFAULT_CHARSET
    StatusBar.Font.Color = clWhite
    StatusBar.Font.Height = -11
    StatusBar.Font.Name = 'Tahoma'
    StatusBar.Font.Style = []
    StatusBar.Color = 14716773
    StatusBar.ColorTo = 16374724
    StatusBar.GradientDirection = gdVertical
    Styler = FrontData.FrontPanelStyler
    FullHeight = 0
    object btnExit: TAdvSmoothButton
      Left = 54
      Top = 6
      Width = 296
      Height = 40
      Hint = #1042#1099#1093#1086#1076
      Appearance.Font.Charset = DEFAULT_CHARSET
      Appearance.Font.Color = clWindowText
      Appearance.Font.Height = -19
      Appearance.Font.Name = 'Times New Roman'
      Appearance.Font.Style = [fsBold]
      Status.Caption = '0'
      Status.Appearance.Fill.Color = clRed
      Status.Appearance.Fill.ColorMirror = clNone
      Status.Appearance.Fill.ColorMirrorTo = clNone
      Status.Appearance.Fill.GradientType = gtSolid
      Status.Appearance.Fill.BorderColor = clGray
      Status.Appearance.Fill.Rounding = 0
      Status.Appearance.Fill.ShadowOffset = 0
      Status.Appearance.Font.Charset = DEFAULT_CHARSET
      Status.Appearance.Font.Color = clWhite
      Status.Appearance.Font.Height = -11
      Status.Appearance.Font.Name = 'Tahoma'
      Status.Appearance.Font.Style = []
      Bevel = False
      Caption = #1042#1099#1093#1086#1076
      Color = 15195349
      DisabledColor = clBlack
      ParentFont = False
      TabOrder = 0
      Version = '1.6.9.0'
      ModalResult = 2
    end
  end
  object pnlRight: TAdvPanel
    Left = 328
    Top = 0
    Width = 93
    Height = 464
    Align = alRight
    BevelOuter = bvNone
    Color = 16640730
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    UseDockManager = True
    Version = '2.0.1.0'
    BorderColor = clGray
    Caption.Color = 14059353
    Caption.ColorTo = 9648131
    Caption.Font.Charset = DEFAULT_CHARSET
    Caption.Font.Color = clWhite
    Caption.Font.Height = -11
    Caption.Font.Name = 'MS Sans Serif'
    Caption.Font.Style = []
    Caption.GradientDirection = gdVertical
    Caption.Indent = 2
    Caption.ShadeLight = 255
    CollapsColor = clNone
    CollapsDelay = 0
    ColorTo = 14986888
    ShadowColor = clBlack
    ShadowOffset = 0
    StatusBar.BorderColor = clNone
    StatusBar.BorderStyle = bsSingle
    StatusBar.Font.Charset = DEFAULT_CHARSET
    StatusBar.Font.Color = clWhite
    StatusBar.Font.Height = -11
    StatusBar.Font.Name = 'Tahoma'
    StatusBar.Font.Style = []
    StatusBar.Color = 14716773
    StatusBar.ColorTo = 16374724
    StatusBar.GradientDirection = gdVertical
    Styler = FrontData.FrontPanelStyler
    FullHeight = 0
    object btnScrollDown: TAdvSmoothButton
      Left = 7
      Top = 61
      Width = 82
      Height = 47
      Action = actGroupDown
      Appearance.PictureAlignment = taCenter
      Appearance.Font.Charset = DEFAULT_CHARSET
      Appearance.Font.Color = clWindowText
      Appearance.Font.Height = -19
      Appearance.Font.Name = 'Times New Roman'
      Appearance.Font.Style = [fsBold]
      Status.Caption = '0'
      Status.Appearance.Fill.Color = clRed
      Status.Appearance.Fill.ColorMirror = clNone
      Status.Appearance.Fill.ColorMirrorTo = clNone
      Status.Appearance.Fill.GradientType = gtSolid
      Status.Appearance.Fill.BorderColor = clGray
      Status.Appearance.Fill.Rounding = 0
      Status.Appearance.Fill.ShadowOffset = 0
      Status.Appearance.Font.Charset = DEFAULT_CHARSET
      Status.Appearance.Font.Color = clWhite
      Status.Appearance.Font.Height = -11
      Status.Appearance.Font.Name = 'Tahoma'
      Status.Appearance.Font.Style = []
      Bevel = False
      Color = 15195349
      DisabledColor = clBlack
      ParentFont = False
      TabOrder = 0
      Version = '1.6.9.0'
    end
    object btnScrollUp: TAdvSmoothButton
      Left = 7
      Top = 8
      Width = 82
      Height = 47
      Action = actGroupUp
      Appearance.PictureAlignment = taCenter
      Appearance.Font.Charset = DEFAULT_CHARSET
      Appearance.Font.Color = clWindowText
      Appearance.Font.Height = -19
      Appearance.Font.Name = 'Times New Roman'
      Appearance.Font.Style = [fsBold]
      Status.Caption = '0'
      Status.Appearance.Fill.Color = clRed
      Status.Appearance.Fill.ColorMirror = clNone
      Status.Appearance.Fill.ColorMirrorTo = clNone
      Status.Appearance.Fill.GradientType = gtSolid
      Status.Appearance.Fill.BorderColor = clGray
      Status.Appearance.Fill.Rounding = 0
      Status.Appearance.Fill.ShadowOffset = 0
      Status.Appearance.Font.Charset = DEFAULT_CHARSET
      Status.Appearance.Font.Color = clWhite
      Status.Appearance.Font.Height = -11
      Status.Appearance.Font.Name = 'Tahoma'
      Status.Appearance.Font.Style = []
      Bevel = False
      Color = 15195349
      DisabledColor = clBlack
      ParentFont = False
      TabOrder = 1
      Version = '1.6.9.0'
    end
  end
  object pnlMain: TAdvPanel
    Left = 0
    Top = 0
    Width = 328
    Height = 464
    Align = alClient
    BevelOuter = bvNone
    Color = 16640730
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 2
    UseDockManager = True
    Version = '2.0.1.0'
    BorderColor = clGray
    Caption.Color = 14059353
    Caption.ColorTo = 9648131
    Caption.Font.Charset = DEFAULT_CHARSET
    Caption.Font.Color = clWhite
    Caption.Font.Height = -11
    Caption.Font.Name = 'MS Sans Serif'
    Caption.Font.Style = []
    Caption.GradientDirection = gdVertical
    Caption.Indent = 2
    Caption.ShadeLight = 255
    CollapsColor = clNone
    CollapsDelay = 0
    ColorTo = 14986888
    ShadowColor = clBlack
    ShadowOffset = 0
    StatusBar.BorderColor = clNone
    StatusBar.BorderStyle = bsSingle
    StatusBar.Font.Charset = DEFAULT_CHARSET
    StatusBar.Font.Color = clWhite
    StatusBar.Font.Height = -11
    StatusBar.Font.Name = 'Tahoma'
    StatusBar.Font.Style = []
    StatusBar.Color = 14716773
    StatusBar.ColorTo = 16374724
    StatusBar.GradientDirection = gdVertical
    Styler = FrontData.FrontPanelStyler
    FullHeight = 0
  end
  object aclPayGroup: TActionList
    Left = 200
    Top = 128
    object actGroupUp: TAction
      OnExecute = actGroupUpExecute
      OnUpdate = actGroupUpUpdate
    end
    object actGroupDown: TAction
      OnExecute = actGroupDownExecute
      OnUpdate = actGroupDownUpdate
    end
  end
end
