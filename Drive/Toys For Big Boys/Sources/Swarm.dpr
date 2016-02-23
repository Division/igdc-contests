program Swarm;
uses
  Windows,
  eXgine,
  dMath,
  dglOpenGL,
  dMeshes,
  dParticlesQ in 'dParticlesQ.pas',
  dConsole in 'dConsole.pas',
  ConsoleFunctions in 'ConsoleFunctions.pas',
  dPhysics in 'dPhysics.pas',
  variables in 'variables.pas',
  dMap in 'dMap.pas',
  dCamera in 'dCamera.pas',
  dCars in 'dCars.pas',
  utils in 'utils.pas',
  dGameManager in 'dGameManager.pas',
  dMenu in 'dMenu.pas';

function v3f(x,y,z:single):TVector3f;
begin
  result.x:=x;
  result.y:=y;
  result.z:=z;
end;

{$REGION 'Render'}
procedure Render;
var v:TVector3;
begin
  CurTime:=eX.GetTime;
  if GameManager.GamePos >= 1 then
    dt := (CurTime-LastTime)/1000*UPS; // »нтерпол€ци€ (:

  Camera.Interp;
  
  ogl.Clear(true,true);

  glColor3f(1,1,1);

  ogl.Set3D(45,10,1000);

  v.From(0,-0,0);

  glRotatef(180,0,0,1);
  glRotatef(180,0,1,0);

//  v.From(0,0,-10);

//  glLightfv(GL_LIGHT0,GL_POSITION,@v);

  glTranslatef(-camera.CurPos.x,-camera.CurPos.y,camera.CurPos.z);

  GameManager.Render;     

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0, 0 + wnd.Width, 0 + wnd.Height, 0, -1000, 100);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glViewPort(0,0,wnd.Width,wnd.Height);
  glColor3f(1,1,1);

  Console.Render;

  if GameManager.GamePos = 0 then  
    Menu.Render;

  if ShowFPS = 1 then
    ogl.TextOut(0,10,10,PCHAR(inttostr(ogl.FPS)));
end;
{$ENDREGION}

{$REGION 'Update'}
procedure Update;
begin
  if not Console.Active then
  begin
    if inp.LastKey = 27 then
      begin
        Menu.Esc;
      end;
  end;

  Console.Update;

  if GameManager.GamePos >= 1 then
    begin
      GameManager.Update;
      Camera.Update;
    end
  else
    Menu.Update;

  LastTime:=eX.GetTime;
end;
{$ENDREGION}

{$REGION 'Initialize'}
begin
  ReportMemoryLeaksOnShutdown := True;

  Randomize;
  ogl.VSync(false);
  wnd.Mode(true,1024,768,32,75);

  log.Flush(true);

  wnd.Create('SWARM',false);
  eX.SetProc(PROC_UPDATE,@Update);
  eX.SetProc(PROC_RENDER,@Render);

  inp.MCapture(false);

  InitOpenGL;

  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  glEnable(GL_DEPTH_TEST);
  glCullFace(GL_BACK);
  glDisable(GL_CULL_FACE);

  glShadeModel(GL_SMOOTH);

  glEnable(GL_NORMALIZE);

  ShowCursor(false);

  Init;

  camera.Pos.z := 850;

  eX.MainLoop(UPS);

  FreeMeshes;

  GameManager.Destroy;  
  Map.Destroy;
  Menu.Destroy;
  camera.Free;
  Console.Free;
  PartEng.Free;
{$ENDREGION}

end.
