unit Editor3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, eXgine, core, dMath, dglOpenGL, OpenGL,StdCtrls, Menus, Math,
  ComCtrls, items;

const M_ROAD = 0;
      M_OBJ = 1;

type
  TForm3 = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    Panel2: TPanel;
    Panel3: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Button1: TButton;
    Button3: TButton;
    Edit1: TEdit;
    TrackBar1: TTrackBar;
    cbsel: TCheckBox;
    TrackBar2: TTrackBar;
    Edit2: TEdit;
    TrackBar3: TTrackBar;
    Edit3: TEdit;
    Button5: TButton;
    wire: TCheckBox;
    Button2: TButton;
    lb1: TListBox;
    Button4: TButton;
    Edit4: TEdit;
    laps: TUpDown;
    Label5: TLabel;
    procedure Button5Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure TrackBar3Change(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Panel1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public

    { Public declarations }
  end;

var
  Form3: TForm3;
  MRDOWN : boolean = false;
  BEND : boolean = false;
  SELECT:boolean = false;
  MOVE : boolean = false;
  SELSTART,SELEND:TVector3;
  BendSecond : TVector3;
  BendArray : array of TVector3;

  PX,PY,MX,MY : integer;
  mode : integer;

  Temp:single;

  qo : GLUquadricObj;

procedure BuildBendArray(v1,v2,v3:TVector3);

implementation

{$R *.dfm}

procedure Render;
var v:TVector3;
    i:integer;
begin
  glClearColor(0,0,0,1);
  ogl.Clear();

  if form3.wire.Checked then
    glPolygonMode(GL_FRONT_AND_BACK,GL_LINE)
  else
    glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);

  glMatrixMode(GL_PROJECTION);
  glLoadIdentity;
  glOrtho(0, 0 + Form3.Panel1.Width, 0 + Form3.Panel1.Height, 0, -1000, 100);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity;
  glViewPort(0,0,Form3.Panel1.Width,Form3.Panel1.Height);
  glColor3f(1,1,1);

  glDisable(GL_CULL_FACE);

  EditManager.Render;

  if BEND then
    with EditManager do
    begin
      if BendSecond.z = 0 then
      begin
        v := EditManager.Road[EditManager.PointCount-1].v;
        v:=v*Scale - Vector3(CamX,CamY,0);
        glBegin(GL_LINES);
          glVertex2fv(@v);
          glVertex2f(MX,MY);
        glEnd;
      end else
      begin
        v:= EditManager.Road[EditManager.PointCount-1].v;
        v:=v*Scale - Vector3(CamX,CamY,0);
        BuildBendArray(v,BendSecond-Vector3(CamX,CamY,1),Vector3(MX,MY,0));
        glBegin(GL_LINE_STRIP);

          glVertex2fv(@v);

          if Length(BendArray)>0 then          
          for i:=0 to high(BendArray) do
              begin
                glVertex2fv(@BendArray[i]);
              end;
        glEnd;
        glBegin(GL_POINTS);
          for i:=0 to high(BendArray) do
              begin
                glVertex2fv(@BendArray[i]);
              end;
        glEnd;
      end;
    end;

  if SELECT and not MOVE then
    begin
      glClear(GL_DEPTH_BUFFER_BIT);
      glBegin(GL_LINE_LOOP);
        glColor3f(1,0,0);
        glVertex2f(SELSTART.x,SELSTART.y);
        glVertex2f(SELSTART.x,SELEND.y);
        glVertex2f(SELEND.x,SELEND.y);
        glVertex2f(SELEND.x,SELSTART.y);
        glColor3f(1,1,1);
      glEnd;

    end;

    ogl.TextOut(0,10,50,PCHAR(FLoatToStr(Temp)));
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  EditManager.Delete(mode = M_ROAD);
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
  EditManager.CamX := 0;
  EditManager.CamY := 0;
end;

procedure TForm3.Button3Click(Sender: TObject);
begin
  if EditManager.PointCount = 0 then
    Exit;

  Bend := true;
  BendSecond.z := 0;
end;

procedure TForm3.Button4Click(Sender: TObject);
begin
  EditManager.Scale := 1;
end;

procedure TForm3.Button5Click(Sender: TObject);
begin
  if cbsel.Checked and (EditManager.SelCount>0) then
    begin
      MOVE := true;
    end;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  initOpenGL;

  wnd.Create(Panel1.Handle);
  eX.SetProc(PROC_RENDER,@Render);
  ShowCursor(true);

  lb1.ItemIndex := 0;

  glPointSize(4);
  qo := gluNewQuadric;
  EditManager := TEditManager.Create;
  EditManager.CamX:=0;
  EditManager.CamY:=0;  
end;

procedure TForm3.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 106 then
    EditManager.Scale := 1;
end;

procedure TForm3.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  EditManager.Zoom(-0.04,MX,MY);
end;

procedure TForm3.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  EditManager.Zoom(0.04,MX,MY);
end;

procedure TForm3.N2Click(Sender: TObject);
begin
  EditManager.Reset
end;

procedure TForm3.N3Click(Sender: TObject);
begin
  if SaveDialog1.Execute then
    EditManager.Save(SaveDialog1.FileName);
end;

procedure TForm3.N4Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
    EditManager.Load(OpenDialog1.FileName);
end;

procedure TForm3.Panel1Click(Sender: TObject);
begin
  eX.Render;
end;

