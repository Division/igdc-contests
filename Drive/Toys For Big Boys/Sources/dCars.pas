unit dCars;

interface

uses dPhysics, dMath, dglOpenGL, eXgine, windows;

type

{$REGION 'TBasicCar'}

PBasicCar = ^TBasicCar;
TBasicCar = class
constructor Create; virtual;
private
  fPosition:TVector3;
  fPrevPos: TVector3;
  fPrevAngle:single;
  fVertSize:single;
  fSpeed : single;
  fMaxSpeed : single;
  fMoveDir : TVector3;
  fMoveNormal : TVector3;
  fTurnSpeed : single;
  fFrictKoef : single;
  fMaxWAng : single;
  fAngle : single;
  fAccKoef:single;
  whl : boolean;
  fBrake:boolean;
  fMesh : integer;

  procedure ApplyFriction;
protected
  // Прошлая позиция
  fPrevIndex : integer;
  // Текущая позиция
  fCurIndex:integer;
  // 3
  fLastIndex:integer;

  fFinished:boolean;

  procedure GetNPoint;
  function SqRad(v1,v2:TVector3) : single;
public
  // Ближайшая точка пути
  nPoint : integer;

  Points : array[0..1] of TPhysPoint;
  // Направления, по которым можно ехать без трения
  Dirs : array[0..1] of TVector3;
  // Радиус окружностей
  wRad:Single;
  // Коеф. поворота колеса
  WheelAng: single;
  // Текущий круг
  CurLap : integer;
  // Место
  Place:integer;

  function GetPlace:integer;
  function GetRIndex(i:integer):integer;
  procedure SetPos(x,y:single; dir:TVector3);
  procedure UpdatePhysics;
  procedure Update; virtual;
  procedure Render2D;
  procedure Render; virtual;
  procedure Turn(d:integer);
  procedure Collision;
  procedure CollideCar(car:PBasicCar);
  procedure Accelerate(a:integer);
  procedure Brake;
  procedure SetAIModel(i:integer); virtual; abstract;

  procedure SetParams(i:integer);
  property Finished: boolean read fFinished;
  property Position:TVector3 read fPosition;
  property Angle:single read fAngle;
  property Speed: single read fSpeed;
  property MoveDir : TVector3 read fMoveDir;
  property Mesh:integer read fMesh write fMesh;
end;

{$ENDREGION}

{$REGION 'TAICar'}

TAICar = class(TBasicCar)
constructor Create; override;
public
  // На какой стороне дороги находимся
  rside : integer;

  // Вектор, по которому нужно двигаться в данной точке
  nDir : TVector3;
  // Угол, под которым нужно двигаться в данной точке
  nAngle : single;
  // Знак, куда нам нужно поворачивать
  NeedDir : integer;
  // Расстояние до середины трассы
  dFromCenter : single;
  // Знак полуплоскости относительно середины трассы
  cSign:integer;
  // Дистанция до центра дороги
  DistFromCenter : single;
  // Так круто будем поворачивать к центру дороги
  ToCenterKoef : single;
  // Поворачиваем, если курс отличен от требуемого на MinTurn градусов
  MinTurn : single;
  // Время последней проверки
  LastTime:integer;
  // Интервал проверок
  TimeNeed:integer;
  // Поворачиваем назад?
  IsBacking:boolean;
  // Минимальное, которое проезжает нормально едущая машина
  BackDist:integer;
  // Координаты последнего измерения
  LastCoord :TVector3; 
  procedure Update; override;
  procedure Render; override;
  procedure SetAIModel(i:integer); override;
end;

{$ENDREGION}

{$REGION 'TPlayerCar'}

TPlayerCar = class (TBasicCar)
constructor Create; override;
public
  procedure Update; override;
end;

{$ENDREGION}

implementation

uses Variables, dMap;

{$REGION 'Update'}

