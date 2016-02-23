unit log;

interface

uses
  Windows, sys_main,
  com;

type
  TLog = class(TInterface, ILog)
    constructor CreateEx;
    destructor Destroy; override;
   public
    function Create(FileName: PChar): Boolean;
    procedure Print(Text: PChar); 
    function Msg(Caption, Text: PChar; ID: Cardinal): Integer; 
    procedure TimeStamp(Active: Boolean);
    procedure Flush(Active: Boolean);
    procedure Free;
   private
    F    : DWORD;
    TS   : Boolean; // Time Stamp
    AF   : Boolean; // Active Flush
    time : Integer;
  end;

implementation

uses
  eng;

constructor TLog.CreateEx;
begin
  inherited CreateEx;
  F  := NULL_FILE;
  TS := True;
  AF := True;
end;

destructor TLog.Destroy;
begin
  Print('"' + ENG_NAME + ' ' + ENG_VER + '" log close');
  Free;
  inherited;
end;
 
function TLog.Create(FileName: PChar): Boolean;
begin
  Free;
  F := FileOpen(FileName, True);
  Result := FileValid(F);
  if Result then
  begin
    Time := GetTime;
    Print('"' + ENG_NAME + ' ' + ENG_VER + '" log start');
  end;
end;

procedure TLog.Print(Text: PChar);
var
  str : string;
  i   : Integer;
begin
  if FileValid(F) then
  begin
    if TS then
    begin
    // тайминг с предыдущего вызова Print
      i    := GetTime;
      str  := IntToStr(i - time);
      time := i;
      for i := 0 to 6 - Length(str) do
        str := '-' + str;
      str := '[' + str + '] ' + Text + #13#10
    end else
      str := Text + #13#10;
    FileWrite(F, str[1], Length(str));
    if AF then
      FileFlush(F);
  end;
end;

function TLog.Msg(Caption, Text: PChar; ID: Cardinal): Integer; 
begin
  Result := MessageBox(ownd.wnd_handle, Text, Caption, ID);
end;

procedure TLog.TimeStamp(Active: Boolean);
begin
  TS := Active;
end;

procedure TLog.Flush(Active: Boolean);
begin
  AF := Active;
end;

procedure TLog.Free;
begin
  FileClose(F);
end;

end.
