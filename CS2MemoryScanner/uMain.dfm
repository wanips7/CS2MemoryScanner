object Form1: TForm1
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'CS2MemoryScanner'
  ClientHeight = 451
  ClientWidth = 801
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 120
  TextHeight = 20
  object Label6: TLabel
    Left = 9
    Top = 7
    Width = 28
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Log:'
  end
  object Label7: TLabel
    Left = 489
    Top = 9
    Width = 80
    Height = 20
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Search type:'
  end
  object Button1: TButton
    Left = 705
    Top = 239
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Search'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Memo1: TMemo
    Left = 9
    Top = 37
    Width = 472
    Height = 364
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ScrollBars = ssVertical
    TabOrder = 1
  end
  object Button2: TButton
    Left = 387
    Top = 409
    Width = 94
    Height = 31
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    Caption = 'Clear'
    TabOrder = 2
    OnClick = Button2Click
  end
  object PageControl1: TPageControl
    Left = 489
    Top = 37
    Width = 310
    Height = 194
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 4
    ActivePage = TabSheet4
    MultiLine = True
    TabOrder = 3
    object TabSheet1: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Vector3'
      object Label2: TLabel
        Left = 20
        Top = 4
        Width = 9
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'X'
      end
      object Label3: TLabel
        Left = 20
        Top = 40
        Width = 8
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Y'
      end
      object Label4: TLabel
        Left = 20
        Top = 76
        Width = 9
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Z'
      end
      object NumberBox1: TNumberBox
        Left = 37
        Top = 4
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Mode = nbmFloat
        TabOrder = 0
        SpinButtonOptions.ButtonWidth = 21
      end
      object NumberBox2: TNumberBox
        Left = 36
        Top = 40
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Mode = nbmFloat
        TabOrder = 1
        SpinButtonOptions.ButtonWidth = 21
      end
      object NumberBox3: TNumberBox
        Left = 37
        Top = 76
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Mode = nbmFloat
        TabOrder = 2
        SpinButtonOptions.ButtonWidth = 21
      end
    end
    object TabSheet2: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Vector2'
      ImageIndex = 1
      object Label1: TLabel
        Left = 20
        Top = 4
        Width = 9
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'X'
      end
      object Label5: TLabel
        Left = 20
        Top = 43
        Width = 8
        Height = 20
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Caption = 'Y'
      end
      object NumberBox4: TNumberBox
        Left = 37
        Top = 4
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Mode = nbmFloat
        TabOrder = 0
        SpinButtonOptions.ButtonWidth = 21
      end
      object NumberBox5: TNumberBox
        Left = 36
        Top = 40
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        Mode = nbmFloat
        TabOrder = 1
        SpinButtonOptions.ButtonWidth = 21
      end
    end
    object TabSheet3: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Float'
      ImageIndex = 2
      object NumberBox7: TNumberBox
        Left = 20
        Top = 24
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
        SpinButtonOptions.ButtonWidth = 21
      end
    end
    object TabSheet4: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Int32'
      ImageIndex = 3
      object NumberBox8: TNumberBox
        Left = 20
        Top = 24
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
        SpinButtonOptions.ButtonWidth = 21
      end
    end
    object TabSheet5: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Int64'
      ImageIndex = 4
      object NumberBox6: TNumberBox
        Left = 20
        Top = 24
        Width = 121
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
        SpinButtonOptions.ButtonWidth = 21
      end
    end
    object TabSheet6: TTabSheet
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Caption = 'Pattern'
      ImageIndex = 5
      object Edit1: TEdit
        Left = 4
        Top = 20
        Width = 287
        Height = 28
        Margins.Left = 4
        Margins.Top = 4
        Margins.Right = 4
        Margins.Bottom = 4
        TabOrder = 0
      end
    end
  end
end
