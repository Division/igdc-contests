unit Editor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, eXgine, OpenGL, Menus, ComCtrls, Physics;


const POS_REST=0;
      POS_ADDPOINT=1;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    menu: TPopupMenu;
    N11: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    Edit1: TEdit;
    scale: TUpDown;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    Memo1: TMemo;
    Label1: TLabel;
    N6: TMenuItem;
    procedure N6Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure scaleClick(Sender: TObject; Button: TUDBtnType);
    procedure Button4Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure N31Click(Sender: TObject);
    procedure N21Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N11Click(Sender: TObject);
    procedure Panel1MouseLeave(Sender: TObject);
    procedure Panel1MouseEnter(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


TPolygon=record
   Vertexes:array of TPoint;
end;


THeader=record
  Lines:integer;
  Enemies:integer;
  StX,StY,FX,FY,Scale:integer;
end;

TLine=record
  v1,v2:TPoint;
  Group:integer;
end;

TEnemy=record
  x,y:integer;
  Kind:integer;
end;


var
  Form1: TForm1;

  Polygons:array of TPolygon;
  Lines:array of TLine;
  CurLine:TLine;
  LastPoint,FirstPoint:TPoint;
  Pos,LineCount,EnemyCount,cx,cy,lx,ly:integer;
  AddFirst:boolean;

  Enemies:array of TEnemy;
  Killers:array of TEnemy;
  Start,Finish:TPoint;

  LGroup,SelGR:integer;

  SelEnemy:integer;

  PolygonCount, KillerCOunt:integer;

  SKiller:boolean;

procedure PreparePolygons;
procedure SaveToFile(FileName:String);
procedure LoadFromFile(FileName:String);
procedure MapReset;
function GetGroup(x,y:integer):integer;
function GetEnemy(x,y:integer):integer;
procedure DeleteLines(Gr:integer);
procedure DeleteEnemy(e:integer);
procedure DeleteKiller(k:integer);

implementation

{$R *.dfm}

procedure Render;
var i:integer;
    j:TEnemy;
    sx,sy:single;
    v:TVector3;
    a:integer;
begin
  ogl.Clear;
  ogl.Set2D(0,0,450,450);
  glViewPort(0,0,450,450);

  glBegin(GL_LINES);
    if PolygonCount>0 then
    for i := 0 to PolygonCount-1 do
      begin
      for a := 0 to High(Polygons[i].Vertexes)-1 do
      begin
        glColor3f(0.4,0.4,0.4);
        glVertex2f(Polygons[i].Vertexes[a].X,Polygons[i].Vertexes[a].y);

        if (i=SelGR) and (SelEnemy=-1) then glColor3f(1,0,0) else
        glColor3f(1,1,1);
        glVertex2f(Polygons[i].Vertexes[a+1].X,Polygons[i].Vertexes[a+1].y);
      end;
      
      if POS<>POS_ADDPOINT then
      begin
        glColor3f(0.4,0.4,0.4);
        glVertex2f(Polygons[i].Vertexes[High(Polygons[i].Vertexes)].X,Polygons[i].Vertexes[High(Polygons[i].Vertexes)].y);
        if (i=SelGR) and (SelEnemy=-1) then glColor3f(1,0,0) else
        glColor3f(1,1,1);
        glVertex2f(Polygons[i].Vertexes[0].X,Polygons[i].Vertexes[0].y);
      end;
      end;

    if Pos=POS_ADDPOINT then
    begin
      glVertex2f(LastPoint.X,LastPoint.Y);
      glVertex2f(cx,cy);
    end;

    a:=-1;
    if EnemyCount>0 then
    for j in Enemies do
      begin
        inc(a);
        if (a=SelEnemy) and not SKiller then glColor3f(1,0,0) else
        glColor3f(1,0,1);
        glVertex(j.X-10,j.Y);
        glVertex(j.X+10,j.Y);
        glVertex(j.X,j.Y-10);
        glVertex(j.X,j.Y+10);
      end;

    a:=-1;
    if KillerCount>0 then
    for i :=0 to KillerCount-1 do
      begin
        inc(a);
        if (a=SelEnemy) and SKiller then glColor3f(1,0,0) else
        glColor3f(1,1,1);
        glVertex(Killers[i].X-10,Killers[i].Y);
        glVertex(Killers[i].X+10,Killers[i].Y);
        glVertex(Killers[i].X,Killers[i].Y-10);
        glVertex(Killers[i].X,Killers[i].Y+10);
      end;

//  Старт
    glColor3f(0,1,0);
    glVertex(Start.X-10,Start.Y);
    glVertex(Start.X+10,Start.Y);
    glVertex(Start.X,Start.Y-10);
    glVertex(Start.X,Start.Y+10);

//  Финиш
    glColor3f(1,0,0);
    glVertex(Finish.X-10,Finish.Y);
    glVertex(Finish.X+10,Finish.Y);
    glVertex(Finish.X,Finish.Y-10);
    glVertex(Finish.X,Finish.Y+10);

//  Курсор
    glColor3f(1,1,1);
    glVertex(cx-(10- form1.scale.Position/10),cy);
    glVertex(cx+(10- form1.scale.Position/10),cy);
    glVertex(cx,cy-(10- form1.scale.Position/10));
    glVertex(cx,cy+(10- form1.scale.Position/10));
  glEnd;

  ogl.TextOut(0,Start.X+2,Start.Y+2,'S');
  ogl.TextOut(0,Finish.X+2,Finish.Y+2,'F');


  if EnemyCount>0 then
  for j in Enemies do
    begin
      ogl.TextOut(0,j.X+2,j.Y+2,'E');
    end;

  if KillerCount>0 then
  for i := 0 to KillerCount-1 do
    begin
      ogl.TextOut(0,Killers[i].X+2,Killers[i].Y+2,'K');
    end;


    ogl.TextOut(0,10,10,PCHAR(inttostr(selgr)));

end;

procedure AddLine(L:TLine; Group:integer);
begin
  inc(LineCount);
  SetLength(Lines,LineCount);
  Lines[High(Lines)]:=l;
  Lines[High(Lines)].Group:=Group;
end;

procedure AddEnemy(x,y:integer;kind:integer);
begin
  Inc(EnemyCount);
  SetLength(Enemies,EnemyCount);
  Enemies[High(Enemies)].X:=x;
  Enemies[High(Enemies)].Y:=y;
  Enemies[High(Enemies)].Kind:=Kind;
end;

procedure AddKiller(x,y:integer);
begin
  Inc(KillerCount);
  SetLength(Killers,KillerCount);
  Killers[High(Killers)].X:=x;
  Killers[High(Killers)].Y:=y;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if SaveDialog1.Execute then SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  MapReset;
end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  OpenDialog1.InitialDir:=ExtractFilePath(paramstr(0));
  SaveDialog1.InitialDir:=ExtractFilePath(paramstr(0));
  wnd.Create(panel1.Handle);
  ex.SetProc(PROC_RENDER,@render);
  Pos:=POS_REST;
  LineCount:=0;
  inp.MCapture(false);
  glClearColor(0,0,0,0);
  eX.Render;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
  eX.Render;
end;

procedure TForm1.N11Click(Sender: TObject);
begin
  AddEnemy(lx,ly,1);
end;

procedure TForm1.N21Click(Sender: TObject);
begin
  AddEnemy(lx,ly,2);
end;

procedure TForm1.N2Click(Sender: TObject);
begin
  if (SelGr<>-1) and (SelEnemy=-1) then DeleteLines(SelGR);
  if SelEnemy<>-1 then
    begin
      if not SKiller then DeleteEnemy(SelEnemy)
        else DeleteKiller(SelEnemy);
    end;
  
end;

procedure TForm1.N31Click(Sender: TObject);
begin
 AddEnemy(lx,ly,3);
end;

procedure TForm1.N3Click(Sender: TObject);
begin
  Start.X:=lx;
  Start.Y:=ly;
end;

procedure TForm1.N4Click(Sender: TObject);
begin
  Finish.X:=lx;
  Finish.Y:=ly;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  AddKiller(lx,ly);
end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  lx:=x;
  ly:=y;
  if ssShift in shift then
    begin
      lx:=cx;
      ly:=cy;
    end;
    
  case button of
    mbLeft:
    begin
      case Pos of
        POS_REST:
          begin
            inc(PolygonCount);
            SetLength(Polygons,PolygonCount);
            SetLength(Polygons[High(Polygons)].Vertexes,1);
            Polygons[High(Polygons)].Vertexes[High(Polygons[High(Polygons)].Vertexes)]:=Point(lx,ly);

            CurLine.v1.X:=lx;
            CurLine.v1.Y:=ly;
            LastPoint:=Point(lx,ly);
            FirstPoint:=LastPoint;
            Pos:=POS_ADDPOINT;
            AddFirst:=true;
            Inc(LGroup);
          end;
        POS_ADDPOINT:
          begin
            SetLength(Polygons[High(Polygons)].Vertexes,Length(Polygons[High(Polygons)].Vertexes)+1);
            Polygons[High(Polygons)].Vertexes[High(Polygons[High(Polygons)].Vertexes)]:=Point(lx,ly);
            LastPoint:=Point(lx,ly);
          end;
      end;
    end;
    mbRight:
    begin
      case Pos of
        POS_ADDPOINT:
        begin
          CurLine.v1.X:=LastPoint.X;
          CurLine.v1.Y:=LastPoint.Y;
          CurLine.v2.X:=FirstPoint.X;
          CurLine.v2.Y:=FirstPoint.Y;
          AddLine(CurLine,LGroup);
          Pos:=POS_REST;
        end;
        POS_REST:
        begin
          menu.Popup(form1.Left+x+Panel1.Left+BorderWidth,form1.Top+y+Panel1.Top+(Height-ClientHeight));
        end;
      end;
    end;

  end;
end;

procedure TForm1.Panel1MouseEnter(Sender: TObject);
begin
  showcursor(false);
end;

procedure TForm1.Panel1MouseLeave(Sender: TObject);
begin
  showcursor(true);
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 eX.Render;

 SelGR:=GetGroup(x,y);
 SelEnemy:=GetEnemy(x,y);

 if (Pos=POS_REST) or (not (ssShift in shift)) then
 begin
   cx:=x;
   cy:=y;
 end
 else
   if ssShift in shift then
     begin
       if abs(LastPoint.X-x)>abs(LastPoint.Y-y) then
       begin
         cx:=x;
         cy:=LastPoint.Y;
       end
       else
       begin
         cy:=y;
         cx:=LastPoint.X;
       end;
     end;
end;

procedure TForm1.scaleClick(Sender: TObject; Button: TUDBtnType);
begin
  Edit1.Text:=FloatTostr(scale.Position/10);
end;

procedure SaveToFile(FileName:String);
type TVertex=record
               x,y:integer;
             end;
var f:file of integer;
    H:THeader;

    i,j,t:integer;

begin
  h.Lines:=LineCount;
  h.Enemies:=EnemyCount;
  h.StX:=Start.X;
  h.StY:=Start.Y;
  h.FX:=Finish.X;
  h.FY:=Finish.Y;
  h.Scale:=form1.Scale.Position;

  AssignFile(f,FileName);
  Rewrite(f);
  Write(f,h.Scale);
  write(f,PolygonCount);
  Write(f,h.Enemies);
  Write(f,h.StX);
  Write(f,h.StY);
  Write(f,h.FX);
  Write(f,h.FY);

  if PolygonCount>0 then
  for i := 0 to PolygonCount-1 do
    begin
    t:=Length(Polygons[i].Vertexes);
    Write(f,t);
    for j := 0 to t - 1 do
      begin
        Write(f,Polygons[i].Vertexes[j].X);
        Write(f,Polygons[i].Vertexes[j].Y);
      end;
    end;

  if EnemyCount>0 then
  for i := 0 to EnemyCount-1 do
    begin
      Write(f,Enemies[i].X);
      Write(f,Enemies[i].Y);
    end;

  write(f,KillerCount);

  if KillerCount>0 then
  for i := 0 to KillerCount-1 do
    begin
      Write(f,Killers[i].X);
      Write(f,Killers[i].Y);
    end;


  CloseFile(f);
end;

procedure MapReset;
begin
 LineCount:=0;
 EnemyCount:=0;
 PolygonCount:=0;
 KillerCount:=0;
 SetLength(Killers,KillerCount);
 SetLength(Lines,LineCount);
 SetLength(Enemies,EnemyCount);
 SetLength(Polygons,PolygonCount);

 Finish.X:=0;
 Finish.Y:=0;
 Start.X:=0;
 Start.Y:=0;

 eX.Render;
end;

procedure LoadFromFile(FileName:String);
var f:file of Integer;
    h:THeader;
    i,j,t:integer;

    a:TObject;
    b:TUDBtnType;
begin
  MapReset;

  AssignFile(f,FileName);
  Reset(f);

  Read(f,h.Scale);
  Read(f,PolygonCount);
  Read(f,h.Enemies);

  Read(f,h.StX);
  Read(f,h.StY);
  Read(f,h.FX);
  Read(f,h.FY);

  EnemyCount:=h.Enemies;
  Start.X:=h.StX;
  Start.Y:=h.StY;
  Finish.X:=h.FX;
  Finish.Y:=h.FY;
  form1.Scale.position:=h.Scale;

  SetLength(Polygons,PolygonCount);

  if EnemyCount>0 then
  SetLength(Enemies,EnemyCount);

  if PolygonCount>0 then
  for i := 0 to PolygonCount-1 do
    begin
    Read(f,t);
    SetLength(Polygons[i].Vertexes,t);
    for j := 0 to t - 1 do
      begin
        Read(f,Polygons[i].Vertexes[j].X);
        Read(f,Polygons[i].Vertexes[j].Y);
      end;
    end;

  if EnemyCount>0 then
  for i := 0 to EnemyCount-1 do
    begin
      Read(f,Enemies[i].X);
      Read(f,Enemies[i].Y);
    end;

  Read(f,KillerCount);
  SetLength(Killers,KillerCount);
  if KillerCount>0 then
  for i := 0 to KillerCount - 1 do
    begin
      Read(f,Killers[i].x);
      Read(f,Killers[i].y);      
    end;
  

  CloseFile(f);

  eX.Render;

  form1.scale.onclick(a,b);
end;

function GetGroup(x,y:integer):integer;
var i,j:integer;
    h,lh:single;

function Circ(x,y,r:single):TCircle;
begin
  Result.x:=x;
  Result.y:=y;
  Result.Radius:=r;
end;

function Vec(a:TPoint):TVector3;
begin
  result.x:=a.x;
  result.y:=a.y;
  result.z:=0;
end;

begin
  lh:=10;
  result:=-1;
  if PolygonCount>0 then  
  for i := 0 to PolygonCount - 1 do
  begin
    for j := 0 to High(Polygons[i].Vertexes)-1 do
      if LineVsCircle(Vec(Polygons[i].Vertexes[j]),Vec(Polygons[i].Vertexes[j+1]),Circ(x,y,10),h) then
        if lh>h then
          begin
            lh:=h;
            Result:=i;
          end;

    if LineVsCircle(Vec(Polygons[i].Vertexes[High(Polygons[i].Vertexes)]),Vec(Polygons[i].Vertexes[0]),Circ(x,y,10),h) then
        if lh>h then
          begin
            lh:=h;
            Result:=i;
          end;
  end;

end;

procedure DeleteLines(Gr:integer);
var i:integer;
    Del:integer;
begin
  Polygons[Gr]:=Polygons[High(Polygons)];
  Dec(PolygonCount);
  SetLength(Polygons,PolygonCount);
end;

function GetEnemy(x,y:integer):integer;
var i:integer;
    h,lh:single;

function Dist(x1,y1,x2,y2:single):Single;
begin
  result:=sqrt(sqr(x2-x1)+sqr(y2-y1));
end;

begin
  lh:=10;
  result:=-1;
  SKiller:=false;
  for i := 0 to EnemyCount - 1 do
    begin
      h:= Dist(Enemies[i].x,Enemies[i].y,x,y);
      if (h<10) and (h<lh) then
        begin
          lh:=h;
          result:=i;
        end;
    end;
  if KillerCount>0 then
  for i := 0 to KillerCount - 1 do
    begin
      h:= Dist(Killers[i].x,Killers[i].y,x,y);
      if (h<10) and (h<lh) then
        begin
          lh:=h;
          result:=i;
          SKiller:=true;
        end;
    end;

     
end;

procedure DeleteEnemy(e:integer);
begin
  Enemies[e]:=Enemies[High(Enemies)];
  Dec(EnemyCount);
  SetLength(Enemies,EnemyCount);
end;


procedure DeleteKiller(k:integer);
begin
  Killers[k]:=Killers[High(Killers)];
  Dec(KillerCount);
  SetLength(Killers,KillerCount);
end;

procedure PreparePolygons;
var i,t,PCount,gr:integer;
    arr:set of byte;
begin
  PCount:=0;
  arr:=[];
  for i := 0 to LineCount - 1 do
    begin
      gr:=Lines[i].Group;
      if not gr in arr then
        begin
          arr:=arr+[gr];
          inc(PCount);
        end;
    end;
  PolygonCount:=PCount;
  SetLength(Polygons,PCount);
end;

end.
