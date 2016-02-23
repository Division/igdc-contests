unit Game;

interface

uses eXgine, OpenGL;

procedure Init;
function RectInRect(X1,Y1,W1,H1,X2,Y2,W2,H2:single):boolean;
function Collision(X,Y,Size:single; SprSize:integer; var CX,CY:integer; const Who:byte):boolean; // Столкновение с ландшафтом
procedure DeadEagle(Eagle:byte);
procedure ShowText(Text:string; NextMenu:integer);
procedure LoadNextLevel;
procedure AddBonus;
procedure TakeBonus(Kind:integer);
function SaveScores:boolean;
function LoadScores:boolean;
procedure GameOver;

type
     PPatron=^TPatron;// Не знаю, как это называется грамотно
     TPatron=object   // Или списки или ещё как-то. Вообщем каждый патрон
              X,Y:single; // Хранит ссылку на предедущий и на следующий
              Direction:Byte;
              MustDie:boolean;
              Speed:Single;
              Friendly:boolean;
              Kind:byte;
              Next,Prev:PPatron;
              FromTank:boolean;
              IsChecking:boolean;
              procedure Update;
             end;

     TMenu=record
            Screen,Position,Next:byte;
            CurText:String;
           end;

     TScore=record
      Name:string[15];
      Score:integer;
     end;

     TScores=record
      Items:array[1..10] of TScore;
     end;

     TBonus=record
      Kind:integer;
      X,Y:integer;
      Active:boolean;
      TimeStart:integer;
     end;

     TGameParam=record
                 MotionInterpolation:boolean;
                 SinglePlayer:boolean;
                 SecondPlayer:boolean;
                 Position:byte;
                end;

     TBrick=record
             Kind:ShortInt;
             OFR,OFL,OFD,OFU:Byte;
             Tex:TTexture;
//             Health:Byte;
             CanHit:boolean;
            end;

     TMapBricks = array[0..15,0..10] of TBrick;
     TPRBricks  = array[0..63,0..43] of Byte;

     PTank=^TTank;
     TTank=object
      public
       Friend:boolean;
       Texture:TTexture;
       Goal:Single;
       Kind:integer; // 1 - игрок1   2 - игрок2   0 - комп
       RealS:integer;// Реальный размер танка (хех, на самом деле танки квадратные...)
       Ready,FireReady:boolean;
       HV:boolean;// Вращаемся по часовой стрелке
       CurAction:Byte;
       Speed,RotSpeed:single;
       x,y:single;
       Angle:single;
       Direction:byte;
       Health:integer;
       PatrSpeed:Single;
       MustDie:boolean;
       IsChecking:boolean;
       FireInterval,FireTimer:integer;//Промежуток между выстрелами в миллисекундах
       Prev,Next:PTank; // Указатели на предедущий и следующий объекты
       // AI
       Interrupt:boolean;// Прервать текущее действие?
       TimeStart,TimeNeed:integer;
       Busy,NeedFire:boolean;// Занят ли?
       CurAIAction:byte;
       FlashPoses:array[1..6] of Single;
       procedure Move(Dir:byte);
       procedure Fire;
       procedure StartMove(Dir: Byte);
       procedure Command(Cmd:byte);
       procedure Update;
       procedure FinishUpdate;
       procedure Hit;
       procedure Die;
       procedure Reset;
       constructor Create(sx,sy,SAngle:single; SHealth:integer; TFriend:boolean=false);
     end;

     TMap=object
      Map:TMapBricks;
      PRMap:array[0..63,0..43] of Byte;
      procedure UpdatePRMap;
      function Load(FileName:string):boolean;
      procedure Render(Target:byte);
      procedure Hit(Dir,CX,CY:integer);
      procedure RefreshBrick(x,y:integer);
     end;


procedure PrepareBrick(var b:TBrick);
function AddPatron:PPatron;
function DeletePatron(P:PPatron):PPatron;
procedure ClearPatrons;
function AddTank:PTank;
function DeleteTank(T:PTank):PTank;
procedure ClearTanks;
procedure SortScores;
procedure ShowScores;

implementation

uses Variables, Render, Maps, Particles;



constructor TTank.Create(sx,sy,SAngle:single; SHealth:integer; TFriend:boolean=false);
begin