constructor TBasicCar.Create;
var i:integer;
begin
  fBrake := false;
  for i := 0 to 1 do
    PhysSetMass(Points[i],1);
  // Моделька
  fMesh := 0;  
  // Длина машины
  fVertSize := 50;
  // Радиус окружностей
  wRad :=12.5;
  // длина связи точек машины
  fVertSize := fVertSize-wRad*2;
  // Максимальная скорость
  fMaxSpeed := 14;
  // Скорость поворота
  fTurnSpeed :=0.01;
  // Коэф. трения. Чем больше, тем больше заносит
  fFrictKoef := 5;
  // Максимальный угол поворота колес
  fMaxWAng := 0.2;
  // Коэф. Разгона
  fAccKoef := 0.5;
  // Круги
  CurLap := 0;
  // Приехали?
  fFinished := false;
end;

procedure TBasicCar.SetParams(i: Integer);
begin
  case i of
    0:
      begin
      
      end;
    1:
      begin
        fTurnSpeed := 0.018;
        fMaxWAng := 0.12;
      end;
    2:
      begin
        fAccKoef := 0.68;
        fMaxSpeed := 13.5;
      end;
    3:
      begin
        PhysSetMass(Points[0],1.3);
        PhysSetMass(Points[1],1.3);

        fMaxWAng := 0.17;
        fAccKoef := 0.37;
      end;
    4:
      begin
        PhysSetMass(Points[0],1.2);
        PhysSetMass(Points[1],1.2);

        fFrictKoef := 5.5;
      end;
    5:
      begin
        fMaxSpeed := 14.13;
        fFrictKoef := 7;
      end;
  end;
end;

// Какое место занимаем?
function TBasicCar.GetPlace:integer;
var i: integer;
begin
  Result := 0;
  for i := 0 to GameManager.CarCount - 1 do
    begin
      if GameManager.Places[i]^ = self then
        begin
          Result := i;
          exit;
        end;
    end;
end;

// Ближайшая к машине точка пути
procedure TBasicCar.GetNPoint;
var i,ind:integer;
    dist,t:single;
begin
  dist:=SqRad(Map.Road[0].v,Position);
  ind:=0;
  for i := 1 to Map.PointCount-1 do
    begin
      t:=SqRad(Map.Road[i].v,Position);
      if t<dist then
        begin
          dist:=t;
          ind:=i;
        end;
    end;
  nPoint:=ind;
end;

function TBasicCar.SqRad(v1: TVector3; v2: TVector3):single;
begin
  Result := sqr(v1.x-v2.x) + sqr(v1.y-v2.y);
end;

function TBasicCar.GetRIndex(i: Integer):integer;
begin
  Result:=i;
  if i < 0 then
    Result:=Map.PointCount + i - 1;
  if i > Map.PointCount - 1 then
    Result:=i - Map.PointCount;
end;

procedure TBasicCar.Update;
const wd = 0.0001;
begin
  fPrevIndex := nPoint;
  GetNPoint;
  if fPrevIndex <> nPoint then
    begin
      fLastIndex:=fPrevIndex;

      if (fLastIndex = GetRIndex(Map.StartPoint-1)) and (nPoint = Map.StartPoint) then
        inc(CurLap);
      if (fLastIndex = Map.StartPoint) and (nPoint = GetRIndex(Map.StartPoint-1)) then
        dec(CurLap);

      if CurLap = GameManager.NeedLaps then
        begin
          GameManager.Finish(@self);
          fFinished := true;
        end;
    end;

  if not whl then
    begin
      if WheelAng >=-wd then
        begin
          WheelAng := WheelAng - wd;
          if Abs(WheelAng)<wd then
            WheelAng := 0;
        end
      else WheelAng := 0;
      if WheelAng <= wd then
        begin
          WheelAng := WheelAng + wd;
          if Abs(WheelAng)<wd then
            WheelAng :=0;
        end
      else WheelAng :=0;
    end;

  fPrevPos:=fPosition;
  fPrevAngle:=fAngle;  
  UpdatePhysics;
  whl := false;
  Place := GetPlace;
end;

procedure TBasicCar.Turn(d: Integer);
begin
  if ((d<0) and (WheelAng>0)) or ((d>0) And (WheelAng<0)) then
    WheelAng := 0;

  WheelAng:=WheelAng + fTurnSpeed*d;

  if WheelAng<-fMaxWAng then
    WheelAng := -fMaxWAng;
  if WheelAng > fMaxWAng then
    WheelAng := fMaxWAng;
  whl := true;  
