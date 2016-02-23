unit dCars;

interface

uses dPhysics, dMath, dglOpenGL, eXgine, windows, dAnimation, l_math, dWeapons;

type

{$REGION 'TBasicCar'}

PBasicCar = ^TBasicCar;
TBasicCar = class
constructor Create; virtual;
destructor Destroy; override;
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

  fWAction : integer; // Время взятия оружия
  fMaterial : TMaterial; // Материал машинки
  fModelMatrix : TMatrix; // Модельная матрица машины
  fCurWeapon : TBasicWeapon; // Текущее оружие

  procedure HitCheck; // Проверяем на столкновения с патронами
  procedure ApplyFriction;
protected
  // Прошлая позиция
  fPrevIndex : integer;
  // Текущая позиция
  fCurIndex:integer;
  // 3
  fLastIndex:integer;

  fFinished:boolean;

  procedure TakeWeapon; virtual;
  procedure Fire; virtual;
  procedure HandleWeaponBase;
  procedure GetNPoint;
  procedure UpdateWeapon; virtual;
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
  procedure Render; virtual;
  procedure Turn(d:integer);
  procedure Collision;
  procedure CollideCar(car:PBasicCar);
  procedure Accelerate(a:Single);
  procedure Brake;
  procedure SetAIModel(i:integer); virtual; abstract;
  procedure SetParams(i:integer);
  procedure PickWeapon(index:integer);

  property Finished: boolean read fFinished;
  property Position:TVector3 read fPosition;
  property Material:TMaterial read fMaterial;
  property PrevPos : TVector3 read fPrevPos;
  property Angle:single read fAngle;
  property Speed: single read fSpeed;
  property MoveDir : TVector3 read fMoveDir;
  property Mesh:integer read fMesh write fMesh;
  property CurWeapon : TBasicWeapon read fCurWeapon;
end;

{$ENDREGION}

{$REGION 'TAICar'}

TAICar = class(TBasicCar)
constructor Create; override;
protected
  fSleepEnd : integer; // Время, до которого ни в кого не стреляем
  fCurWAngle : Single; // Текущий угол поворота оружия
  fNeedWAngle : Single; // Угол поворота оружия
  fCurTarget : integer; // Индекс текущей цели
  fNeedFire : boolean;
  fLastShootTime : integer; // Время последнего выстрела
  fLastTargetChange : integer; // Время последней смены цели
  fStateChange : integer; // Пора менять статус. Типа стреляем очередями
  procedure HandleWeapon; // Обрабатываем пушечки. Целимся, стреляем
  procedure UpdateWeapon; override;
  procedure Fire; override;
  procedure TakeWeapon; override; // Подобрали оружие

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
  procedure SetAIModel(i:integer); override;
end;

{$ENDREGION}

{$REGION 'TPlayerCar'}

TPlayerCar = class (TBasicCar)
constructor Create; override;
private
  // Пусть это не логично, но за управление курсором будет
  // отвечать класс машинки
  fCursorPos : TVector3; // Позиция курсора.
  fCursorAngle : single; // Угол курсора
public
  procedure HandleCursor;
  procedure Update; override;
  procedure Render; override;
end;

{$ENDREGION}

implementation

uses Variables, dMap, dCartridge;

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
//  fMaterial.AddTexture(tex.Load('data\textures\car1_tex.jpg'));
end;

destructor TBasicCar.Destroy;
begin
  inherited;
end;

procedure TBasicCar.TakeWeapon;
begin
  // Ы?
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

procedure TBasicCar.HandleWeaponBase;
var i:integer;
begin
  for i := 0 to length(Map.WeaponPoints) - 1 do
    if (fPrevIndex = Map.WeaponPoints[i]) then
      begin
        PickWeapon(Random(3));
      end;
end;

procedure TBasicCar.Fire;
begin
  if eX.GetTime - fWAction < 1000 then
    Exit;
  if CurWeapon <> nil then
    fCurWeapon.Fire(fMoveDir,Self);
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

  HitCheck;

  HandleWeaponBase;

  UpdateWeapon;  
end;

procedure TBasicCar.UpdateWeapon;
begin
  if fCurWeapon <> nil then
    begin
      fCurWeapon.PrevPos := fCurWeapon.Position;
      fCurWeapon.Position := Position;
      fCurWeapon.Angle := fAngle;
    end;
end;

// Столкновение машинки с патронами
procedure TBasicCar.HitCheck;
const STEP_COUNT = 8;
var i:integer;
    v,d:TVector3;
    j,k:integer;
    len : Single;
    Success : boolean;