end;

procedure TTank.Reset;// Приводим танк в исходное состояние
begin
 FireTimer:=0;
 x:=-100;
 y:=-100;
 Angle:=0;
 if Kind<>0 then 
  Health:=4
 else health:=2;
 Ready:=true;
 FireReady:=true;
 CurAction:=ANONE;
 Goal:=0;
 Speed:=5;
 RotSpeed:=10;
 Direction:=DTOP;
 Texture:=TankTex[0];
 RealS:=30;
 FireInterval:=500;
 Friend:=True;
 PatrSpeed:=15;
 MustDie:=false;
end;

procedure TTank.StartMove(Dir: Byte);
begin
 Ready:=false;
 CurAction:=AMOVE;
 Goal:=Direction;
end;

procedure TTank.FinishUpdate;
begin
 if CurAction=AMOVE then
 begin
  Ready:=true;
  CurAction:=ANONE;
  Goal:=ANONE;
 end;
end;

procedure TTank.Update;
var Temp,PX,PY:single;
    i,a,b:integer;
    CanMove:Boolean;
    T:PTank;
    d:boolean;
begin
 inc(FireTimer,1000 div UPS);
 if FireTimer>FireInterval then
  FireReady:=true;

 CanMove:=true;

 PX:=X;
 PY:=Y;

 hv:=false;
 if not Ready then
 case CurAction of
  AROTATE:
   begin

    Temp:=Goal-Angle;
    if temp<0 then temp:=360+temp;
    if Temp > 180 then Hv:=false
    else Hv:=true;

    if Angle <> Goal then
    begin
     if (HV)  then
      Angle:=Angle+RotSpeed
     else Angle:=Angle-RotSpeed;
    end;

    if Angle < 0 then Angle:= 360 + Angle;
    if Angle > 360 then Angle:=Angle - 360;

    if Temp < ROTSPEED  then Angle:=Goal;

    if Angle=Goal then
     begin
      Ready:=true;
      CurAction:=ANONE;
      for i:= 0 to 3 do
       if DIRANGLES[i]=Goal then
        Direction:=i;
     end;
   end;


   AMOVE:
    begin
     case Trunc(Goal) of
       DLEFT  : begin
                 CanMove := not Collision(X-Speed,Y,RealS,64,a,b,CTANK);
                 PX:=PX-Speed;
                 if not CanMove then X:=(a+1)*BSIZE div 4-(64-RealS)/2+1;
                 if x+(64-RealS)/2-Speed<0 then
                  begin
                   CanMove:=false;
                   x:=-(64-RealS)/2+1;
                  end;
                end;
       DRIGHT : begin
                 CanMove := not Collision(X+Speed,Y,RealS,64,a,b,CTANK);
                 PX:=PX+Speed;
                 if not CanMove then X:=a*BSIZE div 4-64+(64-RealS)/2-1;
                 if x+32+RealS/2>=1024-1 then
                  begin
                   CanMove:=false;
                   X:=1024-32-RealS/2-1;
                  end;
                end;
       DTOP   : begin
                 CanMove := not Collision(X,Y-Speed,RealS,64,a,b,CTANK);
                 PY:=PY-Speed;
                 if not CanMove then Y:=(b+1)*BSIZE div 4-(64-RealS)/2+1;
                 if Y+(64-RealS)/2-Speed<0 then
                  begin
                   CanMove:=false;
                   Y:=-(64-RealS)/2+1;
                  end;
                end;
       DDOWN  : begin
                 CanMove := not Collision(X,Y+Speed,RealS,64,a,b,CTANK);
                 PY:=PY+Speed;
                 if not CanMove then Y:=b*BSIZE div 4-64+(64-RealS)/2-1;
                 if Y+32+RealS/2>=768-64-1 then
                  begin
                   CanMove:=false;
                   Y:=768-64-32-RealS/2-1;
                  end;
                end;
     end;


     // Столкновение с другими танками     
     case kind of
      1:// Если наш танк - игрок1
       begin
        if RectInRect(PX+(64-RealS)/2,PY+(64-RealS)/2,RealS,RealS, PTank2.X+(64-RealS)/2,PTank2.Y+(64-RealS)/2, RealS,RealS) then
        begin
         CanMove:=false;
        end;
       end;
      2:// Если наш танк - игрок2
       begin
        if RectInRect(PX+(64-RealS)/2,PY+(64-RealS)/2,RealS,RealS, PTank1.X+(64-RealS)/2,PTank1.Y+(64-RealS)/2, RealS,RealS) then
        begin
         CanMove:=false;
        end;
       end;
      0:// Наш танк - компьютер
       begin
        if RectInRect(PX+(64-RealS)/2,PY+(64-RealS)/2,RealS,RealS, PTank1.X+(64-RealS)/2,PTank1.Y+(64-RealS)/2, RealS,RealS) then
        begin
         CanMove:=false;
        end;
        if RectInRect(PX+(64-RealS)/2,PY+(64-RealS)/2,RealS,RealS, PTank2.X+(64-RealS)/2,PTank2.Y+(64-RealS)/2, RealS,RealS) then
        begin
         CanMove:=false;
        end;
       end;

     end;

     // Столкновение с компьютерными танками
     T:=Tank^.Next;

     IsChecking:=true;
     while T<>nil do
     begin
      if not T^.IsChecking then
      begin
      if RectInRect(PX+(64-RealS)/2,PY+(64-RealS)/2,RealS,RealS, T^.X+(64-RealS)/2,T^.Y+(64-RealS)/2, RealS,RealS)
       then CanMove:=false;
      end;
      T:=T^.Next;
     end;
     IsChecking:=false;

     if (Kind<>0) and CanMove And (Bonus.Active) and
      RectInRect(PX+(64-RealS)/2,PY+(64-RealS)/2,RealS,RealS, Bonus.x*64,Bonus.y*64,64,64)
       then
       begin
        TakeBonus(Kind);
       end;

     if CanMove then Move(Trunc(Goal))
     else
      begin
       CurAction:=ANONE;
       Interrupt:=true;
       Ready:=true;
      end;

    end;


 end;// case

     d:=Random(2)=0;  
     if Texture=TankTex[3] then // Молния :)
      begin
       for i:=1 to 6 do
        if d then
        begin
         d:=not d; // -
         FlashPoses[i]:=-Random(100)/30;
        end
        else// +
        begin
         d:=not d;
         FlashPoses[i]:=Random(100)/30;
        end;

      end;


