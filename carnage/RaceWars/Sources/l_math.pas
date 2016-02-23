unit l_math;
// математический модуль
// содержит базовые типы и операции над векторами
interface

uses
  eXgine;

type
  TFace = array [0..2] of Integer;

//  TVector2D = record
//    X, Y : Single;
//  end;

  TQuat = record
    X, Y, Z, W : Single;
  end;

  TMatrix = array [0..3, 0..3] of Single;

  function V_Lerp(v1, v2: TVector; t: Single): TVector;
  procedure Q_Matrix(q: TQuat; var m: TMatrix);
  function Q_Add(q1, q2: TQuat): TQuat;
  function Q_Sub(q1, q2: TQuat): TQuat;
  function Q_Dot(q1, q2: TQuat): single;
  function Q_Mult(q: TQuat; d: single): TQuat;
  function Q_Lerp(q1, q2: TQuat; t: single): TQuat;

implementation

function V_Lerp(v1, v2: TVector; t: Single): TVector;
begin
  Result.X := v1.X + (v2.X - v1.X) * t;
  Result.Y := v1.Y + (v2.Y - v1.Y) * t;
  Result.Z := v1.Z + (v2.Z - v1.Z) * t;
end;

procedure Q_Matrix(q: TQuat; var m: TMatrix);
var
  wx, wy, wz, xx, yy, yz, xy, xz, zz, x2, y2, z2 : single;
begin
  with q do
  begin
    x2 := x + x;   y2 := y + y;   z2 := z + z;
    xx := x * x2;  xy := x * y2;  xz := x * z2;
    yy := y * y2;  yz := y * z2;  zz := z * z2;
    wx := w * x2;  wy := w * y2;  wz := w * z2;
  end;

  m[0][0] := 1 - (yy + zz);  m[1][0] := xy + wz;        m[2][0] := xz - wy;
  m[0][1] := xy - wz;        m[1][1] := 1 - (xx + zz);  m[2][1] := yz + wx;
  m[0][2] := xz + wy;        m[1][2] := yz - wx;        m[2][2] := 1 - (xx + yy);

  m[3][0] := 0;
  m[3][1] := 0;
  m[3][2] := 0;
  m[0][3] := 0;
  m[1][3] := 0;
  m[2][3] := 0;
  m[3][3] := 1;
end;

function Q_Add(q1, q2: TQuat): TQuat;
begin
  Result.X := q1.X + q2.X;
  Result.Y := q1.Y + q2.Y;
  Result.Z := q1.Z + q2.Z;
  Result.W := q1.W + q2.W;
end;

function Q_Sub(q1, q2: TQuat): TQuat;
begin
  Result.X := q1.X - q2.X;
  Result.Y := q1.Y - q2.Y;
  Result.Z := q1.z - q2.Z;
  Result.W := q1.W - q2.W;
end;

function Q_Dot(q1, q2: TQuat): single;
begin
  Result := q1.X * q2.X + q1.Y * q2.Y + q1.Z * q2.Z + q1.W * q2.W;
end;

function Q_Mult(q: TQuat; d: single): TQuat;
begin
  Result.X := q.X * d;
  Result.Y := q.Y * d;
  Result.Z := q.z * d;
  Result.W := q.W * d;
end;

function Q_Lerp(q1, q2: TQuat; t: single): TQuat;
begin
  if Q_Dot(q1, q2) < 0 then
    Result := Q_Sub(q1, Q_Mult(Q_Add(q2, q1), t))
  else
    Result := Q_Add(q1, Q_Mult(Q_Sub(q2, q1), t));
end;

end.