begin
  for i := 0 to GameManager.CartridgeCount - 1 do
    if (GameManager.Cartridges[i].Sender <> nil) and ((GameManager.Cartridges[i].Sender) <> Self) then // Патрон не наш
      for j := 0 to 1 do
        with GameManager do
          begin
            Success := false;
            v := Cartridges[i].PrevPos;
            d := (Cartridges[i].Position - Cartridges[i].PrevPos) / STEP_COUNT;
            for k := 0 to STEP_COUNT - 1 do
              begin
                len := VecLength(v-Points[j].Pos);
                if len < wRad + Cartridges[i].Radius then
                  begin
                    Cartridges[i].HandlePoint(Points[j],v);
                    Cartridges[i].Hit();
                    Success := true;
                    break;
                  end;
                v := v + d;
              end;
            if Success then
              Break;
          end;
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

procedure TBasicCar.Accelerate(a: Single);
begin
  // Прикладываем силу к заднему колесу. Если не тормозим
  if not fBrake then
    PhysAddForce(Points[1],fMoveDir*a*fAccKoef)
end;

procedure TBasicCar.PickWeapon(index: Integer);
var w :TBasicWeapon;
    tm : integer;
begin
  // TODO: добавить проверку на возможность подобрать оружие
  tm := eX.GetTime;
  if tm - fWAction < 1000 then
    Exit;

  fWAction := tm;
  case index of
    W_MACHINEGUN:
      begin
        if fCurWeapon <> nil then
          fCurWeapon.Dead := true;
        fCurWeapon := TMachineGun.Create;
        GameManager.AddWeapon(fCurWeapon);
      end;
    W_PLASMAGUN:
      begin
        if fCurWeapon <> nil then
          fCurWeapon.Dead := true;
        fCurWeapon := TPlasmaGun.Create;
        GameManager.AddWeapon(fCurWeapon);
      end;
    W_ROCKETLAUNCHER:
      begin
        if fCurWeapon <> nil then
          fCurWeapon.Dead := true;

        fCurWeapon := TRocketLauncher.Create;
        GameManager.AddWeapon(fCurWeapon);
      end;
  end;
end;

{$ENDREGION}

{$REGION 'Render'}
// Рендер на самом деле говнорендер
// Подстраивался под прошлогодний код
procedure TBasicCar.Render;
var v:TVector3;
    ang,t1,t2,da,rang:single;
    left,dir,up : TVector3;
begin
  v := fPrevPos + (fPosition-fPrevPos)*dt;
  t1 := fAngle;
  t2 := fPrevAngle;
  da := t1+t2;
  if ((t1<0) and (t2>0)) or ((t1>0) and (t2<0)) and (da < 180) then
    ang := t2 + (t1 + t2)*dt
  else
    ang := t2 + (t1 - t2)*dt;

  rang := deg2rad * ang;
  up.From(0,0,-1);
  dir.From(cos(rang),sin(rang),0);
  left := GetNormal2(ZeroVec,dir);

  fModelMatrix[0][0] := left.x;   fModelMatrix[0][1] := left.y;   fModelMatrix[0][2] := left.z;
  fModelMatrix[1][0] := dir.x;   fModelMatrix[1][1] := dir.y;   fModelMatrix[1][2] := dir.z;
  fModelMatrix[2][0] := up.x;   fModelMatrix[2][1] := up.y;   fModelMatrix[2][2] := up.z;
  fModelMatrix[3][0] := 0;   fModelMatrix[3][1] := 0;   fModelMatrix[3][2] := 0;
  fModelMatrix[3][3] := 1;
  fModelMatrix[2][3] := 0;
  fModelMatrix[1][3] := 0;
  fModelMatrix[0][3] := 0;
  fModelMatrix[3][0] := v.x;
  fModelMatrix[3][1] := v.y;  

  glPushMatrix;
    glMultMatrixf(@fModelMatrix);
    CarMeshes[fMesh].Render();
    if fCurWeapon <> nil then // отрисовка оружия
      begin
        glLoadMatrixf(@Camera.ViewMatrix);
        glTranslatef(v.x,v.y,-20);
        fCurWeapon.Render;
      end;
  glPopMatrix;

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
    n,v:TVector3;
    r,fc,bc:single;

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


          if fBrake then
            bc := 5
          else bc := 10;
          
          if VecLength(Points[i].Pos-Points[i].PrevPos) > 0.1 then
            begin
              v := normalize(Points[i].Pos-Points[i].PrevPos);
              Points[i].Pos := Points[i].Pos - v/bc;
            end
          else Points[i].Pos := Points[i].PrevPos;
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
    delta:TVector3;
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
        delta:=ZeroVec;
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
                // TODO: Добавить торможение при трении об стенки
                p := p + Bounds[i].n*wRad/r;
                delta := delta + Bounds[i].n*wRad/r;
              end;
          end;
          Points[j].Pos := Points[j].Pos + delta;
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
  fCurTarget := -1;
  DistFromCenter := 0.3;
  ToCenterKoef := 0.01;
  MinTurn := 5;

  LastTime:=eX.GetTime;
  fSleepEnd := LastTime;
  fStateChange := LastTime;
  IsBacking:=false;
  TimeNeed:=1000;
  BackDist:=200;
  LastCoord := Position;
