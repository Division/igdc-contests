unit GameUpdate;

interface

uses eXgine, Variables, Game, Windows,Particles;

procedure UpdateInput;
procedure StartUpdateTanks;
procedure FinishUpdateTanks;
procedure UpdatePatrons;
procedure MenuEnter;
procedure Resurrect(Kind:integer);

implementation

procedure UpdateInput;
begin
 if inp.Down(27) then
  begin
   GameParam.Position:=SMENU;
   Menu.Position:=0;
   Menu.Screen:=2;
  end;

 if inp.LastKey=VK_F1  then GameParam.MotionInterpolation:=not GameParam.MotionInterpolation;
 if inp.Down(VK_LEFT)  then PTank1.Command(DLEFT);
 if inp.Down(VK_RIGHT) then PTank1.Command(DRIGHT);
 if inp.Down(VK_UP)    then PTank1.Command(DTOP);
 if inp.Down(VK_DOWN)  then PTank1.Command(DDOWN);
 if inp.Down(VK_CONTROL) then PTank1.Command(AFIRE);

 if GameParam.SecondPlayer then
 begin
  if inp.Down(ord('A')) then PTank2.Command(DLEFT);
  if inp.Down(ord('D')) then PTank2.Command(DRIGHT);
  if inp.Down(ord('W')) then PTank2.Command(DTOP);
  if inp.Down(ord('S')) then PTank2.Command(DDOWN);
  if inp.Down(VK_SPACE) then PTank2.Command(AFIRE);
 end;
end;

procedure StartUpdateTanks;
var i:integer;
begin
 if PTank1.Health>0 then 
  PTank1.Update;

 for i := 1 to 2 do
 if ResTimer[i]<RESNEED then
 begin
  ResTimer[i]:=ResTimer[i]+trunc(1000/UPS);
  if ResTimer[i]>=RESNEED then
   Resurrect(i);
 end;

 if GameParam.SecondPlayer and (PTank2.Health>0) then
 begin
  PTank2.Update;
 end;

end;

procedure FinishUpdateTanks;
var T:PTank;
begin
 PTank1.FinishUpdate;
 if GameParam.SecondPlayer then PTank2.FinishUpdate;

 if GameParam.SinglePlayer then // Если играем против компьютера
 begin
  T:=Tank^.Next;
  while T<>nil do
  begin
   T^.FinishUpdate;
   T:=T^.Next;
  end;
 end;
end;

procedure UpdatePatrons;
var P:PPatron;
begin
// if Patron^.Next=nil then exit;

 P:=Patron^.Next;
 while P<>nil do
 begin
  P^.Update;
  if P^.MustDie then
  begin
   if not P^.FromTank then
    CreateExplosion(trunc(P^.X)-16+8,trunc(P^.Y)-16+8,PARTCOUNTP,Random(4),PARTPOWERP,2);
   P:=DeletePatron(P);
  end
  else P:=P^.Next;
 end;
end;

procedure MenuEnter;
var success:boolean;
begin
 with  Menu do
 begin
  case Screen of
   0:
    begin
     if Position=3 then eX.Quit;
     if Position=2 then
     begin
      Screen:=7;
     end;     
     if Position=1 then
     begin
      ShowScores;
      inp.Reset;
      exit;
     end;
     if Position=0 then
     begin
      Screen:=1;
      Position:=0;
     end;
    end;
   1:
    begin
     if Position=0 then // Один игрок
      begin
       Screen:=3;
       Position:=0;
       GameParam.SinglePlayer:=true;
       GameParam.SecondPlayer:=false;
       EnemyNeed:=5;
       PrevEnemyNeed:=EnemyNeed;
       P1LIVES:=3;
       P1SCORE:=0;
       P2SCORE:=0;
       LastScore1:=1;
       LastScore2:=1;
      end;
     if Position=1 then // Два игрока против компа
      begin
       Screen:=3;
       GameParam.SinglePlayer:=true;
       GameParam.SecondPlayer:=true;
       Position:=0;
       EnemyNeed:=8;
       PrevEnemyNeed:=EnemyNeed;
       P1LIVES:=3;
       P2LIVES:=3;
       P1SCORE:=0;
       P2SCORE:=0;
       LastScore1:=1;
       LastScore2:=1;
      end;
     if Position=2 then // Два игрока Versus
      begin
       Screen:=3;
       GameParam.SinglePlayer:=false;
       GameParam.SecondPlayer:=true;
       Position:=0;
      end;


    end;
   2:
    begin
     if Position=0 then
      begin
       GameParam.Position:=SGAME;
       Menu.Position:=0;
      end;
     if Position=1 then
      begin
       Menu.Screen:=0;
       Menu.Position:=0;
      end;
    end;
   3:
    begin
     if GameParam.SinglePlayer then
      success := Map.Load('Maps\lev'+inttostr(SelectedLevel)+'.map')
     else success := Map.Load('Maps\vs'+inttostr(SelectedLevel)+'.map');
     if success then GameParam.Position:=SGAME;
     CurLevel:=SelectedLevel;
     GameOverStart:=-1;
    end;
  end;

 end;
end;

procedure Resurrect(Kind:integer);
begin
 case Kind of
  1: if not GameParam.SinglePlayer or (P1LIVES>0) then
   begin
    PTank1.Reset;
    PTank1.x:=P1STX;
    PTank1.y:=P1STY;
    PTank1.Health:=PLAYERS_HEALTH;
    with PTank1 do
     if RectInRect(X+(64-RealS)/2,Y+(64-RealS)/2,RealS,RealS, PTank2.X+(64-RealS)/2,PTank2.Y+(64-RealS)/2, RealS,RealS)
     then PTank2.Die;
    with PTank1 do
    CreateExplosion(trunc(X),trunc(Y),40,4,0.0);
   end;
  2: if not GameParam.SinglePlayer or (P2LIVES>0) then
   begin
    PTank2.Reset;
    PTank2.x:=P2STX;
    PTank2.y:=P2STY;
    PTank2.Health:=PLAYERS_HEALTH;
    with PTank2 do
     if RectInRect(X+(64-RealS)/2,Y+(64-RealS)/2,RealS,RealS, PTank1.X+(64-RealS)/2,PTank1.Y+(64-RealS)/2, RealS,RealS)
     then PTank1.Die;
    with PTank2 do
    CreateExplosion(trunc(X),trunc(Y),40,4,0.0);

   end;
 end;
end;

end.
