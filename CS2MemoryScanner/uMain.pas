{

  A program for searching values in game memory (Counter-Strike 2).

  https://github.com/wanips7/CS2MemoryScanner

}

unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox, uMemoryScanner,
  Vcl.ComCtrls;

const
  APP_VERSION = '0.1';

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Button2: TButton;
    NumberBox1: TNumberBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    NumberBox2: TNumberBox;
    NumberBox3: TNumberBox;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    Label1: TLabel;
    Label5: TLabel;
    NumberBox4: TNumberBox;
    NumberBox5: TNumberBox;
    NumberBox6: TNumberBox;
    Edit1: TEdit;
    NumberBox7: TNumberBox;
    NumberBox8: TNumberBox;
    Label6: TLabel;
    Label7: TLabel;
    procedure MemoryScannerErrorHandler(Sender: TObject; const E: Exception);
    procedure OffsetFoundHandler(Sender: TObject; const N, Offset: NativeUInt);
    procedure MemoryScannerStartHandler(Sender: TObject);
    procedure MemoryScannerFinishHandler(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    FMemoryScanner: TMemoryScanner;
    procedure ClearLog;
    procedure Log(const Text: string);
    procedure FillSearchData(var Value: TSearchData);
  public

  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  WindowHandle: HWND;
  PID: Cardinal;
  SearchData: TSearchData;
begin
  if FMemoryScanner.IsRunning then
    Exit;

  ClearLog;

  FillSearchData(SearchData);

  WindowHandle := FindWindow(PChar('SDL_app'), PChar('Counter-Strike 2'));

  if not IsWindow(WindowHandle) then
  begin
    MessageBox(Self.Handle, PChar('Game window is not found.'), PChar('Error'), MB_ICONERROR);
    Exit;
  end;

  if GetWindowThreadProcessId(WindowHandle, PID) = 0 then
  begin
    MessageBox(Self.Handle, PChar('PID find error.'), PChar('Error'), MB_ICONERROR);
    Exit;
  end;

  FMemoryScanner.StartSearch(PID, SearchData);

end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  ClearLog;
end;

procedure TForm1.ClearLog;
begin
  Memo1.Lines.Clear;
end;

procedure TForm1.FillSearchData(var Value: TSearchData);
const
  PAGE_INDEX_VECTOR3 = 0;
  PAGE_INDEX_VECTOR2 = 1;
  PAGE_INDEX_FLOAT = 2;
  PAGE_INDEX_INT32 = 3;
  PAGE_INDEX_INT64 = 4;
  PAGE_INDEX_PATTERN = 5;
begin
  case PageControl1.ActivePageIndex of
    PAGE_INDEX_VECTOR3:
      begin
        Value.SearchType := uMemoryScanner.TSearchType.Vector3;
        Value.Vector3.X := NumberBox1.Value;
        Value.Vector3.Y := NumberBox2.Value;
        Value.Vector3.Z := NumberBox3.Value;
      end;

    PAGE_INDEX_VECTOR2:
      begin
        Value.SearchType := uMemoryScanner.TSearchType.Vector2;
        Value.Vector2.X := NumberBox4.Value;
        Value.Vector2.Y := NumberBox5.Value;
      end;

    PAGE_INDEX_FLOAT:
      begin
        Value.SearchType := uMemoryScanner.TSearchType.Float;
        Value.Float := NumberBox7.Value;
      end;

    PAGE_INDEX_INT32:
      begin
        Value.SearchType := uMemoryScanner.TSearchType.Int32;
        Value.Int32 := NumberBox8.ValueInt;
      end;

    PAGE_INDEX_INT64:
      begin
        Value.SearchType := uMemoryScanner.TSearchType.Int64;
        Value.Int64 := NumberBox6.ValueInt;
      end;

    PAGE_INDEX_PATTERN:
      begin
        Value.SearchType := uMemoryScanner.TSearchType.Pattern;
        Value.Pattern := Edit1.Text;

        if Edit1.Text = '' then
          raise Exception.Create('Pattern is empty.');
      end;

    else
      raise Exception.Create('Unknown page.');
  end;

end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Caption := 'CS2MemoryScanner' + ' v' + APP_VERSION;

  FMemoryScanner := TMemoryScanner.Create;
  FMemoryScanner.OnOffsetFound := OffsetFoundHandler;
  FMemoryScanner.OnStart := MemoryScannerStartHandler;
  FMemoryScanner.OnFinish := MemoryScannerFinishHandler;
  FMemoryScanner.OnError := MemoryScannerErrorHandler;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FMemoryScanner.Free;
end;

procedure TForm1.Log(const Text: string);
begin
  TThread.Synchronize(TThread.Current,
    procedure ()
    begin
      Memo1.Lines.Add(Text);
    end);
end;

procedure TForm1.MemoryScannerErrorHandler(Sender: TObject; const E: Exception);
begin
  Log('Error: ' + E.Message);
end;

procedure TForm1.MemoryScannerFinishHandler(Sender: TObject);
begin
  Log('Finished. Time elapsed: ' + FMemoryScanner.GetTimeElapsed.ToString);
end;

procedure TForm1.OffsetFoundHandler(Sender: TObject; const N, Offset: NativeUInt);
begin
  Log(Format('%d. A new match has been found. Offset: 0x%s', [N, Offset.ToHexString]));
end;

procedure TForm1.MemoryScannerStartHandler(Sender: TObject);
begin
  Log('Started.');
end;

end.
