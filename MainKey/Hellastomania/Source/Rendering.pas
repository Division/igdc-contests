unit Rendering;

interface

uses OpenGL, eXgine, Game, Physics;

var tx,Lead,Arrow,Back:TTexture;
    CurTime,LastTime:Single;
    dtime:single;

procedure DrawQuad(tx:TTexture; x,y,w:single; Ang:single=0);
procedure RenderGame;
procedure RenderPlayer;
procedure RenderLines;
procedure RenderMenu;

implementation

uses Particles;

procedure DrawQuad(tx:TTexture; x,y,w:single; Ang:single=0);
begin
 tex.Enable(tx);
 glPushMatrix;
 glTranslatef(x,y,0);
 glRotatef(Ang,0,0,1);
 glBegin(GL_QUADS);
   glTexCoord2f(0,0); glVertex2f(-w/2,-w/2);
   glTexCoord2f(1,0); glVertex2f(+w/2,-w/2);
   glTexCoord2f(1,1); glVertex2f(+w/2,+w/2);
   glTexCoord2f(0,1); glVertex2f(-w/2,+w/2);
 glEnd;
 glPopMatrix;
 tex.Disable;
end;

procedure RenderMini;
const KOEF=20;
var i:integer;
    l:TLine;
    c:TCircle;
    h:single;
begin
  glViewPort(700,0,100,100);
  ogl.Set2D(0,0,100,100);
  glLineWidth(1);
  glColor3f(1,1,1);
  glBegin(GL_LINE_LOOP);
    glVertex2f(0,0);
    glVertex2f(0,100);
    glVertex2f(100,100);
    glVertex2f(100,0);
  glEnd;

  glPointSize(2);

  c.x:=Player.x^;
  c.y:=Player.y^;
  c.Radius:=2000;

  for l in Lines do
    if LineVsCircle(l.v1,l.v2,c,h) then
      begin
        glBegin(GL_LINES);
          glVertex2f(50+(l.v1.x-Player.X^)/KOEF,50+(l.v1.y-Player.y^)/KOEF);
          glVertex2f(50+(l.v2.x-Player.X^)/KOEF,50+(l.v2.y-Player.y^)/KOEF);
        glEnd;
      end;

  glColor3f(1,0,0);
  glBegin(GL_POINTS);      
  for i := 0 to TargetCount - 1 do
    if Targets[i].Enabled then    
    begin
      glVertex2f(50+(Targets[i].x-Player.X^)/KOEF,50+(Targets[i].y-Player.y^)/KOEF);
    end;

  glColor3f(0,1,0);
  glVertex2f(50,50);  
  glVertex2f(50+(ps.m_x[Player.Control+1].x-Player.x^)/KOEF,50+(ps.m_x[Player.Control+1].y-Player.y^)/KOEF);
  glVertex2f(50+(ps.m_x[Player.Control+2].x-Player.x^)/KOEF,50+(ps.m_x[Player.Control+2].y-Player.y^)/KOEF);
  glColor3f(0,1,1);
  glPointSize(3);
  glVertex2f(50+(Finish.x-Player.x^)/KOEF,50+(Finish.y-Player.y^)/KOEF);
  glEnd;

  glLineWidth(2);
  glColor3f(1,1,1);
end;

procedure RenderBackGround;
var dx,dy:single;
begin
 dx:=(trunc(Camera.SmX) mod 800)/80;
 dy:=(trunc(Camera.SmY) mod 600)/60;
 tex.Enable(Back);
 glBegin(GL_QUADS);
   glTexCoord2f(0+dx,0+dy); glVertex2f(0,0);
   glTexCoord2f(10+dx,0+dy); glVertex2f(800,0);
   glTexCoord2f(10+dx,10+dy); glVertex2f(800,600);
   glTexCoord2f(0+dx,10+dy); glVertex2f(0,600);
 glEnd;
 tex.Disable;
end;

procedure RenderGame;
begin
  RenderBackGround;

  RenderLines;

  RenderPlayer;

  RenderParticles;

  DrawQuad(Arrow,400,300,25,TargetAngle);

  ogl.TextOut(f,750,10,PCHAR(inttostr(GetCount)+'/'+inttostr(TargetCount)));

  RenderMini;
end;

procedure RenderFlash(Flash:TFlash; DeltaS,DeltaF:TVector3; Range:Single=3);
var i:integer;
    vr:TVector3;
    cx,cy:single;
begin
  cx:=Flash.Pos^.x+DeltaS.x;
  cy:=Flash.Pos^.y+DeltaS.y;
  glBegin(GL_LINE_STRIP);
   glVertex2f(cx-Camera.SmX,Flash.Pos.y-Camera.SmY);
    with Flash do
    for i := 0 to High(d) do
      begin
        vr:=Vector3(cx,cy,0)+v*(i+1)*SegSize+n*d[i];
        glVertex2f(vr.x-Camera.SmX,vr.y-Camera.SmY);
      end;
    if Flash.Tg then
      glVertex2f(Flash.T.x+DeltaF.x-Camera.SmX,Flash.T.y+DeltaF.y-Camera.SmY)
    else
      glVertex2f(Flash.Target^.x+DeltaF.x-Camera.SmX,Flash.Target^.y+DeltaF.y-Camera.SmY);
  glEnd;

