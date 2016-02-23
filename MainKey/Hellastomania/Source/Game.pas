unit Game;

interface

uses Physics, eXgine, OpenGL, Map, Windows, Utilite;

const UPS=30;

      P_MENU=0;
      P_GAME=1;

      Menu:array[0..1,0..2] of string = (('Новая игра','О программе','Выход'),
                                         ('Продолжить игру','Рестарт уровня','В главное меню'));

      MAX_SPEED=10;

      VIS_DIST=500;

      arr:array[0..15,0..15] of single = ((0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0),
                                          (0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0),
                                          (0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0),
                                          (0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0),
                                          (0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0));
type
 TRGBA=record
  R,G,B,A:GLubyte;
 end;

 TMyTex16=array[0..15,0..15] of TRGBA;
 TMyTex32=array[0..31,0..31] of TRGBA; 
 TMyTex128=array[0..127,0..127] of TRGBA; 


 TFlash=record
   d:array of single;
   SegSize:Single;
   DCount:integer;
   v,n,t:TVector3;
   Pos,Target:^TVector3;
   Tg:boolean;
   procedure Update(Range:Single=3);
 end;


 TPlayer=record
   Particles :array[0..2] of integer; // 0 - ведущая частица
   Constr    :array[0..2] of integer; // Связи между частицами игрока
   Control   :integer; // Она же самая ведущая частица
   Cir       :integer; // Индекс окружности, ответственной за ведущую частицу
   x,y       :^Single; // Указатели на координаты ведущей частицы
   Flashes   :array[0..11] of TFlash;

   FAngle:Single;
   FPlus,Dead:boolean;

   procedure Update;
   procedure Create(x,y:single);
 end;

 TLine=record
   v1,v2,n:TVector3;
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

    LineCount,CircleCount,TargetCount,Scl,GetCount:integer;

    Start,Finish:TVector3;
    Lines:array of TLine;
    Circles:array of TCircle;
    inner:array[0..3] of integer;

    PSPEED, TargetAngle:Single;
procedure UpdateMenu;
procedure UpdateGame;

procedure GameReset;
procedure PrepareTextures;
procedure Init;
procedure InitMenuPS;

procedure AddLine(Line:TLine);
function AddCircle(c:TCircle):integer;
function Line(v1,v2,n:TVector3):TLine;

procedure Shutdown;
procedure NextLevel;

implementation

uses Rendering, Particles;


procedure GameReset;
begin
  ps.SetPCount(1000);
  ps.SetCCount(1000);
  ClearParticles;
  LineCount:=0;
  CircleCount:=0;
  TargetCount:=0;
  SetLength(Targets,TargetCount);
  SetLength(Circles,CircleCount);
  SetLength(Lines,LineCount);
  ps.Reset;
end;

procedure TPlayer.Create(x,y:single);
const r1=13; r2=20; l=60;
var i:integer;
begin
  Dead:=false;
  Particles[0]:=ps.AddParticle(Vector3(x,y,0));
  Particles[1]:=ps.AddParticle(Vector3(x,y+50,0),1.2);
  Particles[2]:=ps.AddParticle(Vector3(x+2,y+100,0),1.5);
  Constr[0]:=ps.AddConstrain(Constraint(Particles[0],Particles[1],l));
  Constr[1]:=ps.AddConstrain(Constraint(Particles[1],Particles[2],l));
  Control:=Particles[0];
  Self.x:=@ps.m_x[Particles[0]].x;
  Self.y:=@ps.m_x[Particles[0]].y;
  Cir:=AddCircle(Circle(r2,Particles[0]));
  AddCircle(Circle(r1,Particles[1]));
  AddCircle(Circle(r2,Particles[2]));

  Flashes[0].Pos:=@ps.m_oldx[Particles[0]];
  Flashes[1].Pos:=@ps.m_oldx[Particles[0]];
  Flashes[2].Pos:=@ps.m_oldx[Particles[2]];
  Flashes[3].Pos:=@ps.m_oldx[Particles[2]];

  Flashes[0].Target:=@ps.m_oldx[Particles[1]];
  Flashes[1].Target:=@ps.m_oldx[Particles[1]];
  Flashes[2].Target:=@ps.m_oldx[Particles[1]];
  Flashes[3].Target:=@ps.m_oldx[Particles[1]];

  Flashes[0].SegSize:=10;
  Flashes[1].SegSize:=10;
  Flashes[2].SegSize:=10;
  Flashes[3].SegSize:=10;

  for i := 4 to 11 do
    begin
      Flashes[i].Tg:=true;
      Flashes[i].Pos:=@ps.m_oldx[Particles[0]];
      Flashes[i].SegSize:=3.5;
    end;
