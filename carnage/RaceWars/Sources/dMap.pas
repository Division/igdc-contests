unit dMap;

interface

uses dMath, dShaderMan, eXgine , Classes, SysUtils, dglOpenGL, dCamera, dAnimation, dColor;

const UNITSIZE = 1;

      LINE_COLORS : array[0..2,0..3] of Single = ((0.39,0,1,1),(0,0.64,1,1),(1,0,0,1));

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

  TObjParams = record
    StartTime : integer;
    Period : integer;
    ColorIndex : integer;
  end;

  TGarbage = record
    model : integer;
    params : TObjParams;
    Position : TVector3;
    Dir : TVector3;
    Speed : Single;
    Rotation : TVector3;
    RSpeed : TVector3;
  end;

  TMap = class
    constructor Create;
    destructor Destroy; override;
    private
      fLineColor : TColor4;
      CIManager : TCIManager; // интерполиция цвета
      fPointCount : integer;
      fObjCount : integer;
      fRoadMat  : TMaterial;
      fRoadMesh : TMesh;
      fTableTex : TTexture;
      fTableTexSize : integer;
      fRoadTexSize : integer;
      fLapCount : integer;
      fObjParams : array of TObjParams;
      fColor: array[0..3] of Single; // Цвет полос на дороге(текущий)
      fNeedColor : array[0..3] of Single; // Цвет, к которому стремимся
      fLastColorUpd : integer; // Время последнего изменения fNeedColor
      fUpdFreq : integer;
      fLightVector : TVector3; // Вектор освещения
      fLightCount : integer; // Количество источников света для шейдера
      fcIndex : integer; // Индекс текущего цвета линий дороги - чтоб не повторяться
      fAnimation : TAnimation;
      fSunAng : Single; // Угол солнца
      fLastSunChange : integer;
      fSunDelay : integer;
      fNeedSun : single;

      fGarbageCount : integer;

      fMin : TVector3; // AABB карты
      fMax : TVector3;
      fMaxGarbage : integer;

      procedure UpdLightData;
      procedure RenderGarbage;
      procedure AddGarbage(Pos : TVector3);
      procedure UpdateGarbage;
      procedure InitGarbage;
      
    public
      LightPoses : array[0..5] of TVector3; // Позиции источников освещения для дороги 

      WeaponPoints : array of integer;
      Road : array of TRoadElem;
      Bounds : array of TLine;
      Objects : array of TObj;

      Garbage : array of TGarbage;

      StartPoint:integer;

      property Material : TMaterial read fRoadMat;      
      property PointCount:integer read fPointCount;
      property LapCount :integer read fLapCount;
      property GarbageCount : integer Read fGarbageCount;
      procedure LoadFromFile(filename:string);
      procedure GenerateRoadMesh;
      procedure CalculateBounds;
      function Visible(v:TVector3) : boolean;
      procedure Render2D;
      procedure Render;
      procedure SetFlag;
      procedure RenderTable;
      procedure Update;

  end;

implementation

uses Variables, dCars;

constructor TMap.Create;
var sh :PSh;
begin
  fPointCount := 0;

  CIManager := TCIManager.Create;

  with CIManager.AddInterp do
    begin
      AddColor4(Color4(1,0.54,0,1),0);
      AddColor4(Color4(1,0.54,0,1),0.3);

      AddColor4(Color4(0,0.64,1,1),0.3500);
      AddColor4(Color4(0,0.64,1,1),0.6500);

      AddColor4(Color4(1,0.2,0,1),0.7000);
      AddColor4(Color4(1,0.2,0,1),0.9500);
      
      AddColor4(Color4(1,0.54,0,1),1);
    end;

  fAnimation.LoopAnimation(0);
  fColor[0] := 1;
  fColor[1] := 1;
  fColor[3] := 1;
  fUpdFreq := 3000;
  fLightVector.From(0.2,1.0,0.6);

  fLightVector := normalize(fLightVector);

  ShMan.AddUniform('LightDir','objbump',SU_F3,@fLightVector);
  ShMan.AddUniform('LightDir','objdiffuse',SU_F3,@fLightVector);
  ShMan.AddUniform('LightDir','linebump',SU_F3,@fLightVector);
  ShMan.AddUniform('LineColor','linebump',SU_F3,@fLineColor);
  ShMan.AddUniform('LightDir','linediffuse',SU_F3,@fLightVector);
  ShMan.AddUniform('LineColor','linediffuse',SU_F3,@fLineColor);

  ShMan.AddUniform('clr','road',SU_F4,@fColor);
  ShMan.AddUniform('LightDir','road',SU_F3,@fLightVector);
  ShMan.AddUniform('Light0','road',SU_F3,@LightPoses[0]);
  ShMan.AddUniform('Light1','road',SU_F3,@LightPoses[1]);
  ShMan.AddUniform('Light2','road',SU_F3,@LightPoses[2]);
  ShMan.AddUniform('Light3','road',SU_F3,@LightPoses[3]);
  ShMan.AddUniform('Light4','road',SU_F3,@LightPoses[4]);
  ShMan.AddUniform('Light5','road',SU_F3,@LightPoses[5]);
  ShMan.AddUniform('LightCount','road',SU_I1,@fLightCount);
  fRoadMesh := TMesh.Create;
  fRoadMat.AddTexture(tex.Load('data\textures\road.jpg'));
  fRoadMat.AddTexture(tex.Load('data\textures\roadline.jpg'));
  fRoadMat.AddTexture(tex.Load('data\textures\bump.jpg'));  
  sh := ShMan.GetShaderByName('road');
  if sh <> nil then
    fRoadMat.SetShader(sh^.Shader);
  fTableTex := tex.Load('data\textures\table.jpg');
  fTableTexSize:=1024;
  fRoadTexSize := 512;

