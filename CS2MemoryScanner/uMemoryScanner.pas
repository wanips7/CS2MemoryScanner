{

  A program for searching values in game memory (Counter-Strike 2).

  https://github.com/wanips7/CS2MemoryScanner

}

unit uMemoryScanner;

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows, System.SysUtils, System.Classes, System.Generics.Collections,
  System.Threading, System.Diagnostics, System.TimeSpan, uTypes;

type
  TSearchType = (Vector3, Vector2, Float, Int32, Int64, Pattern);

type
  TOnOffsetFoundEvent = procedure(Sender: TObject; const N, Offset: NativeUInt) of object;
  TOnErrorEvent = procedure(Sender: TObject; const E: Exception) of object;

type
  TPatternArray = TArray<PByte>;

type
  TSearchData = record
    SearchType: TSearchType;
    case Integer of
      1: (Vector3: TVector3);
      2: (Vector2: TVector2);
      3: (Float: Single);
      4: (Int32: Integer);
      5: (Int64: Int64);
      6: (Pattern: string[128]);
  end;

type
  TSearchAddress = record
    ProcessHandle: THandle;
    Base: Pointer;
    Size: NativeUInt;
  end;

type
  EMemoryScannerError = class(Exception);

type
  TMemoryScanner = class
  public const
    CLIENT_DLL = 'client.dll';

  strict private
    FOnError: TOnErrorEvent;
    FOnStart: TNotifyEvent;
    FOnFinish: TNotifyEvent;
    FOnOffsetFound: TOnOffsetFoundEvent;
    FTask: ITask;
    FCompareMargin: Single;
    FWatch: TStopwatch;
    FSearchLimit: Cardinal;
    function IsValidVector2(const Value: TVector2): Boolean; inline;
    function IsValidVector3(const Value: TVector3): Boolean; inline;
    function SameVector2(const Value1, Value2: TVector2): Boolean; inline;
    function SameVector3(const Value1, Value2: TVector3): Boolean; inline;
    procedure Search(const SearchAddress: TSearchAddress; const Sample: TVector2); overload;
    procedure Search(const SearchAddress: TSearchAddress; const Sample: TVector3); overload;
    procedure Search(const SearchAddress: TSearchAddress; const Sample: Single); overload;
    procedure Search(const SearchAddress: TSearchAddress; const Sample: Integer); overload;
    procedure Search(const SearchAddress: TSearchAddress; const Sample: Int64); overload;
    procedure Search(const SearchAddress: TSearchAddress; const Pattern: string); overload;
    function ParsePattern(const Value: string): TPatternArray;
    procedure DoError(const E: Exception);
    procedure DoStart;
    procedure DoFinish;
    procedure DoOffsetFound(const N, Offset: NativeUInt);
  public
    property OnError: TOnErrorEvent read FOnError write FOnError;
    property OnStart: TNotifyEvent read FOnStart write FOnStart;
    property OnFinish: TNotifyEvent read FOnFinish write FOnFinish;
    property OnOffsetFound: TOnOffsetFoundEvent read FOnOffsetFound write FOnOffsetFound;
    property CompareMargin: Single read FCompareMargin write FCompareMargin;
    property SearchLimit: Cardinal read FSearchLimit write FSearchLimit;
    constructor Create;
    destructor Destroy; override;
    procedure StartSearch(const PID: Cardinal; const SearchData: TSearchData);
    function IsRunning: Boolean;
    function GetTimeElapsed: TTimeSpan;
  end;

implementation

uses
  System.Math, Winapi.TlHelp32;

type
  TModulePointerData = record
    BaseAddr: Pointer;
    BaseSize: Cardinal;
  end;

function GetBasePointerOfModule(ProcessId: dword; Modulename: string; out ModulePointerData: TModulePointerData): Boolean;
var
  SnapshotHandle: THandle;
  ModulEntry32: MODULEENTRY32;
  s: string;
begin
  Result := False;
  SnapshotHandle := CreateToolhelp32Snapshot(TH32CS_SNAPMODULE, ProcessId);
  try
    if SnapshotHandle <> INVALID_HANDLE_VALUE then
    begin
      ModulEntry32.dwSize := SizeOf(ModulEntry32);
      if Module32First(SnapshotHandle, ModulEntry32) then
      begin
        repeat
          s := ModulEntry32.szModule;
          if s = Modulename then
          begin
            ModulePointerData.BaseAddr := ModulEntry32.modBaseAddr;
            ModulePointerData.BaseSize := ModulEntry32.modBaseSize;
            Result := True;
            Break;
          end;
        until (not Module32Next(SnapshotHandle, ModulEntry32));
      end;
    end;

  finally
    CloseHandle(SnapshotHandle);
  end;
end;

procedure RaiseReadProcessError;
begin
  raise EMemoryScannerError.Create('Read process error. ' + SysErrorMessage(GetLastError));
end;

{ TMemoryScanner }

constructor TMemoryScanner.Create;
begin
  FOnStart := nil;
  FOnFinish := nil;
  FOnOffsetFound := nil;
  FCompareMargin := 1.0;
  FSearchLimit := 1000;
