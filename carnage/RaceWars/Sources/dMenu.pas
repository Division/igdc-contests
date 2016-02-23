(*

    Говноменю.
    Давно уже пора написать пристойный гуй...

*)

unit dMenu;

interface

uses eXgine, dglOpenGL, dMath, windows, dGameManager, SysUtils, dCars;

const P_MAINMENU = 0;
      P_NEWGAME = 1;
      P_ABOUT = 2;
      P_QUIT = 3;

type

TPos = record
  p:TVector3;
  w,h:integer;
  function Check(v:TVector3) : boolean;
end;

TMenu = class
constructor Create;
destructor Destroy; override;
private
  fMainBackTex : TTexture;
  fSecondBackTex : TTexture;
  fBack2 : TTexture;
  fTextures:array of array[0..1] of TTexture;
  fPosition: integer;
  fBtnCount:integer;
  fCoords : array of TPos;
  fActions:array of Procedure;
  fCarAngle : single;
  fCursor:TTexture;
public
  SelCar:integer;
  SelMap:integer;

  function LoadRect(name:String;index:integer=0) : cardinal;

  procedure DrawQuad(tx:TTexture; p:TVector3; w,h:integer; flip:boolean = false);
  procedure Update;
  procedure Render;
  procedure Esc;
  property Position:integer read fPosition write fPosition; 
end;

implementation

uses variables;

function TPos.Check(v: TVector3):boolean;
begin
  Result := (v.x > p.x - 20) and (v.x < p.x+w - 20) and
            (v.y > p.y- H/2) and (v.y < p.y+h-H/2);
end;

procedure pLeft;
begin
  case Menu.Position of
    1:
      begin
        dec(Menu.SelCar);
        if Menu.SelCar < 0 then Menu.SelCar := 5;
      end;
    2:
      begin
        dec(Menu.SelMap);
        if Menu.SelMap < 1 then Menu.SelMap := MAP_COUNT;
      end;
  end;
end;

procedure pRight;
begin
  case Menu.Position of
    1:
      begin
        inc(Menu.SelCar);
        if Menu.SelCar > 5 then Menu.SelCar := 0;
      end;
    2:
      begin
        inc(Menu.SelMap);
        if Menu.SelMap > MAP_COUNT then Menu.SelMap := 1;
      end;  
  end;
end;

procedure pNewGame;
begin
  Menu.Position := 1;
end;

procedure pContinue;
var i:integer;
begin
  if GameManager.CarCount > 0 then
    begin
      inp.MCapture(true);
      if GameManager.Finished then
        GameManager.GamePos := 2
      else
        begin
          GameManager.GamePos := 1;
          Menu.Position := 4;

          for i := 1 to GameManager.CarCount - 1 do
            (GameManager.Cars[i] as TAICar).LastTime:=eX.GetTime;
        end;
    end;
end;

procedure pAbout;
begin
  Menu.Position := 3;
end;

procedure pNext;
begin
  with menu do
    case Position of
      1:
        begin
          Menu.Position := 2;
        end;
      2:
        begin
          GameManager.Level := Menu.SelMap;
          GameManager.LoadLevel('map'+inttostr(Menu.SelMap));
        end;
      4:
        begin
          if GameManager.PlayerPlace <= 2 then
            GameManager.Level := GameManager.level+1;
            
          if not FileExists('Data/Maps/map'+inttostr(GameManager.Level)+'.map') then
            GameManager.Level := 1;
          GameManager.LoadLevel('map'+inttostr(GameManager.level));
        end;  
    end;
end;

procedure pQuit;
begin
  eX.Quit;
end;

function TMenu.LoadRect(name: string;index:integer) : cardinal;
var p:pointer;
    bpp,w,h,c,f : integer;
    res : Cardinal;
begin
  tex.Load(PCHar(name),w,h,bpp,p);