end;

destructor TMap.Destroy;
begin
  fRoadMesh.Free;
  CIManager.Destroy;
end;

procedure TMap.LoadFromFile(filename: string);
var ff:TFileStream;
    i,j,k:integer;
    Min,tmp : single;
begin
  ff:=TFileStream.Create(filename,fmOpenRead);
  ff.Read(fPointCount,sizeof(integer));
  ff.Read(fObjCount,sizeof(integer));
  ff.Read(StartPoint,sizeof(integer));
  ff.Read(fLapCount,sizeof(integer));

  SetLength(Road,fPointCount);
  SetLength(Objects,fObjCount);
  SetLength(fObjParams,fObjCount);
  for i := 0 to fPointCount - 1 do
    begin
      ff.Read(Road[i].v,sizeof(TVector3));
      ff.Read(Road[i].Radius,sizeof(single));
    end;

  WeaponPoints := nil;

  for i := 0 to fObjCount - 1 do
    begin
      ff.Read(Objects[i],sizeof(TObj));
      fObjParams[i].Period := 5000;
      fObjParams[i].StartTime :=eX.GetTime + random(fObjParams[i].Period);
      fObjParams[i].ColorIndex := 0;
    end;

  ff.Destroy;

  fMin := Road[0].v;
  fMax := Road[0].v;  
  for i := 0 to fPointCount - 1 do
    begin
      fMin := vmin(fMin,Road[i].v);
      fMax := vmax(fMax,Road[i].v);      
    end;

  console.echo(inttostr(trunc(fMin.x))+':'+inttostr(trunc(fMin.y)));
  console.echo(inttostr(trunc(fMax.x))+':'+inttostr(trunc(fMax.y)));  

  inc(fPointCount);
  SetLength(Road,fPointCount);
  Road[fPointCount-1] := Road[0];

  CalculateBounds;
  GenerateRoadMesh;

  k := 0;
  for i := 0 to fObjCount - 1 do
    if Objects[i].index = 0 then // Точка получения оружия
      begin
        SetLength(WeaponPoints,Length(WeaponPoints)+1);
        Min := VecLength(Road[0].v - Objects[i].v);
        for j := 0 to fPointCount - 1 do
          begin
            tmp := VecLength(Road[j].v - Objects[i].v);
            if tmp<min then
              begin
                WeaponPoints[High(WeaponPoints)] := j;
                min := tmp;
              end;
          end;
      end;

  InitGarbage;

  inp.MCapture(true);
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

// Рендер карт
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
    time : integer;
begin
  time := eX.GetTime;

  UpdLightData;

  glDisable(GL_LIGHTING);
    glColor3f(1,1,1);
    Sky.Render;
    fRoadMesh.Render(@fRoadMat);
  glEnable(GL_LIGHTING);
  
    if fObjCount>0 then
      for i := 0 to fObjCount - 1 do
        if Visible(Objects[i].v) then
        begin
          if Objects[i].index>6 then
            begin
              continue;
            end;
          if Objects[i].index=22 then
            glDisable(GL_LIGHTING);
          inc(ObjRender);
          glPushMatrix;
            // Хитрость: в gl_ModelViewMatrix содержится только модельная матрица объекта
            // Видовая передаётся в шейдер через Camera.ViewMatrix
            // Это чтоб не переписывать говнорендер с нуля (:
            glLoadIdentity;

            fLineColor := CIManager.GetColor(fObjParams[i].ColorIndex,((time-fObjParams[i].startTime) mod fObjParams[i].period)/fObjParams[i].period);

            glTranslatef(Objects[i].v.x,Objects[i].v.y,0);
            glRotatef(180,1,0,0);
            glRotatef(Objects[i].Angle+180,0,0,1);
            fAnimation.Update(@ObjMeshes[Objects[i].index]);
            ObjMeshes[Objects[i].index].Animation := fAnimation;
            ObjMeshes[Objects[i].index].Render;
          glPopMatrix;
          if Objects[i].index=22 then
            glEnable(GL_LIGHTING);
        end;

  RenderGarbage;
  RenderTable;
end;