end;

procedure PrepareTextures;
var i,j:integer;
    a:single;
begin
 for j:= 0 to 127 do
 for i:= 0 to 127 do
   begin
     a:=sqrt(sqr(63-i)+sqr(63-j));
     if (a<20) or ((a>50) and (a<=63)) then
       begin
         t[i,j].R:=255;
         t[i,j].G:=255;
         t[i,j].B:=255;
         t[i,j].A:=255;
       end
       else
       begin
         t[i,j].R:=0;
         t[i,j].G:=0;
         t[i,j].B:=0;
         t[i,j].A:=0;
       end;
   end;
  tx:=tex.Create('CircleTex',4,GL_RGBA,128,128,@t);


 for j:= 0 to 127 do
 for i:= 0 to 127 do
   begin
     a:=sqrt(sqr(63-i)+sqr(63-j));
     if (a<11) or ((a>57) and (a<=63)) then
       begin
         LeadW[i,j].R:=0;
         LeadW[i,j].G:=255;
         LeadW[i,j].B:=0;
         LeadW[i,j].A:=255;
       end;
       if a>63 then
       begin
         LeadW[i,j].R:=0;
         LeadW[i,j].G:=0;
         LeadW[i,j].B:=0;
         LeadW[i,j].A:=0;
       end;
       if (a>=11) and (a<=57) then
       begin
         LeadW[i,j].R:=100;
         LeadW[i,j].G:=150;
         LeadW[i,j].B:=255;
         LeadW[i,j].A:=90;
       end;
   end;
 Lead:=tex.Create('LeadTex',4,GL_RGBA,128,128,@LeadW);

 for j:= 0 to 15 do
 for i:= 0 to 15 do
   begin
     Artex[i,j].R:=0;
     Artex[i,j].G:=trunc(arr[i,j]*255);
     Artex[i,j].B:=0;
     Artex[i,j].A:=trunc(arr[i,j]*100);
   end;
 Arrow:=tex.Create('ArrowTex',4,GL_RGBA,16,16,@Artex);

 for j:= 0 to 31 do
 for i:= 0 to 31 do
   begin
     BackW[i,j].R:=0;
     BackW[i,j].G:=0;
     BackW[i,j].B:=0;
     BackW[i,j].A:=255;
   end;
 for j:= 2 to 29 do
 for i:= 12 to 19 do
   begin
     BackW[i,j].R:=20;
     BackW[i,j].G:=20;
     BackW[i,j].B:=20;
     BackW[i,j].A:=255;
   end;
 for i:= 2 to 29 do
 for j:= 12 to 19 do
   begin
     BackW[i,j].R:=20;
     BackW[i,j].G:=20;
     BackW[i,j].B:=20;
     BackW[i,j].A:=255;
   end;

 Back:=tex.Create('BackTex',4,GL_RGBA,32,32,@BackW);

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
        lns[0,i]:=AddParticle(Vector3(0+i*20,i*30+Random(10),0));
      end;
    for i := 0 to 13 do
      AddConstrain(Constraint(lns[0,i],lns[0,i+1],50));

    AddConstrain(Constraint(corners[0],lns[0,0],50));
    inner[0]:=AddParticle(Vector3(300,300,0));
    fixparticle(inner[0]);
    AddConstrain(Constraint(inner[0],lns[0,14],50));

    for i := 0 to 14 do
      begin
        lns[3,i]:=AddParticle(Vector3(800-i*20,i*30+Random(10),0));
      end;
    for i := 0 to 13 do
      AddConstrain(Constraint(lns[3,i],lns[3,i+1],50));

    AddConstrain(Constraint(corners[3],lns[3,0],50));
    inner[3]:=AddParticle(Vector3(500,300,0));
    fixparticle(inner[3]);
    AddConstrain(Constraint(inner[3],lns[3,14],50));

    for i := 0 to 10 do
      begin
        lns[1,i]:=AddParticle(Vector3(0+i*20,600-i*30+Random(10),0));
      end;
    for i := 0 to 9 do
      AddConstrain(Constraint(lns[1,i],lns[1,i+1],30));

    AddConstrain(Constraint(corners[1],lns[1,0],30));
    inner[1]:=AddParticle(Vector3(300,300,0));
    fixparticle(inner[1]);
    AddConstrain(Constraint(inner[1],lns[1,10],30));

    for i := 0 to 10 do
      begin
        lns[2,i]:=AddParticle(Vector3(700-i*20,600-i*30+Random(10),0));
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
 glEnable( GL_BLEND );
 glBlendFunc(GL_SRC_ALPHA, GL_ONE);
 ogl.Blend(BT_SUB);

 PrepareTextures;
 PreparePart;


 MenuPS.m_vGravity:=Vector3(0,1,0);
 MenuPS.InitParam(2,Vector3(800,600,0),Vector3(0,1,0),1);;
 InitMenuPS;

 MenuPos:=0;
 LevNum:=1;
 ScreenPos:=0;

 f:=ogl.FontCreate('Arial',12);
