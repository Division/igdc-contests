unit dMap;

interface

uses dMath, eXgine , Classes, SysUtils, dglOpenGL, dCamera, dMeshes;

const UNITSIZE = 1;

type
  TRoadElem  = record
    v,n:TVector3;
    Radius : single;
  end;

  asd = record
    v:TVector3;
    Radius : single;
  end;

  TLine = record
    v1,v2:TVector3;
    n:TVector3;
  end;

  TObj = record
    v:TVector3;
    Angle : Single;
    index:integer;
  end;

  TMap = class
    constructor Create;
    destructor Destroy; override;
    private
      fPointCount : integer;
      fObjCount : integer;
      fRoadMesh : TMesh;
      fTableTex : TTexture;
      fTableTexSize : integer;
      fRoadTexSize : integer;
      fLapCount : integer;
    public
      Road : array of TRoadElem;
      Bounds : array of TLine;
      Objects : array of TObj;
      StartPoint:integer;
      
      property PointCount:integer read fPointCount;
      property LapCount :integer read fLapCount;
      procedure LoadFromFile(filename:string);
      procedure GenerateRoadMesh;
      procedure CalculateBounds;
      function Visible(v:TVector3) : boolean;
      procedure Render2D;
      procedure Render;
      procedure SetFlag;
      procedure RenderTable;
  end;

implementation

uses Variables;

constructor TMap.Create;
begin
  fPointCount := 0;
  fRoadMesh := TMesh.Create;
  fRoadMesh.LoadTexture('data\textures\road.jpg');
  fTableTex := tex.Load('data\textures\table.jpg');
  fTableTexSize:=512;
  fRoadTexSize := 512;
end;

destructor TMap.Destroy;
begin
  fRoadMesh.Free;
end;

procedure TMap.LoadFromFile(filename: string);
var ff:TFileStream;
    i:integer;
begin
  ff:=TFileStream.Create(filename,fmOpenRead);
  ff.Read(fPointCount,sizeof(integer));
  ff.Read(fObjCount,sizeof(integer));
  ff.Read(StartPoint,sizeof(integer));
  ff.Read(fLapCount,sizeof(integer));      

  SetLength(Road,fPointCount);
  SetLength(Objects,fObjCount);
  for i := 0 to fPointCount - 1 do
    begin
      ff.Read(Road[i].v,sizeof(TVector3));
      ff.Read(Road[i].Radius,sizeof(single));
    end;

  for i := 0 to fObjCount - 1 do
    begin
      ff.Read(Objects[i],sizeof(TObj));
    end;

  ff.Destroy;

  inc(fPointCount);
  SetLength(Road,fPointCount);
  Road[fPointCount-1] := Road[0];

  CalculateBounds;
  GenerateRoadMesh;
end;

procedure TMap.GenerateRoadMesh;
var i:integer;
begin
  SetLength(fRoadMesh.Vertex,Length(Bounds)*3);
  SetLength(fRoadMesh.TexCoord,length(fRoadMesh.Vertex));
  SetLength(fRoadMesh.Normal,length(fRoadMesh.Vertex));
  SetLength(fRoadMesh.Face,Length(Bounds));

  fRoadMesh.F_Count := length(fRoadMesh.Face);
  fRoadMesh.V_Count := length(fRoadMesh.Vertex);
  
  for i := 0 to high(fRoadMesh.Face) do
    begin
      fRoadMesh.Face[i][0]:=i*3;
      fRoadMesh.Face[i][1]:=i*3+1;
      fRoadMesh.Face[i][2]:=i*3+2;
    end;
  with fRoadMesh do
  begin
  for i := 0 to High(Bounds) do
    begin
      Vertex[i*3] := Bounds[i].v2;
      Vertex[i*3+1] := Bounds[i].v1;

      if i < High(Bounds) then
        begin
          if i mod 2 = 0 then
            Vertex[i*3+2] := Bounds[i+1].v2
          else
            Vertex[i*3+2] := Bounds[i+1].v1;
        end
      else
        begin
          if i mod 2 = 0 then
            Vertex[i*3+2] := Bounds[0].v2
          else
            Vertex[i*3+2] := Bounds[0].v1;
        end;  
    end;

  for i := 0 to High(Vertex) do
    begin
      TexCoord[i].X :=trunc(Vertex[i].x) / fRoadTexSize*2;
      TexCoord[i].Y := trunc(Vertex[i].y) / fRoadTexSize*2;
    end; 
  end;

end;

procedure TMap.Render2D;
var i:integer;
    v1,v2:TVector3;
begin
  if fPointCount > 0 then
    begin
      glBegin(GL_LINES);
      for i:=0 to fPointCount - 2 do
        begin
          glColor3f(1,1,1);
          v1:=Road[i].v;
          v2:=Road[i+1].v;
          glVertex2f(v1.x*UNITSIZE-camera.Pos.x,v1.y*UNITSIZE-camera.Pos.y);
          glVertex2f(v2.x*UNITSIZE-camera.Pos.x,v2.y*UNITSIZE-camera.Pos.y);
          glVertex2f(v1.x*UNITSIZE-camera.Pos.x,v1.y*UNITSIZE-camera.Pos.y);
          glVertex2f(v1.x*UNITSIZE + Road[i].n.x*50-camera.Pos.x,v1.y*UNITSIZE +Road[i].n.y*50-camera.Pos.y);
        end;
      for i:=0 to High(Bounds) do
        begin
          glColor3f(1,1,1);
          glVertex2f(Bounds[i].v1.x*UNITSIZE-camera.Pos.x,Bounds[i].v1.y*UNITSIZE-camera.Pos.y);
          glColor3f(1,0,0);
          glVertex2f(Bounds[i].v2.x*UNITSIZE-camera.Pos.x,Bounds[i].v2.y*UNITSIZE-camera.Pos.y);
          v1:=(Bounds[i].v1 + Bounds[i].v2) / 2 * UNITSIZE - Vector3(camera.Pos.x,camera.Pos.y,0);
          v2:=v1+Bounds[i].n*20;
          glVertex2fv(@v1);
          glVertex2fv(@v2);
        end;
      glEnd;
      glColor3f(1,1,1);
    end;
