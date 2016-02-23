(*
    Классы патронов
*)

unit dCartridge;

interface

uses dMath, dglOpenGL, eXgine,dPhysics, dParticles;

const
  C_MachineGun = 0;

type
  CCartridge = class of TBasicCartridge;

  PBasicCartridge = ^TBasicCartridge;
  TBasicCartridge = class
    constructor Create; virtual;
    private
      fModel : integer;
      fPrevPos : TVector3;
      fPosition : TVector3;
      fDir : TVector3;
      fDead : boolean;
      fCreateTime : integer;
      fActive : boolean;
      fRadius : Single;
      fAngle : Single;
      fSpeed : Single;
    public
      Sender : Pointer; // Указатель на выпустившего патрон

      procedure Update; virtual; abstract;
      procedure Render; virtual;
      procedure Hit(Kind : integer = 0); virtual; abstract; // Патрон врезался куда-то (: Или кончилось время жизни
      procedure HandlePoint(var point : TPhysPoint; cPos : TVector3); virtual;

      property PrevPos : TVector3 read fPrevPos write fPrevPos;
      property Position : TVector3 read fPosition write fPosition;
      property Dir : TVector3 read fDir write fDir;
      property Dead : boolean read fDead;
      property Active : boolean read fActive write fActive;
      property Radius : Single read fRadius;
      property CreateTime : integer read fCreateTime write fCreateTime;
      property Angle : Single read fAngle write fAngle;
      property Speed : Single read fSpeed write fSpeed;
  end;

  TMachineGunCartridge = class(TBasicCartridge)
     constructor Create; override;
     destructor Destroy; override;
     private
      Emitter : TMachineGunEmitter;
     public
       procedure Hit(Kind : integer = 0); override;
       procedure Update; override;
  end;

  TPlasmaGunCartridge = class(TBasicCartridge)
     destructor Destroy; override;
     constructor Create; override;
     private
       Emitter : TPlasmaEmitter;
     public
       procedure Hit(Kind : integer = 0); override;
       procedure Update; override;
       procedure Render; override;
       procedure HandlePoint(var point : TPhysPoint; cPos : TVector3); override;
  end;

  TRocket = class(TBasicCartridge)
     constructor Create; override;
     destructor Destroy; override;
     private
       Emitter : TRocketEmitter;
     public
       procedure Hit(Kind : integer = 0); override;
       procedure Update; override;
       procedure Render; override;
       procedure HandlePoint(var point : TPhysPoint; cPos : TVector3); override;
  end;
implementation

uses Variables;

{$REGION 'TBasicCartridge'}
constructor TBasicCartridge.Create;
begin
  fCreateTime := eX.GetTime;
  fActive := true;
end;

procedure TBasicCartridge.HandlePoint(var point: TPhysPoint; cPos : TVector3);
begin
  PhysAddForce(Point,normalize(Dir)*10);
end;

procedure TBasicCartridge.Render;
var v:TVector3;
begin
  v := fPrevPos + (Position - fPrevPos) * dt;
  glPushMatrix;
    glLoadMatrixf(@Camera.ViewMatrix);
    glTranslatef(v.x,v.y,0);
    CartridgeModels[fModel].Render();
  glPopMatrix;
end;
{$ENDREGION}

{$REGION 'TMachineGunCartridge'}
destructor TMachineGunCartridge.Destroy;
begin
  Emitter.Stop;
  inherited;
end;

constructor TMachineGunCartridge.Create;
begin
  inherited;
  fModel := 0;
  fRadius := 4;
  Emitter := TMachineGunEmitter.Create;
  ParticleSystem.AddEmitter(Emitter);  
end;

procedure TMachineGunCartridge.Update;
begin
  fPrevPos := Position;
  Position := Position + Dir;

  Emitter.PrevPos := Emitter.Pos;
  Emitter.Pos := Position;

  if eX.GetTime - fCreateTime > 2000 then
    Hit;
end;

procedure TMachineGunCartridge.Hit(Kind : integer = 0);
begin
  fDead := true;
end;
{$ENDREGION}

{$REGION 'TPlasmaGunCartridge'}
destructor TPlasmaGunCartridge.Destroy;
begin
  Emitter.Stop;
  inherited;
end;

constructor TPlasmaGunCartridge.Create;
begin
  inherited;
  fModel := 1;
  fRadius := 35;
  Emitter := TPlasmaEmitter.Create;
  Emitter.Pos := Position;
  Emitter.PrevPos := Position;
  ParticleSystem.AddEmitter(Emitter);  
