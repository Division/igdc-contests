unit dCamera;

interface

uses dCars, eXgine, dMath;

type TCamera = class
  constructor Create;

  public
    PrevPos,CurPos,Pos,Need,Delta:TVector3;
    follow : ^TBasicCar;
    procedure Interp;
    procedure Update;
end;

implementation

uses Variables;

constructor TCamera.Create;
begin

end;

procedure TCamera.Update;
var d:TVector3;
    z:single;
begin
  PrevPos:=Pos;
  if GameManager.CarCount=0 then exit;

  Pos.z := Pos.z - inp.WDelta*40;
  z:=pos.z;

  Pos.x:=follow.Position.x;
  Pos.y:=follow.Position.y;

  Need.x := follow.MoveDir.x*follow.Speed*7;
  Need.y := follow.MoveDir.y*follow.Speed*7;

  Delta := Delta + (Need-Delta)/15;

  d := (Need - Pos);
  Pos := Pos + Delta;
  pos.z:=z;
end;

procedure TCamera.Interp;
begin
  CurPos := PrevPos+(Pos-PrevPos)*dt;
end;

end.
