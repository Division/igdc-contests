program SatanBok;
uses
  Windows,
  eXgine,
  OpenGL,
  Physics,
  Utilite in 'Utilite.pas',
  Game in 'Game.pas',
  Rendering in 'Rendering.pas',
  Map in 'Map.pas',
  Particles;



procedure Render;
begin
 glClearColor(0.0,0.0,0.0,0);
 glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT);
 glViewPort(0,0,800,600);
 ogl.Set2D(0,0,800,600);
 CurTime:=eX.GetTime;
 dtime:=CurTime-LastTime;
 Camera.SmX:=Camera.PX+(Camera.X-Camera.PX)*(dtime/(1000/UPS));
 Camera.SmY:=Camera.PY+(Camera.Y-Camera.PY)*(dtime/(1000/UPS));

 ogl.TextOut(f,5,5,PCHAR(inttostr(ogl.FPS)));

 case GamePos of
   P_GAME:RenderGame;
   P_MENU:RenderMenu;
 end;


end;

procedure Update;
begin
 case GamePos of
   P_GAME:UpdateGame;
   P_MENU:UpdateMenu;
 end;     
end;

begin
 Randomize;
 ogl.VSync(true);
 wnd.Mode(true,800,600,32,75);
 wnd.Create('SatanBok');
 eX.SetProc(PROC_UPDATE,@Update);
 eX.SetProc(PROC_RENDER,@Render);

 Init;


 eX.MainLoop(UPS);
end.
