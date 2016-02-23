library eXgine;
//=====================================//
//  Created by XProger                 //
//  mail : XProger@list.ru             //
//  site : http://xproger.mirgames.ru  //
//=====================================//

uses
  Windows,
// ������� � �������� ����������
  sys_main in 'sys_main.pas',
// �������� ����������� �������� ������
  g_tga in 'g_tga.pas',
  g_bjg in 'g_bjg.pas',
// ������ eXgine
  com in 'com.pas', // �������� �����������
  eng in 'eng.pas',
  log in 'log.pas',
  wnd in 'wnd.pas',
  inp in 'inp.pas',
  ogl in 'ogl.pas',
  vbo in 'vbo.pas',
  tex in 'tex.pas',
  vfp in 'vfp.pas',
  snd in 'snd.pas',
  vec in 'vec.pas';

procedure Copyright;
begin
//  "eXgine" �� ���� �������� ����������� ��� ����� API
//  ����� ��� �� ������� ����� ��� ����, � ����� ���������� ���� "����������"
// � ������������ ����� ���������, �� ���� ��������������� ���������� ������� ������������ :)
//
// ������ ������� �� ���� �������� ������ (�����������):
// - Engine  - ����� ����� ������
// - Log     - ����� ���������� �� ��������� � ������� ���� ������ ����������
// - Window  - ������������ ������ � ������������� � ����� ����������
// - Input   - �������� �� ��������� ����� � ����������, ���� � ���������
// - OpenGL  - ���������� ��� OpenGL API � ����� ��������� ��������� ��������
// - VBuffer - ������� ���������� ��� VBO ��� ������ ������������������ ���������
// - Shader  - ������������ ������� ������ � ���������� � ������������ �����������
// - Texure  - �������� �������� ������� �������� tga, bmp, jpg � gif (��� ��������)
// - Sound   - ����� �������������� 3D �����, � ��������� ������������ ����� � ����� ��������
// - Vector  - ������������ ��������� �������
//
//  ������� ������ ��� ���������: ������ � �������������� ����� �� ��� ������
// ��� ����� ���� �����������, �� ��� ������� ���������� ����� ���������� ����� ;)
end;

procedure exInit(out Engine: IEngine; LogFile: PChar);
begin
  if oeng = nil then
  begin
    olog := TLog.CreateEx;
    if LogFile <> nil then
      olog.Create(LogFile);
    ovec := TVec.CreateEx;
    oeng := TEng.CreateEx;
    osnd := TSnd.CreateEx;
    oinp := TInp.CreateEx;
    oogl := TOGL.CreateEx;
    ovbo := TVBO.CreateEx;
    otex := TTex.CreateEx;
    ownd := TWnd.CreateEx;
    ovfp := TVFP.CreateEx;
  end;
  Engine := oeng;
end;

exports
  Copyright name #13#10#13#10'<<< ' + ENG_NAME + ' ' + ENG_VER + ' by XProger >>>'#13#10#13#10,
  exInit;

begin
end.