procedure TMap.RenderTable;
const size = 60;
      rc = 2;
var dv:single;
begin
  exit;
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
  Objects[High(Objects)-1].Angle := a + 180;
end;

procedure TMap.Update;
  procedure HandleColor(var Color:single; NeedColor:single);
  var dc : single;
  begin
    dc := NeedColor - Color;
    Color := Color + Sign(dc)*0.04;    
    if abs(dc) < 0.05 then
      Color := NeedColor;
  end;
var i:integer;
    ind:integer;
begin
  Sky.Update;

  if abs(eX.GetTime - fLastColorUpd) >= fUpdFreq then
    begin
      ind := random(length(LINE_COLORS));
      if ind = fcIndex then
        ind := (ind + 1) mod length(LINE_COLORS);
      fcIndex := ind;
      for i := 0 to 2 do        
        fNeedColor[i] := LINE_COLORS[ind][i];
      fLastColorUpd := eX.GetTime;
    end;

  for i := 0 to 2 do
    HandleColor(fColor[i],fNeedColor[i]);

  fSunAng := fSunAng + 0.01;

  UpdateGarbage;
end;

procedure TMap.UpdLightData;
var i:integer;
    cnt:integer;
begin
  cnt := 0;
  for i := 0 to 5 do
    begin
      if Visible(GameManager.Cars[i].Position) then
        begin
          LightPoses[cnt] := GameManager.Cars[i].PrevPos + ( GameManager.Cars[i].Position-GameManager.Cars[i].PrevPos)*dt;
          LightPoses[cnt].z := 20;
          inc(cnt);
        end;
    end;
  fLightCount := cnt;

  i := eX.GetTime;
  if i - fLastSunChange > fSunDelay then // Пора менять время суток
    begin
      fLastSunChange := i;
      if fNeedSun > 0.9 then
        begin
          fNeedSun := 0.2;
          fSunDelay := 5000 + random(100)*50;
        end
      else
        begin
          fNeedSun := 1;
          fSunDelay := 8000 + random(100)*80;
        end;
    end;

  // О как (:
  SUNLIGHT_POWER := max(min(SUNLIGHT_POWER + (ord(SUNLIGHT_POWER < fNeedSun)*2 - 1)/600,1),0.2);
end;

procedure TMap.RenderGarbage;
var i:integer;
begin
  glPushMatrix;
    for i := 0 to fGarbageCount - 1 do
      if Visible(Garbage[i].Position) then
      begin
        glLoadIdentity;
        glTranslatef(Garbage[i].Position.x,Garbage[i].Position.y,Garbage[i].Position.z);
        glRotatef(180,1,0,0);
        glRotatef(Garbage[i].Rotation.x,Garbage[i].Rotation.y,Garbage[i].Rotation.z,1);
        GarbageMeshes[Garbage[i].model].Render();
      end;
  glPopMatrix;
end;


procedure TMap.UpdateGarbage;
const D_RAD = 1000;
var cd : TVector3;
    i,j:integer;

begin
  for i := 0 to fGarbageCount - 1 do
    with Garbage[i] do
      begin
        Position := Position + Dir * Speed;
        Rotation := Rotation + RSpeed;
      end;

  for i := fGarbageCount - 1 downto 0 do
    begin
      cd := Garbage[i].Position;
      if (cd.x > fMax.x + D_RAD) then
        cd.x := fMin.x - D_RAD;
      if (cd.y > fMax.y + D_RAD) then
        cd.y := fMin.y - D_RAD;

      if (cd.x < fMin.x - D_RAD) then
        cd.x := fMax.x + D_RAD;
      if (cd.y < fMin.y - D_RAD) then
        cd.y := fMax.y + D_RAD;
      Garbage[i].Position := cd;
    end;    

end;

procedure TMap.InitGarbage;
const G_DIST = 500;
var sizes,v : TVector3;
    cx,i,j : integer;
    cy : integer;

begin
  sizes := fMax - fMin;

  cx := trunc(sizes.x) div G_DIST;
  cy := trunc(sizes.y) div G_DIST;

  fMaxGarbage := (cx+1)*(cy+1);

  for i := 0 to cx do
    for j := 0 to cy do
      begin
        v := fMin + Vector3(i*G_DIST,j*G_DIST,0);
        v.z := 200;
        AddGarbage(v);
      end;    
end;

procedure TMap.AddGarbage(Pos : TVector3);
begin
  inc(fGarbageCount);
  SetLength(Garbage,fGarbageCount);
  with Garbage[fGarbageCount-1] do
    begin
      model := random(4);
      Params.StartTime := eX.GetTime;
      Params.Period := 5000;
      Params.ColorIndex := 0;
      Speed := 1 + Random * 10;
      Position := Pos;
      Rotation := ZeroVec;
      RSpeed := Vector3(random*2-1,random*2-1,random*2-1)*3;
      Dir := Normalize(Vector3(Random*2-1,Random*2-1,0));
    end;
end;

end.
