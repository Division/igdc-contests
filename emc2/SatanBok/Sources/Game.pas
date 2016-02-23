unit Game;

interface

uses Physics, eXgine, OpenGL, Map, Windows, Utilite;

const UPS=30;

      P_MENU=0;
      P_GAME=1;

      Menu:array[0..1,0..2] of string = (('Новая игра','О программе','Выход'),
                                         ('Продолжить игру','Рестарт уровня','В главное меню'));

      P_SPEED=2;                                   
type
 TRGBA=record
  R,G,B,A:GLubyte;
 end;

 TMyTex16=array[0..15,0..15] of TRGBA;
 TMyTex32=array[0..31,0..31] of TRGBA;
 TMyTex128=array[0..127,0..127] of TRGBA;

 TLine=record
   v1,v2,n:TVector3;
 end;

 TPolygon=record
    Vertexes:array of TVector3;
    Lines:array of TLine;
    TexCoords:array of TVector3;
    LineCount,VertexCount:integer;
    Textured:boolean;
    procedure AddVertex(v:TVector3);
    procedure CalculateTexCoords(TexSize:Single;b:boolean=false);
    procedure GetNormals;
    procedure Clear;
 end;

 TPlayer=record
   Particles :array[0..8] of integer; // 0 - ведущая частица
   Constr    :array[0..11] of integer; // Связи между частицами игрока
   ControlL,ControlR   :integer; // Она же самая ведущая частица
   Cir       :integer; // Индекс окружности, ответственной за ведущую частицу
   x,y       :^Single; // Указатели на координаты ведущей частицы

   FAngle:Single;
   FPlus,Dead:boolean;
   
   Polygon:TPolygon;

   procedure Fire(x,y:single);
   procedure Unfix;
   procedure Jump;
   procedure Update;
   procedure Create(x,y:single);
 end;


TVerevka=record // Хм, как по-английски веревка?
  Parts:array[0..19] of integer;
  Constraints:array[0..19] of integer;
  Enabled,Fixed:boolean;

  procedure Create;
  procedure Update;
end;



 TCamera=record
   PX,PY,X,Y,SmX,SmY:Single; // PX,PY - прошлое положение камеры; X,Y - настоящее; SmX,SmY - интерполированное (:
   procedure Update;
 end;

 type   TTarget=record
          x,y:Single;
          Kind:integer;
          Enabled:boolean;
          procedure Create(dx,dy:single; Kind:integer);
        end;

        TKiller=record
          x,y:Single;
        end;

var Targets:array of TTarget;

    Player:TPlayer;
    Camera:TCamera;
    t:TMyTex128;
    LeadW:TMyTex128;
    artex:TMyTex16;
    BackW:TMyTex32;
    f:TFont;

    MenuCenter:Single;

    GamePos,ScreenPos,MenuPos,LevNum:Integer;

    PolygonCount,CircleCount,TargetCount,Scl,GetCount:integer;

    Start,Finish:TVector3;
    Circles:array of TCircle;
    inner:array[0..3] of integer;

    PSPEED, TargetAngle:Single;

    Polygons:array of TPolygon;

    AnimPos,Counter:integer;

    Verevka:TVerevka;

    Mouse:array[0..1] of Boolean;

    Pentagr:array[0..20] of TTexture;
    Killertex:array[0..10] of TTexture;
    Killers:array of TKiller;
    KillerCount:integer;

procedure UpdateMenu;
procedure UpdateGame;

procedure GameReset;
procedure PrepareTextures;
procedure Init;


procedure AddPolygon(Pol:TPolygon);
function AddCircle(c:TCircle):integer;
function Line(v1,v2,n:TVector3):TLine;

procedure Shutdown;
procedure NextLevel;

function PointInPolygon(V:TVector3; Pol:TPolygon):boolean;
function LinesIntersect(v1,v2,v3,v4:TVector3):boolean;
function Distance(a,b,c:TVector3):Single;

implementation

uses Rendering, Particles;

procedure TVerevka.Create;
var i:integer;
begin
  for i := 0 to 19 do
    begin
      Parts[i]:=ps.AddParticle(Vector3(0,0,0),0.5);
      ps.PEnabled[Parts[i]]:=false;
    end;
  for i := 0 to 18 do
    begin
      Constraints[i]:=ps.AddConstrain(Constraint(Parts[i],Parts[i+1],15,P_NOTBIGGER));
      ps.CEnabled[Constraints[i]]:=false;
    end;
  Constraints[19]:=ps.AddConstrain(Constraint(Parts[19],Player.Particles[8],15,P_NOTBIGGER));
  ps.CEnabled[Constraints[19]]:=false;

  Enabled:=false;