end;

procedure TTank.Move(Dir:byte);
begin
 case Direction of
  DRIGHT:
   begin
    X:=X+Speed;
   end;
  DLEFT:
   begin
    X:=X-Speed;
   end;
  DTOP:
   begin
    Y:=Y-Speed;
   end;
  DDOWN:
   begin
    Y:=Y+Speed;
   end;
 end;
end;

procedure TTank.Command(Cmd: Byte);
begin
 case cmd of
  DLEFT,DRIGHT,DTOP,DDOWN:
   begin
    if (Direction<>cmd) or (CurAction=AROTATE) then
    begin
     Ready:=false;
     Goal:=DIRANGLES[cmd];
     CurAction:=AROTATE;
    end
    else
    begin
     if Ready then StartMove(Cmd);
    end;
   end;
  AFIRE:
   begin
    if FireReady and (CurAction<>AROTATE) then Fire;
   end;
 end;//case
end;

procedure TTank.Fire;
var PS,PX,PY:single;
    PD,K:integer;
    F:boolean;
begin
 PX:=X+32-8;
 PY:=Y+32-8;
 PS:=PatrSpeed;
 PD:=Direction;
 F:=Friend;
 K:=Kind;
 with AddPatron^ do
 begin
  X:=PX;
  Y:=PY;
  Speed:=PS;
  Direction:=PD;
  Friendly:=F;
  Kind:=K;
  MustDie:=false;
 end;

 FireReady:=false;
 FireTimer:=0;
end;

function TMap.Load(FileName: string):boolean;
var i,j:integer;
    LMap:SAVEDMAP;
