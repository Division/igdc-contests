unit dGameManager;

interface

uses dCars, dMath, Windows, eXgine, dCartridge, dWeapons, dPhysics, dParticles, dglOpenGL;

const MAP_COUNT = 6;
      MAX_CARTRIDGES = 100;

type
  TGameManager = class
  constructor Create;
  destructor Destroy; override;
  public
    // Кол-во машинок на трассе
    CarCount:integer;
    // Массив с машинками
    Cars:array of TBasicCar;
    // Угадай что
    GamePos:integer;
    // Сколько кругов проедем
    NeedLaps : integer;
    // Ы?
    Finished:boolean;
    // Уже стартанули?
    Started : boolean;
    // Последнее время отсчета
    fLastTime:integer;
    // Счетчик времени
    SecCounter : integer;
    // Победитель
    PlayerPlace:integer;
    // Текущий уровень
    Level:integer;
    // Массив, упорядоченный по местам
    Places : array of PBasicCar;
    // Победители
    WinList : array of PBasicCar;

    Weapons : array of TBasicWeapon;
    WeaponCount : integer;
    Cartridges : array[0..MAX_CARTRIDGES] of TBasicCartridge;
    CartridgeCount : integer;

    procedure Reset;
    procedure UpdateWeapon;
    function AddWeapon(Weapon : TBasicWeapon) : integer;
    procedure DeleteWeapon(index : integer);
    procedure AddCartridge(Cartridge : TBasicCartridge);
    procedure DeleteCartridge(index:integer);
    procedure GetPlaces;
    procedure LoadLevel(name:string);
    procedure Finish(car:PBasicCar);
    procedure RenderCartridges;
    procedure Render;
    procedure AddWinner(car:PBasicCar);
    procedure UpdateCartridges;
    procedure Update;
    procedure CreateExplosion(p,Dir : TVector3); // Взрыв ракеты
  end;

implementation

uses Variables, dMap;

constructor TGameManager.Create;
begin
  CarCount := 0;
  GamePos:=0;
  Level := 1;
end;

procedure TGameManager.CreateExplosion(p,Dir : TVector3);
const EXPL_RAD = 70;
var i,j:integer;
    d,Force:Single;
    Dist : array[0..1] of Single;
    v : array[0..1] of TVector3;
    vec : TVector3;
    Emitter : TRocketExplosionEmitter;
begin
  for i := 0 to 5 do
    begin
      for j := 0 to 1 do
        begin
          v[j] := Cars[i].Points[j].Pos - p;
          Dist[j] := VecLength(v[j]);
        end;

      if Dist[0] < Dist[1] then
        begin
          d := Dist[0];
          vec := v[0];
          j := 0;
        end
      else
        begin
          d := Dist[1];
          vec := v[1];
          j := 1;
        end;
      // Прикладываем силу только к одному колесу
      // Иначе толку от ракет нету
      if d <= EXPL_RAD then
        begin
          vec := normalize(vec);
          Force := d / EXPL_RAD * 50;
          PhysAddForce(Cars[i].Points[j],vec*Force);
        end;
    end;

  // Добавим частиц для взрыва
  Emitter := TRocketExplosionEmitter.Create;
  Emitter.LiveTime := 600;
  Emitter.Pos := p+Dir;
  ParticleSystem.AddEmitter(Emitter);


end;

function TGameManager.AddWeapon(Weapon: TBasicWeapon) : integer;
begin
  inc(WeaponCount);
  SetLength(Weapons,WeaponCount);
  Weapons[WeaponCount - 1] := Weapon;
  Result := WeaponCount - 1;
end;

procedure TGameManager.UpdateWeapon;
var i:integer;
begin
  for i := 0 to WeaponCount - 1 do
    Weapons[i].Update;

  for i := WeaponCount - 1 downto 0 do
    if Weapons[i].Dead then
      DeleteWeapon(i);
end;

procedure TGameManager.DeleteWeapon(index: Integer);
begin
  Weapons[index].Destroy;
  Weapons[index] := Weapons[WeaponCount - 1];
  Dec(WeaponCount);
end;

procedure TGameManager.AddCartridge(Cartridge: TBasicCartridge);
begin
  inc(CartridgeCount);
  Cartridges[CartridgeCount - 1] := Cartridge;
end;

procedure TGameManager.Reset;
var i:integer;
begin
  for i := 0 to CartridgeCount - 1 do
    Cartridges[i].Destroy;
  CartridgeCount := 0;
  for i := 0 to WeaponCount - 1 do
    Weapons[i].Destroy;
  WeaponCount := 0;
    
end;

procedure TGameManager.DeleteCartridge(index:integer);
begin
  Cartridges[index].Destroy;
  Cartridges[index] := Cartridges[CartridgeCount - 1];
  dec(CartridgeCount);
end;

procedure TGameManager.UpdateCartridges;
var i:integer;
begin
  for i := 0 to CartridgeCount - 1 do
    if Cartridges[i].Active then
      Cartridges[i].Update;

  for i := CartridgeCount - 1 downto 0 do
    if Cartridges[i].Dead then
      DeleteCartridge(i);
end;

procedure TGameManager.RenderCartridges;
var i:integer;
begin
  for i := 0 to CartridgeCount - 1 do
    if Assigned(Cartridges[i]) then
      Cartridges[i].Render;
end;

procedure TGameManager.LoadLevel(name:string);
var i,j:integer;
    v,n,v1:TVector3;
    r:Single;
