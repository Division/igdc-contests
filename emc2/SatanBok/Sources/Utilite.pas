unit Utilite;

interface

uses Physics;

function GetAngle(v1,v2:TVector3):Single;
function DegToRad(const Degrees: Extended): Extended;
function RadToDeg(const Radians: Extended): Extended;

implementation

function ArcCos(const X : Extended) : Extended; overload;
asm
  //Result := ArcTan2(Sqrt((1+X) * (1-X)), X)
  FLD   X
  FLD1
  FADD  ST(0), ST(1)
  FLD1
  FSUB  ST(0), ST(2)
  FMULP ST(1), ST(0)
  FSQRT
  FXCH
  FPATAN
end;

function DegToRad(const Degrees: Extended): Extended;  { Radians := Degrees * PI / 180 }
begin
  Result := Degrees * (PI / 180);
end;

function RadToDeg(const Radians: Extended): Extended;  { Degrees := Radians * 180 / PI }
begin
  Result := Radians * (180 / PI);
end;

function GetAngle(v1,v2:TVector3):Single;
var t1:TVector3;
begin
 t1:=v2-v1;
 Result:=radtodeg(arccos(-t1.Y/VecLength(v1,v2)));
 if t1.x<0 then Result:=360-Result;
end;

end.
