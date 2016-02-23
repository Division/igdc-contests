unit inp;

interface

uses
  Windows, MMSystem, com;

type
  TInp = class(TInterface, IInput)
    constructor CreateEx;
   public
    procedure Reset;
    function Down(Key: Integer): Boolean;
    function LastKey: Integer;
    function MDelta: TPoint;
    function WDelta: Integer; 
    procedure MCapture(Active: Boolean); 
   private
    joy_id    : integer;
    joy_caps  : TJoyCaps;
    joy_ready : Boolean;
    joy_xinv  : Boolean;
    joy_yinv  : Boolean;
   public
    keys    : array [0..279] of ShortInt;
    m_delta : TPoint;
    m_cap   : Boolean;
    v_klast : Integer;
    procedure log(Text: string);
    procedure Update;
    procedure SetKey(key: Integer; value: Shortint);
  end;

implementation

uses
  eng;

constructor TInp.CreateEx;
var
  i        : integer;
  joy      : TJoyInfoEx;
  joy_num  : integer;
begin
  inherited;
  Reset;
  log('Keyboard ready');
// Мышь
  m_delta.X := 0;
  m_delta.Y := 0;
  m_cap     := False;
  log('Mouse    ready');
// Джойстик
  joy_num := joyGetNumDevs;
  if joy_num <> 0 then
  begin
    joy_id := -1;
    joy.dwSize  := SizeOf(joy);
    joy.dwFlags := JOY_RETURNCENTERED;
  // Ищем активный
    for i := 0 to joy_num - 1 do
      if joyGetPos(i, @joy) = JOYERR_NOERROR then
      begin
        joy_id := i;
        break;
      end;
  // Если джойстик найден - получаем о нём информацию
    if joy_id > -1 then
      if joyGetDevCaps(joy_id, @joy_caps, SizeOf(joy_caps)) <> JOYERR_NOERROR then
        joy_ready := true;
  end;

  if joy_ready then
    log('Joystick ready')
  else
    log('Joystick not ready');
end;

procedure TInp.Reset;
begin
  FillChar(keys, SizeOf(keys), 0);
end;

function TInp.Down(Key: Integer): Boolean;
begin
  if (Key < 0) or (Key > High(keys)) then
    Result := False
  else
    Result := keys[Key] <> 0;
end;

function TInp.LastKey: Integer;
begin
  Result := v_klast;
end;

function TInp.MDelta: TPoint;
begin
  Result := m_delta;
end;

function TInp.WDelta: Integer;
begin
  Result := keys[M_WHEEL];
end;

procedure TInp.MCapture(Active: Boolean);
begin
  if m_cap <> Active then
    ShowCursor(m_cap);
  m_cap := Active;
  Update;
  m_delta.X := 0;
  m_delta.Y := 0;
end;

procedure TInp.log(Text: string);
begin
  olog.Print(PChar('Input   : ' + Text));
end;

procedure TInp.Update;
var
  joy  : TJoyInfoEx;
  i    : Integer;
  Rect : TRect;
  pos  : Windows.TPoint;
begin       
// вычисление смещения мыши
  if ownd.Active and m_cap then
  begin
    GetWindowRect(ownd.wnd_handle, Rect);
    GetCursorPos(pos);
    m_delta.X := pos.X - Rect.Left - (Rect.Right - Rect.Left) div 2;
    m_delta.Y := pos.Y - Rect.Top  - (Rect.Bottom - Rect.Top) div 2;
    SetCursorPos(Rect.Left + (Rect.Right - Rect.Left) div 2, Rect.Top + (Rect.Bottom - Rect.Top) div 2);
  end;
  
// Ввод с джойстика
  if joy_ready then
  begin
    joy.dwSize  := SizeOf(Joy);
    joy.dwFlags := JOY_RETURNALL;
  // Пытаемся считать состояние джойстика
    if joyGetPosEx(joy_id, @joy) <> JOYERR_NOERROR then
      Exit;
  // Наэатие клавишь
    for i := 0 to integer(joy_caps.wNumButtons) - 1 do
      if (joy.wButtons and (1 shl i) <> 0) and (keys[J_BTN_1 + i] = 0) then
        SetKey(J_BTN_1 + i, 1) // Нажали
      else
        if (not (joy.wButtons and (1 shl i) <> 0)) and (keys[J_BTN_1 + i] <> 0) then
          SetKey(J_BTN_1 + i, 0); // Отпустили
  // Влево-вправо
    i := (integer(joy.wXpos) - 32768) div 1000;
    if (i > 0) and not joy_xinv then
    begin
      if keys[J_BTN_R] = 0 then
        SetKey(keys[J_BTN_R], i);
      keys[J_BTN_L] := 0;
    end else
    begin
      if keys[J_BTN_L] = 0 then
        SetKey(keys[J_BTN_L], abs(i));
      keys[J_BTN_R] := 0;
    end;
  // Вверх-вниз
    i := (integer(joy.wYpos) - 32768) div 1000;
    if (i > 0) and not joy_yinv then
    begin
      if keys[J_BTN_U] = 0 then
        SetKey(keys[J_BTN_U], i);
      keys[J_BTN_D] := 0;
    end else
    begin
      if keys[J_BTN_D] = 0 then
        SetKey(keys[J_BTN_D], abs(i));
      keys[J_BTN_U] := 0;
    end;
  end;
end;

procedure TInp.SetKey(key: Integer; value: Shortint);
begin
  // Т.к. эта процедура вызывается только из движка
  // ошибки криворукого вызова исключены ;)
  // следовательно, key проверять диапозон не стоит ;)
  keys[key] := value;
  if value <> 0 then
    v_klast := key;
end;

end.
