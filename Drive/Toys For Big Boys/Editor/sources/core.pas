unit core;

interface

uses dMath, dglOpenGL, eXgine, SysUtils, Classes, dialogs, dMeshes;

CONST UNITSIZE = 10;

type

TRoadElemSize = record
  v:TVector3;
  Radius:single;
end;

TRoadElem = record
  v:TVector3;
  Radius:single;
  n:TVector3;
end;

TLine = record
  v1,v2,n:TVector3;
end;

TElement = record
  v:TVector3;
  Angle : single;
  index:integer;
end;

TEditManager = class
  constructor Create;
  private
    fPointCount : integer;
    fObjCount : integer;
    fWidth, fHeight : integer;
    fSelCount:integer;
    fEditRoad : boolean;
  public
    Scale : Single;
    CamX,CamY : integer;
    GridEnable : boolean;
    GridFreq : single;

    StartPoint:integer;

    Selected : array of integer;
    ObjMeshes : array of TMesh;
    Objects : array of TElement;
    Road:array of TRoadElem;

    Bounds : array of TLine;

    property PointCount:integer read fPointCount;
    property Width:integer read fWidth;
    property Height:integer read fHeight;
    property EditRoad:boolean write fEditRoad;
    property SelCount : integer read fSelCount;
    procedure SelectNone;
    procedure AddPoint(v:TVector3; R:single = 1; Position:integer = - 1);
    procedure AddElement(v:TVector3; index:integer; Angle:Single=0);
    procedure Zoom(k:single; x,y:integer);
    procedure Scroll(x,y:integer);
    procedure Render;
    function IsSelected(index:integer):boolean;
    procedure DrawGrid;
    procedure SetAngle(ang:Single);
    procedure Select(v1,v2:TVector3; sroad:boolean);
    procedure SetSize(w,h:integer);
    procedure SetRoadWidth(r:single);
    procedure SetStart(s:integer);
    procedure Delete(droad:boolean);
    procedure Reset;
    procedure Move(v:TVector3);
    procedure Save(filename:string);
    procedure Load(filename:string);
    procedure CalculateBounds;
end;

var EditManager :TEditManager;

implementation

uses editor3;

constructor TEditManager.Create;
var i:integer;
begin
  StartPoint:=0;
  fPointCount:=0;
  fEditRoad:=true;
  Scale := 1;
  CamX := -100;
  CamY := -100;
  GridEnable := true;
  GridFreq := 5;
  SetLength(ObjMeshes,22);

  for i := 0 to 21 do
    ObjMeshes[i] := TMesh.Create;

  ObjMeshes[0]:=TMesh.Create;

  ObjMeshes[0].LoadFromFile('..\data\meshes\izmeritel.mdl');
  ObjMeshes[0].LoadTexture('..\data\textures\objects\izmeritel.jpg');

  ObjMeshes[1].LoadFromFile('..\data\meshes\cap.mdl');
  ObjMeshes[1].LoadTexture('..\data\textures\objects\cap.jpg');

  ObjMeshes[2].LoadFromFile('..\data\meshes\calendar.mdl');
  ObjMeshes[2].LoadTexture('..\data\textures\objects\calendar.jpg');

  ObjMeshes[3].LoadFromFile('..\data\meshes\telephone.mdl');
  ObjMeshes[3].LoadTexture('..\data\textures\objects\telephone.jpg');  

  ObjMeshes[4].LoadFromFile('..\data\meshes\stepler.mdl');
  ObjMeshes[4].LoadTexture('..\data\textures\objects\stepler.jpg');

  ObjMeshes[5].LoadFromFile('..\data\meshes\skrepka_st.mdl');
  ObjMeshes[5].LoadTexture('..\data\textures\objects\skrepka_st.jpg');

  ObjMeshes[6].LoadFromFile('..\data\meshes\skrepka.mdl');
