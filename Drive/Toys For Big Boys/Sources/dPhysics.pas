unit dPhysics;

interface

uses dMath;

type TPhysPoint = record
       Pos,PrevPos:TVector3;
       m:single;
     end;

// Узнаем скорость частицы
function PhysGetSpeed(Point:TPhysPoint):single;
// Устанавливаем массу...
procedure PhysSetMass(var Point:TPhysPoint; const m:single);
// Передвигаем частицу
procedure PhysMovePoint(var Point:TPhysPoint);
// Прикладываем к частице силу
procedure PhysAddForce(var Point:TPhysPoint; Force:TVector3);
// Задаем скорость частицы
procedure PhysSetVelocity(var Point:TPhysPoint; Velocity:Single);
// Обработка столкновений окружностей
procedure PhysCollision(var Point1:TPhysPoint; var Point2:TPhysPoint; const r1,r2:single; TraceCount:integer = 5);
// Направление движения частицы
function PhysGetDir(Point:TPhysPoint):TVector3;
// Обработка связей. Поддерживает между частицами
// расстояние равное Radius
procedure PhysHandleConstraint(var Point1:TPhysPoint; var Point2:TPhysPoint; const Radius:single);

implementation

uses Variables;

procedure PhysMovePoint(var Point:TPhysPoint);
var t:TVector3;
begin
  with Point do
    begin
      t:=Pos;
      Pos:=Pos*2-PrevPos;
      PrevPos:=t;
      Pos.z:=0;
      PrevPos.z := 0;
    end;
end;

procedure PhysAddForce(var Point:TPhysPoint; Force:TVector3);
begin
  with Point do
    begin
      PrevPos:=PrevPos-Force;
    end;
end;

procedure PhysSetMass(var Point:TPhysPoint; const m:single);
begin
  Point.m := 1/m;
end;

procedure PhysSetVelocity(var Point:TPhysPoint; Velocity:Single);
begin
  with Point do
    begin
      PrevPos:=Pos-Normalize((Pos-PrevPos))*Velocity;
    end;
end;

function PhysGetSpeed(Point:TPhysPoint):single;
begin
  with Point do
    Result:=VecLength(Pos,PrevPos);
end;

procedure PhysCollision(var Point1:TPhysPoint; var Point2:TPhysPoint; const r1,r2:single; TraceCount:integer = 5);
var deltalength,diff:single;
    p1,delta,p2,Dir1,Dir2:TVector3;
begin
  Dir1:=Point1.Pos-Point1.PrevPos;
  Dir2:=Point2.Pos-Point2.PrevPos;
  p1:=Point1.PrevPos;
  p2:=Point2.PrevPos;

  if Point1.Pos=Point2.Pos then
    Exit;
      if VecLength(point1.Pos,point2.Pos)<=r1+r2 then
        begin
          delta:=point2.Pos-point1.Pos;
          deltalength:=sqrt(dot3(delta,delta));
          diff:=(deltalength*(Point1.m+Point2.m));
          if diff<>0 then
            diff:=(deltalength-r1-r2)/diff;
          if Diff<0 then
            begin
              Point1.Pos:=point1.Pos+delta*Point1.m*0.5*diff;
              Point2.Pos:=point2.Pos-delta*Point2.m*0.5*diff;
            end;
        end;
end;

function PhysGetDir(Point:TPhysPoint):TVector3;
begin
  with Point do
    Result:=Pos-PrevPos;
end;

procedure PhysHandleConstraint(var Point1:TPhysPoint; var Point2:TPhysPoint; const Radius:single);
var deltalength,diff:single;
    delta:TVector3;
begin
  if Point1.Pos=Point2.Pos then
    Exit;
  delta:=point2.Pos-point1.Pos;
  deltalength:=sqrt(dot3(delta,delta));
  diff:=(deltalength*(Point1.m+Point2.m));
  if diff<>0 then
    diff:=(deltalength-Radius)/diff;
  Point1.Pos:=point1.Pos+delta*Point1.m*0.5*diff;
  Point2.Pos:=point2.Pos-delta*Point2.m*0.5*diff;
end;


end.