end;

procedure TVerevka.Update;
var i,j,k:integer;
begin
  if not Fixed then
    ps.m_x[Verevka.Parts[19]]:=ps.m_x[Player.Particles[8]];
  if PolygonCount>0 then
  for i := 0 to PolygonCount-1 do
    begin
      for k := 19 downto 0 do
      if PointInPolygon(ps.m_x[Parts[k]],Polygons[i]) and not Fixed then
        begin
          Fixed:=true;
          ps.m_x[Parts[0]]:=ps.m_x[Parts[k]];
          ps.FixParticle(Parts[0]);
          ps.CEnabled[Verevka.Constraints[19]]:=true;
          with ps do
          for j := 0 to 18 do
            m_constraints[Constraints[j]].RestLength:=5;
        end;
      
    end;
end;

procedure TPolygon.Clear;
begin
  LineCount:=0;
  VertexCount:=0;
  Vertexes:=nil;
//  TexCoords:=nil;
  Lines:=nil;
end;

procedure TPolygon.GetNormals;
var i:integer;
begin
  inc(LineCount);
  SetLength(Lines,LineCount);
  Lines[High(Lines)].v1:=Vertexes[High(Vertexes)];
  Lines[High(Lines)].v2:=Vertexes[0];

  for i := 0 to LineCount - 1 do
    Lines[i].n:=Normalize(GetNormal2(Lines[i].v1,Lines[i].v2));
    
end;

procedure TPolygon.AddVertex(v: TVector3);
begin
  inc(VertexCount);
  SetLength(Vertexes,VertexCount);
  Vertexes[High(Vertexes)]:=v;
  if VertexCount>1 then
    begin
      inc(LineCount);
      SetLength(Lines,LineCount);
      Lines[High(Lines)].v1:=Vertexes[VertexCount-2];
      Lines[High(Lines)].v2:=v;
    end;
end;

procedure TPolygon.CalculateTexCoords(TexSize:Single;b:boolean=false);
var TX,TY:Single;//Самая верхняя и самая левая
    i:integer;
    Temp:TVector3;
begin
  SetLength(TexCoords,VertexCount);
  TX:=Vertexes[0].x;
  TY:=Vertexes[0].y;
  for i := 0 to VertexCount-1 do // Нашли самый левый верхний угол
    begin
      if Vertexes[i].x<TX then TX:=Vertexes[i].x;
      if Vertexes[i].y<TY then TY:=Vertexes[i].y;
    end;
  for i := 0 to VertexCount - 1 do
    begin
      Temp:=Vertexes[i];
      if b then Temp:=Temp-Vector3(TX,TY,0);

      TexCoords[i].x:=Temp.x / TexSize;
      TexCoords[i].y:=Temp.y / TexSize;
    end;
end;

procedure GameReset;
var i:integer;
begin
  AnimPos:=0;
  Counter:=0;

  ps.SetPCount(1000);
  ps.SetCCount(1000);
  ClearParticles;

  for i := 0 to PolygonCount - 1 do
    Polygons[i].Clear;
  Polygons:=nil;
  PolygonCount:=0;
  CircleCount:=0;
  TargetCount:=0;
  KillerCount:=0;
  Killers:=nil;
  SetLength(Targets,TargetCount);
  SetLength(Circles,CircleCount);
  ps.Reset;
end;

procedure TPlayer.Fire(x,y:single);
var i:integer;
    px,py:single;
    v:TVector3;
begin
  px:=ps.m_x[Player.Particles[8]].x-Camera.SmX;
  py:=ps.m_x[Player.Particles[8]].y-Camera.SmY;
  v:=Normalize(Vector3(x-px,y-py,0))*20;
  with Verevka do
  begin
    for i := 0 to 19 do
      begin
        ps.m_x[Parts[i]]:=ps.m_x[Player.Particles[8]];
        ps.m_oldx[Parts[i]]:=ps.m_x[Player.Particles[8]]-v;
        ps.PEnabled[Verevka.Parts[i]]:=true;
        if i<>19 then
          ps.CEnabled[Verevka.Constraints[i]]:=true;
        ps.m_constraints[Verevka.Constraints[i]].RestLength:=15;  
        ps.Fixed[Parts[0]]:=false;
        Enabled:=true;
        Fixed:=false;
      end;
  end;