//  ObjMeshes[6].LoadTexture('..\data\textures\objects\skrepka.jpg');

  ObjMeshes[7].LoadFromFile('..\data\meshes\cigaret.mdl');
  ObjMeshes[7].LoadTexture('..\data\textures\objects\cigaret.jpg');

  ObjMeshes[8].LoadFromFile('..\data\meshes\pen.mdl');
  ObjMeshes[8].LoadTexture('..\data\textures\objects\pen.jpg');

  ObjMeshes[9].LoadFromFile('..\data\meshes\podstavka.mdl');
  ObjMeshes[9].LoadTexture('..\data\textures\objects\podstavka.jpg');

  ObjMeshes[10].LoadFromFile('..\data\meshes\cigaret_box.mdl');
  ObjMeshes[10].LoadTexture('..\data\textures\objects\cigaret_box.jpg');

  ObjMeshes[11].LoadFromFile('..\data\meshes\papka.mdl');
  ObjMeshes[11].LoadTexture('..\data\textures\objects\papka.jpg');

  ObjMeshes[12].LoadFromFile('..\data\meshes\nojnici.mdl');
  ObjMeshes[12].LoadTexture('..\data\textures\objects\nojnici.jpg');

  ObjMeshes[13].LoadFromFile('..\data\meshes\monitor.mdl');
  ObjMeshes[13].LoadTexture('..\data\textures\objects\monitor.jpg');

  ObjMeshes[14].LoadFromFile('..\data\meshes\rooler.mdl');
  ObjMeshes[14].LoadTexture('..\data\textures\objects\rooler.jpg');

  ObjMeshes[15].LoadFromFile('..\data\meshes\eracer.mdl');
  ObjMeshes[15].LoadTexture('..\data\textures\objects\eracer.jpg');

  ObjMeshes[16].LoadFromFile('..\data\meshes\book.mdl');
  ObjMeshes[16].LoadTexture('..\data\textures\objects\book.jpg');

  ObjMeshes[17].LoadFromFile('..\data\meshes\disc.mdl');
  ObjMeshes[17].LoadTexture('..\data\textures\objects\disc.jpg');

  ObjMeshes[18].LoadFromFile('..\data\meshes\paper.mdl');
  ObjMeshes[18].LoadTexture('..\data\textures\objects\paper.jpg');

  ObjMeshes[19].LoadFromFile('..\data\meshes\paper_m.mdl');
  ObjMeshes[19].LoadTexture('..\data\textures\objects\paper.jpg');

  ObjMeshes[20].LoadFromFile('..\data\meshes\cube.mdl');
  ObjMeshes[20].LoadTexture('..\data\textures\objects\cube.jpg');

//  ObjMeshes[21].LoadFromFile('..\data\meshes\smallcar.mdl');
//  ObjMeshes[21].LoadTexture('..\data\textures\objects\smallcar.jpg');


end;

procedure TEditManager.Reset;
begin
  fPointCount:=0;
  fObjCount := 0;
  Objects := nil;
  Road := nil;
  CamX := 0;
  CamY := 0;
  Scale := 1;
  CalculateBounds;
end;

procedure TEditManager.Delete(droad:boolean);
begin
  if droad then
    begin
      if fPointCount = 0 then exit;
      
      dec(fPointCount);
      SetLength(Road,fPointCount);
      CalculateBounds;
    end
  else
    begin
      if fObjCount = 0 then exit;    
      dec(fObjCount);
      SetLength(Objects,fObjCount);
    end;
end;

procedure TEditManager.SetSize(w: Integer; h: Integer);
begin
  fWidth := w;
  fHeight := h;
end;

procedure TEditManager.Scroll(x: Integer; y: Integer);
begin
  CamX := CamX + x;
  CamY := CamY + y;
end;

procedure TEditManager.Zoom(k:single; x,y:integer);
begin
  Scale := Scale + k;
  if Scale < 0.1 then Scale := 0.1;
  if Scale > 3 then Scale := 3;  
end;

procedure TEditManager.AddPoint(v:TVector3; R:single=1; Position:integer = - 1);
begin
  inc(fPointCount);
  SetLength(Road,fPointCount);
  v:=Vector3(CamX,CamY,0)/Scale+v/Scale;
  if Position = -1 then
    begin
      Road[fPointCount-1].v := v;
      Road[fPointCount-1].Radius := R;
    end;
  CalculateBounds;  
end;

procedure TEditManager.Render;
var i:integer;
    n:TVector3;