end;

procedure AddLine(Line:TLine);
begin
  inc(LineCount);
  SetLength(Lines,LineCount);
  Lines[High(Lines)]:=Line;
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

  TgX:=(ps.m_x[Player.Control]+ps.m_x[Player.Control+1]+ps.m_x[Player.Control+2]).x/3;
  TgY:=(ps.m_x[Player.Control]+ps.m_x[Player.Control+1]+ps.m_x[Player.Control+2]).y/3;

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
var i:integer;
begin
  if inp.LastKey=27 then
  begin
    GamePos:=P_MENU;
    ScreenPos:=1;
    MenuPos:=0;
  end;
  
  PSPEED:= (VecLength(ps.m_oldx[Player.Control],ps.m_x[Player.Control])+
            VecLength(ps.m_oldx[Player.Control+1],ps.m_x[Player.Control+1])+
            VecLength(ps.m_oldx[Player.Control+2],ps.m_x[Player.Control+2]))/3;

  if inp.Down(vk_up) and not Player.Dead then
    begin
      ps.m_oldx[Player.Control] := ps.m_oldx[Player.Control]-Normalize(ps.m_x[Player.Control]-ps.m_x[Player.Control+1])*2;
      if PSPEED>=MAX_SPEED then
        ps.m_oldx[Player.Control] := ps.m_x[Player.control] - Normalize( ps.m_x[Player.Control]-ps.m_oldx[Player.Control] )*MAX_SPEED;
    end;

  ps.TimeStep;

  Player.Update;

  if TargetCount>0 then
  for i := 0 to TargetCount-1 do
    if (VecLength(Vector3(Targets[i].x,Targets[i].y,0),Vector3(Camera.X+400,Camera.Y+300,0))<VIS_DIST)
      and Targets[i].Enabled then
      CreateExplosion(Targets[i].x,Targets[i].y,1,3,0.2);

  Camera.Update;

  CreateExplosion(Finish.x,Finish.y,2,0);

  UpdateParticles;

  GetTargetAngle;

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

procedure TFlash.Update(Range:Single=3);
var i,Segments:integer;
    Len:Single;
begin
  if Tg then
    Len:=VecLength(Pos^,T)
  else Len:=VecLength(Pos^,Target^);
  Segments:=trunc(Len / SegSize)-1;
  if Segments<1 then exit;
  SetLength(d,Segments);
  for i := 0 to Segments-1 do
    d[i]:=Random(trunc(SegSize*Range))-SegSize*Range/2;

  if Tg then
    v:=Normalize(T-Pos^)
  else v:=Normalize(Target^-Pos^);

  if Tg then
    n:=Normalize(GetNormal2(T,Pos^))
  else n:=Normalize(GetNormal2(Target^,Pos^));
end;

procedure TPlayer.Update;
var i,j:integer;
    r:single;
    c:TCircle;
begin
  if Dead Then Exit;

  for i := 0 to 3 do
    Flashes[i].Update(PSPEED/4);

  if FPlus then FAngle:=FAngle+0.1
    else FAngle:=FAngle-0.1;
  
  if Random(100)=0 then FPlus:=not FPlus;

  for i := 4 to 11 do
    with Flashes[i] do
    begin
      r:=((i-4)/8)*pi*2+FAngle;
      T:=Pos^+Vector3(Sin(r)*(Circles[Player.Cir].Radius-2),cos(r)*(Circles[Player.Cir].Radius-2),0);
      Update;
    end;

  c.x:=Finish.x;
  c.y:=Finish.y;
  c.Radius:=12;  
  for i := 0 to 2 do
    begin
      Circles[Cir+i].x:=ps.m_x[Control+i].x;
      Circles[Cir+i].y:=ps.m_x[Control+i].y;      
      if CircleVsCircle(c,Circles[Cir+i],r) then Nextlevel;
    end;

  for i := 0 to TargetCount-1 do
  for j := 0 to 2 do
    begin
      c.x:=Targets[i].x;
      c.y:=Targets[i].y;
      if CircleVsCircle(c,Circles[Cir+j],r) and Targets[i].Enabled then
        begin
          Targets[i].Enabled:=false;
          inc(GetCount);
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

end.
