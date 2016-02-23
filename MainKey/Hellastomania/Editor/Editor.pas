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

  Lines:array of TLine;
  CurLine:TLine;
  LastPoint,FirstPoint:TPoint;
  Pos,LineCount,EnemyCount,cx,cy,lx,ly:integer;
  AddFirst:boolean;

  Enemies:array of TEnemy;
  Start,Finish:TPoint;

  LGroup,SelGR:integer;

  SelEnemy:integer;


procedure SaveToFile(FileName:String);
procedure LoadFromFile(FileName:String);
procedure MapReset;
function GetGroup(x,y:integer):integer;
function GetEnemy(x,y:integer):integer;
procedure DeleteLines(Gr:integer);
procedure DeleteEnemy(e:integer);

implementation

{$R *.dfm}

procedure Render;
var i:TLine;
    j:TEnemy;
    sx,sy:single;
    v:TVector3;
    a:integer;
begin
  ogl.Clear;
  ogl.Set2D(0,0,450,450);
  glViewPort(0,0,450,450);

  glBegin(GL_LINES);
    if LineCount>0 then
    for i in lines do
      begin

        glColor3f(0.4,0.4,0.4);
        glVertex2f(i.v1.X,i.v1.Y);
        if (i.Group=SelGR) and (SelEnemy=-1) then glColor3f(1,0,0) else        
        glColor3f(1,1,1);
        glVertex2f(i.v2.X,i.v2.Y);
                 
        sx:=(i.v2.x+i.v1.x)/2;
        sy:=(i.v2.y+i.v1.y)/2;

        v:=Normalize(GetNormal2(Vector3(i.v1.X,i.v1.Y,0),Vector3(i.v2.x,i.v2.Y,0)));

        glColor3f(0,1,0);
        glVertex2f(sx,sy);
        glVertex2f(sx+v.x*10,sy+v.y*10);
        glColor3f(1,1,1);
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
        if a=SelEnemy then glColor3f(1,0,0) else        
        glColor3f(1,0,1);
        glVertex(j.X-10,j.Y);
        glVertex(j.X+10,j.Y);
        glVertex(j.X,j.Y-10);
        glVertex(j.X,j.Y+10);
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
      ogl.TextOut(0,j.X+2,j.Y+2,PCHAR(inttostr(j.Kind)));
    end;

  glPointSize(3);
  glBegin(GL_POINTS);
     for i in lines do
     begin
       glVertex2f(i.v2.X,i.v2.Y);
     end;
   glEnd;   
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
  if SelEnemy<>-1 then DeleteEnemy(SelEnemy);
  
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
            if AddFirst then
            begin
              CurLine.v2.X:=lx;
              CurLine.v2.Y:=ly;
              AddLine(CurLine,LGroup);
              CurLine.v1.X:=0;
              CurLine.v1.Y:=0;
              LastPoint:=Point(lx,ly);
              AddFirst:=false;
            end
            else
            begin
              CurLine.v1.X:=LastPoint.X;
              CurLine.v1.Y:=LastPoint.Y;
              CurLine.v2.X:=lx;
              CurLine.v2.Y:=ly;
              LastPoint:=Point(lx,ly);
              AddLine(CurLine,LGRoup);
            end;
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

    i:integer;
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
  write(f,h.Lines);
  Write(f,h.Enemies);
  Write(f,h.StX);
  Write(f,h.StY);
  Write(f,h.FX);
  Write(f,h.FY);

  if LineCount>0 then
  for i := 0 to LineCount-1 do
    begin
      Write(f,Lines[i].v1.X);
      Write(f,Lines[i].v1.Y);
      Write(f,Lines[i].v2.X);
      Write(f,Lines[i].v2.Y);
    end;

  if EnemyCount>0 then
  for i := 0 to EnemyCount-1 do
    begin
      Write(f,Enemies[i].X);
      Write(f,Enemies[i].Y);
      Write(f,Enemies[i].Kind);
    end;

  CloseFile(f);
end;

procedure MapReset;
begin
 LineCount:=0;
 EnemyCount:=0;
 SetLength(Lines,LineCOunt);
 SetLength(Enemies,EnemyCount);
 Finish.X:=0;
 Finish.Y:=0;
 Start.X:=0;
 Start.Y:=0;

 eX.Render;
end;

procedure LoadFromFile(FileName:String);
var f:file of Integer;
    h:THeader;
    i:integer;

    a:TObject;
    b:TUDBtnType;
begin
  MapReset;

  AssignFile(f,FileName);
  Reset(f);
  
  Read(f,h.Scale);
  Read(f,h.Lines);
  Read(f,h.Enemies);

  Read(f,h.StX);
  Read(f,h.StY);
  Read(f,h.FX);
  Read(f,h.FY);

  LineCount:=h.Lines;
  EnemyCount:=h.Enemies;
  Start.X:=h.StX;
  Start.Y:=h.StY;
  Finish.X:=h.FX;
  Finish.Y:=h.FY;
  form1.Scale.position:=h.Scale;
  if LineCount>0 then
  SetLength(Lines,LineCount);
  if EnemyCount>0 then
  SetLength(Enemies,EnemyCount);

  if LineCount>0 then        
  for i := 0 to LineCount-1 do
    begin
      Read(f,Lines[i].v1.X);
      Read(f,Lines[i].v1.Y);
      Read(f,Lines[i].v2.X);
      Read(f,Lines[i].v2.Y);
    end;

  if EnemyCount>0 then
  for i := 0 to EnemyCount-1 do
    begin
      Read(f,Enemies[i].X);
      Read(f,Enemies[i].Y);
      Read(f,Enemies[i].Kind);
    end;

  CloseFile(f);

  eX.Render;

  form1.scale.onclick(a,b);
end;

function GetGroup(x,y:integer):integer;
var i:integer;
    h,lh:single;

function Circ(x,y,r:single):TCircle;
begin
  Result.x:=x;
  Result.y:=y;
  Result.Radius:=r;
end;

begin
  lh:=10;
  result:=-1;
  for i := 0 to LineCount - 1 do
  begin
    if LineVsCircle(Vector3(Lines[i].v1.x,Lines[i].v1.y,0),Vector3(Lines[i].v2.x,Lines[i].v2.y,0),Circ(x,y,10),h)
     then if lh>h then
                     begin
                       lh:=h;
                       Result:=Lines[i].Group;
                     end;
  end;

end;

procedure DeleteLines(Gr:integer);
var i:integer;
    Del:integer;
begin
  i:=-1;
  Del:=0;
  while i<LineCount-1 do
  begin
    inc(i);
    if Lines[i].Group=Gr then
    begin
      Lines[i]:=Lines[High(Lines)-Del];
      inc(Del);
    end;
  end;
  Dec(LineCount,Del);
  SetLength(Lines,LineCount);
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
  for i := 0 to EnemyCount - 1 do
    begin
      h:= Dist(Enemies[i].x,Enemies[i].y,x,y);
      if (h<10) and (h<lh) then
        begin
          lh:=h;
          result:=i;
        end;
    end;
end;

procedure DeleteEnemy(e:integer);
begin
  Enemies[e]:=Enemies[High(Enemies)];
  Dec(EnemyCount);
  SetLength(Enemies,EnemyCount);
end;


end.
