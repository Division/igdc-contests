unit dGameManager;

interface

uses dCars, dMath, Windows, eXgine;

const MAP_COUNT = 11;

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

    procedure GetPlaces;
    procedure LoadLevel(name:string);
    procedure Finish(car:PBasicCar);
    procedure Render;
    procedure AddWinner(car:PBasicCar);
    procedure Update;
  end;

implementation

uses Variables, dMap;

constructor TGameManager.Create;
begin
  CarCount := 0;
  GamePos:=0;
  Level := 1;
end;

procedure TGameManager.LoadLevel(name:string);
var i:integer;
    v,n,v1:TVector3;
    r:Single;
begin
  Map.LoadFromFile('data\maps\'+name+'.map');

  NeedLaps := Map.LapCount;
  Finished := false;
  Started := false;
  SecCounter := 3;

  if CarCount>0 then
    begin
      for i := 0 to High(Cars) do
        Cars[i].Free;
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

   v := Map.Road[Map.StartPoint].v;
   n:=Normalize(Map.Road[Map.StartPoint].n);
   r := Map.Road[Map.StartPoint].Radius;

   v:=v-n*r*0.8;

   for i := 0 to CarCount - 1 do
     begin
       v1:=v+n*r*i*2/(CarCount)*0.8;

       Cars[i].SetPos(v1.x,v1.y,normalize(GetNormal2(ZeroVec,Map.Road[Map.StartPoint].n)));
       if i>0 then
         Cars[i].SetAIModel(i-1);         
       Cars[i].Mesh := i;
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
          for i := 0 to CarCount-1 do
            Cars[i].Update;
          GetPlaces;
          if (GamePos = 2) then
            Menu.Update;           
        end
      else if GamePos = 1 then
        begin
          t:=eX.GetTime;
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
    for i := 0 to High(Cars) do
      Cars[i].Render;
    Map.Render;
    ogl.Set2D(0,0,wnd.Width,wnd.Height);
    if GamePos<>2 then
      begin
        ogl.TextOut(0,10,30,PCHAR('Круг: '+inttostr(camera.follow.CurLap+1)+'/'+inttostr(NeedLaps)));
        ogl.TextOut(0,10,50,PCHAR('Ваша позиция: '+inttostr(camera.follow.Place+1)));        
      end
    else
      begin
        ogl.TextOut(0,400,300,PCHAR('Вы приехали '+inttostr(PlayerPlace)));
        if PlayerPlace > 2 then
          begin
            ogl.TextOut(0,200,500,'Финишируйте хотя бы вторым, чтобы пройти дальше');
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
    Cars[i].Free;
  Cars:=nil;
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
