unit dConsole;

interface

uses eXgine, dglOpenGL, Windows, dMath, messages,sysutils;

const
  CA_CLOSED  = 0;
  CA_OPENING = 1;
  CA_CLOSING = 2;
  CA_READY   = 3;
  // ����������� ��� ����� �������
  SYMBOLS : set of char = ['a'..'z','A'..'Z','.',',','''','!','|','[',']',
                           '@','#','$','%','^','&','*','(',')',':','+','{','}',
                           '0'..'9','-','_','=','\','/',' ','?','"',';'];



type
  TConsoleProcedure = procedure;

  type ExplodeRes = array of string;

  TProcRegistry = record
    name:string; // ��� ������
    Proc:TConsoleProcedure; // ��������� �� ���������
    Hint:string; // ���������. ��������� ����� � ������� ������ help <name>
  end;

{$REGION 'TConsole'}  
  TConsole = class
    constructor Create;
    destructor Destroy; override;
    public
      Enable : boolean;
      procedure echo(s:string); // �������� ����� � �������
      procedure Execute(s:string); // ��������� �����
      procedure Reset; // �������� ������� ������� ��� ���������� ���������
      procedure Update; // ������ ���
      procedure Render; //
      procedure Clear; // �������� ����� �������
      procedure RegProc(Name:string; Proc:TConsoleProcedure; ref:string=''); // ����������� ���������
    private
      fParams     : ExplodeRes; // ����� ���� ������ ���������� ��������� � ���������� ���������
      RepeatH     : single;  // ���������� ���������� �������� �� �����������
      RepeatV     : single;  // �� ���������
      Texture     : TTexture;// �������� ���� �������
      MaxRange    : integer; // ���� �������� ���������� �������
      Speed       : single;  // �������� �������
      Position    : single;  // ������� ����������
      PrevPos     : single;  // ���������� ����������
      Action      : integer; // ��� ������ ������ �������
      Strings     : array of string; // ������ � �������
      StringCount : integer; // �� ����������
      StringMax   : integer; // ������������ ���������� �����
      CurString   : string;  // ������� ������. � ��� �����
      ProcReg     : array of TProcRegistry; // ������������������ ���������
      ProcCount   : integer; // �� ����������
      Commands    : array of String; // ��������� ����� ��������
      ComCount    : integer; // �� ����������
      MaxCommands : integer; // �������� �������
      CurCommand  : integer; // ������� ��������
      LeftOffset  : integer; // ������ ������ �����
      StringOffs  : integer; // ������ ����� ��������
      BottomOffs  : integer; // ������ �� ���� �������
      ScrollPos   : integer; // ������� ������� �������
      LinesOnScr  : integer; // ���������� ������������ �����
      CursorPos   : integer; // ������� �������
      TextColor   : TVector3;// ���� ������
      Tex1Pos     : TVector3;// ���������� ���������� 1
      Tex2Pos     : TVector3;// ���������� ���������� 2
      function GetActive:boolean; // ������, ������� �� �������
      procedure AddCommand(s:string); // ��������� ��������� �������� � ������
    public
      property Active : boolean read GetActive;  // ������� ������� ��� ��� 
      property Params : ExplodeRes read fParams; // ������ � �����������
  end;
{$ENDREGION}  

implementation

uses Variables;

{$REGION 'Methods'}

function LowerCase(const s: string): string;
var
  i, l   : integer;
  Rc, Sc : PChar;
begin
  l := Length(s);
  SetLength(Result, l);
  Rc := Pointer(Result);
  Sc := Pointer(s);
  for i := 1 to l do
  begin
    if s[i] in ['A'..'Z', '�'..'�'] then
      Rc^ := Char(Byte(Sc^) + 32)
    else
      Rc^ := Sc^;
    inc(Rc);
    inc(Sc);
  end;
end;

// ��������� ������ �� �������� � ��������
// ������ ����� � ������.
procedure Explode(s:string; var m:ExplodeRes);
var i:integer;
begin
  i:=0;
  while Pos('  ',s)>0 do
    delete(s,Pos('  ',s),1);
  if Pos(' ',s)>0 then
  begin
    while Pos(' ',s)>0 do
      begin
        inc(i);
        SetLength(m,i);
        m[i-1]:=Copy(s,1,Pos(' ',s)-1);
        Delete(s,1,Pos(' ',s));
      end;
    if (s<>'') and (s<>' ') then
      begin
        inc(i);
        SetLength(m,i);
        m[i-1]:=s;
      end;
  end
  else
    begin
      SetLength(m,1);
      m[0]:=s;
    end;  
end;

procedure cClear;
var i:integer;
begin
  with Console do
    begin
      for i := 0 to StringCount - 1 do
        Strings[i]:='';
      StringCount:=0;
    end;
end;

procedure TConsole.Clear;
begin
  cClear;
end;

procedure TConsole.AddCommand(s: string);
var i:integer;
begin
  inc(ComCount);
  if ComCount>MaxCommands then
    ComCount:=MaxCommands;
  for i := MaxCommands-1 downto 1 do
    Commands[i]:=Commands[i-1];
  Commands[0]:=s;  
end;

// ����� ����� � �������
procedure TConsole.echo(s: string);
var i:integer;
begin
  inc(StringCount);
  if StringCount>StringMax then
    begin
      StringCount:=StringMax;
    end;

  for i := StringMax-1 downto 1 do
    Strings[i]:=Strings[i-1];
    
  Strings[0]:=s;
  ScrollPos:=0;
end;

function TConsole.GetActive:boolean;
begin
  Result := Action = CA_READY;
end;

// ������� ��� ���������� �������, � ���� ���� ��������
// � �� ���� �������, �� ������� ������� �� ���� �������
procedure PrintList;
var i:integer;
begin
  with Console do
    begin
      if Length(fParams) = 2 then
        begin
          for i := 0 to ProcCount - 1 do
           if lowercase(ProcReg[i].name) = lowercase(fParams[1]) then
           begin
             echo(ProcReg[i].Hint);
             exit;
           end;
        end;

      if Length(fParams)=1 then
      if ProcCount>0 then
        begin
          echo('');
          echo('���������� �������:');
          for i := 0 to ProcCount - 1 do
            echo(ProcReg[i].name);
          echo('');
        end
    end;
end;

procedure TConsole.Reset;
begin
  ProcCount:=0;
  ProcReg:=nil;
  Action:=0;
  Position:=0;
  PrevPos:=0;
  Strings:=nil;
  StringCount:=0;
  CurString:='';
  Commands:=nil;
  ComCount:=0;
  SetLength(Strings,StringMax);
  SetLength(Commands,MaxCommands);
  CurCommand:=0;
  CursorPos:=0;
  ScrollPos:=0;
  RegProc('Help',@PrintList,'����� Help <���_�������> ����� �������� ������� �� �������');
end;

constructor TConsole.Create;
begin
  MaxRange:=200;
  Enable:=true;
  Speed:=20;
  StringMax:=100;
  SetLength(Strings,StringMax);
  MaxCommands:=20;
  CurCommand:=0;
  SetLength(Commands,MaxCommands);
  TextColor:=Vector3(0.941176470588235,0.517647058823529,0);
  Texture:=tex.Load('DATA\Textures\console.jpg');
  LeftOffset:=15;
  StringOffs:=17;
  BottomOffs:=25;
  RepeatV:=1.17;
  RepeatH:=RepeatV*800/MaxRange;
  LinesOnScr:=10;
  RegProc('Help',@PrintList,'����� Help <���_�������> ����� �������� ������� �� �������'); // ����� ����� �������
  RegProc('Clear',@cClear) // � ������� �������
end;

destructor TConsole.Destroy;
begin
  Reset;
  inherited;
end;

procedure TConsole.RegProc(Name: string; Proc: TConsoleProcedure; ref:string='');
var i:integer;
begin
  if ProcCount>0 then
    for i := 0 to ProcCount - 1 do
      if lowercase(ProcReg[i].name) = lowercase(name) then
        begin
          echo('������ �����������: ��������� � ������ ' + ProcReg[i].name + ' ��� ���� ����������������');
          exit;
        end;
  inc(ProcCount);        
  SetLength(ProcReg,ProcCount);
  ProcReg[High(ProcReg)].name:=Name;
  ProcReg[High(ProcReg)].Proc:=Proc;
  ProcReg[High(ProcReg)].Hint:=ref;
end;

procedure TConsole.Execute(s: string);
var i:integer;
begin
  if s='' then
    exit;
  echo(s);
  fParams:=nil;
  Explode(s,fParams);

  if ProcCount>0 then
  for i := 0 to ProcCount - 1 do
    if lowercase(fParams[0]) = lowercase(ProcReg[i].name) then
      begin
        ProcReg[i].Proc;
        break;
      end;

  if s<>Commands[0] then  
    AddCommand(s);
  CurString:='';
  CurCommand:=0;
end;
{$ENDREGION}

{$REGION 'Update'}
procedure TConsole.Update;
var TildaPres:boolean;
    i:integer;
    k:TKeyboardstate;
    c:char;
begin
  if not Enable then
    Exit;
  // ������ �� ������
  TildaPres:=inp.LastKey = 192;

  // �������� ���������� ���������
  Tex1Pos.x:=Tex1Pos.x+0.005;
  Tex2Pos:=Tex2Pos+Vector3(0.001+sin(Tex1Pos.x*20)/100,0.002,0);

  case Action of
    CA_OPENING: // ��������� �������
      begin
        if TildaPres then
          Action:=CA_CLOSING;

        PrevPos:=Position;  
        Position:=Position+Speed;
        if Position>MaxRange then
          begin
            Position:=MaxRange;
            PrevPos:=Position;
            Action:=CA_READY;
          end; 
      end;
    CA_CLOSING: // ���������
      begin
        if TildaPres then
          Action:=CA_OPENING;
        PrevPos:=Position;
        Position:=Position-Speed;
        if Position<0 then
          begin
            Position:=0;
            PrevPos:=Position;
            CurString:='';
            CurCommand:=0;
            ScrollPos:=0;
            CursorPos:=0;
          end;
      end;
    CA_CLOSED:
      begin
        if TildaPres then
          Action:=CA_OPENING;
      end;
    CA_READY: // ������� �������
      begin
        if TildaPres then
          Action:=CA_CLOSING;

        // ��������� ��������� ������� ������  
        GetKeyboardState(k);
        if inp.LastKey<>-1 then
          begin
            // ������������ ��� � ������
            ToAscii(inp.LastKey,1,k,@c,0);
            // ���� ������ � ����������� ���������, �� ����� ���
            if c in SYMBOLS then
              begin
                insert(c,CurString,CursorPos+1);
                inc(CursorPos);
              end;
          end;

        // ������ Backspace, �������
        if inp.LastKey = 8 then
          begin
            if Length(CurString)>0 then
              Delete(CurString,CursorPos,1);
            Dec(CursorPos);
          end;
        // ������ Delete, �������
        if inp.LastKey = VK_DELETE then
          begin
            if Length(CurString)>0 then
              Delete(CurString,CursorPos+1,1);
          end;
        // �� ��� home � end, �������
        if inp.LastKey = VK_HOME then
          CursorPos:=0;
        if inp.LastKey = VK_END then
          CursorPos:=Length(CurString);
        // ������ ������ ����� - ������� ���������� ��������� �������
        if inp.LastKey = VK_UP then
           begin
             if CurString<>'' then
               inc(CurCommand);
             if CurCommand>ComCount-1 then
               CurCommand:=ComCount-1;
              CurString:=Commands[CurCommand];
             CursorPos:=Length(CurString);
           end;

        if inp.LastKey = VK_DOWN then
          begin
            dec(CurCommand);
            if CurCommand<0 then
              begin
                CurCommand:=0;
                CurString:='';
              end
            else
              CurString:=Commands[CurCommand];
            CursorPos:=Length(CurString);  
          end;
        // ������ �����-������
        if inp.LastKey = VK_LEFT then
          begin
            dec(CursorPos);
          end;
        if inp.LastKey = VK_RIGHT then
          begin
            inc(CursorPos);
          end;
        // ���� ������ �� ������  
        if CursorPos<0 then
          CursorPos:=0;
        if CursorPos > Length(CurString) then
          CursorPos:=Length(CurString);

        // ����� �������� Enter - ������ ������ �� ����������
        if inp.LastKey = 13 then
          begin
            Execute(CurString);
          end;

        if (inp.LastKey = 33) then // ������ �����
          begin
            inc(ScrollPos);
            if ScrollPos + LinesOnScr > StringCount then
              ScrollPos:=StringCount - LinesOnScr;
            if StringCount < LinesOnScr then
              ScrollPos:=0;
          end;  

        if (inp.LastKey = 34) then // ������ ����
          begin
            dec(ScrollPos);
            if ScrollPos<0 then
              ScrollPos:=0;
          end;

        // ��������������
        if (inp.LastKey = VK_TAB) and (CurString<>'') then
          begin
            for i := 0 to ProcCount - 1 do
              if lowercase(CurString) = lowercase(Copy(ProcReg[i].name,1,Length(CurString))) then
                begin
                  CurString:=ProcReg[i].name+' ';
                  CursorPos:=Length(CurString);
                  break;
                end;
          end;
      end;
  end;
end;
{$ENDREGION}

{$REGION 'Render'}
procedure TConsole.Render;
var d:single;
    i:integer;
begin
  if not Enable or (Action = CA_CLOSED) then
    Exit;
  // ������������
  d:=(Position-PrevPos)*dt;

  glColor3f(1,1,1);
  glDisable(GL_LIGHTING);
  glDisable(GL_DEPTH_TEST);
  // ������ ���
  tex.Enable(Texture,0);
  tex.Enable(Texture,1);
  glBegin(GL_QUADS);
    glMultiTexCoord2f(GL_TEXTURE1,RepeatH+Tex2Pos.x,Tex2Pos.y);
    glMultiTexCoord2f(GL_TEXTURE0,RepeatH+Tex1Pos.x,0);
    glVertex2f(wnd.Width,0);

    glMultiTexCoord2f(GL_TEXTURE1,0+Tex2Pos.x,Tex2Pos.y);
    glMultiTexCoord2f(GL_TEXTURE0,0+Tex1Pos.x,0);
    glVertex2f(0,0);

    glMultiTexCoord2f(GL_TEXTURE1,0+Tex2Pos.x,RepeatV+Tex2Pos.y);
    glMultiTexCoord2f(GL_TEXTURE0,0+Tex1Pos.x,RepeatV);
    glVertex2f(0,PrevPos+d);

    glMultiTexCoord2f(GL_TEXTURE1,RepeatH+Tex2Pos.x,RepeatV+Tex2Pos.y);
    glMultiTexCoord2f(GL_TEXTURE0,RepeatH+Tex1Pos.x,RepeatV);
    glVertex2f(Wnd.Width,PrevPos+d);
  glEnd;

  tex.Disable();
  tex.Disable(1);
  // ������� ����� � ������
  glColor3fv(@TextColor);
  if Length(CurString)>0 then
    ogl.TextOut(0,LeftOffset,PrevPos+d-BottomOffs,PCHAR(CurString));
  glBegin(GL_LINES);
    glVertex2f(ogl.TextLen(0,PCHAR(Copy(CurString,1,CursorPos)))+LeftOffset,PrevPos+d-10);
    glVertex2f(ogl.TextLen(0,PCHAR(Copy(CurString,1,CursorPos)))+LeftOffset+9,PrevPos+d-10);
  glEnd;
  // ����� � �������
  if StringCount>0 then
    begin
      for i := 0 to LinesOnScr - 1 do
        begin
          ogl.TextOut(0,LeftOffset,PrevPos+d-BottomOffs-StringOffs*(i+1),PCHAR(Strings[ScrollPos+i]));
        end;
    end;
  // ������ �� ��� ����
  glColor3f(1,1,1);

  glEnable(GL_LIGHTING);
  glEnable(GL_DEPTH_TEST);
end;
{$ENDREGION}

end.