glGenTextures(1,@res);
glBindTexture(GL_TEXTURE_RECTANGLE_ARB,res);

  case bpp of
    8  : begin
           c := GL_LUMINANCE8;
           f := GL_LUMINANCE;
         end;
    24 : begin
           c := GL_RGB8;
           f := GL_BGR;
         end
    else
      c := GL_RGBA8;
      f := GL_BGRA;
  end;


//glTexParameteri(GL_TEXTURE_RECTANGLE_ARB,GL_TEXTURE_WRAP_S,GL_REPEAT);
//glTexParameteri(GL_TEXTURE_RECTANGLE_ARB,GL_TEXTURE_WRAP_T,GL_REPEAT);
//glTexParameteri(GL_TEXTURE_RECTANGLE_ARB,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
//glTexParameteri(GL_TEXTURE_RECTANGLE_ARB,GL_TEXTURE_MIN_FILTER,GL_NEAREST);

glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,0,c,w,h,
0,f,GL_UNSIGNED_BYTE,p);

result := res;
//  result := tex.Load(PChar(name));
end;

constructor TMenu.Create;
begin
  fMainBackTex := LoadRect('data\textures\buttons\back.jpg');
  fBack2 := LoadRect('data\textures\buttons\back2.jpg');

  fSecondBackTex := LoadRect('data\textures\buttons\logo2.jpg');


  fPosition:=0;
  fBtnCount := 8;
  SelCar := 0;
  SelMap := 1;
  fCarAngle := 90;

  SetLength(fTextures,fBtnCount);
  SetLength(fActions,fBtnCount);
  SetLength(fCoords,fBtnCount);

  fTextures[0][0] := LoadRect('data\textures\buttons\newgame.jpg');
  fTextures[0][1] := LoadRect('data\textures\buttons\newgameover.jpg');

  fTextures[1][0] := LoadRect('data\textures\buttons\continue.jpg');
  fTextures[1][1] := LoadRect('data\textures\buttons\continueover.jpg');

  fTextures[2][0] := LoadRect('data\textures\buttons\about.jpg');
  fTextures[2][1] := LoadRect('data\textures\buttons\aboutover.jpg');

  fTextures[3][0] := LoadRect('data\textures\buttons\quit.jpg');
  fTextures[3][1] := LoadRect('data\textures\buttons\quitover.jpg');

  fTextures[4][0] := LoadRect('data\textures\buttons\arr1.jpg');
  fTextures[4][1] := LoadRect('data\textures\buttons\arr2.jpg');

  fTextures[5][0] := fTextures[4][0];
  fTextures[5][1] := fTextures[4][1];

  fTextures[6][0] := LoadRect('data\textures\buttons\next.jpg');
  fTextures[6][1] := LoadRect('data\textures\buttons\nextover.jpg');

  fTextures[7][0] := fTextures[6][0];
  fTextures[7][1] := fTextures[6][1];

  fCursor := LoadRect('data\textures\cursor.tga');


fCoords[0].p.From(175,527,0);
  fCoords[0].w:=200;
  fCoords[0].h:=29;    

  fCoords[1].p.From(375 ,527,0);
  fCoords[1].w:=137;
  fCoords[1].h:=29;

  fCoords[2].p.From(512,527,0);
  fCoords[2].w:=136;
  fCoords[2].h:=29;

  fCoords[3].p.From(648,527,0);
  fCoords[3].w:=152;
  fCoords[3].h:=29;

  fCoords[4].p.From(387,527,0);
  fCoords[4].w:=27;
  fCoords[4].h:=29;

  fCoords[6].p.From(414,527,0);
  fCoords[6].w:=188;
  fCoords[6].h:=29;

  fCoords[5].p.From(602,527,0);
  fCoords[5].w:=27;
  fCoords[5].h:=29;

  fCoords[7].p.From(525,450,0);
  fCoords[7].w:=128;
  fCoords[7].h:=32;