end;

procedure TBasicCar.Accelerate(a: Integer);
begin
  if not fBrake then  
    PhysAddForce(Points[1],fMoveDir*a*fAccKoef)
  else PhysAddForce(Points[1],fMoveDir*a*fAccKoef/4);
end;

{$ENDREGION}

{$REGION 'Render'}

procedure TBasicCar.Render;
var v:TVector3;
    ang,t1,t2,da:single;

begin
  v := fPrevPos + (fPosition-fPrevPos)*dt;
  t1 := fAngle;
  t2 := fPrevAngle;
  da := t1+t2;
  if ((t1<0) and (t2>0)) or ((t1>0) and (t2<0)) and (da < 180) then
    ang := t2 + (t1 + t2)*dt
  else
    ang := t2 + (t1 - t2)*dt;

  glPushMatrix;
    glTranslatef(v.x,v.y,0);
    glRotatef(180,0,1,0);
    glRotatef(90-ang,0,0,1);
    CarMeshes[fMesh].Render;
  glPopMatrix;
end;

procedure TBasicCar.Render2D;
begin
  glPointSize(4);
  glPushMatrix;

  glTranslatef(-camera.Pos.x,-camera.Pos.y,0);

  glBegin(GL_LINES);
    glVertex2fv(@Points[0].Pos);
    glVertex2fv(@Points[1].Pos);    
  glEnd;

  tex.Enable(tc);
  glEnable(GL_BLEND);
  ogl.Blend(BT_SUB);
  glBegin(GL_QUADS);
    glTexCoord2f(0,0);
    glVertex2f(Points[0].Pos.x-wRad,Points[0].Pos.y-wRad);
    glTexCoord2f(0,1);
    glVertex2f(Points[0].Pos.x-wRad,Points[0].Pos.y+wRad);
    glTexCoord2f(1,1);
    glVertex2f(Points[0].Pos.x+wRad,Points[0].Pos.y+wRad);
    glTexCoord2f(1,0);
    glVertex2f(Points[0].Pos.x+wRad,Points[0].Pos.y-wRad);

    glTexCoord2f(0,0);
    glVertex2f(Points[1].Pos.x-wRad,Points[1].Pos.y-wRad);
    glTexCoord2f(0,1);
    glVertex2f(Points[1].Pos.x-wRad,Points[1].Pos.y+wRad);
    glTexCoord2f(1,1);
    glVertex2f(Points[1].Pos.x+wRad,Points[1].Pos.y+wRad);
    glTexCoord2f(1,0);
    glVertex2f(Points[1].Pos.x+wRad,Points[1].Pos.y-wRad);    
  glEnd;
  glDisable(GL_BLEND);
  tex.Disable();


  glClear(GL_DEPTH_BUFFER_BIT);
  glColor3f(1,0,0);
  glBegin(GL_LINES);
    glVertex2fv(@Points[0].Pos);
    glVertex2f(Points[0].Pos.x+Dirs[0].x*30,Points[0].Pos.y+Dirs[0].y*30);
  glEnd;
  glColor3f(1,1,1);

  glPopMatrix;

  ogl.TextOut(0,10,10,PCHAR(inttostr(round(fAngle))));
end;

{$ENDREGION}

{$REGION 'Physics'}

procedure TBasicCar.SetPos(x,y:single; dir:TVector3);
var i:integer;
begin
  fPosition := Vector3(x,y,0);
  // верхний
  Points[0].Pos := fPosition - dir*wRad;
  // нижний
  Points[1].Pos := fPosition + dir*wRad;

  for i:=0 to 1 do
    Points[i].PrevPos := Points[i].Pos;

  Update;
  fPrevAngle:=Angle;  
end;

procedure TBasicCar.UpdatePhysics;
var i:integer;
    s1,s2:single;
