program ex_demo;
//////////////////////////////
// Демонстрация работы движка
//////////////////////////////
uses
  OpenGL,
  eXgine in '..\eXgine.pas';
// для компиляции всего приложения в один exe (не использовать eXgine.dll)
// объявите EX_STATIC в eXgine.pas

var
  obj   : GLUquadricObj;
  Angle : Single;
  
procedure Update;
begin
// Изменение угла поворота
  Angle := Angle + 0.01;
// Выход по нажатии Escape (код клавиши 27)
  if inp.Down(27) then eX.Quit;
end;

procedure Render;
var
  i : Integer;
begin
  ogl.Clear(True, True);
  ogl.Set3D(45, 0.1, 512);
// Отрисовка
  glEnable(GL_DEPTH_TEST);
  glEnable(GL_LIGHTING);

  ogl.Blend(BT_ADD);
  glTranslatef(0, 0, -16);
  glRotatef(Angle * rad2deg, sin(Angle), cos(Angle), sin(Angle));
  for i := 0 to 4 do
  begin
    glColor3f(sin(Angle), i/16, cos(Angle));
    gluSphere(obj, 1 + i, 4, 2);
  end;

// Вывод статистики
  glDisable(GL_DEPTH_TEST);
  glDisable(GL_LIGHTING);
  ogl.Set2D(0, 0, wnd.Width, wnd.Height);
  glColor3f(0.1, 0.8, 0.1);
  ogl.TextOut(0, 8, 16, PChar('FPS: ' + IntToStr(ogl.FPS)));
end;

begin
  wnd.Create(PChar(eX.Version + ' demo'));
  eX.SetProc(PROC_UPDATE, @Update);
  eX.SetProc(PROC_RENDER, @Render);
// Инициализация ресурсов
  obj := gluNewQuadric;
  glEnable(GL_CULL_FACE);
  glEnable(GL_LIGHT0);
// Установка полноэкранного режима
  wnd.Mode(True, 640, 480, 16, 85);
// Вход в главный цикл
  eX.MainLoop(50);
end.

