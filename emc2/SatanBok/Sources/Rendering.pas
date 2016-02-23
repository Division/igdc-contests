unit Rendering;

interface

uses OpenGL, eXgine, Game, Physics, Windows;

var tx,Lead,Arrow,Back,Ground:TTexture;
    CurTime,LastTime:Single;
    dtime:single;

procedure DrawQuad(tx:TTexture; x,y,w:single; Ang:single=0);
procedure RenderPolygon(Texture:TTexture; P:TPolygon);
procedure RenderGame;
procedure RenderPlayer;
procedure RenderLines;
procedure RenderMenu;
procedure RenderVerevka;

implementation

uses Particles;

procedure RenderMini;
const KOEF=17;
var i,j:integer;
    l:TLine;
    c:TCircle;
    h:single;
begin
  glViewPort(700,0,100,100);
  ogl.Set2D(0,0,100,100);

  glColor3f(1,1,1);
  glBegin(GL_POLYGON);
    glVertex2f(0,0);
    glVertex2f(0,100);
    glVertex2f(100,100);
    glVertex2f(100,0);
  glEnd;
  
  glLineWidth(1);
  glColor3f(1,1,1);
  glBegin(GL_LINE_LOOP);
    glVertex2f(0,0);
    glVertex2f(0,100);
    glVertex2f(100,100);
    glVertex2f(100,0);
  glEnd;


  tex.Disable();
  glColor3f(0.2,0.8,0.2);

  if PolygonCount>0 then
    for i := 0 to PolygonCount - 1 do
    begin
      glBegin(GL_POLYGON);
      begin
        for j := 0 to Polygons[i].VertexCount - 1 do
          glVertex2f(50+(Polygons[i].Vertexes[j].x-ps.m_x[Player.Particles[8]].x)/KOEF,50+(Polygons[i].Vertexes[j].y-ps.m_x[Player.Particles[8]].y)/KOEF);
      end;
      glEnd;
    end;

  glColor3f(0,1,0);
  glPointSize(2);

  glBegin(GL_POINTS);
    glVertex2f(50,50);
    glColor3f(0,0,1);
    if TargetCount>0 then    
    for i := 0 to TargetCount - 1 do
      if Targets[i].Enabled then
        glVertex2f(50+(Targets[i].x-ps.m_x[Player.Particles[8]].x)/koef,50+(Targets[i].y-ps.m_x[Player.Particles[8]].y)/koef);

    glColor3f(1,0,0);
    if KillerCount>0 then
    for i := 0 to KillerCount - 1 do
      glVertex2f(50+(killers[i].x-ps.m_x[Player.Particles[8]].x)/koef,50+(killers[i].y-ps.m_x[Player.Particles[8]].y)/koef);

  glEnd;
  glColor3f(1,1,1);
end;


procedure RenderVerevka;
var i:integer;
    dx,dy:Single;
begin
  if not Verevka.Enabled then exit;
  
  glLineWidth(2);
  glPointSize(2);
  glColor3f(1,1,1);
  glBegin(GL_LINE_STRIP);
    for i := 0 to 19 do
      begin
        dx:=(ps.m_x[Verevka.Parts[i]].x-ps.m_oldx[Verevka.Parts[i]].x)*dtime/(1000/UPS);
        dy:=(ps.m_x[Verevka.Parts[i]].y-ps.m_oldx[Verevka.Parts[i]].y)*dtime/(1000/UPS);
        glVertex2f(ps.m_x[Verevka.Parts[i]].x-Camera.SmX+dx,ps.m_x[Verevka.Parts[i]].y-Camera.SmY+dy);
      end;
    dx:=(ps.m_x[Player.Particles[8]].x-ps.m_oldx[Player.Particles[8]].x)*dtime/(1000/UPS);
    dy:=(ps.m_x[Player.Particles[8]].y-ps.m_oldx[Player.Particles[8]].y)*dtime/(1000/UPS);
    glVertex2f(ps.m_x[Player.Particles[8]].x-Camera.SmX+dx,ps.m_x[Player.Particles[8]].y-Camera.SmY+dy);
  glEnd;
end;

procedure RenderPolygon(Texture:TTexture; P:TPolygon);
var i:integer;
begin
 tex.Enable(Texture);
  glBegin(GL_POLYGON);
    with p do
      for i := 0 to VertexCount - 1 do
        begin
          glTexCoord2f(TexCoords[i].x,TexCoords[i].y);
          glVertex2f(Vertexes[i].x-Camera.SmX,Vertexes[i].y-Camera.SmY);
        end;
  glEnd;
  Tex.Disable();
end;

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
var p:TPoint;
    v1,v2,v3:TVector3;
    i:integer;
begin
  RenderBackGround;

//  ogl.Blend(BT_ADD);
//
  glEnable(GL_BLEND);

  if PolygonCount>0 then
    for i := 0 to PolygonCount - 1 do
      RenderPolygon(Ground,Polygons[i]);

  glDisable(GL_BLEND);

  GetCursorPos(p);

  v1:=Polygons[0].Vertexes[0];
  v2:=Polygons[0].Vertexes[3];
  v3:=Vector3(p.X,p.Y,0);    

  RenderVerevka;

  RenderPlayer;

  if TargetCount>0 then
    for i := 0 to TargetCount - 1 do
      if Targets[i].Enabled then
        DrawQuad(Pentagr[AnimPos mod 19],Targets[i].x-Camera.SmX,Targets[i].y-Camera.SmY,64);

  DrawQuad(Arrow,p.X,p.Y,16);

  if KillerCount>0 then
    for i := 0 to KillerCount - 1 do
      DrawQuad(Killertex[AnimPos mod 10],Killers[i].x-Camera.SmX,Killers[i].y-Camera.SmY,64);

  ogl.TextOut(f,750,20,PCHAR(inttostr(GetCount)+'/'+inttostr(TargetCount)));
  ogl.TextOut(f,10,10,PCHAR('LEVEL '+inttostr(LevNum)));



  RenderMini;


end;


procedure RenderPlayer;
var i:integer;
    v:array[0..2] of TVector3;
    DeltaS,DeltaF:TVector3;
    dx,dy:Single;
begin
 glPushMatrix;
 tex.Enable(lead);
  glBegin(GL_POLYGON);
      if Length(Player.Polygon.TexCoords)>0 then
      for i := 0 to 7 do
        with Player.Polygon do
        begin
          dx:=(ps.m_x[Player.Particles[i]].x-ps.m_oldx[Player.Particles[i]].x)*dtime/(1000/UPS);
          dy:=(ps.m_x[Player.Particles[i]].y-ps.m_oldx[Player.Particles[i]].y)*dtime/(1000/UPS);
          glTexCoord2f(TexCoords[i].x,TexCoords[i].y);
          glVertex2f(Vertexes[i].x+dx-Camera.SmX,Vertexes[i].y+dy-Camera.SmY);
        end;
  glEnd;
  Tex.Disable();
  glPopMatrix;
end;

procedure RenderLines;
var i:integer;
begin

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
//  RenderMenuPS;
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
      ogl.TextOut(f,300,250,'Программирование: Никита Сидоренко aka Division');
      ogl.TextOut(f,330,280,'mailto:Division88@list.ru');
      ogl.TextOut(f,300,320,'Графика: Осмоловский Михаил aka e`; Division');      
    end;
    4:// Рекорды
    begin

    end;
    5:ogl.TextOut(f,300,250,'Не могу загрузить карту');
  end;

  glColor3f(1,1,1);
end;

end.
