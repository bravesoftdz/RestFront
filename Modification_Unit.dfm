object ModificationForm: TModificationForm
  Left = 343
  Top = 193
  ActiveControl = btnOK
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = #1052#1086#1076#1080#1092#1080#1082#1072#1090#1086#1088#1099
  ClientHeight = 473
  ClientWidth = 654
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCloseQuery = FormCloseQuery
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TAdvPanel
    Left = 0
    Top = 0
    Width = 654
    Height = 80
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
    object lbExtraModificator: TLabel
      Left = 0
      Top = 40
      Width = 654
      Height = 40
      Align = alBottom
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      Transparent = False
      Layout = tlCenter
      WordWrap = True
      ExplicitTop = 0
    end
    object lbCaption: TLabel
      Left = 0
      Top = 0
      Width = 654
      Height = 40
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = #1052#1086#1076#1080#1092#1080#1082#1072#1090#1086#1088#1099
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -19
      Font.Name = 'Times New Roman'
      Font.Style = []
      ParentFont = False
      Transparent = False
      Layout = tlCenter
      WordWrap = True
    end
  end
  object plnRight: TAdvPanel
    Left = 493
    Top = 80
    Width = 161
    Height = 393
    Align = alRight
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
    FullHeight = 432
    object btnOK: TAdvSmoothButton
      Left = 17
      Top = 285
      Width = 137
      Height = 47
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
      DisabledColor = clBlack
      ParentFont = False
      TabOrder = 0
      Version = '1.6.9.0'
    end
    object btnCancel: TAdvSmoothButton
      Left = 17
      Top = 338
      Width = 137
      Height = 47
      Action = actCancel
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
    object btnInputMod: TAdvSmoothButton
      Left = 16
      Top = 6
      Width = 137
      Height = 47
      Appearance.Font.Charset = DEFAULT_CHARSET
      Appearance.Font.Color = clWindowText
      Appearance.Font.Height = -13
      Appearance.Font.Name = 'Times New Roman'
      Appearance.Font.Style = []
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
      Caption = #1042#1074#1077#1089#1090#1080' '#1084#1086#1076#1080#1092#1080#1082#1072#1090#1086#1088
      Color = 15195349
      DisabledColor = clBlack
      ParentFont = False
      TabOrder = 2
      Version = '1.6.9.0'
      OnClick = btnInputModClick
    end
    object btnScrollUp: TAdvSmoothButton
      Left = 17
      Top = 169
      Width = 137
      Height = 47
      Action = actGoodUp
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
      TabOrder = 3
      Version = '1.6.9.0'
    end
    object btnScrollDown: TAdvSmoothButton
      Left = 17
      Top = 222
      Width = 137
      Height = 47
      Action = actGoodDown
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
      TabOrder = 4
      Version = '1.6.9.0'
    end
  end
  object pnlMain: TAdvPanel
    Left = 0
    Top = 80
    Width = 493
    Height = 393
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
    Touch.GestureManager = gmModficator
    FullHeight = 432
  end
  object aclModify: TActionList
    Left = 320
    Top = 240
    object actOK: TAction
      Caption = 'OK'
      OnExecute = actOKExecute
      OnUpdate = actOKUpdate
    end
    object actCancel: TAction
      Caption = #1054#1090#1084#1077#1085#1072
      OnExecute = actCancelExecute
      OnUpdate = actCancelUpdate
    end
    object actGoodUp: TAction
      OnExecute = actGoodUpExecute
      OnUpdate = actGoodUpUpdate
    end
    object actGoodDown: TAction
      OnExecute = actGoodDownExecute
      OnUpdate = actGoodDownUpdate
    end
  end
  object gmModficator: TGestureManager
    Left = 208
    Top = 104
    GestureData = <
      item
        Control = pnlMain
        Collection = <
          item
            Action = actGoodUp
            GestureID = sgiUp
          end
          item
            Action = actGoodDown
            GestureID = sgiDown
          end>
      end>
  end
end