begin
 Bonus.Active:=false;

 GameIsOver:=false;

 EnemyStartCount:=0;
 EnemyCount:=0;
 ClearPatrons;
 ClearTanks;
 ClearParticles;

 AddStart:=-1;
 GameOverStart:=-1;
 NextLevelStart:=-1;

 PTank1.Reset;
 PTank2.Reset;
 ResTimer[1]:=RESNEED;
 ResTimer[2]:=RESNEED;

 for i := 0 to 15 do
 for j := 0 to 10 do
  begin
   map[i,j]:=EMPTYBRICK;
   LMap.Map[i,j]:=EMPTYBRICK;
  end;

 result := LoadFromFile(LMAP,FileName);
 if not result then exit;
 
 Map:=LMAP.Map;

 for i := 0 to 15 do
 for j := 0 to 10 do
   PrepareBrick(Map[i,j]);

 for i := 0 to 15 do
 for j := 0 to 10 do
   if map[i,j].Kind=BP1ST then
   begin
    P1STX:=i*64;
    P1STY:=j*64;
    PTANK1.X:=P1STX;
    PTANK1.Y:=P1STY;
   end
   else
   if map[i,j].Kind=BP2ST then
   begin
    P2STX:=i*64;
    P2STY:=j*64;
    if GameParam.SecondPlayer then
    begin
     PTANK2.X:=P2STX;
     PTANK2.Y:=P2STY;
    end;
   end
   else
   if map[i,j].Kind=BCOMST then
   begin
    inc(EnemyStartCount);
    SetLength(EnemyStart,EnemyStartCount);
    with EnemyStart[EnemyStartCount-1] do
    begin
     X:=i*BSIZE;
     Y:=j*BSIZE;
    end;
   end
   else
   if map[i,j].Kind=BEAGLE1 then
   begin
    EagleX:=i*64;
    EagleY:=j*64;    
   end
   else
   if map[i,j].Kind=BEAGLE2 then
   begin
    Eagle2X:=i*64;
    Eagle2Y:=j*64;
   end;

 UpdatePRMap;

end;

procedure TMap.Render(Target:byte);
var i,j:integer;
begin
 for i := 0 to 15 do
 for j := 0 to 10 do
 if Map[i,j].Kind<=8 then
 case Target of
  RBACK:if (Map[i,j].Kind<>BNONE) and (Map[i,j].Kind<>BWEB1)and (Map[i,j].Kind<>BWEB2) then
         DrawBrick(Map[i,j],i,j);
  RFRONT:if (Map[i,j].Kind<>BNONE) and ((Map[i,j].Kind=BWEB1) or (Map[i,j].Kind=BWEB2)) then
         DrawBrick(Map[i,j],i,j);
 end;
{ for i := 0 to 63 do
 for j := 0 to 43 do   
  if PRMap[i,j]>PYES then DrawQuad(BrickTex[0],i*16,j*16,16,16,0);}

end;

procedure TMap.UpdatePRMap;
var i,j,m,k,t:integer;
begin
 for i := 0 to 63 do
 for j := 0 to 43 do
  PRMap[i,j]:=PYES; 
   

 for i := 0 to 15 do
 for j := 0 to 10 do 
  case Map[i,j].Kind of
   BSIMPLE1,BSIMPLE2,BSTRONG1,BSTRONG2,BWATER,BEAGLE1,BEAGLE2:
    begin
     t:=PNO;
     if Map[i,j].Kind=BWATER then t:=PONLYBULLETS;
     
     for m := 0 to 3 do
     for k := 0 to 3 do       
     PRMap[i*4+m,j*4+k]:=t;

     with Map[i,j] do
     begin
      if (OFR<>0) or (OFL<>0) or
         (OFD<>0) or (OFU<>0) then
           RefreshBrick(i,j);

     end; 
     
    end;
   BNONE,BWEB1,BWEB2:
    begin
     for m := 0 to 3 do
     for k := 0 to 3 do       
     PRMap[i*4+m,j*4+k]:=PYES;
    end;   
  end;

end;

procedure TMap.Hit(Dir,CX,CY:integer);
begin
 if (Map[CX,CY].Kind<>BEAGLE1) and (Map[CX,CY].Kind<>BEAGLE2) then
 case Dir of
  DLEFT:inc(Map[CX,CY].OFR);
  DRIGHT:inc(Map[CX,CY].OFL);
  DTOP:inc(Map[CX,CY].OFD);
  DDOWN:inc(Map[CX,CY].OFU);
 end
 else
 begin
  DeadEagle(Map[CX,CY].Kind);
  exit;
 end;
 RefreshBrick(CX,CY);
