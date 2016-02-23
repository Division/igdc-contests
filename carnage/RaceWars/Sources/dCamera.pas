unit dCamera;

interface

uses dCars, eXgine, dMath, dglOpenGL, SysUtils;

type TCamera = class
  constructor Create;

  public
    ViewMatrix : array [0..3,0..3] of Single; // Видовая матрицв
    PrevPos,CurPos,Pos,Need,Delta,LIPos,PrevLIPos:TVector3;
    follow : ^TBasicCar;
    procedure Interp;
    procedure GetViewMatrix;
    procedure Update;
end;

implementation

uses Variables, dShaderMan;

constructor TCamera.Create;
begin
  // Раскиданы эти юниформы по всем модулям. Не дело это
  ShMan.AddUniform('ViewMatrix','objbump',SU_M4,@ViewMatrix);
  ShMan.AddUniform('ViewMatrix','objdiffuse',SU_M4,@ViewMatrix);
  ShMan.AddUniform('ViewMatrix','linebump',SU_M4,@ViewMatrix);
  ShMan.AddUniform('ViewMatrix','linediffuse',SU_M4,@ViewMatrix);
end;

procedure TCamera.Update;
var d:TVector3;
begin
//  PrevLIPos := LIPos;
  LIPos := CurPos;
  PrevPos:=Pos;
  Pos.z := Pos.z - inp.WDelta*40;
  
  if GameManager.CarCount=0 then exit;


  Pos.x:=follow.Position.x;
  Pos.y:=follow.Position.y;

  Need.x := follow.MoveDir.x*follow.Speed*7;
  Need.y := follow.MoveDir.y*follow.Speed*7;

  Delta := Delta + (Need-Delta)/15;

  d := (Need - Pos);
  Pos := Pos + Delta;
//  pos.z:=z;
end;

procedure TCamera.GetViewMatrix;
begin
  glGetFloatv(GL_MODELVIEW_MATRIX,@ViewMatrix[0]);
end;

procedure TCamera.Interp;
begin
  CurPos := PrevPos+(Pos-PrevPos)*dt;
//  CurPos := LIPos+(Pos-LIPos)*dt;
end;

end.