end;

procedure TMap.CalculateBounds;
var i:integer;
    n,n1,n2,v1,v2,v3:TVector3;
begin

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
      v1:=Road[i].v+n*Road[i].Radius*UNITSIZE;
      v2:=Road[i+1].v+n*Road[i+1].Radius*UNITSIZE;
      if i>0 then
        begin
          v1 := (v1+Bounds[(i-1)*2].v2)/2;
          Bounds[(i-1)*2].v2 := v1;
        end;

      Bounds[i*2].v1 := v1;
      Bounds[i*2].v2 := v2;

      v1:=Road[i].v-n*Road[i].Radius*UNITSIZE;
      v2:=Road[i+1].v-n*Road[i+1].Radius*UNITSIZE;
      if i>0 then
        begin
          v1 := (v1+Bounds[(i-1)*2+1].v1)/2;
          Bounds[(i-1)*2+1].v1 := v1;
        end;
      Bounds[i*2+1].v1 := v2;
      Bounds[i*2+1].v2 := v1;
    end;

  Bounds[0].v1 := (Bounds[0].v1+Bounds[High(Bounds)-1].v2)/2;
  Bounds[High(Bounds)-1].v2 := Bounds[0].v1;
  Bounds[1].v2 := (Bounds[1].v2+Bounds[High(Bounds)].v1)/2;
  Bounds[High(Bounds)].v1 := Bounds[1].v2;

  for i := 0 to High(Bounds) do
    Bounds[i].n:=Normalize(GetNormal2(Bounds[i].v2,Bounds[i].v1));

  SetFlag;
end;

procedure TMap.Render;
var i:integer;
begin
  glDisable(GL_LIGHTING);
    glColor3f(1,1,1);
    fRoadMesh.Render;
  glEnable(GL_LIGHTING);
    if fObjCount>0 then
      for i := 0 to fObjCount - 1 do
        if Visible(Objects[i].v) then        
        begin
          if Objects[i].index=22 then
            glDisable(GL_LIGHTING);
          inc(ObjRender);
          glPushMatrix;
            glTranslatef(Objects[i].v.x,Objects[i].v.y,0);
            glRotatef(180,1,0,0);
            glRotatef(Objects[i].Angle+180,0,0,1);
            ObjMeshes[Objects[i].index].Render;
          glPopMatrix;
          if Objects[i].index=22 then
            glEnable(GL_LIGHTING);
        end;

  RenderTable;
end;

procedure TMap.RenderTable;
const size = 500;
      rc = 2;
var dv:single;
begin
  dv := (size+fTableTexSize) / rc;

  glDepthMask(FALSE);

  glTranslatef(Camera.CurPos.x,Camera.CurPos.y,0.02);

  tex.Enable(fTableTex);
  glColor3f(1,1,1);
  glDisable(GL_LIGHTING);
  glBegin(GL_QUADS);
    glTexCoord2f(Camera.CurPos.x/dv,Camera.CurPos.y/dv);
    glVertex3f(-size,-size,0);

    glTexCoord2f(Camera.CurPos.x/dv,Camera.CurPos.y/dv+rc);
    glVertex3f(-size, size,0);

    glTexCoord2f(Camera.CurPos.x/dv+rc,Camera.CurPos.y/dv+rc);
    glVertex3f( size, size,0);

    glTexCoord2f(Camera.CurPos.x/dv+rc,Camera.CurPos.y/dv);
    glVertex3f( size,-size,0);
  glEnd;
  glEnable(GL_LIGHTING);
  tex.Disable();
  glDepthMask(TRUE);  
end;

function TMap.Visible(v:TVector3) : boolean;

const RANGE = sqr(800);

function SqRad(v1,v2:TVector3) : Single;
begin
  Result:=sqr(v1.x-v2.x) + sqr(v1.y-v2.y);
end;
begin
  Result := SqRad(Camera.CurPos,v) < RANGE;  
end;

procedure TMap.SetFlag;
var v1,v2:TVector3;
    a:single;
begin
  v1:=Road[StartPoint].v;
  v2:=v1+Road[StartPoint].n;

  a:=360 - arcTan2(v2.y-v1.y,v2.x-v1.x)*rad2deg;

  inc(fObjCount,2);
  SetLength(Objects,fObjCount);
  Objects[High(Objects)].v := Bounds[StartPoint*2].v1;
  Objects[High(Objects)].index := 22;
  Objects[High(Objects)].Angle := a;

  Objects[High(Objects)-1].v := Bounds[StartPoint*2+1].v2;
  Objects[High(Objects)-1].index := 22;
  Objects[High(Objects)-1].Angle := a+ 180;
end;

end.