end;

// Обновление карты проходимости при попадании патрона или загрузке карты
procedure TMap.RefreshBrick(x: Integer; y: Integer);
var i,j:integer;
    Full:boolean;

procedure SetPR(var Target:byte);
begin
 Target:=PYES;
end;

begin
if Map[x,y].OFL<>0 then
 for j := Y * 4 to Y * 4 + 3 do
 for i := 0 to Map[x,y].OFL-1 do
  SetPR(PRMap[X * 4+i , j]);

if Map[x,y].OFR<>0 then
 for j := Y * 4 to Y * 4 + 3 do
 for i := 0 to Map[x,y].OFR-1 do
  SetPR(PRMap[X * 4+3-i , j]);

if Map[x,y].OFU<>0 then
 for i := X * 4 to X * 4 + 3 do
 for j := 0 to Map[x,y].OFU-1 do
  SetPR(PRMap[i , Y * 4 + j]);

if Map[x,y].OFD<>0 then
 for i := X * 4 to X * 4 + 3 do
 for j := 0 to Map[x,y].OFD-1 do
  SetPR(PRMap[i , Y * 4 + 3 - j]);

  
 Full:=false;
 for i := X * 4 to X * 4 + 3 do
 for j := Y * 4 to Y * 4 + 3 do
  if PRMap[i,j] <> PYES then Full:=true;

 if not Full then
 begin
  Map[x,y].Kind:=BNONE;
 end;


end;

procedure Init;
begin
 Randomize;
 New(Patron);
 New(Tank);
 New(Particle);
 PreparePart;
 AddStart:=-1;

 glLineWidth(0.2);

 LoadScores;
 SortScores;

 GameParam.MotionInterpolation:=true;
 GameParam.Position:=SMENU;
// GameParam.Position:=SGAME;

 Menu.Screen:=0;
 Menu.Position:=0; 

 TankTex[0]:= tex.Load('Graphics\Tank1.tga',false,false);
 TankTex[1]:= tex.Load('Graphics\Tank2.tga',false,false);
 TankTex[2]:= tex.Load('Graphics\Tank3.tga',false,false);
 TankTex[3]:= tex.Load('Graphics\Tank4.tga',false,false);

 BrickTex[BSIMPLE1]:= tex.Load('Graphics\Wall1.bmp',false,false);
 BrickTex[BSIMPLE2]:= tex.Load('Graphics\Wall2.bmp',false,false);
 BrickTex[BSTRONG1]:= tex.Load('Graphics\Wall5.bmp',false,false);
 BrickTex[BSTRONG2]:= tex.Load('Graphics\Wall6.bmp',false,false);
 BrickTex[BWATER]:= tex.Load('Graphics\Water.bmp',false,false);
 BrickTex[BWEB1]:= tex.Load('Graphics\Web1.tga',false,false);
 BrickTex[BWEB2]:= tex.Load('Graphics\Web2.tga',false,false);
 BrickTex[BEAGLE1]:= tex.Load('Graphics\Eagle.tga',false,false);
 BrickTex[BEAGLE2]:= tex.Load('Graphics\Eagle.tga',false,false);

 Back:=tex.Load('Graphics\Back.bmp',false,false);

 PatrTex[0] := tex.Load('Graphics\Patr.tga',false,false);

 LogoTex:=tex.Load('Graphics\Logo.jpg',false,false);

 BonusTex[BONUS_SPEED] := tex.Load('Graphics\Speed.tga',false,false);
 BonusTex[BONUS_HEALTHPLUS2] := tex.Load('Graphics\Health.tga',false,false);
 BonusTex[BONUS_PATRONSPEED] := tex.Load('Graphics\Reload.tga',false,false);

 PTank1.Kind:=1;
 PTank2.Kind:=2;

 glAlphaFunc(GL_GREATER, 0.5); // 0.1 - некрасиво :)
 glBlendFunc(GL_SRC_ALPHA,GL_ONE);
 glDisable(GL_DEPTH_TEST);
end;