end;

procedure TPlasmaGunCartridge.Update;
begin
  fPrevPos := Position;
  Position := Position + Dir;

  Emitter.PrevPos := Emitter.Pos;
  Emitter.Pos := Position;

  if eX.GetTime - fCreateTime > 2000 then
    Hit(1);
end;

procedure TPlasmaGunCartridge.HandlePoint(var point : TPhysPoint; cPos : TVector3);
var d:single;
    v : TVector3;
begin
  d := VecLength(point.Pos,cPos);
  v := cPos - point.Pos;
  d := abs(1 - d / fRadius)*20;
  PhysAddForce(point,normalize(v)*d);
end;

procedure TPlasmaGunCartridge.Hit(Kind : integer = 0);
begin
  if Kind=1 then
    fDead := true;
end;

procedure TPlasmaGunCartridge.Render;
var v : TVector3;
    k : Single;
begin
  k := min((eX.GetTime - fCreateTime) / 200,1);

  v := fPrevPos + (Position - fPrevPos) * dt;
  glPushMatrix;
    glLoadMatrixf(@Camera.ViewMatrix);
    glTranslatef(v.x,v.y,0);
    glScalef(k,k,k);
    CartridgeModels[fModel].Render();
  glPopMatrix;
end;
{$ENDREGION}

{$REGION 'TRocket'}
constructor TRocket.Create;
begin
  inherited;
  fModel := 2;
  fRadius := 35;
  Emitter := TRocketEmitter.Create;
  ParticleSystem.AddEmitter(Emitter);
  Emitter.Active := false;  
end;

destructor TRocket.Destroy;
begin
  Emitter.Active := false;
  Emitter.Stop;
end;

// Самонаводящийся ракет
procedure TRocket.Update;
var tm,i : integer;
    Dist,tmp,ang : single;
    ind : integer;
    np,v : TVector3;
begin
  if Active then
    begin
      // цикл по машинкам, ищем свою цель
      Dist := 1000000000000; // Ведь этого хватит? (:
      ind := 0;
      for i := 0 to 5 do
        if GameManager.Cars[i] <> Sender then
          begin
            // Найдём ближайшую машинку
            tmp := VecLength(GameManager.Cars[i].Position,Position);
            if tmp < Dist then
              begin
                Dist := tmp;
                ind := i;
              end;
          end;

      np := GameManager.cars[ind].Position - Position; // Летим сюда

      v := np * fDir;
      if (v.z > 0) then // Определим в какую сторону ближе разворачиваться
        ang := 0.03 // Угол, на который следует повернуть Dir
      else
        ang := -0.03;
      // Теперь типа умножаем fDir на матрицу поворота (:
      fDir.x := fDir.x*cos(ang) + fDir.y*sin(ang);
      fDir.y := fDir.y*cos(ang) - fDir.x*sin(ang);
      fDir := normalize(fDir);

      Emitter.PrevPos := Emitter.Pos;
      Emitter.Pos := Position;    
      Emitter.Active := true;
      tm := eX.GetTime;
      if tm - fCreateTime > 600 then
        Speed := min(Speed + 0.3,20);
      Angle := trunc(Angle + 5) mod 360;
      fPrevPos := Position;
      Position := Position + Dir*Speed;

      Emitter.Pos := Position;

      if tm - fCreateTime > 9000 then
        Hit();
    end;
end;

procedure TRocket.HandlePoint(var point : TPhysPoint; cPos : TVector3);
begin
  GameManager.CreateExplosion(cPos,Dir*60);
end;

procedure TRocket.Hit(Kind : integer = 0);
begin
  fDead := true;
end;

procedure TRocket.Render;
var v : TVector3;
    k : Single;
begin
  if Active then // Если выстрелили ракету, рендерим так
    begin
      v := Position - fPrevPos;
      k := arctan2(v.y,v.x) * rad2deg;
      v := fPrevPos + (Position - fPrevPos) * dt;
      glPushMatrix;
        glLoadMatrixf(@Camera.ViewMatrix);
        glTranslatef(v.x,v.y,-v.z);
        glRotatef(k-90,0,0,1);
        glRotatef(Angle,0,1,0);        
        CartridgeModels[fModel].Render();
      glPopMatrix;
    end
  else // Если нет, то эдак
    begin
      glPushMatrix;
        glTranslatef(Position.x,Position.y,Position.z);
        CartridgeModels[fModel].Render();        
      glPopMatrix;
    end;

end;
{$ENDREGION}

end.
