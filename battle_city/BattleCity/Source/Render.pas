unit Render;

interface

uses OpenGL, eXgine, Game, Variables;

procedure DrawQuad(texture:TTexture; x,y,w,h,angle:single; OFR:integer=0; OFL:integer=0; OFD:integer=0; OFU:integer=0; s_P:Single=0; t_P:Single=0);
procedure DrawTank(var Tank:TTank);
procedure DrawBrick(Brick:TBrick; X,Y:integer);
procedure RenderPatrons;
procedure DrawBack;
procedure DrawSphere;
procedure RenderGame;
procedure RenderMenu;
procedure RenderETanks;
procedure RenderHUD;
procedure DrawFlash(x,y,angle:single; Tank:TTank);

implementation

uses Particles;

// Самая главная процедура отрисовки :)
procedure DrawQuad(texture:TTexture; x,y,w,h,angle:single; OFR:integer=0; OFL:integer=0; OFD:integer=0; OFU:integer=0; s_P:Single=0; t_P:Single=0);
var L,R,T,D:Single;
begin
 L:=0;
 R:=0;
 T:=0;
 D:=0;

 if OFR<>0 then
 begin
  R:=1/4*OFR;
 end;
 if OFU<>0 then
 begin
  T:=1/4*OFU;
 end;
 if OFD<>0 then
 begin
  D:=1/4*OFD;
 end;
 if OFL<>0 then
 begin
  L:=1/4*OFL;
 end;
          
 glPushMatrix;
 tex.Enable(texture);
 glDisable(GL_COLOR_MATERIAL);
 glTranslatef(x+w/2,y+h/2,0);
 glRotatef(Angle,0,0,1);
 glBegin(GL_QUADS);
  glTexCoord2d(0+L+s_P,1-D+t_P); glVertex2f(-w/2+W*L,h/2-H*D);
  glTexCoord2d(1-R+s_P,1-D+t_P); glVertex2f(w/2-W*R,h/2-H*D);
  glTexCoord2d(1-R+s_P,0+T+t_P); glVertex2f(w/2-W*R,-h/2+H*T);
  glTexCoord2d(0+L+s_P,0+T+t_P); glVertex2f(-w/2+W*L,-h/2+H*T);
 glEnd;
 tex.Disable;
 glPopMatrix;
end;

// Что-то типа интерполяции движения :)
procedure DrawTank(var Tank:TTank);
var Time:Integer;
    TempX,TempY:Single;
    a:Single;
begin
 if GameParam.MotionInterpolation then
 case Tank.CurAction of
  AROTATE:
   begin
    Time := eX.GetTime;
    Time:= Time-LastTime;
    a:=Time/1000*UPS;

    if Tank.HV then
    begin
     DrawQuad(Tank.Texture,Tank.x,Tank.y,64,64,Tank.Angle+Tank.RotSpeed*(a-1));
     if Tank.Texture=TankTex[3] then
     begin
      DrawFlash(Tank.x,Tank.y,Tank.Angle+Tank.RotSpeed*(a-1), Tank);
     end;
    end
    else
    begin
     DrawQuad(Tank.Texture,Tank.x,Tank.y,64,64,Tank.Angle-Tank.RotSpeed*a);
     if Tank.Texture=TankTex[3] then
     begin
      DrawFlash(Tank.x,Tank.y,Tank.Angle-Tank.RotSpeed*a, Tank);
     end;
    end;
   end;
  AMOVE:
   begin
    Time := eX.GetTime;
    Time:= Time-LastTime;
    a:=Time/1000*UPS;
    case Trunc(Tank.Goal) of
     DLEFT:
      begin
       TempX:=-Tank.Speed;
       TempY:=0;
      end;
     DRIGHT:
      begin
       TempX:=Tank.Speed;
       TempY:=0;
      end;
     DTOP:
      begin
       TempX:=0;
       TempY:=-Tank.Speed;
      end;
     DDOWN:
      begin
       TempX:=0;
       TempY:=Tank.Speed;
      end;
     else
      begin
       TempX:=0;
       TempY:=0;
      end;
    end;
    if Tank.Texture=TankTex[3] then
     DrawFlash(Tank.x+TempX*(a-1),Tank.y+TempY*(a-1),Tank.Angle, Tank);
    DrawQuad(Tank.Texture,Tank.x+TempX*(a-1),Tank.y+TempY*(a-1),64,64,Tank.Angle);

   end
   else
    begin
     if Tank.Texture=TankTex[3] then
      DrawFlash(Tank.x,Tank.y,Tank.Angle, Tank);
     DrawQuad(Tank.Texture,Tank.x,Tank.y,64,64,Tank.Angle);
    end
 end
 else
 begin
  if Tank.Texture=TankTex[3] then
   DrawFlash(Tank.x,Tank.y,Tank.Angle, Tank);
  DrawQuad(Tank.Texture,Tank.x,Tank.y,64,64,Tank.Angle);
 end;