begin
  glPushMatrix;
  glTranslatef(-CamX,-CamY,0);
  glScalef(Scale,Scale,0);

  if fObjCount > 0 then
  for i := 0 to fObjCount - 1 do
    begin
      glPushMatrix;
        glTranslatef(Objects[i].v.x,Objects[i].v.y,0);
        glScalef(-1,1,1);
        glRotatef(Objects[i].Angle,0,0,1);
        if not fEditRoad then
        if IsSelected(i) then
          glColor3f(1,0,0)
        else
          glColor3f(1,1,1);

        if form3.wire.Checked then
          ObjMeshes[Objects[i].index].Textured := false
        else
          ObjMeshes[Objects[i].index].Textured := true;

        ObjMeshes[Objects[i].index].Render;
      glPopMatrix;
    end;

  glColor3f(1,1,1);

  glClear(GL_DEPTH_BUFFER_BIT);  
  glBegin(GL_LINES);
  if length(Bounds) > 4 then
    begin
      for i := 4 to High(Bounds) do
        begin
          glVertex2fv(@Bounds[i].v1);
          glVertex2fv(@Bounds[i].v2);

          // ¨æ
        end;

      for i := 0 to fPointCount - 2 do
        begin
          glVertex2fv(@Road[i]);
          glVertex2fv(@Road[i+1]);

          // ¨æ
{          n:=Normalize(GetNormal2(Road[i].v,Road[i+1].v))/Scale;
          glVertex2f(Road[i].v.x-n.x*Road[i].Radius*Scale/2,Road[i].v.y-n.y*Road[i].Radius*Scale/2);
}//          glVertex2f(Road[i].v.x+n.x*Road[i].Radius*Scale/2,Road[i].v.y+n.y*Road[i].Radius*Scale/2);
        end;
    end;
  glEnd;

  glColor3f(1,1,1);  
  glBegin(GL_POINTS);
  if fPointCount > 0 then
    begin
      for i := 0 to fPointCount - 1 do
        begin
          if fEditRoad then
        if IsSelected(i) then
          glColor3f(1,0,0)
        else
          begin
            if i = StartPoint then
              begin
                glColor3f(0,1,0);
              end
            else
              begin
                glPointSize(4);
                glColor3f(1,1,1);
              end;
          end;

          glVertex2fv(@Road[i]);
        end;
    end;
  glEnd;



  glPopMatrix;
  DrawGrid;
  glColor4f(1,1,1,1);

  ogl.TextOut(0,10,10,PCHAR(IntToStr(CamX)+':'+IntToStr(CamY)));
  ogl.TextOut(0,10,30,PCHAR(FloatToStr(Scale)));
end;

procedure TEditManager.DrawGrid;
var i,cx,cy:integer;
    f:single;
    sx,sy:single;
begin
  f := GridFreq*UNITSIZE*Scale;
  cx := fWidth div trunc(f);
  cy := fHeight div trunc(f);
  sx := CamX mod trunc(f);
  sy := CamY mod trunc(f);  

  glEnable(GL_BLEND);
  ogl.Blend(BT_ADD);

  glColor4f(0.2,0.2,0.1,1);
  glBegin(GL_LINES);
    for i := 0 to cx do
      begin
        glVertex2f(i*f-sx,0);
        glVertex2f(i*f-sx,fHeight);
      end;
    for i := 0 to cy do
      begin
        glVertex2f(0,i*f-sy);
        glVertex2f(fWidth,i*f-sy);
      end;      
  glEnd;
  glDisable(GL_BLEND);
end;

procedure TEditManager.Load(filename: string);
var ff:TFileStream;
    i:integer;
    temp:integer;
begin
  ff:=TFileStream.Create(filename,fmOpenRead);
  ff.Read(fPointCount,sizeof(integer));
  ff.Read(fObjCount,sizeof(integer));
  ff.Read(StartPoint,sizeof(integer));
  ff.Read(temp,sizeof(integer));      
  SetLength(Road,fPointCount);
  SetLength(Objects,fPointCount);  
  for i := 0 to fPointCount - 1 do
    ff.Read(Road[i],sizeof(TRoadElemSize));
  for i := 0 to fObjCount - 1 do
    ff.Read(Objects[i],sizeof(TElement));
  ff.Destroy;
  CalculateBounds;

  form3.laps.Position := temp;  
end;

procedure TEditManager.Save(filename: string);
var ff:TFileStream;
    i:integer;
    temp:integer;
begin
  temp :=form3.laps.position;
  ff:=TFileStream.Create(filename,fmCreate);
  ff.Write(fPointCount,sizeof(integer));
  ff.Write(fObjCount,sizeof(integer));
  ff.Write(StartPoint,sizeof(integer));
  ff.Write(temp ,sizeof(integer));
  for i := 0 to fPointCount - 1 do
    ff.Write(Road[i],sizeof(TRoadElemSize));
  for i := 0 to fObjCount - 1 do
    ff.Write(Objects[i],sizeof(TElement));
  ff.Destroy;
end;

procedure TEditManager.AddElement(v: TVector3; index:integer; Angle: Single);
begin
  inc(fObjCount);

  SetLength(Objects,fObjCount);
  v:=Vector3(CamX,CamY,0)/Scale+v/Scale;
  Objects[High(Objects)].v:=v;
  Objects[High(Objects)].Angle:=Angle;
  Objects[High(Objects)].index:=index;
end;

procedure TEditManager.Select(v1: TVector3; v2: TVector3; sroad: Boolean);

var i:integer;