end;

destructor TMemoryScanner.Destroy;
begin

  inherited;
end;

procedure TMemoryScanner.DoError(const E: Exception);
begin
  if Assigned(FOnError) then
    FOnError(Self, E);
end;

procedure TMemoryScanner.DoFinish;
begin
  if Assigned(FOnFinish) then
    FOnFinish(Self);
end;

procedure TMemoryScanner.DoOffsetFound(const N, Offset: NativeUInt);
begin
  if Assigned(FOnOffsetFound) then
    FOnOffsetFound(Self, N, Offset);
end;

procedure TMemoryScanner.DoStart;
begin
  if Assigned(FOnStart) then
    FOnStart(Self);
end;

function TMemoryScanner.GetTimeElapsed: TTimeSpan;
begin
  Result := FWatch.Elapsed;
end;

function TMemoryScanner.IsRunning: Boolean;
begin
  Result := Assigned(FTask) and (FTask.Status = TTaskStatus.Running);
end;

function TMemoryScanner.IsValidVector2(const Value: TVector2): Boolean;
begin
  Result := not (IsNaN(Value.x) or IsNaN(Value.y));
end;

function TMemoryScanner.IsValidVector3(const Value: TVector3): Boolean;
begin
  Result := not (IsNaN(Value.x) or IsNaN(Value.y) or IsNaN(Value.z));
end;

function TMemoryScanner.ParsePattern(const Value: string): TPatternArray;
var
  Splitted: TArray<string>;
  s: string;
  b: Byte;
  p: PByte;
begin
  Result := [];

  Splitted := Value.Split([' ']);

  for s in Splitted do
  begin
    if s = '?' then
    begin
      Result := Result + [nil];
    end
      else
    begin
      if Byte.TryParse('$' + s, b) then
      begin
        New(p);
        p^ := b;
        Result := Result + [p];
      end
        else
      raise EMemoryScannerError.CreateFmt('Pattern parse error. Value: %s.', [s]);

    end;

  end;

end;

function TMemoryScanner.SameVector2(const Value1, Value2: TVector2): Boolean;
begin
  Result := SameValue(Value1.X, Value2.X, FCompareMargin) and
    SameValue(Value1.Y, Value2.Y, FCompareMargin);
end;

function TMemoryScanner.SameVector3(const Value1, Value2: TVector3): Boolean;
begin
  Result := SameValue(Value1.X, Value2.X, FCompareMargin) and
    SameValue(Value1.Y, Value2.Y, FCompareMargin) and SameValue(Value1.Z, Value2.Z, FCompareMargin);
end;

procedure TMemoryScanner.StartSearch(const PID: Cardinal; const SearchData: TSearchData);
begin
  if IsRunning then
    Exit;

  FTask := TTask.Run
   (procedure()
    var
      ModulePointerData: TModulePointerData;
      SearchAddress: TSearchAddress;
      ProcessHandle: THandle;
    begin
      ProcessHandle := OpenProcess(PROCESS_VM_READ, False, PID);

      try
        try

          if ProcessHandle = 0 then
          begin
            raise EMemoryScannerError.Create('Error opening game process.');
          end;

          if not GetBasePointerOfModule(PID, CLIENT_DLL, ModulePointerData) then
            raise EMemoryScannerError.CreateFmt('Can''t find %s.', [CLIENT_DLL]);

          SearchAddress.Base := ModulePointerData.BaseAddr;
          SearchAddress.Size := ModulePointerData.BaseSize;
          SearchAddress.ProcessHandle := ProcessHandle;

          DoStart;

          FWatch := TStopwatch.StartNew;

          case SearchData.SearchType of
            TSearchType.Vector3:
              begin
                Search(SearchAddress, SearchData.Vector3);
              end;

            TSearchType.Vector2:
              begin
                Search(SearchAddress, SearchData.Vector2);
              end;

            TSearchType.Float:
              begin
                Search(SearchAddress, SearchData.Float);
              end;

            TSearchType.Int32:
              begin
                Search(SearchAddress, SearchData.Int32);
              end;

            TSearchType.Int64:
              begin
                Search(SearchAddress, SearchData.Int64);
              end;

            TSearchType.Pattern:
              begin
                Search(SearchAddress, SearchData.Pattern);
              end;

          end;

          FWatch.Stop;

          DoFinish;

        except
          on E: EMemoryScannerError do
            DoError(E);
        end;

      finally
        CloseHandle(ProcessHandle);
      end;

    end);

end;

procedure TMemoryScanner.Search(const SearchAddress: TSearchAddress; const Sample: Single);
var
  i: NativeUInt;
  Ptr: Pointer;
  BytesRead: NativeUInt;
  Value: Single;
  n: Integer;
begin
  n := 0;
  Ptr := SearchAddress.Base;

  for i := 0 to SearchAddress.Size - SizeOf(Value) do
  begin
    if ReadProcessMemory(SearchAddress.ProcessHandle, Ptr, @Value, SizeOf(Value), BytesRead) then
    begin
      if not IsNaN(Value) then
        if SameValue(Value, Sample, FCompareMargin) then
        begin
          Inc(n);

          DoOffsetFound(n, i);

          if n >= FSearchLimit then
            Break;
        end;

    end
      else
    begin
      RaiseReadProcessError;
    end;

    Inc(PByte(Ptr), 1);
  end;
