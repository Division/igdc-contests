unit Map;

interface

uses eXgine, Windows;

function LoadMap(FileName:string):boolean;


implementation

uses Game, Physics;

var pol:TPolygon;

function FileExists(const FileName: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(FileName));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code = 0);
end;


function LoadMap(FileName:String):boolean;
var f:file of Integer;
    i,t,j,t2:integer;
    e:TTarget;
    ec,vc:integer;

begin
 GameReset;

 Result:=false;

{$I-}
 ps.SetPCount(1000);
 ps.SetCCount(1000);
 GetCount:=0;
 AssignFile(f,'maps\'+FileName);
 Reset(f);

  if IOResult<>0 then
  begin
    CloseFile(f);

    exit;

  end;
{$I-}
  Read(f,Scl);
  Read(f,PolygonCount);
  Read(f,Ec);
  Read(f,i); Start.X:=i*(Scl/10);
  Read(f,i); Start.Y:=i*(Scl/10);
  Read(f,i); Finish.X:=i*(Scl/10);
  Read(f,i); Finish.Y:=i*(Scl/10);



//  if PolygonCount>0 then
  SetLength(Polygons,PolygonCount);
  if PolygonCount>0 then
  for i := 0 to PolygonCount-1 do
  begin
    Read(f,t);
    for j := 0 to t - 1 do
    begin
      Read(f,t);
      Read(f,t2);
      Polygons[i].AddVertex(Vector3(t*Scl/10,t2*Scl/10,0));
    end;
    Polygons[i].CalculateTexCoords(100);
    Polygons[i].GetNormals;
  end;


  if IOResult<>0 then exit;
  TargetCount:=ec;
  if TargetCount>0 then
  SetLength(Targets,ec);


  if ec>0 then
  for i := 0 to ec-1 do
    begin
      Read(f,t); Targets[i].x:=t*(Scl/5)/2;
      Read(f,t); Targets[i].y:=t*(Scl/5)/2;
      Targets[i].Enabled:=true;
    end;

  Read(f,KillerCount);
  if IOResult<>0 then exit;



  SetLength(Killers,KillerCount);
  if KillerCOunt>0 then
    for i := 0 to KillerCount - 1 do
    begin
      Read(f,t);
      Killers[i].x:=t*(scl/10);
      Read(f,t);
      Killers[i].y:=t*(scl/10);
    end;

  CloseFile(f);
{$I+}

  Result:=IOResult=0;
  if not Result then exit;
  
  

  Pol.Clear;
  Pol.AddVertex(Vector3(-600,450*scl/10,0));
  Pol.AddVertex(Vector3(-600,450*scl/10+600,0));
  Pol.AddVertex(Vector3(450*scl/10+600,450*scl/10+600,0));
  Pol.AddVertex(Vector3(450*scl/10+600,450*scl/10,0));
  Pol.CalculateTexCoords(100);
  Pol.GetNormals;
  AddPolygon(Pol);
  Pol.Clear;

  Pol.AddVertex(Vector3(-600,-600,0));
  Pol.AddVertex(Vector3(-600,450*scl/10+600,0));
  Pol.AddVertex(Vector3(0,450*scl/10+600,0));
  Pol.AddVertex(Vector3(0,-600,0));
  Pol.CalculateTexCoords(100);
  Pol.GetNormals;
  AddPolygon(Pol);
  Pol.Clear;

  Pol.AddVertex(Vector3(-600,0,0));
  Pol.AddVertex(Vector3(450*scl/10+600,0,0));
  Pol.AddVertex(Vector3(450*scl/10+600,-600,0));
  Pol.AddVertex(Vector3(-600,-600,0));
  Pol.CalculateTexCoords(100);
  Pol.GetNormals;
  AddPolygon(Pol);
  Pol.Clear;

  Pol.AddVertex(Vector3(450*scl/10,0,0));
  Pol.AddVertex(Vector3(450*scl/10,450*scl/10+600,0));
  Pol.AddVertex(Vector3(450*scl/10+600,450*scl/10+600,0));
  Pol.AddVertex(Vector3(450*scl/10+600,-600,0));
  Pol.CalculateTexCoords(100);
  Pol.GetNormals;
  AddPolygon(Pol);
  Pol.Clear;
  

  ps.InitParam(4,Vector3(450*Scl/10,450*Scl/10,0),Vector3(0,0.8,0),0.5);
  Player.Create(Start.x,Start.y);
  Player.Polygon.Clear;
  Player.Update;
  Player.Polygon.CalculateTexCoords(100,true);

  Verevka.Create;
end;


end.