begin
  Reset;
  Map.LoadFromFile('data\maps\'+name+'.map');

  NeedLaps := Map.LapCount;
  Finished := false;
  Started := false;
  SecCounter := 3;

  if CarCount>0 then
    begin
      for i := 0 to High(Cars) do
        Cars[i].Destroy;
      Cars:=nil;
    end;

  CarCount:=6;
  Cars:=nil;
  SetLength(Cars,CarCount);
  for i := 0 to CarCount - 1 do
    if i=0 then
      Cars[i] := TPlayerCar.Create
    else
      Cars[i] := TAICar.Create;

   SetLength(CarColl,CarCount);
   SetLength(Places,CarCount);
   for i := 0 to CarCount - 1 do
    begin
      CarColl[i]:=@Cars[i];
      Places[i] := @Cars[i];
    end;
   Camera.follow := @Cars[0];

   // Расстановка машин по местам
   for j := 0 to 2 do
     begin
       v := Map.Road[Map.StartPoint+j*5].v;
       n:=Normalize(Map.Road[Map.StartPoint+j*5].n);
       r := Map.Road[Map.StartPoint+j*5].Radius;

       for i := 0 to 1 do
         begin
           v:=v-n*r*(i*2-1)*0.2;
           v1:=v-n*r*(i*2-1)*0.2;
           Cars[i+j*2].SetPos(v1.x,v1.y,normalize(GetNormal2(ZeroVec,Map.Road[Map.StartPoint].n)));
           if i>0 then
             Cars[i+j*2].SetAIModel(i+j*2-1);
           Cars[i+j*2].Mesh := i+j*2;
         end;
     end;

  Cars[Menu.SelCar].Mesh := Cars[0].Mesh;
  Cars[0].Mesh:=Menu.SelCar;

  for i := 0 to CarCount - 1 do
    begin
      Cars[i].SetParams(Cars[i].Mesh);
    end;


  GamePos := 1;
  fLastTime := eX.GetTime;
  console.echo('Карта ' + name + ' загружена');
end;

procedure TGameManager.Update;
var i:integer;
    t:integer;
begin
  if CarCount>0 then
    begin
      if Started then
        begin
          UpdateCartridges;

          for i := 0 to CarCount-1 do
            begin
              Cars[i].Update;
            end;
          UpdateWeapon;

          GetPlaces;
          Map.Update;
          
          if (GamePos = 2) then
            Menu.Update;           
        end
      else if GamePos = 1 then
        begin
          t:=eX.GetTime;
          Map.Update;
          if t - fLastTime > 1000 then
            begin
              fLastTime := t;
              dec(SecCounter);
              if SecCounter = 0 then
                begin
                  Started := true;
                  for i := 1 to CarCount - 1 do
                    begin
                      (Cars[i] as TAICar).LastTime := eX.GetTime;
                    end;
                end;
            end;
      end;
    end;
end;

procedure TGameManager.Render;
var i:integer;
begin
  if (CarCount>0) and ( (GamePos >= 1) or ((GamePos = 0) and (Menu.Position=0)))   then
  begin
    if GamePos <> 0 then
      begin
        RenderCartridges;
        Map.Render;
        for i := 0 to High(Cars) do
          Cars[i].Render;
        ParticleSystem.Render;
        glColor4f(1,1,1,1);
      end;
    ogl.Set2D(0,0,wnd.Width,wnd.Height);
    if GamePos<>2 then
      begin
        ogl.TextOut(0,10,30,PCHAR('Круг: '+inttostr(camera.follow.CurLap+1)+'/'+inttostr(NeedLaps)));
        ogl.TextOut(0,10,50,PCHAR('Ваша позиция: '+inttostr(camera.follow.Place+1)));        
      end
    else
      begin
        ogl.TextOut(0,400,300,PCHAR('Вы приехали '+inttostr(PlayerPlace)));
        if PlayerPlace > 5 then
          begin
            ogl.TextOut(0,200,500,'Финишируйте хотя бы пятым, чтобы пройти дальше');
          end;

        Menu.Render;
      end;  

  end;

  if not Started and (GamePos = 1) then
    begin
      ogl.Set2D(0,0,wnd.Width,wnd.Height);
      ogl.TextOut(sFont,500,250,PCHAR(inttostr(SecCounter)));
      tex.Disable();
    end;

end;

destructor TGameManager.Destroy;
var i:integer;
begin
  for i := 0 to High(Cars) do
    Cars[i].Destroy;
  Cars:=nil;
  Reset;
end;

procedure TGameManager.Finish(car: PBasicCar);
var i:integer;
begin
  if not Finished then
    for i := 0 to CarCount - 1 do
      if Cars[i] = Car^ then
        begin
          AddWinner(car);
          if (i=0) and not car.Finished then
            begin
              GamePos := 2;
              inp.MCapture(false);
              PlayerPlace := car^.Place+1;
              Menu.Position := 4;
              Finished := true;
            end;
          exit;
        end;
end;

procedure TGameManager.GetPlaces;
var i:integer;
    temp:PBasicCar;
begin
  for i := 0 to CarCount-2 do
    begin
      if Places[i].CurLap < Places[i+1].CurLap then
        begin
          temp := Places[i+1];
          Places[i+1] := Places[i];
          Places[i] := temp;
        end
      else if (Places[i].CurLap=Places[i+1].CurLap) and (Places[i].nPoint < Places[i+1].nPoint) then
        if not ((Places[i].nPoint < Map.StartPoint) and (Places[i].nPoint>=0) and
               (Places[i+1].nPoint > Map.StartPoint)) then
        begin
          temp := Places[i+1];
          Places[i+1] := Places[i];
          Places[i] := temp;
        end;
    end;
end;

procedure TGameManager.AddWinner(car: PBasicCar);
begin
  if not Car^.Finished then
    begin
      SetLength(WinList,Length(WinList)+1);
      WinList[High(WinList)] := car;
    end;
end;

end.