end;

procedure TPlayer.Unfix;
var i:integer;
begin
  with Verevka do
    begin
      Enabled:=false;
      fixed:=false;
      for i := 0 to 19 do
        begin
          ps.PEnabled[Parts[i]]:=false;
          ps.CEnabled[Constraints[i]]:=false;          
        end;
    end;
end;

procedure TPlayer.Create(x,y:single);
const r1=13; r2=20; l=60;
      PRADIUS=50;
      GRAD=45*deg2rad;
var i:integer;
    Size:single;
begin
  Dead:=false;
  for i := 0 to 7 do
    Particles[i]:=ps.AddParticle(Vector3(x+sin(i*GRAD)*PRADIUS,y+cos(i*GRAD)*PRADIUS,0));
  Particles[8]:=ps.AddParticle(Vector3(x,y,0));

  Size:=VecLength(ps.m_x[Particles[0]],ps.m_x[Particles[1]]);  
  for i := 0 to 6 do
    Constr[i]:=ps.AddConstrain(Constraint(Particles[i],Particles[i+1],Size));
  Constr[7]:=ps.AddConstrain(Constraint(Particles[7],Particles[0],Size));

  for i := 0 to 7 do
    Constr[i+8]:=ps.AddConstrain(Constraint(Particles[8],Particles[i],PRADIUS));
end;