end;

procedure DrawBrick(Brick:TBrick; X,Y:integer);
begin
 with Brick do
  if Kind<>BWATER then  
   DrawQuad(Brick.Tex,X*BSIZE,Y*BSIZE,BSIZE,BSIZE,0,OFR,OFL,OFD,OFU)
  else DrawQuad(Brick.Tex,X*BSIZE,Y*BSIZE,BSIZE,BSIZE,0,OFR,OFL,OFD,OFU,Sin(Ang),Cos(Ang));
end;

procedure RenderPatrons;
var
    Time:integer;
    TempX,TempY,a:Single;
    P:PPatron;
begin
 P:=Patron;

 while P^.Next<>nil do
 begin
  P:=P^.Next;
  with P^ do
   begin
    if GameParam.MotionInterpolation then
    begin
     Time := eX.GetTime;
     Time:= Time-LastTime;
     a:=Time/1000*UPS;
     case Direction of
      DLEFT:
       begin
        TempX:=-Speed;
        TempY:=0;
       end;
      DRIGHT:
       begin
        TempX:=Speed;
        TempY:=0;
       end;
      DTOP:
       begin
        TempX:=0;
        TempY:=-Speed;
       end;
      DDOWN:
       begin
        TempX:=0;
        TempY:=Speed;
       end;
      else
       begin
        TempX:=0;
        TempY:=0;
       end;
     end;
     DrawQuad(PatrTex[0],X+TempX*(a-1),Y+TempY*(a-1),16,16,DIRANGLES[Direction]);
    end
    else
    begin
     DrawQuad(PatrTex[0],X,Y,16,16,DIRANGLES[Direction]);
    end;
   end;
 end;
end;

procedure DrawBack;
begin
tex.Enable(Back);
 glBegin(GL_QUADS);
  {glColor3f(1,0,0);} glTexCoord2d(0,1); glVertex2f(0,768);
  {glColor3f(0,1,0);} glTexCoord2d(8,1); glVertex2f(1024,768);
  {glColor3f(0,0,1);} glTexCoord2d(8,0); glVertex2f(1024,768-64);
  {glColor3f(0,1,0);} glTexCoord2d(0,0); glVertex2f(0,768-64);
 glEnd;
 glColor3f(1,1,1); 
tex.Disable;
end;

procedure DrawSphere;
var q:GLUQuadricObj;
begin
 glEnable(GL_LIGHTING);
 glEnable(GL_LIGHT0);
 q:=GluNewQuadric;
 glPushMatrix;

 glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
 glTranslatef(100,100,-40);
 gluSphere(q,40,30,30);
 glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
 glPopMatrix;
 glDisable(GL_LIGHTING);
end;

procedure RenderGame;
begin
  ogl.Clear(True, false);
  ogl.Set2D(0, 0, 1024,768);

  Map.Render(RBACK);
  
  RenderPatrons;
  if PTank1.Health <> 0 then DrawTank(PTank1);
  if (GameParam.SecondPlayer) and (PTank2.Health <> 0) then DrawTank(PTank2);
  if GameParam.SinglePlayer then RenderETanks;


  Map.Render(RFRONT);

  glEnable(GL_BLEND);
  glDisable(GL_ALPHA_TEST);
  RenderParticles;
  glDisable(GL_BLEND);
  glEnable(GL_ALPHA_TEST);
  DrawBack;
  if GameParam.SinglePlayer then
   RenderHUD;
  
  if Bonus.Active then
   With Bonus Do
    DrawQuad(BonusTex[Kind],X*64+16,Y*64+16,32,32,0);

