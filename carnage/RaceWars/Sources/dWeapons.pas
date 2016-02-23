(*

    Классы оружия

*)

unit dWeapons;

interface

uses dCartridge, dMath, dglOpenGL, eXgine;

const
  W_MACHINEGUN = 0;
  W_PLASMAGUN = 1;
  W_ROCKETLAUNCHER = 2;

type
  // Базовое оружие
  TBasicWeapon = class
    destructor Destroy; override;
    private
      fLastShoot : integer;
      fReloadTime : integer;
      fShootCount : integer;
      fModel : integer;
      fAngle : Single;

      fCartridges : array of TBasicCartridge;
      fPrevPos : TVector3;
      fPosition : TVector3;

      fFlyTime : integer;
      fFlyAway : boolean; // Не пора ли ли отлететь?)
      fDead : boolean;

      fDeadDir : TVector3;

      function AddCartridge(ctype : CCartridge; GameMan : boolean = true) : TBasicCartridge; // При стрельбе добавляются патроны
      function GetCartridgeCount : integer;
      function GetCartridge(Index : integer) : TBasicCartridge;
    public
      procedure Render; virtual;
      procedure Fire(Dir:TVector3; Sender:Pointer); virtual; abstract;
      procedure Update; virtual;
      procedure DeleteCartridge(Index:integer);

      property CartridgeCount : integer read GetCartridgeCount;
      property Model:integer read fModel;
      property Cartridges[Index : integer]:TBasicCartridge read GetCartridge;
      property Position : TVector3 read fPosition write fPosition;
      property PrevPos : TVector3 read fPrevPos write fPrevPos;      
      property Angle : Single read fAngle write fAngle;
      property Dead : boolean read fDead write fDead;
  end;

  TMachineGun = class(TBasicWeapon)
    constructor Create;
    public
      procedure Fire(Dir:TVector3; Sender:Pointer); override;
  end;

  TPlasmaGun = class(TBasicWeapon)
    constructor Create;
    public
      procedure Fire(Dir:TVector3; Sender:Pointer); override;
  end;

  TRocketLauncher = class(TBasicWeapon)
    destructor Destroy; override;
    constructor Create;
    public
      Carts : array[0..2] of TRocket;
      Positions : array[0..2] of TVector3; // Позиции патронов
      fCurCartridge : integer; // Патрон, который будет выстрелен
      procedure Fire(Dir:TVector3; Sender:Pointer); override;
      procedure  Render; override;
      procedure Update; override;
  end;


implementation

uses Variables;

{$REGION 'TBasicWeapon'}
destructor TBasicWeapon.Destroy;
begin
  inherited;
end;

function TBasicWeapon.GetCartridgeCount;
begin
  Result := Length(fCartridges);
end;

function TBasicWeapon.GetCartridge(Index : integer) : TBasicCartridge;
begin
  if (Index < 0) or (CartridgeCount < Index + 1) then
    begin
      Result := nil;
      Exit;
    end;

  Result := fCartridges[Index];
end;

function TBasicWeapon.AddCartridge(ctype: CCartridge; GameMan : boolean = true) : TBasicCartridge;
var cart : TBasicCArtridge;
begin
  SetLength(fCartridges,length(fCartridges) + 1);
  // Вот оно оказывается как можно (:
  Cart := ctype.Create;
  if GameMan then
    GameManager.AddCartridge(Cart);
  fCartridges[high(fCartridges)] := cart;
  Result := Cart;
end;

procedure TBasicWeapon.DeleteCartridge(Index: Integer);
begin
  if (Index < 0) or (CartridgeCount < Index + 1) then
    Exit;

  fCartridges[Index].Destroy;
  fCartridges[Index] := fCartridges[High(fCartridges)];
  SetLength(fCartridges,CartridgeCount - 1);
end;

procedure TBasicWeapon.Update;
begin
  if fShootCount <= 0 then
    begin
      if not fFlyAway then
        begin
          fFlyTime := eX.GetTime;
          fDeadDir := fPosition - fPrevPos;
        end;
      fFlyAway := true;
    end;
end;

procedure TBasicWeapon.Render;
var a:Single;
begin
  // TODO: добавить анимацию отлетания оружия при окончании патронов
  glRotatef(Angle+90,0,0,1);
  glRotatef(180,1,0,0);

  if (fFlyAway) then
    begin
      a := 1 - (eX.GetTime - fFlyTime) / 2000;
      if a<0 then
        begin
          glColor4f(1,1,1,1);
          Exit;
        end;
      glEnable(GL_BLEND);
      ogl.Blend(BT_ADD);
      glDepthMask(false);
        
      glColor4f(1,1,1,a);
    end;

  WeaponModels[fModel].Render();

  if (fFlyAway) then
    begin
      glDisable(GL_BLEND);
      glDepthMask(true);
      glColor4f(1,1,1,1);      
    end;
