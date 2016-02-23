//!!! ICamera
unit eng;

interface

uses
  Windows, sys_main, com,
  log, wnd, inp, ogl, vbo, tex, vfp, snd, vec;

const
  ENG_NAME = 'eXgine';
  ENG_VER  = '0.65';

type
  TEng = class(TInterface, IEngine)
    constructor CreateEx;
   public
    function log: ILog; overload; 
    function wnd: IWindow; 
    function inp: IInput; 
    function ogl: IOpenGL;
    function vbo: IVBuffer; 
    function tex: ITexture; 
    function vfp: IShader;
    function snd: ISound;
    function vec: IVector;
    function Version: PChar;
    procedure SetProc(ID: Integer; Proc: Pointer);
    procedure ActiveUpdate(OnlyActive: Boolean);
    function  GetTime: Integer;
    procedure ResetTimer;
    procedure MainLoop(UPS: Integer);
    procedure Update;
    procedure Render;
    procedure Quit;
   public
    ProcUpdate  : TProcUpdate;
    ProcRender  : TProcRender;
    ProcMessage : TProcMessage;
    ProcActive  : TProcActive;

  // fps - frames per second
    fps_time     : Integer;
    fps_cur      : Integer;
    FPS          : Integer;
  // ups - updates per second
    ups_time_old : Integer;  // Время с последнего вызова eng_update
    ups_time     : Integer;  // Время предыдущего замера ups
    Time, Time_Delta : Integer;
    OnlyActive   : Boolean;
    procedure log(Text: string); overload;
    procedure onActive;
  end;

var
  eng_isquit : Boolean;
  oeng : TEng;
  olog : TLog;
  ownd : TWnd;
  oinp : TInp;
  oogl : TOGL;
  ovbo : TVBO;
  otex : TTex;
  ovfp : TVFP;
  osnd : TSnd;
  ovec : TVec;

implementation

constructor TEng.CreateEx;
begin
  inherited;
  ProcUpdate  := nil;
  ProcRender  := nil;
  ProcMessage := nil;
  ProcActive  := nil;
  eng_isquit := False;
  OnlyActive := False;
// установка языка ввода (English)
  LoadKeyboardLayout('00000409', KLF_ACTIVATE);
end;

function TEng.log: ILog;
begin
  Result := olog;
end;

function TEng.wnd: IWindow;
begin
  Result := ownd;
end;

function TEng.inp: IInput;
begin
  Result := oinp;
end;

function TEng.ogl: IOpenGL;
begin
  Result := oogl;
end;

function TEng.vbo: IVBuffer;
begin
  Result := ovbo;
end;

function TEng.tex: ITexture;
begin
  Result := otex;
end;

function TEng.vfp: IShader;
begin
  Result := ovfp;
end;

function TEng.snd: ISound;
begin
  Result := osnd;
end;

function TEng.vec: IVector;
begin
  Result := ovec;
end;

function TEng.Version: PChar;
begin
  Result := PChar(ENG_NAME + ' ' + ENG_VER);
end;

procedure TEng.SetProc(ID: Integer; Proc: Pointer);
begin
  case ID of
    PROC_UPDATE  : ProcUpdate  := Proc;
    PROC_RENDER  : ProcRender  := Proc;
    PROC_MESSAGE : ProcMessage := Proc;
    PROC_ACTIVE  : ProcActive  := Proc;
  end;
end;

procedure TEng.ActiveUpdate(OnlyActive: Boolean);
begin
  self.OnlyActive := OnlyActive;
end;

function TEng.GetTime: Integer;
var
  T : LARGE_INTEGER;
  F : LARGE_INTEGER;
begin
  QueryPerformanceFrequency(Int64(F));
  QueryPerformanceCounter(Int64(T));
  Result := Trunc(1000 * T.QuadPart / F.QuadPart);
end;

procedure TEng.ResetTimer;
begin
  // Сброс состояния таймера
  ups_time_old := GetTime;
end;

procedure TEng.MainLoop(UPS: Integer);
var
  msg : TMsg;
begin
  log('Main Loop start');
// Инициализация таймера
  ups_time_old := GetTime - 1000 div UPS;
  ups_time     := GetTime;
  fps_time     := GetTime;

//== ГЛАВНЫЙ ЦИКЛ ОБРАБОТКИ СООБЩЕНИЙ И ТАЙМИНГА ==//
  while not eng_isquit do
  begin
  // обработка Windows сообщений
    while PeekMessage(msg, 0, 0, 0, PM_REMOVE) do
    begin
      TranslateMessage(msg);
      DispatchMessage(msg);
    end;
  // Тайминг 
    if (ownd.wnd_active and OnlyActive) or (not OnlyActive) then
    begin
      Time       := GetTime;
      Time_Delta := Time - ups_time_old;
      while Time_Delta >= (1000 div UPS) do
      begin
        Update;
        dec(Time_Delta, 1000 div UPS);
      end;
      ups_time_old := Time - Time_Delta;
      Render;
    end else
      WaitMessage;
  end;
  log('Main Loop stop');
end;

procedure TEng.Update;
begin
  if eng_isquit then Exit;
  oinp.Update;
  try
    if @ProcUpdate <> nil then
      ProcUpdate;
  except
    log('Error in ProcUpdate');
  end;
  osnd.Update;
// Сбрасываем хначения в Input
  oinp.v_klast       := -1;
  oinp.keys[M_WHEEL] := 0;
  oinp.m_delta.X     := 0;
  oinp.m_delta.Y     := 0;
end;

procedure TEng.Render;
begin
  if eng_isquit then Exit;
  try
    if @ProcRender <> nil then
      ProcRender;
  except
    log('Error in ProcRender');
  end;
  oogl.Swap;
end;

procedure TEng.Quit;
begin
  eng_isquit := True;
end;

procedure TEng.log(Text: string);
begin
  olog.Print(PChar('Engine  : ' + Text));
end;

procedure TEng.onActive;
begin
  try
    if @ProcActive <> nil then
      ProcActive(ownd.Active);
  except
    log('Error in ProcActive');
  end;
end;

end.