begin
  Dirs[1] := Points[0].Pos-Points[1].Pos;
  Dirs[0] := fMoveDir - fMoveNormal*WheelAng;

  for i := 0 to 1 do
    begin
      PhysMovePoint(Points[i]);
    end;

  // Столкновения
  Collision;
  // Расслабление
  for i := 0 to 3 do
    begin
      PhysHandleConstraint(Points[0],Points[1],fVertSize);
    end;

  fPosition:=(Points[0].Pos+Points[1].Pos)/2;

  fMoveDir := Normalize(Points[0].Pos-Points[1].Pos);
  fMoveNormal := Normalize(GetNormal2(fMoveDir,ZeroVec));

  // Ограничиваем скорость
  s1 := PhysGetSpeed(Points[0]);
  s2 := PhysGetSpeed(Points[1]);
  if s1>fMaxSpeed then
    begin
      PhysSetVelocity(Points[0],fMaxSpeed);
      s1:=fMaxSpeed;
    end;
  if s2>fMaxSpeed then
    begin
      PhysSetVelocity(Points[1],fMaxSpeed);
      s2:=fMaxSpeed;
    end;
  fSpeed := (s1+s2)/2;

  fAngle := rad2deg*arctan2(Points[0].Pos.y-Points[1].Pos.y,Points[0].Pos.x-Points[1].Pos.x);
  // Применяем трение... Повороты осуществляются за счет трения
  ApplyFriction;
  fBrake := false;
end;

function Distance2(a,b,c:TVector3):Single;
var dx,dy,D:Single;
begin
  dx:=a.x-b.x;
  dy:=a.y-b.y;
  D:=dx*(c.y-a.y)-dy*(c.x-a.x);
  Result:=abs(D/Sqrt(dx*dx+dy*dy));
end;

procedure TBasicCar.ApplyFriction;
var i:integer;
    n:TVector3;
    r,fc:single;
begin
  for i := 0 to 1 do
    begin
      n := fMoveNormal;
      n.z:=0;
      r:=DistToLine2(Points[i].Pos-Dirs[i],Points[i].Pos+Dirs[i],Points[i].PrevPos);
      if r<>0 then
        begin
          if fBrake then
            fc := fFrictKoef*3
          else fc := fFrictKoef;
          Points[i].PrevPos := Points[i].PrevPos + n*r/fc;
        end;
    end;
end;

procedure TBasicCar.Brake;
begin
  fBrake:=true;
end;
{$ENDREGION}

{$REGION 'Collision'}
procedure TBasicCar.Collision;
const minr = 0.7;
      TraceCount = 5;
var r,t,sp:single;
    i,j,k:integer;
    p,dir:TVector3;
begin
  with Map do
    for i := 0 to High(Bounds) do
      begin
        for j := 0 to 1 do
        begin
        dir := Normalize(Points[j].Pos-Points[j].PrevPos);
        sp := PhysGetSpeed(Points[j]);
        p := Points[j].PrevPos;
        t:=1/TraceCount*sp;
        // Трассировка. Чтоб не вылетать за трассу
        if LineVsCircle(Bounds[i].v1,Bounds[i].v2,fPosition,35,r) then
        for k := 1 to TraceCount do
          begin
            p := p + dir*t;
            if (orient(Bounds[i].v1,Bounds[i].v2,p)<0) and LineVsCircle(Bounds[i].v1,Bounds[i].v2,p,wRad,r) then
              begin
                if r=0 then
                r:=1;
                if abs(r)<minr then
                  begin
                    if r>0 then r:=minr;
                    if r<0 then r:=-minr;
                  end;
                p := p + Bounds[i].n*wRad/r;
                Points[j].Pos := p;
              end;
          end;
      end;
      end;
  for i := 0 to High(CarColl) do
    begin
      if CarColl[i]^ <> self then
        CollideCar(CarColl[i]);
    end;

end;

procedure TBasicCar.CollideCar(car:PBasicCar);
var i,j:integer;
begin
  for i := 0 to 1 do
    for j := 0 to 1 do      
    begin
      if VecLength(Points[i].Pos,car^.Points[j].Pos) < wRad*2 then
        PhysHandleConstraint(Points[i],car^.Points[j],wRad*2);      
    end;
end;

{$ENDREGION}

{$REGION 'TAICar'}