procedure TForm3.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var i:integer;
begin
  if Button = mbRight then
    MRDOWN := true;

  if Button = mbLeft then
  begin
  if not cbsel.Checked then  
  case mode of
    M_ROAD:
      begin
        if BEND then
          with EditManager do
          begin
            if BendSecond.z=0 then
              begin
                BendSecond := Vector3(MX+EditManager.CamX,MY+EditManager.CamY,1);
              end
            else
              begin
                if length(BendArray)>0 then
                  begin
                    for i:=0 to high(BendArray) do
                      AddPoint(BendArray[i],TrackBar3.Position);
                  end;
                BendSecond.z := 0;
                BEND := false;
              end;
          end
        else
          EditManager.AddPoint(Vector3(X,Y,0),TrackBar3.Position);
      end;
    M_OBJ :
    begin
      if cbsel.Checked then
        begin
          SELECT := true;
        end
      else
        begin
          EditManager.AddElement(Vector3(x,y,0),lb1.ItemIndex);
        end;
    end;
  end
  else // Выбор
    begin
      SELECT:=true;
      SelStart := Vector3(x,y,0);
      SelEnd:=SelStart;
      if MOVE then
        begin
        
        end;
    end;

  end;

  if Button = mbMiddle then
    with EditManager do
      begin
        CamX := trunc(CamX + ((x-Width/2) ));
        CamY := trunc(CamY + ((y-Height/2))) ;
      end;
end;

procedure TForm3.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var v:TVector3;
var px,py:integer;
begin
  Edit1.SetFocus;
  px:=mx;
  py:=my;

  MX := x;
  MY := Y;

  if MRDOWN then
    begin
      EditManager.Scroll(PX-X,PY-Y);
    end;

  if SELECT then
    begin
      SELEND := vector3(x,y,0);
      if MOVE then
        begin
          EditManager.Move(Vector3(x-px,y-py,0));
        end;
    end;

  PX := x;
  PY := y;
  v:=vector3(x,y,0);
  with EditManager do
    v:=Vector3(CamX,CamY,0)/Scale+v/Scale;
  Label1.Caption := floattostr(v.X) + ':' + floattostr(v.Y);
end;

procedure TForm3.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);

var v1,v2:TVector3;  

begin
  if Button = mbRight then
    MRDOWN := false;

  if (Button = mbLeft) and SELECT then
    begin
      if not move then
      begin
        v1:=vmin(SELSTART,SELEND);
        v2:=vmax(SELSTART,SELEND);
        EditManager.Select(v1,v2, mode = M_ROAD);
        SELECT:=false;
      end else
      begin
        SELECT:=FALSE;
      end;
    end;
  MOVE := false;
end;

procedure TForm3.RadioButton1Click(Sender: TObject);
begin
  mode := M_ROAD;
  EditManager.EditRoad := true;
  EditManager.SelectNone;
end;

procedure TForm3.RadioButton2Click(Sender: TObject);
begin
  mode := M_OBJ;
  EditManager.EditRoad := false;
  EditManager.SelectNone;    
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  EditManager.SetSize(Panel1.Width,Panel1.Height);
  eX.Render;
end;

procedure TForm3.TrackBar1Change(Sender: TObject);
begin
  Edit1.Text := inttostr(TrackBar1.Position);
end;

procedure TForm3.TrackBar2Change(Sender: TObject);
begin
  Edit2.Text := inttostr(TrackBar2.Position);
  EditManager.SetAngle(TrackBar2.Position);
end;

procedure TForm3.TrackBar3Change(Sender: TObject);
begin
  Edit3.Text := inttostr(TrackBar3.Position);
  EditManager.SetRoadWidth(TrackBar3.Position);
end;

function GetCircleCenter(v1,v2,v3:TVector3):TVector3;
var ma,mb:single;
begin
  ma:= (v2.y-v1.y)/(v2.x-v1.x);
  mb:= (v3.y-v2.y)/(v3.x-v2.x);  
  with Result do
    begin
      x:=(ma*mb*(v1.y-v3.y)+mb*(v1.x+v2.x)-ma*(v2.x+v3.x))/(2*(mb-ma));
      y:=-(1/ma)*(x-(v1.x+v2.x)/2)+(v1.y+v2.y)/2;
      z:=0;
    end;
end;

procedure BuildBendArray(v1,v2,v3:TVector3);
var count,i:integer;
    center,v,n:TVector3;
    Rad,ang1,ang2:single;
begin
  count:=form3.TrackBar1.Position;

  center := GetCircleCenter(v3,v1,v2);
  
  Rad:=VecLength(v1,center);

  ang1 := arctan2(center.y-v1.y,center.x-v1.x);
  ang2 := arctan2(center.y-v2.y,center.x-v2.x);

  temp:=radtodeg(ang1-ang2);

  BendArray := nil;
  SetLength(BendArray,Count);

  glColor3f(1,0,0);
  glBegin(GL_POINTS);
    glVertex2fv(@center);
    glVertex2fv(@v1);
    glVertex2fv(@v2);
    glVertex2fv(@v3);
  glEnd;
  glColor3f(1,1,1);

  n:=Normalize(GetNormal2(v1,v2));

  for i:=0 to Count - 1 do
    begin
      v:=v1+normalize(v2-v1)*veclength(v2,v1)/(Count)*(i+1);
      v := center + Normalize(v-center)*rad;
      BendArray[i] := v;
    end;
end;

initialization
  chdir('..\release\data\');

end.