function InRect(v1,v2,p:TVector3):boolean;
begin
  result := (p.x>v1.x) and (p.x<v2.x) and (p.y>v1.y) and (p.y<v2.y);
end;

begin
  fSelCount:=0;

  v1:=Vector3(CamX,CamY,0)/Scale+v1/Scale;
  v2:=Vector3(CamX,CamY,0)/Scale+v2/Scale;  
    
  if sroad then
    begin
      for i := 0 to fPointCount - 1 do
        if InRect(v1,v2,Road[i].v) then
          begin
            inc(fSelCount);
            SetLength(Selected,fSelCount);
            Selected[fSelCount-1] := i;
          end;
    end
  else // Îáúåêòû
    begin
      for i := 0 to fObjCount - 1 do
        if InRect(v1,v2,Objects[i].v) then
          begin
            inc(fSelCount);
            SetLength(Selected,fSelCount);
            Selected[fSelCount-1] := i;
          end;
    end;
end;

function TEditManager.IsSelected(index: Integer):boolean;
var i:integer;
begin
  result:=false;
  if fSelCount>0 then
    for i := 0 to fSelCount - 1 do
      if Selected[i] = index then
        begin
          Result:=true;
          break;
        end;
end;

procedure TEditManager.SetAngle(ang: Single);
var i:integer;
begin
  if fSelCount>0 then
    for i := 0 to fSelCount - 1 do
      begin
        Objects[Selected[i]].Angle:=Ang;
      end;    
end;

procedure TEditManager.SelectNone;
begin
  fSelCount:=0;
  Selected := nil;
end;

procedure TEditManager.SetRoadWidth(r:single);
var i:integer;
begin
  if fEditRoad then
    for i := 0 to fSelCount - 1 do      
    begin
      Road[Selected[i]].Radius := r;    
    end;
  CalculateBounds;    
end;

procedure TEditManager.Move(v: TVector3);
var i:integer;
begin
  v:=v/Scale;
 
  if fSelCount>0 then
    for i := 0 to fSelCount-1 do
      begin
        if fEditRoad then
          Road[Selected[i]].v:=Road[Selected[i]].v+v
        else Objects[Selected[i]].v:=Objects[Selected[i]].v+v;
      end;
  CalculateBounds;      
end;

procedure TEditManager.CalculateBounds;
var i:integer;
    n,n1,n2,v1,v2,v3:TVector3;
    Koef:single;
begin
  koef:=1;

  Bounds:=nil;

  if (fPointCount <2) then exit;

  for i:=0 to fPointCount - 2 do
    begin
      v1:=Road[i].v;
      v2:=Road[i+1].v;
      if i=0 then
        v3:=Road[High(Road)].v
      else v3:=Road[i-1].v;

      n1 := GetNormal2(v1,v2);
      n2 := GetNormal2(v3,v1);
      Road[i].n := Normalize(n1+n2);
    end;

  SetLength(Bounds,(fPointCount-1)*2);
  for i:=0 to fPointCount - 2 do
    begin
      n:=Road[i].n;
      v1:=Road[i].v+n*Road[i].Radius*Koef;
      v2:=Road[i+1].v+n*Road[i+1].Radius*Koef;
      if i>0 then
        begin
          v1 := (v1+Bounds[(i-1)*2].v2)/2;
          Bounds[(i-1)*2].v2 := v1;
        end;

      Bounds[i*2].v1 := v1;
      Bounds[i*2].v2 := v2;

      v1:=Road[i].v-n*Road[i].Radius*Koef;
      v2:=Road[i+1].v-n*Road[i+1].Radius*Koef;
      if i>0 then
        begin
          v1 := (v1+Bounds[(i-1)*2+1].v1)/2;
          Bounds[(i-1)*2+1].v1 := v1;
        end;
      Bounds[i*2+1].v1 := v2;
      Bounds[i*2+1].v2 := v1;
    end;

{    if length(Bounds)>0 then
    begin
      Bounds[0].v1 := (Bounds[0].v1+Bounds[High(Bounds)-1].v2)/2;
      Bounds[High(Bounds)-1].v2 := Bounds[0].v1;
      Bounds[1].v2 := (Bounds[1].v2+Bounds[High(Bounds)].v1)/2;
      Bounds[High(Bounds)].v1 := Bounds[1].v2;
    end;}
    
    for i := 0 to High(Bounds) do
      Bounds[i].n:=Normalize(GetNormal2(Bounds[i].v2,Bounds[i].v1));
end;

procedure TEditManager.SetStart(s: Integer);
begin
  if (fSelCount=1) and fEditRoad then
    StartPoint:=Selected[0];  
end;

end.