end;

procedure RenderPlayer;
var i:integer;
    v:array[0..2] of TVector3;
    DeltaS,DeltaF:TVector3;
begin
 glColor3f(0,0,1);
 v[0]:=ps.m_oldx[Player.Particles[0]]+(ps.m_x[Player.Particles[0]]-ps.m_oldx[Player.Particles[0]])*(dtime/(1000/UPS));
 v[1]:=ps.m_oldx[Player.Particles[1]]+(ps.m_x[Player.Particles[1]]-ps.m_oldx[Player.Particles[1]])*(dtime/(1000/UPS));
 v[2]:=ps.m_oldx[Player.Particles[2]]+(ps.m_x[Player.Particles[2]]-ps.m_oldx[Player.Particles[2]])*(dtime/(1000/UPS));

 if PSPEED>1 then
 begin
   DeltaS:=(ps.m_x[Player.Particles[0]]-ps.m_oldx[Player.Particles[0]])*(dtime/(1000/UPS));
   DeltaF:=(ps.m_x[Player.Particles[1]]-ps.m_oldx[Player.Particles[1]])*(dtime/(1000/UPS));
   glColor3f(0.7,0.9,1);
   glLineWidth(1);
   RenderFlash(Player.Flashes[0],DeltaS,DeltaF,PSPEED/2);
   glColor3f(0.7,0.8,1);
   glLineWidth(2);
   RenderFlash(Player.Flashes[1],DeltaS,DeltaF,PSPEED/2);

   DeltaS:=(ps.m_x[Player.Particles[2]]-ps.m_oldx[Player.Particles[2]])*(dtime/(1000/UPS));
   glColor3f(0.7,0.9,1);
   glLineWidth(1);
   RenderFlash(Player.Flashes[2],DeltaS,DeltaF,PSPEED/2);
   glColor3f(0.7,0.8,1);
   glLineWidth(2);
   RenderFlash(Player.Flashes[3],DeltaS,DeltaF,PSPEED/2);
 end;
 DeltaS:=(ps.m_x[Player.Particles[0]]-ps.m_oldx[Player.Particles[0]])*(dtime/(1000/UPS));
 DeltaF:=DeltaS;
 glColor3f(1,1,1);
 glLineWidth(2);

 for i := 4 to 11 do
   begin
     RenderFlash(Player.Flashes[i],DeltaS,DeltaF);
   end;

 glColor3f(1,1,1);
 for i := 0 to 2 do
   begin
     if i=0 then DrawQuad(Lead, v[i].x-Camera.SmX, v[i].y-Camera.SmY,Circles[Player.Cir+i].Radius*2)
     else DrawQuad(tx, v[i].x-Camera.SmX, v[i].y-Camera.SmY,Circles[Player.Cir+i].Radius*2);

   end;
 glLineWidth(2);
end;

procedure RenderLines;
var i:integer;
begin
 glBegin(GL_LINES);
 for i := 0 to LineCount-1 do
   begin
     glVertex2f(Lines[i].v1.x-Camera.SmX,Lines[i].v1.y-Camera.SmY);
     glVertex2f(Lines[i].v2.x-Camera.SmX,Lines[i].v2.y-Camera.SmY);
   end;
 glEnd;
end;

procedure RenderMenuPS;
var i:integer;
begin
  glBegin(GL_LINES);
  for i := 0 to MenuPS.ConstrCount-1 do
    with MenuPS do
    begin
      glVertex2f(m_x[m_constraints[i].ParticleA].x,m_x[m_constraints[i].ParticleA].y);
      glVertex2f(m_x[m_constraints[i].ParticleB].x,m_x[m_constraints[i].ParticleB].y);      
    end;
  glEnd;
end;

procedure RenderMenu;
var i:integer;
begin
  RenderMenuPS;
  case ScreenPos of
    0:// Главное меню
    begin
      for  i:= 0 to 2 do
      begin
        if MenuPos=i then glColor3f(0,1,0)
        else glColor3f(1,1,1);
        ogl.TextOut(f,350,250+i*40,PCHAR(Menu[0,i]));
      end;
    end;
    1:// Меню паузы
    begin
      for  i:= 0 to 2 do
      begin
        if MenuPos=i then glColor3f(0,1,0)
        else glColor3f(1,1,1);
        ogl.TextOut(f,335,250+i*40,PCHAR(Menu[1,i]));
      end;
    end;
    2:// Выбор уровня
    begin
      ogl.TextOut(f,350,250,Pchar('Выбери уровень: '+inttostr(LevNum)));
    end;
    3:// Разработчики
    begin
      glColor3f(1,0,0);
      ogl.TextOut(0,480,200,'HELLastomania');
      glColor3f(1,1,1);      
      ogl.TextOut(f,300,250,'Автор:Никита Сидоренко aka Division');
      ogl.TextOut(f,330,280,'mailto:Division88@list.ru');
    end;
    4:// Рекорды
    begin

    end;
    5:ogl.TextOut(f,300,250,'Не могу загрузить карту');
  end;

  glColor3f(1,1,1);
end;

end.
