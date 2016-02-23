// Слабонервным читать не рекомендуется!
// Жуткая математика by Division (:
unit dMath;

interface

const
  deg2rad = pi / 180;
  rad2deg = 180 / pi;

  EPS = 0.01; // Точность наших архизаумных вычислений



type
     // Странный тип какой-то. Скорее всего он не нужен...
     // (:
     TVector3=record
                x,y,z:single;
                procedure From(const X, Y, Z: Single);
                class operator Add(const Left, Right: TVector3): TVector3;
                class operator Divide(const Left, Right: TVector3): TVector3;
                class operator Divide(const Left:TVector3; Right: Single): TVector3;
                class operator Subtract(const Left, Right: TVector3): TVector3;
                class operator Multiply(const Left, Right: TVector3): TVector3;
                class operator Multiply(const Left: TVector3; right:single): TVector3;
                class operator Equal(const Left: TVector3; Right:TVector3): boolean;
              end;

      TVector2=record
                 x,y:single;
               end;

{$REGION 'Functions'}
function GetNormal2(x1,x2:TVector3):TVector3;
function GetAngle(v1,v2:TVector3):Single; // Угол между векторами
function Normalize(v:TVector3):TVector3; // Нормализация
function GetNormal(a,b,c:TVector3):TVector3; // Получаем нормаль к треугольнику
function VecLength(v1,v2:TVector3):single; overload; // Расстояние между точками
function VecLength(v:TVector3):single; overload; // Длина вектора
function Vector3(x,y,z:single):TVector3; // Конвертация трех координат в вектор
function ArcTan2(const Y, X: single): single; // Абыр
function ArcCos(const X: single): single; // Акваланг
function ArcSin(const X: single): single; // И паяльник
function LineVsTriangle(const p1,p2,pa,pb,pc:TVector3; var p:TVector3):boolean; // Пересекает ли отрезок треугольник. 3D
function LineVsCircle(X1,X2:TVector3; Circle:TVector3; Radius:Single; var h:single):boolean;
function Dot3(v1, v2: TVector3): Single; // Скалярное произведение векторов
function Distance(p,v1,v2,v3:TVector3):single; // Расстояние от прямой до точки
function InsideTr(v, v1, v2, v3: TVector3): boolean; // Точка внутри треугольника?
function ClosestPointOnLine(vA, vB, Point: TVector3): TVector3; // И так понятно
function DistToLine2(vA, vB, Point: TVector3): Single; //2D Случай. Расстояние от точки до прямой
function DistToSegment2(vA,vB,Point:TVector3):Single; // Расстояние от точки до _отрезка_
function EdgeSphereCollision(Center: TVector3; v1, v2, v3: TVector3; Radius: Single): Boolean;
function LinesIntersect2(v1,v2,v3,v4:TVector3):boolean;
function min(a,b:single):single;
function max(a,b:single):single;
function V_Angle(v1, v2: TVector3): single;
function Orient(a,b,c:TVector3):single;
function vmin(v1,v2:TVector3):TVector3; // Возвращает минимальные координаты двух векторов
function vmax(v1,v2:TVector3):TVector3; // Возвращает минимальные координаты двух векторов
function GetVArrayCenter(Arr:array of TVector3):TVector3; // Центр фигуры, состоящей из вертексов массива Arr
function PointInPolygon(v:TVector3; Arr:array of TVector3):boolean; // 2D версия. Лежит ли точка внутри выпуклого многоугольника
procedure Rotate(var v:TVector3; const Angle:single); // Повернуть вектор вокруг начала координат
function LessAngle(Angle,Target:Single):Single;
function SameSign(a,b:single):boolean;
function Sign(a:single):integer;
function CollisionDir(Pos1,Pos2,Dir1:TVector3; Speed1,Speed2,R:Single; var Dir2:TVector3; var t:Single; const Maxt: single = 50):boolean;
procedure CalculateTBN(const v0,v1,v2:TVector3; const st0,st1,st2:TVector2; var t,b,n:TVector3); // Базис касательного пространства
{$ENDREGION}

const ZeroVec : TVector3 = (X:0; Y:0; Z:0); // Угадай что

implementation


{$REGION 'Trigonometry'}
// Арктангенс
function ArcTan2(const Y, X: single): single;
asm
 FLD     Y
 FLD     X
 FPATAN
 FWAIT