end;
{$ENDREGION}

{$REGION 'TMachineGun'}
constructor TMachineGun.Create;
begin
  fReloadTime := 200;
  fModel := 0;
  fShootCount := 20;  
end;

procedure TMachineGun.Fire(Dir:TVector3; Sender:Pointer);
var cart : TMachineGunCartridge;
begin
  if eX.GetTime - fLastShoot < fReloadTime then
    Exit;

  if fShootCount <= 0 then Exit;

  // А чё, удобно (:
  cart := AddCartridge(TMachineGunCartridge) as TMachineGunCartridge;
  cart.Position := Position;
  Cart.PrevPos := Cart.Position;
  cart.Dir := normalize(Dir)*30;
  cart.Sender := Sender;
  fLastShoot := eX.GetTime;
  dec(fShootCount);
end;
{$ENDREGION}

{$REGION 'TPlasmaGun'}
constructor TPlasmaGun.Create;
begin
  fReloadTime := 500;
  fModel := W_PLASMAGUN;
  fShootCount := 5;
end;

procedure TPlasmaGun.Fire(Dir:TVector3; Sender:Pointer);
var cart : TPlasmaGunCartridge;
begin
  if eX.GetTime - fLastShoot < fReloadTime then
    Exit;

  if fFlyAway then
    Exit;

  cart := AddCartridge(TPlasmaGunCartridge) as TPlasmaGunCartridge;
  cart.Position := Position;
  cart.Dir := normalize(Dir)*25;
  cart.Sender := Sender;
  fLastShoot := eX.GetTime;
  dec(fShootCount);
end;
{$ENDREGION}

{$REGION 'TRocketLauncher'}
destructor TRocketLauncher.Destroy;
var i:integer;
begin
  for i := fCurCartridge to 2 do
    Carts[i].Destroy;
  inherited;
end;

constructor TRocketLauncher.Create;
var i:integer;
begin
  fReloadTime := 300;
  fModel := W_ROCKETLAUNCHER;
  fShootCount := 3;

  Positions[0].From(-15.45,1.221,0);
  Positions[1].From(15.45,1.221,0);
  Positions[2].From(0,1.221,19);

  for i := 0 to 2 do
    begin
      carts[i] := AddCartridge(TRocket,false) as TRocket;
      carts[i].Position := Positions[i];
      carts[i].Sender := nil;
      carts[i].Active := false;
    end;

end;

procedure TRocketLauncher.Fire(Dir:TVector3; Sender:Pointer);
var ang : single;
    v:TVector3;
begin
  if eX.GetTime - fLastShoot < fReloadTime then
    Exit;

  if fDead or (fCurCartridge > 2) then
    Exit;

  if Dir.x <> 0 then
    ang := arctan2(Dir.y,Dir.x) + Pi/2
  else if Dir.y > 0 then ang := 0
       else ang := Pi;
  v := Positions[fCurCartridge];
  v := Vector3(v.x*cos(ang) - v.y*sin(ang),v.x*sin(ang) + v.y*cos(ang),v.z+18);
  carts[fCurCartridge].Active := true;
  carts[fCurCartridge].Angle := 180;  
  carts[fCurCartridge].Position := Position*2 + v - PrevPos + Dir;
  carts[fCurCartridge].PrevPos := Position + v;
  carts[fCurCartridge].Dir := Dir;
  carts[fCurCartridge].Sender := Sender;  

  if Position = fPrevPos then
    carts[fCurCartridge].Speed := 1
  else
    carts[fCurCartridge].Speed := min(max(VecLength(Position-fPrevPos),1),20);
  carts[fCurCartridge].CreateTime := eX.GetTime;
  GameManager.AddCartridge(carts[fCurCartridge]);  
  inc(fCurCartridge);

  dec(fShootCount);

  fLastShoot := eX.GetTime;
end;

procedure TRocketLauncher.Render;
var i:integer;
begin
  inherited;
  if fFlyAway then Exit;
    
  for i := fCurCartridge to 2 do
    Cartridges[i].Render;
end;

procedure TRocketLauncher.Update;
var i : integer;
begin
  inherited;
  for i := fCurCartridge to 2 do
    Cartridges[i].Update;
end;
{$ENDREGION}

end.