end;

procedure TMemoryScanner.Search(const SearchAddress: TSearchAddress; const Sample: Integer);
var
  i: NativeUInt;
  Ptr: Pointer;
  BytesRead: NativeUInt;
  Value: Integer;
  n: Integer;
begin
  n := 0;
  Ptr := SearchAddress.Base;

  for i := 0 to SearchAddress.Size - SizeOf(Value) do
  begin
    if ReadProcessMemory(SearchAddress.ProcessHandle, Ptr, @Value, SizeOf(Value), BytesRead) then
    begin
      if SameValue(Value, Sample, FCompareMargin) then
      begin
        Inc(n);

        DoOffsetFound(n, i);

        if n >= FSearchLimit then
          Break;
      end;

    end
      else
    begin
      RaiseReadProcessError;
    end;

    Inc(PByte(Ptr), 1);
  end;
end;

procedure TMemoryScanner.Search(const SearchAddress: TSearchAddress; const Sample: Int64);
var
  i: NativeUInt;
  Ptr: Pointer;
  BytesRead: NativeUInt;
  Value: Int64;
  n: Integer;
begin
  n := 0;
  Ptr := SearchAddress.Base;

  for i := 0 to SearchAddress.Size - SizeOf(Value) do
  begin
    if ReadProcessMemory(SearchAddress.ProcessHandle, Ptr, @Value, SizeOf(Value), BytesRead) then
    begin
      if SameValue(Value, Sample, FCompareMargin) then
      begin
        Inc(n);

        DoOffsetFound(n, i);

        if n >= FSearchLimit then
          Break;
      end;

    end
      else
    begin
      RaiseReadProcessError;
    end;

    Inc(PByte(Ptr), 1);
  end;
end;

procedure TMemoryScanner.Search(const SearchAddress: TSearchAddress; const Sample: TVector2);
var
  i: NativeUInt;
  Ptr: Pointer;
  Vector2: TVector2;
  BytesRead: NativeUInt;
  n: Integer;
begin
  n := 0;
  Ptr := SearchAddress.Base;

  for i := 0 to SearchAddress.Size - SizeOf(Vector2) do
  begin
    if ReadProcessMemory(SearchAddress.ProcessHandle, Ptr, @Vector2, SizeOf(Vector2), BytesRead) then
    begin
      if IsValidVector2(Vector2) then
        if SameVector2(Vector2, Sample) then
        begin
          Inc(n);

          DoOffsetFound(n, i);

          if n >= FSearchLimit then
            Break;
        end;

    end
      else
    begin
      RaiseReadProcessError;
    end;

    Inc(PByte(Ptr), 1);
  end;
end;

procedure TMemoryScanner.Search(const SearchAddress: TSearchAddress; const Sample: TVector3);
var
  i: NativeUInt;
  Ptr: Pointer;
  Vector3: TVector3;
  BytesRead: NativeUInt;
  n: Integer;
begin
  n := 0;
  Ptr := SearchAddress.Base;

  for i := 0 to SearchAddress.Size - SizeOf(Vector3) do
  begin
    if ReadProcessMemory(SearchAddress.ProcessHandle, Ptr, @Vector3, SizeOf(Vector3), BytesRead) then
    begin
      if IsValidVector3(Vector3) then
        if SameVector3(Vector3, Sample) then
        begin
          Inc(n);

          DoOffsetFound(n, i);

          if n >= FSearchLimit then
            Break;
        end;

    end
      else
    begin
      RaiseReadProcessError;
    end;

    Inc(PByte(Ptr), 1);
  end;
end;

procedure TMemoryScanner.Search(const SearchAddress: TSearchAddress; const Pattern: string);
var
  i: NativeUInt;
  Ptr: Pointer;
  Vector3: TVector3;
  BytesRead: NativeUInt;
  n, k: NativeUInt;
  Bytes: TBytes;
  p: PByte;
  b: Byte;
  PatternArray: TPatternArray;
  PatternLen: Integer;
begin
  n := 0;
  Ptr := SearchAddress.Base;
  PatternArray := ParsePattern(Pattern);
  PatternLen := Length(PatternArray);

  try
    for i := 0 to SearchAddress.Size - PatternLen do
    begin
      k := 0;

      for p in PatternArray do
      begin
        if not ReadProcessMemory(SearchAddress.ProcessHandle, PByte(Ptr) + i + k, @b, SizeOf(b), BytesRead) then
          RaiseReadProcessError;

        if (PatternArray[k] <> nil) and (PatternArray[k]^ <> b) then
        begin
          Break;
        end
          else
        begin
          Inc(k);
        end;

      end;

      if k = PatternLen then
      begin
        Inc(n);

        DoOffsetFound(n, i);

        if n >= FSearchLimit then
          Break;
      end;

    end;

  finally
    for p in PatternArray do
      Dispose(p);
  end;

end;

end.
