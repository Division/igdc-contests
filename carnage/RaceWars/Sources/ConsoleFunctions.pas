unit ConsoleFunctions;

interface

uses Variables, {dLua,} eXgine, dMAth,sysutils, dCars;

procedure InitConsole;

var ScriptPath:string;

implementation

procedure ConScriptDir;
var i:integer;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        i:=strtoint(Params[1]);
        if i=0 then
          ScriptPath:='DATA\Scripts\'
        else ScriptPath:='DATA\Levels\Level'+inttostr(i)+'\';
        echo('Script directory changed: "'+ScriptPath+'"');
      end
    else if Length(Params) = 1 then
      Console.echo('Script directory: "'+ScriptPath+'"');
end;

procedure ConQuit;
begin
  eX.Quit;
end;

procedure ConShowFPS;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        ShowFPS := strtoint(Params[1]);
      end
    else console.echo('ShowFPS is '+inttostr(ShowFPS));  

end;

procedure ConLoadLevel;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        if fileexists('data\maps\'+Params[1]+'.map') then
          GameManager.LoadLevel(Params[1])
        else
          Console.echo('����� ' + Params[1] + ' �� ����������');
      end;
end;

procedure ConFollow;
var i:integer;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        i:=strtoint(params[1]);
        if (i>=0) and (i<GameManager.CarCount) then
          Camera.follow:=@GameManager.Cars[i];
      end;
end;

procedure Conai_minturn;
var t:single;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        t:=strtofloat(params[1]);
        if camera.follow^.ClassType = TAICar then
          (Camera.follow^ as TAICar).MinTurn := t;
      end
    else
      begin
        if camera.follow^.ClassType = TAICar then
          echo(floattostr((camera.follow^ as TAICar).MinTurn));
      end;

end;

procedure Conai_tck;
var t:single;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        t:=strtofloat(params[1]);
        if camera.follow^.ClassType = TAICar then
          (Camera.follow^ as TAICar).ToCenterKoef := t;
      end
    else
      begin
        if camera.follow^.ClassType = TAICar then
          echo(floattostr((camera.follow^ as TAICar).ToCenterKoef));
      end;
end;

procedure Conai_dfc;
var t:single;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        t:=strtofloat(params[1]);
        if camera.follow^.ClassType = TAICar then
          (Camera.follow^ as TAICar).DistFromCenter := t;
      end
    else
      begin
        if camera.follow^.ClassType = TAICar then
          echo(floattostr((camera.follow^ as TAICar).DistFromCenter));
      end;

end;

procedure ConLightPow;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        SUNLIGHT_POWER := strtofloat(params[1]);
      end;
end;

procedure ConWeapon;
begin
  with Console do
    if Length(Params) > 1 then
      begin
        GameManager.Cars[0].PickWeapon(strtoint(params[1]));
      end;
end;

procedure InitConsole;
begin
  ScriptPath:='DATA\Scripts\';
  Console.RegProc('Quit',@ConQuit,'����� �� ����');
  Console.RegProc('Follow',@ConFollow,'�������');  
  Console.RegProc('LoadLevel',@ConLoadLevel,'�������� ������');
  Console.RegProc('ShowFPS',@ConShowFPS,'���������� FPS? ����� ���� 0 ��� 1');
  Console.RegProc('ai_dfc',@Conai_dfc,'����� DistFromCenter ��� ����������');
  Console.RegProc('ai_tck',@Conai_tck,'����� ToCenterKoef ��� ����������');
  Console.RegProc('ai_minturn',@Conai_minturn,'����� minturn ��� ����������');
  Console.RegProc('LightPow',@ConLightPow,'���� ���������� �����');
  Console.RegProc('Weapon',@ConWeapon,'����� ������');    
end;

end.