{  fCoords[0].p.From(353-64,559,0);
  fCoords[0].w:=196;
  fCoords[0].h:=64;    

  fCoords[1].p.From(353+196/2+128/2-64,559,0);
  fCoords[1].w:=128;
  fCoords[1].h:=64;

  fCoords[2].p.From(353+196/2+128+128/2-64,559,0);
  fCoords[2].w:=128;
  fCoords[2].h:=64;

  fCoords[3].p.From(353+196/2+256+196/2-64,559,0);
  fCoords[3].w:=196;
  fCoords[3].h:=64;

  fCoords[4].p.From(353,559,0);
  fCoords[4].w:=196;
  fCoords[4].h:=64;

  fCoords[6].p.From(515,559,0);
  fCoords[6].w:=128;
  fCoords[6].h:=64;

  fCoords[5].p.From(677,559,0);
  fCoords[5].w:=196;
  fCoords[5].h:=64;

  fCoords[7].p.From(525,450,0);
  fCoords[7].w:=128;
  fCoords[7].h:=32;}

  fActions[0] := pNewGame;
  fActions[1] := pContinue;
  fActions[2] := pAbout;
  fActions[3] := pQuit;
  fActions[4] := pLeft;
  fActions[5] := pRight;
  fActions[6] := pNext;
  fActions[7] := pNext;              
end;

destructor TMenu.Destroy;
begin

end;

procedure TMenu.DrawQuad(tx:TTexture; p:TVector3; w,h:integer; flip:boolean = false);
begin
  glDisable(GL_TEXTURE_2D);
  glColor3f(1,1,1);
  glEnable(GL_TEXTURE_RECTANGLE_ARB);
  glBindTexture(GL_TEXTURE_RECTANGLE_ARB,tx);
glDisable(GL_LIGHTING);

glBegin(GL_QUADS);
    glTexCoord2f(0 + ord(flip)*w ,0);
    glVertex2f(p.x,p.y);

    glTexCoord2f(0 + ord(flip)*w ,h);
    glVertex2f(p.x,p.y+h);

    glTexCoord2f(w - ord(flip)*w,h);
    glVertex2f(p.x+w,p.y+h);

    glTexCoord2f(w-ord(flip)*w,0);
    glVertex2f(p.x+w,p.y);
  glEnd;

  glDisable(GL_TEXTURE_RECTANGLE_ARB);

  glEnable(GL_TEXTURE_2D);
  glEnable(GL_LIGHTING);
//  tex.Enable(tx);
{  glBegin(GL_QUADS);
    glTexCoord2f(0 + ord(flip),0);
    glVertex2f(p.x-w/2,p.y-h/2);

    glTexCoord2f(0 + ord(flip),1);
    glVertex2f(p.x-w/2,p.y+h/2);

    glTexCoord2f(1 - ord(flip),1);
    glVertex2f(p.x+w/2,p.y+h/2);

    glTexCoord2f(1 - ord(flip),0);
    glVertex2f(p.x+w/2,p.y-h/2);
  glEnd;}
//  tex.Disable();

end;

procedure TMenu.Update;
var i:integer;
    p:TPoint;
begin
  getCursorPos(p);
  case fPosition of
    0:
      for i := 0 to 3 do
      begin
        if (inp.LastKey = M_BTN_1) and (fCoords[i].Check(Vector3(p.x,p.y,0))) then
          begin
            fActions[i];
          end;        
      end;
    1:
      begin
        fCarAngle := fCarAngle + 1;
        for i := 4 to 6 do
        if (inp.LastKey = M_BTN_1) and (fCoords[i].Check(Vector3(p.x,p.y,0))) then
          begin
            fActions[i];
          end;
      end;
    2:
      begin
        for i := 4 to 6 do
        if (inp.LastKey = M_BTN_1) and (fCoords[i].Check(Vector3(p.x,p.y,0))) then
          begin
            fActions[i];
          end;      
      end;
    4:
      begin
        i:=7;
        if (inp.LastKey = M_BTN_1) and (fCoords[i].Check(Vector3(p.x,p.y,0))) then
          begin
            fActions[i];
          end;
      end;        
  end;