//  ogl.TextOut(0,10,10,PCHAR(inttostr(ogl.FPS)));
//  ogl.TextOut(0,10,30,PCHAR(inttostr(EnemyNeed)));
  ogl.TextOut(0,10,30,PCHAR(Temp));
end;

procedure RenderMenu;
var i:integer;
    s:string;
begin
 ogl.Clear;
 ogl.Set2D(0, 0, 1024,768);

 DrawQuad(LogoTex,1024-512,768-512,512,512,0);

 case Menu.Screen of
  0,1,2:
  begin
   for i := 0 to MENUCOUNT[Menu.Screen]-1 do
    begin
     glColor3f(0,1,0);
     if i=Menu.Position then glColor3f(1,0,0);
     ogl.TextOut(0,512-60,300+i*40,PCHAR(MENUTEXT[Menu.Screen,i]));
    end;
  end;

  3: ogl.TextOut(0,512-60,360,PCHAR('Выбери уровень: '+ inttostr(SelectedLevel)));
  4: ogl.TextOut(0,512-60,360,PCHAR(Menu.CurText));
  5:
   begin
    for i := 1 to 10 do
    begin
     s:=Scores.Items[i].Name;
     ogl.TextOut(0,350,200+i*30,PCHAR(s));
     ogl.TextOut(0,650,200+i*30,PCHAR(inttostr(Scores.Items[i].Score)));
    end;
   end;
  6:
   begin
    ogl.TextOut(0,200,350,Pchar('ENTER YOUR NAME: '+PlayerName));
   end;
  7:
   begin
    glColor3f(0,1,0);
    ogl.TextOut(0,250,300,'Программирование');
    glColor3f(1,1,1);
    ogl.TextOut(0,270,360,'Сидоренко Никита(Division)');
    ogl.TextOut(0,300,380,'Division88@list.ru');
    glColor3f(0,1,0);
    ogl.TextOut(0,250,420,'Графика');
    glColor3f(1,1,1);
    ogl.TextOut(0,270,480,'Осмоловский Михаил(`e)');
   end; 
  end;

 glColor3f(1,1,1);

end;

procedure RenderETanks;
var
    T:PTank;
begin

 T:=Tank;
 while T^.Next<>nil do
 begin
  T:=T^.Next;
  with T^ do
  begin
   DrawTank(T^);
  end;
 end;

end;

procedure RenderHUD;
var i:integer;
begin
// glColor3f(0,0,0);
 if P1LIVES>0 then
 begin
  for i := 1 to P1LIVES do
   DrawQuad(PTank1.Texture,(i-1)*35+10,712,40,40,0);
  ogl.TextOut(0,10,768-10,PCHAR('Health: '+inttostr(PTank1.Health)+'   SCORE: '+inttostr(P1Score)));
 end;

 if GameParam.SecondPlayer and (P2LIVES>0) then
 begin
  for i := 1 to P2LIVES do
   DrawQuad(PTank1.Texture,1024-(i-1)*35-45,712,40,40,0);
   ogl.TextOut(0,1024-400,768-10,PCHAR('Health: '+inttostr(PTank2.Health)+'   SCORE: '+inttostr(P2Score)));
   ogl.TextOut(0,1024-650,725,PCHAR('TOTAL SCORE: '+inttostr(P2Score+P1Score)));
 end;
// glColor3f(1,1,1);
// ogl.TextOut(0,10,1024-40,PCHAR('LIVES: '+inttostr(P1LIVES)));
end;

procedure DrawFlash(x,y,angle:single; Tank:TTank);
var i:integer;
begin
 glPushMatrix;
 glColor3f(0,0.8,0.8);
 glTranslatef(X+32,Y+32,0);
 glRotatef(Angle,0,0,1);
 glBegin(GL_LINE_STRIP);
//  glVertex2f(-6,-32+5);
  for i := 1 to 6 do
  begin
   glVertex2f(-7+i*2,-32+Tank.FlashPoses[i]+5);
//   glVertex2f(-6+(i*2)*1.8,-32+Tank.FlashPoses[i*2]);
  end;
//  glVertex2f(32-6,-32+5);
 glEnd;
 glColor3f(1,1,1);
 glPopMatrix;

end;

end.
