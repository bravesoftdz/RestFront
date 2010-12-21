object DeleteOrderLine: TDeleteOrderLine
  Left = 349
  Top = 213
  BorderIcons = []
  BorderStyle = bsSingle
  Caption = #1042#1099#1073#1086#1088' '#1087#1088#1080#1095#1080#1085#1099' '#1091#1076#1072#1083#1077#1085#1080#1103
  ClientHeight = 320
  ClientWidth = 469
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TAdvPanel
    Left = 0
    Top = 0
    Width = 469
    Height = 47
    Align = alTop
    BevelOuter = bvNone
    Color = 16640730
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
    FullHeight = 41
    object Label1: TLabel
      Left = 15
      Top = 8
      Width = 141
      Height = 31
      Caption = #1050#1086#1083#1080#1095#1077#1089#1090#1074#1086':'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object lblQuantity: TLabel
      Left = 167
      Top = 8
      Width = 98
      Height = 31
      Alignment = taCenter
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -27
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
    end
    object btnAddQuantity: TAdvSmoothButton
      Left = 288
      Top = 2
      Width = 73
      Height = 42
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
      ParentFont = False
      TabOrder = 0
      Version = '1.6.9.0'
      OnClick = btnAddQuantityClick
    end
    object btnRemoveQuantity: TAdvSmoothButton
      Left = 376
      Top = 2
      Width = 73
      Height = 42
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
      ParentFont = False
      TabOrder = 1
      Version = '1.6.9.0'
      OnClick = btnRemoveQuantityClick
    end
  end
  object pnlBottom: TAdvPanel
    Left = 0
    Top = 272
    Width = 469
    Height = 48
    Align = alBottom
    BevelOuter = bvNone
    Color = 16640730
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
    FullHeight = 48
    object btnOK: TAdvSmoothButton
      Left = 8
      Top = 4
      Width = 186
      Height = 40
      Action = actOK
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
      ParentFont = False
      TabOrder = 0
      Version = '1.6.9.0'
    end
    object btnCancel: TAdvSmoothButton
      Left = 276
      Top = 4
      Width = 186
      Height = 40
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
      Caption = #1054#1090#1084#1077#1085#1072
      Color = 15195349
      ParentFont = False
      TabOrder = 1
      Version = '1.6.9.0'
      OnClick = btnCancelClick
    end
  end
  object pnlMain: TAdvPanel
    Left = 0
    Top = 47
    Width = 469
    Height = 225
    Align = alClient
    BevelOuter = bvNone
    Color = 16640730
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
    FullHeight = 231
  end
  object ActionList1: TActionList
    Left = 64
    Top = 113
    object actOK: TAction
      Caption = 'OK'
      OnExecute = actOKExecute
      OnUpdate = actOKUpdate
    end
  end
end
