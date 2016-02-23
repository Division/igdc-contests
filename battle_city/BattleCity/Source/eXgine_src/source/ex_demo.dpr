program ex_demo;
//////////////////////////////
// ������������ ������ ������
//////////////////////////////
uses
  OpenGL,
  eXgine in '..\eXgine.pas';
// ��� ���������� ����� ���������� � ���� exe (�� ������������ eXgine.dll)
// �������� EX_STATIC � eXgine.pas

var
  obj   : GLUquadricObj;
  Angle : Single;
  
procedure Update;
begin
// ��������� ���� ��������
  Angle := Angle + 0.01;
// ����� �� ������� Escape (��� ������� 27)
  if inp.Down(27) then eX.Quit;
end;

procedure Render;
var
  i : Integer;
begin
  ogl.Clear(True, True);
  ogl.Set3D(45, 0.1, 512);
// ���������
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

// ����� ����������
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
// ������������� ��������
  obj := gluNewQuadric;
  glEnable(GL_CULL_FACE);
  glEnable(GL_LIGHT0);
// ��������� �������������� ������
  wnd.Mode(True, 640, 480, 16, 85);
// ���� � ������� ����
  eX.MainLoop(50);
end.