procedure PrepareBrick(var b:TBrick);
begin
 b.Tex:=BrickTex[b.Kind];
 b.CanHit:=true;
 if (b.Kind=BSTRONG1) or (b.Kind=BSTRONG2) or (b.Kind=BWEB1) or (b.Kind=BWEB2) or (b.Kind=BWATER)then b.CanHit:=false;

end;

function RectInRect(X1,Y1,W1,H1,X2,Y2,W2,H2:single):boolean;
begin
 Result:=false;

 if (abs(X1+W1/2-(X2+W2/2)) < abs(W1/2+W2/2)) and
    (abs(Y1+H1/2-(Y2+H2/2)) < abs(H1/2+H2/2)) 
  then result:=true;
 
end;

function Collision(X,Y,Size:single; SprSize:integer; var CX,CY:integer; const Who:byte):boolean;
var SX,SY,EX,EY,i,j:Integer;
begin
 result:=false;
 if (Y+SprSize/2-Size/2<0) or (X+SprSize/2-Size/2<0) or
    (X+SprSize/2+Size/2>1024) or (Y+SprSize/2+Size/2>768-64) and (Who=CTANK) then
 begin
  Result:=false;
  exit;
 end;

 SX:=Trunc(X+SprSize/2-Size/2) div 16;
 SY:=Trunc(Y+SprSize/2-Size/2) div 16;
 EX:=Trunc(X+SprSize/2+Size/2) div 16;
 EY:=Trunc(Y+SprSize/2+Size/2) div 16;


 for i := SX to EX do
 for j := SY to EY do
  if Map.PRMap[i,j]>Who then
   begin
    result:=true;
    CX:=i;
    CY:=j;
    exit;
   end;

end;

function AddPatron:PPatron;
var P:PPatron;
begin
 inc(PatrCount);
 New(P);

 if Patron^.Next <> nil then
  Patron^.Next^.Prev:=P;

 P^.Next:=Patron^.Next;
 P^.Prev:=Patron;
 Patron^.Next:=P;

 Result:=P;


end;

function DeletePatron(P:PPatron):PPatron;
begin
 if P^.Next<>nil then
 begin
  Result:=P^.Next;
  P^.Prev^.Next:=P^.Next;
  P^.Next^.Prev:=P^.Prev;
  Dispose(P);
 end
 else
 begin
  Result:=nil;
  P^.Prev^.Next:=nil;
  Dispose(P);
 end;

 Dec(PatrCount);
end;

procedure DeadEagle(Eagle:byte);
var X,Y:Integer;
begin
 X:=0;
 Y:=0;
 DEagle:=Eagle;

 if not GameParam.SinglePlayer then
  begin
   if GameOverStart=-1 then
    GameOverStart:=eX.GetTime;
   case Eagle of
    BEAGLE1:
     begin
      X:=EagleX;
      Y:=EagleY;
     end;
    BEAGLE2:
     begin
      X:=Eagle2X;
      Y:=Eagle2Y;
     end;
   end;
   CreateExplosion(X,Y,450,5,4);
   Map.Map[X div 64,Y div 64].Kind:=BNONE;
   Map.RefreshBrick(X div 64,Y div 64);
  end
 else
 begin
  if GameOverStart=-1 then
   GameOverStart:=eX.GetTime;
  CreateExplosion(EagleX,EagleY,450,5,4);
  Map.Map[EagleX div 64,EagleY div 64].Kind:=BNONE;
  Map.RefreshBrick(EagleX div 64,EagleY div 64);
  GameIsOver:=true;
 end; 
end;

procedure TPatron.Update;
var cx,cy:integer;
    T:PTank;
    P:PPatron;
    Tmp:integer;