constructor TAICar.Create;
begin
  inherited;
  DistFromCenter := 0.3;
  ToCenterKoef := 0.01;
  MinTurn := 5;
  
  LastTime:=eX.GetTime;
  IsBacking:=false;
  TimeNeed:=1000;
  BackDist:=200;
  LastCoord := Position;
end;

procedure TAICar.Update;
var dir,t:integer;
    d:single;
    Delta:TVector3;
begin
  // Ближайший к нам вейпоинт

  Delta.From(0,0,0);
  // Увеличим на 1
  nPoint:=nPoint;
  // Расстояние до середины дороги
  dFromCenter := DistToLine2(Map.Road[GetRIndex(nPoint+1)].v,Map.Road[GetRIndex(nPoint)].v,Position);
  // Вектор, куда мы должны двигаться
  nDir := Normalize(Map.Road[GetRIndex(nPoint+2)].v-Map.Road[GetRIndex(nPoint+1)].v);

  t:=eX.GetTime;

  if t>=LastTime+TimeNeed then
    begin
      if not IsBacking then
        begin
          if (Speed < fMaxSpeed/8) and (VecLength(Position,LastCoord) < BackDist) then
            begin
              IsBacking := true;
              TimeNeed:=1000;
            end;
        end
          else
            begin
              IsBacking := false;
              TimeNeed := 1000;
            end;
      LastTime:=t;
      LastCoord:=Position;
    end;

  // Коррекция пути
  if (abs(dFromCenter) > Map.Road[GetRIndex(nPoint+1)].Radius*DistFromCenter) then
    Delta:=Normalize(Map.Road[GetRIndex(nPoint+1)].n)*ToCenterKoef*Sign(dFromCenter);
  // Угол, под которым мы должны двигаться. В расчетах не используется
  nAngle := rad2deg*arctan2(Map.Road[GetRIndex(nPoint+2)].v.y-Map.Road[GetRIndex(nPoint+1)].v.y+Delta.y,Map.Road[GetRIndex(nPoint+2)].v.x-Map.Road[GetRIndex(nPoint+1)].v.x+Delta.y);
  // Угол, на который нужно повернуть
  d:=arcsin((Normalize(nDir+Delta)*fMoveDir).z)*rad2deg;
  // Его знак
  Dir:=-Sign(d);

  if not fFinished then
    begin
      // Ускоряемся
      Accelerate(ord(not IsBacking)*2-1);
      // Поворачиваем
      if abs(d) > MinTurn then
        Turn(dir);
    end;

  inherited;
end;

procedure TAICar.Render;
begin
  inherited;
end;

procedure TAICar.SetAIModel(i: Integer);
begin
  case i of
    0:
      begin
        DistFromCenter := 0.05;
        ToCenterKoef := 0.1;
        MinTurn := 5;
      end;
    1:
      begin
        DistFromCenter := 0.1;
        ToCenterKoef := 0.1;
        MinTurn := 5;
      end;
    2:
      begin
        DistFromCenter := 0.4;
        ToCenterKoef := 0.2;
        MinTurn := 4;
      end;
    3:
      begin
        DistFromCenter := 0.15;
        ToCenterKoef := 0.1;
        MinTurn := 6;
      end;
    4:
      begin
        DistFromCenter := 0.08;
        ToCenterKoef := 0.15;
        MinTurn := 7;
      end;
    5:
      begin
        DistFromCenter := 0.9;
        ToCenterKoef := 0.6;
        MinTurn := 8;
      end;
  end;
end;

{$ENDREGION}

{$REGION 'TPlayerCar'}

constructor TPlayerCar.Create;
begin
  inherited;
  Mesh := 5;
  PhysSetMass(Points[0],1);
  PhysSetMass(Points[1],1);  
end;

procedure TPlayerCar.Update;
begin
  if not fFinished then
  begin
    if inp.Down(ord('A')) then
        Turn(-1);
    if inp.Down(ord('D')) then
      Turn(1);
    if inp.Down(ord('W')) then
      Accelerate(1);
    if inp.Down(ord('S')) then
      Accelerate(-1);
    if inp.Down(32) then
      Brake;
  end;
  inherited;
end;

{$ENDREGION}

end.
