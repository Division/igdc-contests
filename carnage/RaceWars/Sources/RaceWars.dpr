program RaceWars;
uses
  Windows,
  eXgine,
  dMath,
  dglOpenGL,
  dShaderMan,
  sysutils,
  dConsole in 'dConsole.pas',
  ConsoleFunctions in 'ConsoleFunctions.pas',
  dPhysics in 'dPhysics.pas',
  variables in 'variables.pas',
  dMap in 'dMap.pas',
  dCamera in 'dCamera.pas',
  dCars in 'dCars.pas',
  utils in 'utils.pas',
  dGameManager in 'dGameManager.pas',
  dMenu in 'dMenu.pas',
  dAnimation in 'dAnimation.pas',
  dWeapons in 'dWeapons.pas',
  dCartridge in 'dCartridge.pas',
  dSky in 'dSky.pas',
  dParticleSystem in 'dParticleSystem.pas',
  dColor in 'dColor.pas',
  dParticles in 'dParticles.pas';

var _UPS : integer = 1;

{$REGION 'Render'}
procedure Render;
begin
  glClearColor(0,0.06666,0.1294,1);
  ObjRender := 0;
  CurTime:=eX.GetTime;
  if GameManager.GamePos >= 1 then
    begin
      dt := (CurTime-LastTime)/1000*UPS; // »нтерпол€ци€ (:
//      dt := min(1, (eX.GetTime - LastTime) / (_UPS));
    end;

  Camera.Interp;

  ogl.Clear(true,true);

  glColor3f(1,1,1);

  ogl.Set3D(45,10,10000);

  glRotatef(180,0,0,1);
  glRotatef(180,0,1,0);

  glTranslatef(-camera.CurPos.x,-camera.CurPos.y,camera.CurPos.z);
  // ¬идова€ матрица нужна дл€ шейдера бампа
  Camera.GetViewMatrix; // —читаем всЄ в координатах камеры
  // Ёто самый простой способ подогнать прошлогодний говнокод под крутые шойдеры (:

  GameManager.Render;
  ogl.Set3D(45,10,10000);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0, 0 + wnd.Width, 0 + wnd.Height, 0, -1000, 100);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glViewPort(0,0,wnd.Width,wnd.Height);
  glColor3f(1,1,1);

  if GameManager.GamePos = 0 then  
    Menu.Render;


  Console.Render;


end;
{$ENDREGION}

{$REGION 'Update'}
procedure Update;
var tmp:integer;
begin

  if not Console.Active then
  begin
    if inp.LastKey = 27 then
      begin
        Menu.Esc;
      end;
  end;

  Console.Update;

  if inp.LastKey = ord('E') then
    GameManager.CreateExplosion(ZeroVec,ZeroVEc);

  ParticleSystem.Update;

  if GameManager.GamePos >= 1 then
    begin
      GameManager.Update;
      Camera.Update;
    end
  else
    Menu.Update;

  tmp := eX.GetTime;
  _UPS := tmp-LastTime;
    
  LastTime:=tmp;
end;
{$ENDREGION}

{$REGION 'Initialize'}
begin

  ReportMemoryLeaksOnShutdown := True;

  Randomize;
  ogl.VSync(false);
  wnd.Mode(false,1024,768,32,75);

  log.Flush(false);

  wnd.Create('RaceWars',false);
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
  Finalize;
{$ENDREGION}

end.