end;

// Арккосинус (:
function ArcCos(const X: single): single;
begin
  if abs(X) > 1 then
    Result := 0
  else
    Result := ArcTan2(Sqrt(1 - X * X), X);
end;

// Ну и арксинус не помешает
function ArcSin(const X: single): single;
begin
  if abs(X) > 1 then
    Result := 0
  else
    Result := ArcTan2(X, Sqrt((1+X) * (1-X)));
end;
{$ENDREGION}

{$REGION 'TVector3'}

function GetNormal2(x1,x2:TVector3):TVector3;
var d:TVector3;
begin
  d.x:=x1.y-x2.y;
  d.y:=x2.x-x1.x;
  result:=d;
end;

procedure TVector3.From(const X, Y, Z: Single);
begin
  Self.X := X;
  Self.Y := Y;
  Self.Z := Z;
end;

// Перегрузка операторов для вектора
class operator TVector3.Add(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
  Result.Z := Left.Z + Right.Z;
end;

class operator TVector3.Subtract(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
  Result.Z := Left.Z - Right.Z;
end;

class operator TVector3.Divide(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X / Right.X;
  Result.Y := Left.Y / Right.Y;
  Result.Z := Left.Z / Right.Z;
end;

class operator TVector3.Divide(const Left:TVector3; Right: Single): TVector3;
begin
  Result.X := Left.X / Right;
  Result.Y := Left.Y / Right;
  Result.Z := Left.Z / Right;
end;

// Cross product
class operator TVector3.Multiply(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.Y * Right.Z - Left.Z * Right.Y;
  Result.Y := Left.Z * Right.X - Left.X * Right.Z;
  Result.Z := Left.X * Right.Y - Left.Y * Right.X;
end;

class operator TVector3.Multiply(const Left: TVector3; Right:single): TVector3;
begin
  Result.X := Left.X * Right;
  Result.Y := Left.Y * Right;
  Result.Z := Left.Z * Right;
end;

class operator TVector3.Equal(const Left: TVector3; Right:TVector3): boolean;
begin
  Result:=(Left.x=Right.x) and (Left.y=Right.y) and (Left.z=Right.z);
end;
{$ENDREGION}

{$REGION 'VectorMath'}
// Нормализация вектора
function Normalize(v:TVector3):TVector3;
var l:single;
begin
  l:=VecLength(v,Vector3(0,0,0));
  With Result do
  begin
    x:=v.x/l;
    y:=v.y/l;
    z:=v.z/l;
  end;
end;

// Длина отрезка v1v2
function VecLength(v1,v2:TVector3):single;
begin
  result:=sqrt((v1.x-v2.x)*(v1.x-v2.x)+(v1.y-v2.y)*(v1.y-v2.y)+(v1.z-v2.z)*(v1.z-v2.z));
end;

// Длина вектора 
function VecLength(v:TVector3):single;
begin
  result:=sqrt((v.x)*(v.x)+(v.y)*(v.y)+(v.z)*(v.z));
end;

function Vector3(x,y,z:single):TVector3;
begin
  Result.x:=x;
  Result.y:=y;
  Result.z:=z;
end;

// Нормаль к треугольнику
function GetNormal(a,b,c:TVector3):TVector3;
begin
  Result:=Normalize((b-a)*(c-b));
end;

// Скалярное произведение
function Dot3(v1, v2: TVector3): Single;
begin
  Result := v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;
end;

// Угол между векторами
function V_Angle(v1, v2: TVector3): single;
begin
  Result := ArcCos(Dot3(Normalize(v1), Normalize(v2)));
end;
{$ENDREGION}

{$REGION 'Collision and utils'}
// Круг и линия...
// h - расстояние до нее 
function LineVsCircle(X1,X2:TVector3; Circle:TVector3; Radius:Single; var h:single):boolean;
var a,b,c,tmp:single;
begin
  c:=VecLength(X2,X1);
  a:=VecLength(X1,Vector3(Circle.X,Circle.Y,0));
  b:=VecLength(X2,Vector3(Circle.X,Circle.Y,0));

  tmp:=(b*b+c*c-a*a)/(2*c);
  h:=sqrt(b*b-tmp*tmp);

  if h<= Radius then Result:=true
  else Result:=false;

  if x2.x>x1.x then
   begin
     if (Circle.x>x2.x+Radius) or (Circle.x<x1.x-Radius) then Result:=false;
   end
   else
   begin
     if (Circle.x<x2.x-Radius) or (Circle.x>x1.x+Radius) then Result:=false;
   end;

  if x2.y>x1.y then
   begin
     if (Circle.y>x2.y+Radius) or (Circle.y<x1.y-Radius) then Result:=false;
   end
   else
   begin
     if (Circle.y<x2.y-Radius) or (Circle.y>x1.y+Radius) then Result:=false;
   end;

end;

// Пересекаются ли линии на плоскости?
function LinesIntersect2(v1,v2,v3,v4:TVector3):boolean;
begin
  Result := (((v3.x-v1.x)*(v2.y-v1.y)-(v3.y-v1.y)*(v2.x-v1.x))*((v4.x-v1.x)*(v2.y-v1.y)-(v4.y-v1.y)*(v2.x-v1.x))<=0) and
            (((v1.x-v3.x)*(v4.y-v3.y)-(v1.y-v3.y)*(v4.x-v3.y))*((v2.x-v3.x)*(v4.y-v3.y)-(v2.y-v3.y)*(v4.x-v3.x))<=0)
end;

// Находится ли точка внутри треугольника?
function InsideTr(v, v1, v2, v3: TVector3): boolean;
var
 i      : Integer;
 Angle  : Single;
 vec    : array [0..2] of TVector3;
begin
  Result := False;
  vec[0] := v1 - v;
  vec[1] := v2 - v;
  vec[2] := v3 - v;
  Angle := 0;
  for i := 0 to 2 do
    Angle := Angle + V_Angle(vec[i], vec[(i + 1) mod 3]);
  if Angle >= (0.99 * 2 * pi) then
   Result := true;
end;

// Пересекает ли линия треугольник?
function LineVsTriangle(const p1,p2,pa,pb,pc:TVector3; var p:TVector3):boolean;
var d,denom,mu:single;
    n:TVector3;
begin
  Result:=false;
// /* Calculate the parameters for the plane */
  n:=GetNormal(pa,pb,pc);
  d := - n.x * pa.x - n.y * pa.y - n.z * pa.z;
// /* Calculate the position on the line that intersects the plane */
  denom := n.x * (p2.x - p1.x) + n.y * (p2.y - p1.y) + n.z * (p2.z - p1.z);
  if Abs(Denom)<0.01 then // Параллельны
    Exit;

  mu := - (d + n.x * p1.x + n.y * p1.y + n.z * p1.z) / denom;
  p.x := p1.x + mu * (p2.x - p1.x);
  p.y := p1.y + mu * (p2.y - p1.y);
  p.z := p1.z + mu * (p2.z - p1.z);
  if (mu<0) or (mu>1) then  // /* Intersection not along line segment */
    Exit;

// /* Determine whether or not the intersection point is bounded by pa,pb,pc */
   Result:=InsideTr(p,pa,pb,pc);
end;

// Расстояние между плоскостью и точкой
function Distance(p,v1,v2,v3:TVector3):single;
var A,B,C,D:Single;
begin
  A:=v1.y*(v2.z-v3.z) + v2.y*(v3.z-v1.z) + v3.y*(v1.z-v2.z);
  B:=v1.z*(v2.x-v3.x) + v2.z*(v3.x-v1.x) + v3.z*(v1.x-v2.x);
  C:=v1.x*(v2.y-v3.y) + v2.x*(v3.y-v1.y) + v3.x*(v1.y-v2.y);
  D:= - v1.x*(v2.y*v3.z-v3.y*v2.z) - v2.x*(v3.y*v1.z-v1.y*v3.z) - v3.x*(v1.y*v2.z-v2.y*v1.z);
  Result:= (A*p.x + B*p.y + C*p.z + D) / sqrt(A*A + B*B + C*C);
end;


// Может быть не работает. Проверить
//2D Случай. Расстояние от точки до прямой
function DistToLine2(vA, vB, Point: TVector3): Single;
begin
  Result := ((vA.y-vB.y)*Point.x+(vB.x-vA.x)*Point.y +
            (vA.x*vB.y-vB.x*vA.y)) / sqrt(sqr(vB.x-vA.x)+
            sqr(vB.y-vA.y));
end;


{
float
distance_Point_to_Segment( Point P, Segment S)
{
    Vector v = S.P1 - S.P0;
    Vector w = P - S.P0;

    double c1 = dot(w,v);
    if ( c1 <= 0 )
        return d(P, S.P0);

    double c2 = dot(v,v);
    if ( c2 <= c1 )
        return d(P, S.P1);

    double b = c1 / c2;
    Point Pb = P0 + b * v;
    return d(P, Pb);
}
// Расстояние от точки до _отрезка_
function DistToSegment2(vA,vB,Point:TVector3):Single;
var v,w,Pb:TVector3;
    c1,c2,b:single;
begin
  v := vB-vA;
  w := Point - vA;
  c1 := dot3(w,v);
  if c1<0 then
    begin
      Result:=Sqrt(dot3(Point-vA,Point-vA));
      exit;
    end;
  c2 := dot3(v,v);
  if c2<c1 then
    begin
      Result:=Sqrt(dot3(Point-vB,Point-vB));
      Exit;
    end;
  b:=c1/c2;

  Pb:= vA + v*b;
  Result:=Sqrt(dot3(Point-Pb,Point-Pb));  
end;     

// Ближайшая точка на отрезке vAvB к точне Point
function ClosestPointOnLine(vA, vB, Point: TVector3): TVector3;
var
 Vector1, Vector2, Vector3: TVector3;
 d, t: Single;
begin
  Vector1 := Point - vA;
  Vector2 := Normalize(vB - vA);
  d := VecLength(vA, vB);
  t := Dot3(Vector2, Vector1);

  if t <= 0 then
    begin
      Result := vA;
      Exit;
    end;

  if t >= d then
    begin
      Result := vB;
      Exit;
    end;

  Vector3 := Vector2 * t;
  Result := vA + Vector3;
end;

// Сталкивается ли сфера с ребрами треугольника?
function EdgeSphereCollision(Center: TVector3; v1, v2, v3: TVector3; Radius: Single): Boolean;
var i: Integer;
    Point: TVector3;
    Distance: Single;
    v : array [0..2] of TVector3;
begin
  v[0] := v1;
  v[1] := v2;
  v[2] := v3;
  for i := 0 to 2 do
    begin
      Point := ClosestPointOnLine(v[i], v[(i + 1) mod 3], Center);
      Distance := VecLength(Point, Center);
      if Distance < Radius then
      begin
        Result := true;
        Exit;
      end;
    end;
  Result := false;
end;

function min(a,b:single):single;
begin
  if a<b then Result:=a
    else Result:=b;
end;

function max(a,b:single):single;
begin
  if a>b then Result:=a
    else Result:=b;
end;

// Знак полуплоскости (2D случай, заметьте)
function Orient(a,b,c:TVector3):single;
begin
  result:=(a.x - c.x)*(b.y - c.y) - (a.y - c.y)*(b.x-c.x);
end;

procedure Rotate(var v:TVector3; const Angle:single);
var SinA,CosA,xx:Single;
begin
  SinA:=sin(Angle);
  CosA:=cos(Angle);
  xx:=v.x * CosA - v.y * SinA;
  v.y := v.y * cosA + v.x * sinA;
  v.x := xx;
end;

function vmin(v1,v2:TVector3):TVector3; // Возвращает минимальные координаты двух векторов
begin
  if v1.x < v2.x then result.x:=v1.x
    else result.x:=v2.x;
  if v1.y < v2.y then result.y:=v1.y
    else result.y:=v2.y;
  if v1.z < v2.z then result.z:=v1.z
    else result.z:=v2.z;
end;

function vmax(v1,v2:TVector3):TVector3; // Возвращает минимальные координаты двух векторов
begin
  if v1.x > v2.x then result.x:=v1.x
    else result.x:=v2.x;
  if v1.y > v2.y then result.y:=v1.y
    else result.y:=v2.y;
  if v1.z > v2.z then result.z:=v1.z
    else result.z:=v2.z;
end;

function GetVArrayCenter(Arr:array of TVector3):TVector3;
var v:TVector3;
begin
  Result.From(0,0,0);
  if Length(Arr)=0 then exit;
    
  for v in Arr do
    Result:=Result+v;
  Result:=Result/Length(Arr);
end;

function PointInPolygon(v:TVector3; Arr:array of TVector3):boolean;
var i:integer;
begin
  Result:=true;
  for i := 0 to High(Arr)-1 do
    if Orient(v,Arr[i+1],Arr[i]) < 0 then Result:=false;
  if Orient(v,Arr[0],Arr[High(Arr)]) < 0 then Result:=false;
end;

function GetAngle(v1,v2:TVector3):Single;
var t1:TVector3;
begin
  t1:=v2-v1;
  Result:=arccos(-t1.Y/VecLength(v1,v2)) * rad2deg;
  if t1.x<0 then Result:=360-Result;
end;

// Углы в градусах
function LessAngle(Angle,Target:Single):Single;
var Temp:Single;
begin
  Temp:=Target-Angle;
  if Temp < 0 then Temp:=Temp+360;
  if Temp < 180 then Result:=Temp
  else Result:=-Temp;
end;

// Функция для предсказывания положения врага
// Возвращает вектор, по которому нужно выстрелить
// Dir1 должен быть нормализован
function CollisionDir(Pos1,Pos2,Dir1:TVector3; Speed1,Speed2,R:Single; var Dir2:TVector3; var t:Single; const Maxt: single = 50):boolean;
var tStep:Single;
    p1,p2:TVector3;
begin
  Result:=false;
  tStep:=1;
  t:=0;

  if (Dir1 = ZeroVec) then
    begin
      if not (Pos1=Pos2) then
        Dir2:=Normalize(Pos1-Pos2)
      else Dir2:=ZeroVec;  
      t:=VecLength(Pos1,Pos2)/Speed2;
      Result:=true;
      Exit;
    end;

  while t < Maxt do
    begin
      p1:=Pos1+Dir1*Speed1*t;
      p2:=Pos2+Normalize(p1-Pos2)*Speed2*t;
      if VecLength(p1,p2) < R then
        begin
          Dir2:=normalize(p1-Pos2);
          Result:=true;
          Exit;
        end;
      t:=t+tStep;
    end;
end;

function SameSign(a,b:single):boolean;
begin
  result := not ((a<0) and (b>0)) or ((a>0)and (b<0));
end;

function Sign(a:single):integer;
begin
  result:=0;
  if a<0 then
    Result:=-1;
  if a>0 then
    Result:=1;  
end;

{$ENDREGION}

{$REGION '3D Utils'}
// Расчет базиса касательного пространства
procedure CalculateTBN(const v0,v1,v2:TVector3; const st0,st1,st2:TVector2; var t,b,n:TVector3);
var
  p,e:array[0..1] of TVector3;
  fn,cp:TVector3;
  i,j:integer;
begin
  p[0] := v0 - v1;
  p[1] := v0 - v2;

  fn := Normalize(p[1]*p[0]);

  e[0] := Vector3(0, st0.x - st1.x, st0.y - st1.y);
  e[1] := Vector3(0, st0.x - st2.x, st0.y - st2.y);

  e[0].x:=p[0].x;
  e[1].x:=p[1].x;
  cp:=e[0]*e[1];
  if abs(cp.x)>0.000001 then
    begin
      t.x := -cp.y / cp.x;
      b.x := -cp.z / cp.x;
    end else
    begin
      t.x := 0;
      b.x := 0;
    end;

  e[0].x:=p[0].y;
  e[1].x:=p[1].y;
  cp:=e[0]*e[1];
  if abs(cp.x)>0.000001 then
    begin
      t.y := -cp.y / cp.x;
      b.y := -cp.z / cp.x;
    end else
    begin
      t.y := 0;
      b.y := 0;
    end;

  e[0].x:=p[0].z;
  e[1].x:=p[1].z;
  cp:=e[0]*e[1];
  if abs(cp.x)>0.000001 then
    begin
      t.z := -cp.y / cp.x;
      b.z := -cp.z / cp.x;
    end else
    begin
      t.z := 0;
      b.z := 0;
    end;

  t:=Normalize(t);
  b:=Normalize(b);
  n:=Normalize(b*t);

  if Dot3(n,fn) > 0 then n := n * (-1);
end;
{$ENDREGION}
end.
