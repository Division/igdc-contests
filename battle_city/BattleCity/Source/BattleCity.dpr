program BattleCity;

uses
  eXgine,
  OpenGL,
  Render in 'Render.pas',
  Game in 'Game.pas',
  Variables in 'Variables.pas',
  GameUpdate in 'GameUpdate.pas',
  Maps in 'Maps.pas',
  Windows,
  Particles,
  AI in 'AI.pas';

procedure Update;
begin
 case GameParam.Position of
  SGAME:
   begin

    if P1Score div LIFESCORE >= LastScore1 then
     begin
      inc(LastScore1);
      inc(P1Lives);
     end;
    if P2Score div LIFESCORE >= LastScore2 then
     begin
      inc(LastScore2);
      inc(P2Lives);
     end;

    Ang:=Ang+0.01;

    if ((eX.GetTime - GameOverStart) >=GAMEDELAY) and (GameOverStart<>-1) then
    begin
     if (GameParam.SinglePlayer) or GameIsOver then // Убили наш герб :) в сингле
     begin
      GameOver;
     end
     else
     begin
      ShowText(MWINTEXT[DEagle-7],3)
     end;
    end;

    if eX.GetTime - Bonus.TimeStart > BONUS_STAYTIME then
    begin
     Bonus.Active:=false;
    end;

    FinishUpdateTanks;
    LastTime:=eX.GetTime;
    UpdateInput;
    if GameParam.SinglePlayer then UpdateEnemies; // Обновляем итд вражьи танки если нужно    
    StartUpdateTanks;
    UpdatePatrons;
    UpdateParticles;

   end;
  SMENU:
   begin
    if inp.LastKey=ord('H') then ShowScores;

    if inp.LastKey=VK_ESCAPE then
     if (Menu.Screen<>0) and (Menu.Screen<>2) and (Menu.Screen<>4) then
     begin
      Menu.Screen:=0;
      Menu.Position:=0;
     end
     else if Menu.Screen=2 then
      begin
       GameParam.Position:=SGAME;
       Menu.Position:=0;
       inp.Reset;
      end;

   case Menu.Screen of
    0,1,2:
    begin{}
     if inp.LastKey=VK_UP then
     begin
      if Menu.Position<>0 then
       dec(Menu.Position)
      else Menu.Position:=MENUCOUNT[Menu.Screen]-1;
     end;

     if inp.LastKey=VK_DOWN then
     begin
      if Menu.Position<>MENUCOUNT[Menu.Screen]-1 then
       inc(Menu.Position)
      else Menu.Position:=0;
     end;

     if inp.LastKey=VK_RETURN then
     begin
      MenuEnter;
     end;
    end;{}
    3:
     begin
      if inp.LastKey=VK_ESCAPE then
       begin
        Menu.Screen:=1;
       end;

      if inp.LastKey=VK_LEFT then
       dec(SelectedLevel);
      if inp.LastKey=VK_RIGHT then
       inc(SelectedLevel);
      if SelectedLevel < 1 then SelectedLevel:=1;
       if inp.LastKey=VK_RETURN then
        MenuEnter;
     end;
    4:
     begin
      if (inp.LastKey=VK_RETURN) or (inp.LastKey=VK_ESCAPE) then
       begin
        Menu.Screen:=Menu.Next;
        Menu.Position:=0;
       end;
     end;
    5:// SCORES
     begin
      if (inp.LastKey=VK_RETURN) or (inp.LastKey=VK_ESCAPE) then
       Menu.Screen:=0;
     end;
    6:
     begin
      if (inp.LastKey>=65) and (inp.LastKey<=90) then
      if Length(PlayerName)<=15 then      
      begin
       PlayerName:=PlayerName+chr(inp.LastKey);
      end;
      if inp.LastKey=8 then
       Delete(PlayerName,Length(PlayerName),1);
      inp.Reset;
      if inp.LastKey=VK_RETURN then
      begin
       Scores.Items[10].Score:=GScore;
       Scores.Items[10].Name:=PlayerName;
       if PlayerName='' then
        Scores.Items[10].Name:='NONE';
       SortScores;
       SaveScores;
       ShowScores;
      end;
      
     end; 
   end;
   end;
  7:
   begin
    if (inp.LastKey=VK_RETURN) or (inp.LastKey=VK_ESCAPE) then
     Menu.Screen:=0;
     
   end;
 end;

end;

procedure Render;
begin

 case GameParam.Position of
  SGAME:RenderGame;
  SMENU:RenderMenu;
 end;

end;

begin
  wnd.Create('Main Window');
  eX.SetProc(PROC_UPDATE, @Update);
  eX.SetProc(PROC_RENDER, @Render);
  Init;
//  ogl.VSync(true);

// Установка полноэкранного режима
  wnd.Mode(true, 1024, 768, 32, 100);

// Вход в главный цикл
  eX.MainLoop(UPS);
end.