procedure PrepareTextures;
var i,j:integer;
begin

 Arrow:=tex.Load('gfx\Arrow.tga');

 Lead:=tex.Load('gfx\satanbok.bmp');

 for i := 0 to 20 do
   Pentagr[i]:=tex.Load(PCHAR('gfx\pentagr\'+inttostr(10000+i)+'.tga'));

 for i := 0 to 10 do
   Killertex[i]:=tex.Load(PCHAR('gfx\killer\'+inttostr(10000+i)+'.tga'));


 Ground:=tex.load('gfx\ground.tga');//tex.Create('BackTex',4,GL_RGBA,32,32,@BackW);
 Back:=tex.Load('gfx\Back.tga');

end;


procedure InitMenuPS;
var corners:array[0..3] of integer; // Против часовой с верхнего левого
    lns:array[0..3,0..14] of integer;
    i:integer;
begin
  with MenuPS do
  begin
    SetPCount(100);
    SetCCount(100);
    corners[0]:=AddParticle(Vector3(0,0,0));
    corners[1]:=AddParticle(Vector3(0,600,0));
    corners[2]:=AddParticle(Vector3(800,600,0));
    corners[3]:=AddParticle(Vector3(800,0,0));
    FixParticle(corners[0]);
    FixParticle(corners[1]);
    FixParticle(corners[2]);
    FixParticle(corners[3]);
    for i := 0 to 14 do
      begin
        lns[0,i]:=AddParticle(Vector3(0,i*30+Random(10),0));
      end;
    for i := 0 to 13 do
      AddConstrain(Constraint(lns[0,i],lns[0,i+1],50));

    AddConstrain(Constraint(corners[0],lns[0,0],50));
    inner[0]:=AddParticle(Vector3(300,300,0));
    fixparticle(inner[0]);
    AddConstrain(Constraint(inner[0],lns[0,14],50));

    for i := 0 to 14 do
      begin
        lns[3,i]:=AddParticle(Vector3(800,i*30+Random(10),0));
      end;
    for i := 0 to 13 do
      AddConstrain(Constraint(lns[3,i],lns[3,i+1],50));

    AddConstrain(Constraint(corners[3],lns[3,0],50));
    inner[3]:=AddParticle(Vector3(500,300,0));
    fixparticle(inner[3]);
    AddConstrain(Constraint(inner[3],lns[3,14],50));

    for i := 0 to 10 do
      begin
        lns[1,i]:=AddParticle(Vector3(0,600-i*30+Random(10),0));
      end;
    for i := 0 to 9 do
      AddConstrain(Constraint(lns[1,i],lns[1,i+1],30));

    AddConstrain(Constraint(corners[1],lns[1,0],30));
    inner[1]:=AddParticle(Vector3(300,300,0));
    fixparticle(inner[1]);
    AddConstrain(Constraint(inner[1],lns[1,10],30));

    for i := 0 to 10 do
      begin
        lns[2,i]:=AddParticle(Vector3(700,600-i*30+Random(10),0));
      end;
    for i := 0 to 9 do
      AddConstrain(Constraint(lns[2,i],lns[2,i+1],30));

    AddConstrain(Constraint(corners[2],lns[2,0],30));
    inner[2]:=AddParticle(Vector3(500,200,0));
    fixparticle(inner[2]);
    AddConstrain(Constraint(inner[2],lns[2,10],30));

    AddConstrain(Constraint(inner[0],inner[1],1,P_NOTLESS));
    AddConstrain(Constraint(inner[1],inner[2],1,P_NOTLESS));
    AddConstrain(Constraint(inner[2],inner[3],1,P_NOTLESS));
    AddConstrain(Constraint(inner[3],inner[0],1,P_NOTLESS));
  end;
end;

procedure Init;
begin
 glLineWidth(2);
 glEnable(GL_LINE_SMOOTH);
 glHint(GL_LINE_SMOOTH,GL_NICEST);
 glEnable( GL_BLEND );
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);

 ShowCursor(false);

 PrepareTextures;
 PreparePart;

 inp.MCapture(false);

 MenuPS.m_vGravity:=Vector3(0,1,0);
 MenuPS.InitParam(2,Vector3(800,600,0),Vector3(0,1,0),1);
 InitMenuPS;

 MenuPos:=0;
 LevNum:=1;
 ScreenPos:=0;

 f:=ogl.FontCreate('Arial',12);
end;


function Line(v1,v2,n:TVector3):TLine;
begin
  result.v1 := v1;
  result.v2 := v2;
  result.n  := n;
end;

function AddCircle(c:TCircle):integer;
begin
  inc(CircleCount);
  SetLength(Circles,CircleCount);
  Circles[High(Circles)]:=c;
  Result:=High(Circles);
end;

procedure TCamera.Update;
var cx,cy,xkoef,ykoef:Single;
    TgX,TgY:single;
begin
  cx:=x+400;
  cy:=y+300;

  px:=x;
  py:=y;

  TgX:=ps.m_x[Player.Particles[8]].x;
  TgY:=ps.m_x[Player.Particles[8]].y;

  xkoef:=(TgX-cx)/15;
  ykoef:=(TgY-cy)/15;

  x:=x+xkoef;
  y:=y+ykoef;
end;

procedure MenuEnter;
begin
  case ScreenPos of
    0:
    begin
      case MenuPos of
        0:
        begin
          ScreenPos:=2; // Выбор уровня
          MenuPos:=8;
        end;
        1:
        begin
          ScreenPos:=3; // Разработчики
          MenuPos:=8;
        end;
        2:
        begin
          Shutdown; // Выход
        end;  
      end;
    end;
    2:
    begin
     if LoadMap('map'+inttostr(LevNum)+'.map')
      then
        GamePos:=P_GAME
          else
          begin
            ScreenPos:=5;
            MenuPos:=8;
          end;
    end;
    1:
    begin
      case MenuPos of
        0:
        begin
          GamePos:=P_GAME;
          MenuPos:=0;
        end;
        1:
        begin
          if LoadMap('map'+inttostr(LevNum)+'.map') then
            GamePos:=P_GAME
          else
          begin
            ScreenPos:=5;
            MenuPos:=8;
          end;  
        end;
        2:
        begin
          GamePos:=P_MENU;
          ScreenPos:=0;
          MenuPos:=0;
        end;  
      end;
    end;
  end;
end;

procedure GetTargetAngle;
var v1,v2,tmp:TVector3;
    i:integer;
    r:single;
begin
  v1:=Vector3(Camera.X+400,Camera.Y+300,0);
  if TargetCount=GetCount then
    v2:=Finish
  else
  begin
    for i := 0 to TargetCount - 1 do
      if Targets[i].Enabled then
        begin
          v2:=Vector3(Targets[i].x,Targets[i].y,0);
          r:=VecLength(v1,Vector3(Targets[i].x,Targets[i].y,0));
          break;
        end;
    for i := 0 to TargetCount-1 do
      if Targets[i].Enabled then
      begin
        tmp.x:=Targets[i].x;
        tmp.y:=Targets[i].y;
        tmp.z:=0;
        if (VecLength(v1,tmp)<r) then
          begin
            v2:=tmp;
            r:=VecLength(v1,tmp);
          end;
      end;
  end;

  TargetAngle:=GetAngle(Vector3(0,1,0),v2-v1);
end;

procedure UpdateGame;
var
    p:tpoint;
begin
      inc(AnimPos);
//      if AnimPos>10 then
//      AnimPos:=0;
//      if AnimPos>19 then
//        AnimPos:=0;
      Counter:=0;

  if inp.LastKey=27 then
  begin
    GamePos:=P_MENU;
    ScreenPos:=1;
    MenuPos:=0;
  end;
  if not Player.Dead then
  begin
  if inp.Down(VK_RIGHT) then
    begin
      ps.m_oldx[Player.ControlR]:=ps.m_oldx[Player.ControlR]-Vector3(0,1,0)*P_SPEED;
      ps.m_oldx[Player.ControlL]:=ps.m_oldx[Player.ControlL]+Vector3(0,1,0)*P_SPEED;
    end;
  if inp.Down(VK_LEFT) then
    begin
      ps.m_oldx[Player.ControlL]:=ps.m_oldx[Player.ControlL]-Vector3(0,1,0)*P_SPEED;
      ps.m_oldx[Player.ControlR]:=ps.m_oldx[Player.ControlR]+Vector3(0,1,0)*P_SPEED;
    end;


  end;
  Player.Update;

  ps.TimeStep;

  GetCursorPos(p);

  if not Player.dead then
  begin
  if not Mouse[0] and (inp.Down(M_BTN_1))
    then Player.Fire(p.X,p.Y);
  if not Mouse[1] and (inp.Down(M_BTN_2))
    then Player.Unfix;
  end;

  Mouse[0]:=Inp.Down(M_BTN_1);
  Mouse[1]:=Inp.Down(M_BTN_2);

  Camera.Update;

  LastTime:=eX.GetTime;
end;

procedure UpdateMenu;
var d:single;
begin
  MenuPS.TimeStep;
  d:=(MenuPos*40+250 - MenuCenter)/7;
  MenuCenter:=MenuCenter+d;
  MenuPS.m_x[inner[0]]:=Vector3(320,MenuCenter-10,0);
  MenuPS.m_x[inner[1]]:=Vector3(320,MenuCenter+30,0);
  MenuPS.m_x[inner[2]]:=Vector3(470,MenuCenter+30,0);
  MenuPS.m_x[inner[3]]:=Vector3(470,MenuCenter-10,0);
  

  case ScreenPos of
    0:
    begin
      if inp.LastKey=vk_up then
        begin
          dec(MenuPos);
          if MenuPos<0 then MenuPos:=2;
        end;
      if inp.LastKey=vk_down then
        begin
          inc(MenuPos);
          if MenuPos>2 then MenuPos:=0;
        end;
      if inp.LastKey=vk_return then
        MenuEnter;
    end;
    1: // Меню паузы
    begin
      if inp.LastKey=vk_up then
        begin
          dec(MenuPos);
          if MenuPos<0 then MenuPos:=2;
        end;
      if inp.LastKey=vk_down then
        begin
          inc(MenuPos);
          if MenuPos>2 then MenuPos:=0;
        end;
      if inp.LastKey=vk_return then
        MenuEnter;
    end;
    2:// Выбор уровня
    begin
      if inp.LastKey=27 then
        begin
          ScreenPos:=0;
          MenuPos:=0;
        end;
      if inp.LastKey=vk_left then
        dec(LevNum);
      if LevNum<1 then LevNum:=1;       
      if inp.LastKey=vk_right then
        inc(LevNum);
      if inp.LastKey=vk_return then MenuEnter;                 
    end;
    3,4:
    begin
      if inp.LastKey=27 then
        begin
          ScreenPos:=0;
          MenuPos:=0;
        end;
    end;
    5:
      if inp.LastKey=27 then
        begin
          ScreenPos:=2;
          MenuPos:=8;
        end;
  end;
end;

procedure Shutdown;
begin
  GameReset;
  MenuPS.Reset;
  eX.Quit;
end;



procedure TPlayer.Update;
var i,j:integer;
begin
  Polygon.Clear;
  with ps do
  for i := 0 to 7 do
    Polygon.AddVertex(m_x[Particles[i]]);
  Polygon.GetNormals;

  ControlL:=0;
  ControlR:=0;  
  with ps do
  for i := 0 to 7 do
    begin
      if m_x[Particles[i]].x<m_x[Particles[ControlL]].x then
        ControlL:=i;
      if m_x[Particles[i]].x>m_x[Particles[ControlR]].x then
        ControlR:=i;
    end;

  if TargetCount>0 then   
  for i := 0 to TargetCount - 1 do
    begin
      if Targets[i].Enabled and not Dead and
        (VecLength(ps.m_x[Player.Particles[8]],Vector3(Targets[i].x,Targets[i].y,0))<72) then
      begin
        Targets[i].Enabled:=false;
        inc(GetCount);
      end;
      
    end;
  if KillerCount>0 then
  for i := 0 to KillerCount - 1 do
    begin
       if (VecLength(ps.m_x[Player.Particles[8]],Vector3(Killers[i].x,Killers[i].y,0))<70) then
      begin
        Player.Dead:=true;
        for j := 0 to 7 do
          ps.CEnabled[Player.Constr[j]]:=false;

      end;

    end;

    NextLevel;

end;

procedure TPlayer.Jump;
var i:integer;
    koef:single;
begin
  with ps do
  for i := 0 to 7 do
    begin
      if m_x[Player.Particles[i]].y<m_x[Player.Particles[8]].y then
        begin
          koef:=m_x[Player.Particles[8]].y-m_x[Player.Particles[i]].y;
          m_x[Player.Particles[i]].y:=m_x[Player.Particles[i]].y+Vector3(0,1,0).y*(Koef*0.4);
          m_oldx[Player.Particles[i]].y:=m_x[Player.Particles[i]].y+Vector3(0,1,0).y*(Koef*0.1);
        end;

    end;
end;

procedure NextLevel;
begin
  if GetCount<>TargetCount then exit;

  Inc(LevNum);
  if not LoadMap('map'+inttostr(LevNum)+'.map') then
    begin
      LevNum:=1;
      LoadMap('map'+inttostr(LevNum)+'.map');
    end;
end;


procedure TTarget.Create(dx,dy:single; Kind:integer);
const l=40; r=10;
begin
  x:=dx;
  y:=dy;
  Enabled:=true;
end;

procedure AddPolygon(Pol:TPolygon);
begin
 inc(PolygonCount);
 SetLength(Polygons,PolygonCount);
 Polygons[High(Polygons)]:=Pol;
end;

function PointInPolygon(V:TVector3; Pol:TPolygon):boolean;
var i:integer;
begin
  Result:=false;
  for i := 0 to Pol.VertexCount-2 do
    begin
      if Orient(Pol.Vertexes[i],Pol.Vertexes[i+1],V)>0 then
        exit;
    end;
  if Orient(Pol.Vertexes[High(Pol.Vertexes)],Pol.Vertexes[0],V)>0 then exit;
  Result:=true;
end;

//double distance(DOT2D* a, DOT2D* b, DOT2D* c)
{
  double dx = a->x - b->x;
  double dy = a->y - b->y;
  double D = dx * (c->y - a->y) - dy * (c->x - a->x);
  return fabs(D / sqrt(dx * dx + dy * dy));
}

function Distance(a,b,c:TVector3):Single;
var dx,dy,D:Single;
begin
  dx:=a.x-b.x;
  dy:=a.y-b.y;
  D:=dx*(c.y-a.y)-dy*(c.x-a.x);
  Result:=abs(D/Sqrt(dx*dx+dy*dy));
end;

function LinesIntersect(v1,v2,v3,v4:TVector3):boolean;
begin
  Result := (((v3.x-v1.x)*(v2.y-v1.y)-(v3.y-v1.y)*(v2.x-v1.x))*((v4.x-v1.x)*(v2.y-v1.y)-(v4.y-v1.y)*(v2.x-v1.x))<=0) and
            (((v1.x-v3.x)*(v4.y-v3.y)-(v1.y-v3.y)*(v4.x-v3.y))*((v2.x-v3.x)*(v4.y-v3.y)-(v2.y-v3.y)*(v4.x-v3.x))<=0)
end;


end.
