unit AI;

interface

uses Variables, Game, eXgine, Particles;

procedure UpdateEnemies;
procedure AddEnemies;
procedure UpdateAI;

implementation

procedure AddEnemies;
var i,TX,TY:integer;
    T:PTank;
    a:boolean;
begin
 // Если врагов осталось больше чем стартовых позиций, то
 a:=true;
 if (eX.GetTime-AddStart)>=ADDNEED then
 begin
 if EnemyNeed>EnemyStartCount then
 begin
  AddStart:=-1;
  for i := 0 to EnemyStartCount - 1 - TankCount do
   begin

{     T:=Tank^.Next;
     T^.IsChecking:=true;
     while T<>nil do
     begin
      if not T^.IsChecking then
      begin
      if RectInRect(EnemyStart[i].X+(64-T^.RealS)/2,EnemyStart[i].Y+(64-T^.RealS)/2,T^.RealS,T^.RealS, T^.X+(64-T^.RealS)/2,T^.Y+(64-T^.RealS)/2, T^.RealS,T^.RealS)
       then T^.MustDie:=true;
      end;
      T:=T^.Next;
     end;
     T^.IsChecking:=false;}
    // ДОБАВИТЬ ПРОВЕРКУ НА СТОЛКНОВЕНИЯ С ТАНКАМИ! Возможно телефрагирование

     T:=Tank^.Next;
     TY:=0;
     TX:=0;
     while T<>nil do
     begin
      if RectInRect(EnemyStart[i].X+(64-T^.RealS)/2,EnemyStart[i].Y+(64-T^.RealS)/2,T^.RealS,T^.RealS, T^.X+(64-T^.RealS)/2,T^.Y+(64-T^.RealS)/2, T^.RealS,T^.RealS)
       then a:=false;
      T:=T^.Next;
     end;

    if a then
    
    with AddTank^ do
    begin
     inc(EnemyCount);
     Reset;
     X:=EnemyStart[i].X;
     Y:=EnemyStart[i].Y;
     TimeStart:=eX.GetTime;
     TimeNeed:=1100;
     Busy:=true;
     CurAIAction:=ANONE;
     RealS:=30;
     NeedFire:=false;
     interrupt:=false;
     Texture:=TankTex[1];
     CreateExplosion(trunc(X),trunc(Y),40,4,0);
     Kind:=0;

     if random(5)=0 then
     begin
      Speed:=7;
      FireInterval:=400;
      Texture:=TankTex[2];
      health:=3;
     end;

     if random(10)=0 then
     begin
      Speed:=4;
      FireInterval:=250;
      Texture:=TankTex[3];
      health:=5;
     end;


    end;
   end;
 end
 else
 begin
  for i := 0 to EnemyNeed - 1 - TankCount do
   begin
    // ДОБАВИТЬ ПРОВЕРКУ НА СТОЛКНОВЕНИЯ С ТАНКАМИ! Возможно телефрагирование

{     T:=Tank^.Next;
     TY:=0;
     TX:=0;
     while T<>nil do
     begin
      if not T^.IsChecking then
      begin
       repeat
        TX:=random(EnemyStartCount);
        inc(TY)
       until not RectInRect(EnemyStart[TX].X+(64-T^.RealS)/2,EnemyStart[TX].Y+(64-T^.RealS)/2,T^.RealS,T^.RealS, T^.X+(64-T^.RealS)/2,T^.Y+(64-T^.RealS)/2, T^.RealS,T^.RealS) or (TY > 15);
       if TY>15 then exit;

      end;
      T:=T^.Next;
     end;          }

    with AddTank^ do
    begin
     inc(EnemyCount);
     Reset;
     X:=EnemyStart[i].X;
     Y:=EnemyStart[i].Y;
     TimeStart:=eX.GetTime;
     TimeNeed:=1100;
     CurAIAction:=ANONE;
     NeedFire:=false;
     RealS:=30;
     interrupt:=false;
     Busy:=true;
     Speed:=4;
     FireInterval:=300;
     Texture:=TankTex[3];
     Health:=5;
     CreateExplosion(trunc(X),trunc(Y),40,4,0);
     Kind:=0;
    end;
   end;

 end;
 end;
end;

procedure UpdateEnemies;
var T:PTank;
begin
 // Если на карте маловато врагов, почему бы не добавить?
 if (TankCount < EnemyStartCount) and (EnemyNeed>0) then
 begin
  if AddStart<0 then
   AddStart:=eX.GetTime;
  AddEnemies;
 end;

 UpdateAI;

 T:=Tank^.Next;
 while T<>nil do
 begin
  T^.Update;
  if T^.MustDie then
   T:=DeleteTank(T)
  else T:=T^.Next;
 end;

 if (EnemyNeed=0) and (NextLevelStart=-1) then
 begin
  NextLevelStart:=eX.GetTime;
 end;
 if (eX.GetTime - NextLevelStart >= GAMEDELAY) and (NextLevelStart<>-1) then
 begin
  LoadNextLevel;
 end;

end;

procedure UpdateAI;
var T:PTank;
    Tm,EagleSideH,EagleSideV:integer;
    HD:Single;
    CX,CY:Integer;
begin
 Tm:=eX.GetTime;
 T:=Tank^.Next;
 while T<>nil do
 begin
  with T^ do
  begin
   if Tm-TimeStart>TimeNeed then Busy:=false;
   if Interrupt then
   begin
    Busy:=false;
    NeedFire:=true;
   end;
   if not Busy then // Если не поставлена задача, то ставим      begin
   begin
    // Работа с таймером и др.
    Interrupt:=false;
    CurAIAction:=Random(4);
    TimeStart:=Tm;
    TimeNeed:=Random(10)*200+1500;
    Busy:=true;
    NeedFire:=Random(5)=0;

    if X-EagleX < 0 then EagleSideH:=DRIGHT
    else EagleSideH:=DLEFT;
    if Y-EagleY < 0 then EagleSideV:=DDOWN
    else EagleSideV:=DTOP;

    case Random(2) of // Сначала идём по горизонтали или вертикали?
    0:// По горизонтали :)
     begin
      if random(4)=0 then
       CurAIAction:=Random(2)
      else CurAIAction:=EagleSideH;
     end;
    1:// По вертикали
     begin
     if random(4)=0 then
       CurAIAction:=Random(2)
      else
      begin
       CurAIAction:=EagleSideV;
      end;
     end;
    end;   

    CX:=trunc(X+32) div 64;
    CY:=trunc(Y+32) div 64;
//    i:=0;
//    Probiv:=true;

    HD:=abs(EagleX-CX);
//    VD:=abs(EagleY-CY);


    if (EagleY div 64=CY) and (HD<3) then
    begin
     Busy:=true;
     NeedFire:=true;
     CurAIAction:=EagleSideH;
     TimeNeed:=TimeNeed+1000;
    end;
    
   end
   else // Если поставлена, то выполняем
   begin
    Command(CurAIAction);
    if (random(10)=0) or NeedFire then Command(AFIRE);
   end;


  end;
  T:=T^.Next;
 end;
end;



end.