end;


procedure TAICar.Fire;
begin
  if eX.GetTime - fWAction < 1000 then
    Exit;
  if CurWeapon <> nil then
    fCurWeapon.Fire(vector3(cos(fCurWAngle),sin(fCurWAngle),0),Self);
end;

procedure TAICar.TakeWeapon;
begin
  fSleepEnd := eX.GetTime + random(80)*100+1000;
end;

procedure TAICar.UpdateWeapon;
begin
  if fCurWeapon <> nil then
    begin
      fCurWeapon.PrevPos := fCurWeapon.Position;
      fCurWeapon.Position := Position;
      fCurWeapon.Angle := fNeedWAngle * rad2deg;
    end;
end;

procedure TAICar.HandleWeapon;
const MAX_DIST = 250;
var i,ind,time:integer;
    dist,t,tmp : single;
    ePos,v,v2 : TVector3;

begin
  fNeedFire := false;
  time := eX.GetTime;

  if fCurWeapon = nil then
    begin
      fCurTarget := -1;
      Exit;
    end;

  if Time < fSleepEnd then // Спим?
    Exit;

  // Если нет цели, пытаемся её найти
  dist := 1000000000; // Надеюсь этого хватит (:
  ind := 0;
  if (fCurTarget < 0) or (time - fLastTargetChange > 1000)  then // TODO: подобрать время
    begin
      for i := 0 to 5 do
        if GameManager.Cars[i] <> self then
          begin
            v := Position - GameManager.Cars[i].Position;
            v2 := normalize(Points[1].Pos-Points[0].Pos);
            tmp := Dot3(v2,v);
            if tmp > 0 then
              begin
              t := VecLength(GameManager.Cars[i].Position - Position);
              if dist > t then
                begin
                  ind := i;
                  dist := t;
                end;
              end;
          end;
        if dist < MAX_DIST then
          begin
            fCurTarget := ind;
            fLastTargetChange := time;
          end;
    end;

  if fCurTarget < 0 then
    Exit;

  if GameManager.Cars[fCurTarget].Place > Place then
    begin
      fCurTArget := -1;
      Exit;
    end;

  fNeedFire := true;

  if fCurWeapon.ClassType = TRocketLauncher then
    begin
      if time > fStateChange then
        begin
          fStateChange := time + 1000 + random(10)*100;
          fSleepEnd := time + 1000;
        end;
    end
  else if fCurWeapon.ClassType = TMachineGun then
    begin
     if time > fStateChange then
       begin
         fStateChange := time + 1100 + random(15)*100;
         fSleepEnd := time + 1000 + random(10)*100;
       end;
    end
  else if fCurWeapon.ClassType = TPlasmaGun then
    begin
      fStateChange := time + 3000 + random(15)*100;
      fSleepEnd := time + 2000 + random(10)*100;
    end;

  ePos := GameManager.Cars[fCurTarget].Position;
  fNeedWAngle := arctan2(ePos.y-Position.y,ePos.x-Position.x);
  fCurWAngle := fNeedWAngle;
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

  HandleWeapon;

  inherited;

  if fNeedFire then
    Fire;
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

procedure TPlayerCar.HandleCursor;
begin
  fCursorPos := fCursorPos + Vector3(inp.MDelta.X/2,inp.MDelta.Y/2,0);
  fCursorAngle := arctan2(fCursorPos.y,fCursorPos.x);
end;

procedure TPlayerCar.Update;
begin
  if not fFinished then
  begin
    if (inp.Down(32) or inp.Down(VK_CONTROL)) and (fCurWeapon <> nil) then
      Fire;

    if inp.Down(ord('A')) or inp.Down(VK_LEFT) then
        Turn(-1);
    if inp.Down(ord('D')) or inp.Down(VK_RIGHT) then
      Turn(1);
    if inp.Down(ord('W')) or inp.Down(VK_UP) then
      Accelerate(1);
    if inp.Down(ord('S')) or inp.Down(VK_DOWN) then
      Accelerate(-1);

  end;
//  HandleCursor;
  inherited;
end;

procedure TPlayerCar.Render;
begin
  inherited;
end;

{$ENDREGION}

end.