begin
     case Direction of
      DLEFT:X:=X-Speed;
      DRIGHT:X:=X+Speed;
      DTOP:Y:=Y-Speed;
      DDOWN:Y:=Y+Speed;
     end;

     FromTank:=false;

     if X+16<0 then
      MustDie:=true;
     if Y+16<0 then
      MustDie:=true;
     if X>1024 then
      MustDie:=true;
     if Y>768  then
      MustDie:=true;
     // Ландшафт
     if not MustDie then
     begin
     if Collision(X,Y,8,8,cx,cy,CPATR) then
     if (CX div 4<16) and (CY div 4<11) then
      begin
       if (map.Map[CX div 4, CY div 4].CanHit) then
        Map.Hit(Direction, CX div 4,CY div 4);
       MustDie:=true;
      end;
     // Игроки
     if RectInRect(X+4,Y+4,8,8,PTank1.x+(64-PTank1.RealS)/2,PTank1.y+(64-PTank1.RealS)/2,PTank1.RealS,PTank1.RealS) then
     if Kind<>PTank1.Kind then
      begin
       if (not GameParam.SinglePlayer) and (PTank1.Health=1) then
        FromTank:=true;
       if (Kind<>2) or not GameParam.SinglePlayer then
        PTank1.Hit;
       MustDie:=true;
      end;

     if RectInRect(X+4,Y+4,8,8,PTank2.x+(64-PTank2.RealS)/2,PTank2.y+(64-PTank2.RealS)/2,PTank2.RealS,PTank2.RealS) then
     if Kind<>PTank2.Kind then
      begin
       if (not GameParam.SinglePlayer) and (PTank2.Health=1) then
        FromTank:=true;
       if (Kind<>1) or not GameParam.SinglePlayer then
        PTank2.Hit;
       MustDie:=true;
      end;


      // Танки
      T:=Tank^.Next;
      if kind<>0 then
      while T<>nil do
      begin
       if RectInRect(X+4,Y+4,8,8,T^.x+(64-T^.RealS)/2,T^.y+(64-T^.RealS)/2,T^.RealS,T^.RealS) then
       begin
        if T^.Health=1 then
         begin
          FromTank:=true;
          if T^.Kind=0 then
          begin
           if T^.Texture=TankTex[1] then Tmp:=200
           else if T^.Texture=TankTex[2] then Tmp:=400
           else Tmp:=600;

           if Kind=1 then
            inc(P1SCORE,Tmp)
           else inc(P2SCORE,Tmp);
           

          end;
         end;
        if kind<>0 then
         T^.Hit;
        MustDie:=true;
       end;
       T:=T^.Next;
      end;


      // Патроны
      IsChecking:=true;
      P:=Patron^.Next;
      while P<>nil do
      begin
       if RectInRect(X,Y,16,16,P^.X,P^.Y,16,16) and not P^.IsChecking then
       begin
        MustDie:=true;
        P^.MustDie:=true;
       end;
       P:=P^.Next;
      end;
      IsChecking:=false;

     end;

end;

procedure ClearPatrons;
var P:PPatron;
begin
 P:=Patron;
 while (P<>nil)do
  if P<>Patron then
   P:=DeletePatron(P)
  else P:=P^.Next;

end;

procedure TTank.Die;
begin
 CreateExplosion(trunc(X),trunc(Y),PARTCOUNTT,Random(4));
 if (Kind=1) or (Kind=2) then // Если танк плеера
 begin
  case GameParam.SinglePlayer of
   false:  // Играем Versus
    begin
     ResTimer[Kind]:=0;
     X:=-100;
     Y:=-100;
    end;
   true:
    begin // Играем с компом
     ResTimer[Kind]:=trunc(RESNEED / 2);
     X:=-100;
     Y:=-100;
    end;
  end;
 end
 else
 begin
  MustDie:=true;
  Dec(EnemyNeed);
 end;

 case Kind of
  1:dec(P1LIVES);
  2:dec(P2LIVES);
 end;
 if ((P1LIVES=0) and not GameParam.SecondPlayer) or ((P1LIVES = 0) and (P2LIVES=0) and (GameParam.SecondPlayer) and (GameParam.SinglePlayer) ) then
 begin
  GameOverStart:=eX.GetTime;
  GameIsOver:=true;
 end;

 if {(random(4)=0) and (Kind=0)} true then
  AddBonus;
end;

procedure TTank.Hit;
begin
 Dec(Health);
 if Health<=0 then
  Die;
end;

procedure ShowText(Text:string; NextMenu:integer);
begin
 GameParam.Position:=SMENU;
 Menu.Screen:=4;
 Menu.Next:=NextMenu;
 Menu.CurText:=Text;
end;

function AddTank:PTank;
var T:PTank;
begin
 inc(TankCount);
 New(T);

 if Tank^.Next <> nil then
  Tank^.Next^.Prev:=T;

 T^.Next:=Tank^.Next;
 T^.Prev:=Tank;
 Tank^.Next:=T;

 Result:=T;
