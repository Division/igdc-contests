library eXgine;
//=====================================//
//  Created by XProger                 //
//  mail : XProger@list.ru             //
//  site : http://xproger.mirgames.ru  //
//=====================================//

uses
  Windows,
// функции и перехват исключений
  sys_main in 'sys_main.pas',
// загрузка графических форматов файлов
  g_tga in 'g_tga.pas',
  g_bjg in 'g_bjg.pas',
// модули eXgine
  com in 'com.pas', // описание интерфейсов
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
//  "eXgine" по сути является надстройкой над рядом API
//  Писал его по большей части для себя, с целью уменьшения кода "системщины"
// в испольняемом файле программы, за счёт незначительного увеличения размера дистрибутива :)
//
// Движок состоит из семи основных частей (интерфейсов):
// - Engine  - общий класс движка
// - Log     - класс отвечающий за сообщения и ведение лога работы приложения
// - Window  - обеспечивает работу с видеорежимами и окном приложения
// - Input   - отвечает за обработку ввода с клавиатуры, мыши и джойстика
// - OpenGL  - надстройка над OpenGL API с целью упрощения некоторых операций
// - VBuffer - удобная надстройка над VBO для вывода многополигональной геометрии
// - Shader  - обеспечивает простую работу с вершинными и фрагментными программами
// - Texure  - содержит менеджер текстур форматов tga, bmp, jpg и gif (без анимации)
// - Sound   - вывод многопоточного 3D звука, и потоковое проигрывание аудио и видео форматов
// - Vector  - элементарная векторная алгебра
//
//  Властью данной мне повелеваю: делать с представленным кодом всё что угодно
// без каких либо ограничений, но при условии сохранения моего авторского права ;)
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