end;

procedure TMenu.Render;
var i :integer;
    p:TPoint;
begin
  getCursorPos(p);

  vfp.Disable;
  glDisable(GL_LIGHTING);


  case fPosition of
    0: // Главное меню
      begin
        DrawQuad(fMainBackTex,vector3(256,15,0),512,512);
        for i := 0 to 3 do
          begin
            DrawQuad(fTextures[i][ord(fCoords[i].Check(Vector3(p.x,p.y,0)))],fCoords[i].p,fCoords[i].w,fCoords[i].h);
          end;
        DrawQuad(fBack2,vector3(200,527,0),645,101);          
      end;
    1: // Выбор машины
      begin
        ogl.Set2D(0,0,wnd.Width,wnd.Height);
        DrawQuad(fSecondBackTex,vector3(256,15,0),512,512);
        for i := 4 to 6 do
          DrawQuad(fTextures[i][ord(fCoords[i].Check(Vector3(p.x,p.y,0)))],fCoords[i].p,fCoords[i].w,fCoords[i].h,i=4);

        DrawQuad(fBack2,vector3(200,527,0),645,101);
                  
        ogl.Set3D(60,10,1000);
        glEnable(GL_LIGHTING);
        glTranslatef(0,0,-100);
        glRotatef(-60,1,0,0);
        glRotatef(fCarAngle,0,0,1);
        glClear(GL_DEPTH_BUFFER_BIT);
        CarMeshes[SelCar].Render;
        glDisable(GL_LIGHTING);

        ogl.Set2D(0,0,wnd.Width,wnd.Height);
      end;
    2:
      begin
//        glEnable(GL_TEXTURE_2D);
        ogl.TextOut(0,100,400,PCHAR('Выбранная карта: '+inttostr(SelMap)));
        for i := 4 to 6 do
          DrawQuad(fTextures[i][ord(fCoords[i].Check(Vector3(p.x,p.y,0)))],fCoords[i].p,fCoords[i].w,fCoords[i].h,i=4);

        DrawQuad(fBack2,vector3(200,527,0),645,101);                  
      end;
    3:
      begin
        ogl.TextOut(0,700,595,'RaceWars');
        ogl.TextOut(0,580,620,'Разработчики:');
        ogl.TextOut(0,600,635,'Программирование: Сидоренко Никита (Division)');
        ogl.TextOut(0,600,655,'3D-моделирование, текстуры: Внуков Кирилл (Neyron)');
        ogl.TextOut(0,600,675,'Графика: Осмоловский Михаил');        
      end;
    4:
      begin
        i:=7;
        DrawQuad(fTextures[i][ord(fCoords[i].Check(Vector3(p.x,p.y,0)))],fCoords[i].p,fCoords[i].w,fCoords[i].h);
      end;
  end;

  glClear(GL_DEPTH_BUFFER_BIT);

  glPushMatrix;
//  glEnable(GL_BLEND);
  glTranslatef(8,17,0);
  DrawQuad(fCursor,Vector3(p.x,p.y,0),32,32);
//  glDisable(GL_BLEND);
  glPopMatrix;

  glEnable(GL_LIGHTING);
end;

procedure TMenu.Esc;
begin
  if GameManager.GamePos = 1 then
    begin
      GameManager.GamePos := 0;
      Position := 0;
      inp.MCapture(false);
    end
  else if GameManager.GamePos = 0 then
    begin
      if fPosition > 0 then
        begin
          if fPosition = 3 then
            fPosition := 0
          else dec(fPosition);
        end
      else
        if GameManager.CarCount > 0 then
          pContinue;
    end
  else
    begin
    
    end;  
end;

end.