end;

function DeleteTank(T:PTank):PTank;
begin
 if T^.Next<>nil then
 begin
  Result:=T^.Next;
  T^.Prev^.Next:=T^.Next;
  T^.Next^.Prev:=T^.Prev;
  Dispose(T);
 end
 else
 begin
  Result:=nil;
  T^.Prev^.Next:=nil;
  Dispose(T);
 end;

 Dec(TankCount);
end;

procedure ClearTanks;
var T:PTank;
begin
 T:=Tank;
 while (T<>nil)do
  if T<>Tank then
   T:=DeleteTank(T)
  else T:=T^.Next;
end;


procedure LoadNextLevel;
var i:integer;
begin
 i:=0;
 repeat
  inc(i);
  inc(CurLevel);
  if i=2 then CurLevel:=1;   
 until Map.Load('Maps\lev'+inttostr(CurLevel)+'.map') or (i=3);
 NextLevelStart:=-1;
 EnemyNeed:=PrevEnemyNeed+1;
 PrevEnemyNeed:=EnemyNeed;

 inc(P1Score,1000);
 if GameParam.SecondPlayer then inc(P2Score,1000);
 
 if i=3 then
 begin
  ShowText('ОШИБКА ЗАГРУЗКИ',0);
 end;
end;

procedure AddBonus;
begin
 with Bonus do
 begin
  if Active then exit;
  Active:=true;
  repeat
   X:=random(16);
   Y:=Random(11);
  until Map.Map[X,Y].Kind=BNONE;
  Kind:=random(BONUSCOUNT);
  TimeStart:=eX.GetTime;
 end;
end;

procedure TakeBonus(Kind:integer);
var T:PTank;
begin
 Bonus.Active:=false;

 T:=nil;

 if Kind=1 then
 begin
  T:=@PTank1;
  inc(P1Score,200);
 end
 else if Kind=2 then
 begin
  T:=@PTank2;
  inc(P2Score,200);
 end;

 with T^ do
 begin
  case Bonus.Kind of
   BONUS_SPEED:
    begin
     Speed:=8;
    end;
   BONUS_HEALTHPLUS2:
    begin
     inc(Health,2);
    end;
   BONUS_PATRONSPEED:
   begin
    FireInterval:=255;
   end;   
  end;
 end;
 
end;

function LoadScores:boolean;
var f:file of TScores;
    i:integer;
begin
{$I-}
 Assign(f,'scores.dat');
 reset(f);
 read(f,Scores);
 Closefile(f);
{$I+}
 result:=IOResult=0;
 if not result then
  for i := 1 to 10 do
   with Scores.Items[i] do
   begin
    Name:= 'NONE';
    Score:=0;
   end;
 SortScores;
end;

function SaveScores:boolean;
var f:file of TScores;
begin
{$I-}
 Assign(f,'scores.dat');
 rewrite(f);
 write(f,Scores);
 Closefile(f);
{$I+}
 result:=IOResult=0;
end;

procedure SortScores;
var i,j:integer;
    Temp:TScore;
begin
 with Scores do // Это же метод пузырьковой сортировки:)
 for j := 1 to 9 do
 for i := 1 to 10 - j do
  if Items[i].Score<Items[i+1].Score then
  begin
   Temp:=Items[i];
   Items[i]:=Items[i+1];
   Items[i+1]:=Temp;
  end;
end;

procedure ShowScores;
begin
 GameParam.Position:=SMENU;
 Menu.Screen:=5;
 Menu.Position:=0;
end;

procedure GameOver;
begin
 if not GameParam.SecondPlayer then
 begin
  if (P1Score>Scores.items[10].Score) then
  begin
   Menu.Screen:=6;
   GameParam.Position:=SMENU;
   GScore:=P1Score;
   PlayerName:='';
  end
  else
  begin
   ShowScores;
  end;
 end
 else
 begin
 if (P1Score+P2Score)>Scores.items[10].Score then
 begin
  Menu.Screen:=6;
  GameParam.Position:=SMENU;
  GScore:=P1Score+P2Score;
  PlayerName:='';
 end
 else
 begin
  ShowScores;
 end;
 end;

end;

end.
