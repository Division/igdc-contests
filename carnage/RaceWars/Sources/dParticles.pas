unit dParticles;

interface

uses dParticleSystem, eXgine, dMath;

type
  TSpaceEmitter = class(TBasicEmitter)
    public
      constructor Create;
      procedure Update; override;
  end;

  TSpaceParticle = class(TBasicParticle)
    procedure Update; override;
  end;

  TRocketEmitter = class(TBasicEmitter)
    public
      procedure Update; override;
  end;

  TRocketParticle = class(TBasicParticle)
    procedure Update; override;
  end;

  TPlasmaEmitter = class(TBasicEmitter)
    procedure Update; override;
  end;

  TMachineGunEmitter = class(TBasicEmitter)
    procedure Update; override;
  end;

  TMachineGunParticle = class(TBasicParticle)
    public
      Ang : single;
      Left,Sp : TVector3;
      procedure Update; override;
  end;

  TRocketExplosionEmitter = class(TBasicEmitter)
    procedure Update; override;
  end;

implementation

uses variables;

{$REGION 'Space'}
constructor TSpaceEmitter.Create;
begin
  inherited;
  fAngle := random * Pi * 2;
end;

procedure TSpaceEmitter.Update;
var time:integer;
    p : TSpaceParticle;
begin
  inherited;

  if fStop then Exit;


  fAngle := fAngle + 0.05;
  Pos := Pos + Vector3(cos(fAngle),sin(fAngle),0) * 2;
  time := eX.GetTime;  

  p := TSpaceParticle.Create;
  p.Pos := Pos;
  p.Pos.z := 255;
//  p.PrevPos := Z;
  p.Speed := 10;
  p.LiveTime := 2000;
  p.Dir := Vector3(random-0.5,random-0.5,0);
  p.Size := 40;
  InsertParticle(p);  
end;

procedure TSpaceParticle.Update;
begin
  inherited;

end;
{$ENDREGION}

{$REGION 'Rocket'}
procedure TRocketEmitter.Update;
var p:TRocketParticle;
    i : integer;
    l:integer;
    n,v,left : TVector3;
begin
  inherited;

  if fStop or not fActive then Exit;

  if PrevPos = ZeroVec then
    PrevPos := Pos;

  n:=Pos-PrevPos;
  l := trunc(VecLength(n));
  n := normalize(n);

  for i := 0 to l div 3 do
    begin
      v := PrevPos + n*i*3;
      p := TRocketParticle.Create;
      p.Pos := v;
      p.LiveTime := 500;
      p.Size := 20;
      p.Pos.z := -38;
      p.ColorIndex := CI_ROCKET_1;
      InsertParticle(p);
    end;

{
  for i := 0 to l div 2 do
    begin
      left := normalize(n * vector3(0,0,-1));
      v := PrevPos + n*i*10;
      p := TRocketParticle.Create;
      p.Pos := v;
      p.LiveTime := 200;
      p.Size := 20;
      p.Pos.z := -38;
      p.Dir := left;
      p.Speed := 10;
//      p.Texture := 2;
      p.ColorIndex := CI_ROCKET_2;
      InsertParticle(p);

      left := normalize(n * vector3(0,0,1))*3;
      v := PrevPos + n*i*3;
      p := TRocketParticle.Create;
      p.Pos := v;
      p.LiveTime := 200;
      p.Size := 20;
      p.Pos.z := -38;
      p.Dir := left;
      p.Speed := 10;
//      p.Texture := 2;
      p.ColorIndex := CI_ROCKET_2;
      InsertParticle(p);

    end;    }


end;

procedure TRocketParticle.Update;
begin
  inherited;
  Size := Size+ 1.5;
end;
{$ENDREGION}

{$REGION 'Plasma'}
procedure TPlasmaEmitter.Update;
const P_COUNT = 2;
var p:TBasicParticle;
    i : integer;
    l:integer;
    n,v,left : TVector3;
begin
  inherited;

  if fStop then Exit;

  if PrevPos = ZeroVec then
    PrevPos := Pos;

  n:=(Pos-PrevPos);
  l := trunc(VecLength(n));
  n := normalize(n);
  left := normalize(n * vector3(0,0,-1));

  for i := 0 to P_COUNT do
    begin
      v := Pos + left  * (random(2)*2-1) * (random(5)*7);
      p := TBasicParticle.Create;
      p.Pos := v;
      p.LiveTime := 3000;
      p.Size := 60;
      p.Texture := 2;

      p.Pos.z := -38 + (random-0.9) * 60 ;

      p.ColorIndex := CI_PLASMA_1;
      p.RotSpeed := (random - 0.5)/10;
      InsertParticle(p);
    end;

end;
{$ENDREGION}

{$REGION 'MachineGun'}
procedure TMachineGunEmitter.Update;
var p:TMachineGunParticle;
    i : integer;
    l:integer;
    n,v,left : TVector3;
begin
  inherited;

  if fStop or not fActive then Exit;

  if PrevPos = ZeroVec then
    PrevPos := Pos;

  fAngle := fAngle + 0.5;

  n:=Pos-PrevPos;
  l := trunc(VecLength(n));
  n := normalize(n);
  left := normalize(n * vector3(0,0,-1));
  for i := 0 to l div 3 do
    begin
      p := TMachineGunParticle.Create;
      p.Pos :=PrevPos + n*i*3;
      p.LiveTime := 800;
      p.Size := 20;
      p.Pos.z := -38;
      p.left := left;
      p.ang := (trunc(veclength(pos)) mod 360+i);
      p.Sp := p.Pos;
      p.ColorIndex := CI_PLASMA_1;
      InsertParticle(p);
    end;
end;

procedure TMachineGunParticle.Update;
var v:TVector3;
begin
  inherited;

  Ang := Ang + 0.1;
  Pos := Sp + Left * sin(ang) * 20;
end;

{$ENDREGION}

{$REGION 'RocketExplosion'}
procedure TRocketExplosionEmitter.Update;
var p : TBasicParticle;
    i : integer; 
begin
  inherited;

  if fStop then exit;

  for i := 0 to 4 do
    begin
      p := TBasicParticle.Create;
      p.LiveTime := 1000;
      p.Size := 40;
      p.Pos := Pos;
      p.Pos.z:= -38;
      p.Dir := vector3(random*2-1,random*2-1,random*2-1);
      p.Speed := 3+Random*10;
      p.ColorIndex := CI_EXPLOSION_1;
      InsertParticle(p);
    end;
end;
{$ENDREGION}

end.
