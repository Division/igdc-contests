unit Map;

interface

uses eXgine;

function LoadMap(FileName:string):boolean;

implementation

uses Game, Physics;

function LoadMap(FileName:String):boolean;
var f:file of Integer;
    i,t:integer;
    e:TTarget;
    ec:integer;
begin
 GameReset;

 ps.SetPCount(1000);
 ps.SetCCount(1000);
 GetCount:=0;
{$I-}
  AssignFile(f,'maps\'+FileName);
  Reset(f);
  Read(f,Scl);
  Read(f,LineCount);
  Read(f,Ec);
  Read(f,i); Start.X:=i*(Scl/10);
  Read(f,i); Start.Y:=i*(Scl/10);
  Read(f,i); Finish.X:=i*(Scl/10);
  Read(f,i); Finish.Y:=i*(Scl/10);

  if LineCount>0 then
  SetLength(Lines,LineCount);
  if LineCount>0 then
  for i := 0 to LineCount-1 do
    begin
      Read(f,t); Lines[i].v1.X:=t*(Scl/10);
      Read(f,t); Lines[i].v1.Y:=t*(Scl/10);
      Read(f,t); Lines[i].v2.X:=t*(Scl/10);
      Read(f,t); Lines[i].v2.Y:=t*(Scl/10);
      Lines[i].n:=Normalize(GetNormal2(Lines[i].v1,Lines[i].v2));
    end;

  TargetCount:=ec;
  SetLength(Targets,ec);


  if ec>0 then
  for i := 0 to ec-1 do
    begin
      Read(f,t); Targets[i].x:=t*(Scl/5)/2;
      Read(f,t); Targets[i].y:=t*(Scl/5)/2;
      Read(f,t); e.Kind:=t;
      Targets[i].Enabled:=true;
    end;


  CloseFile(f);
{$I+}

  Player.Create(Start.x,Start.y);

  Camera.X:=Finish.X-400;
  Camera.Y:=Finish.Y-300;

  AddLine(Line(Vector3(0,450*Scl/10,0),Vector3(450*Scl/10,450*Scl/10,0),Normalize(GetNormal2(Vector3(450*Scl/10,450*Scl/10,0),Vector3(0,450*Scl/10,0)))));
  AddLine(Line(Vector3(0,0,0),Vector3(450*Scl/10,0,0),Normalize(GetNormal2(Vector3(0,450*Scl/10,0),Vector3(450*Scl/10,450*Scl/10,0)))));
  AddLine(Line(Vector3(0,0,0),Vector3(0,450*Scl/10,0),Normalize(GetNormal2(Vector3(0,450*Scl/10,0),Vector3(0,0,0)))));
  AddLine(Line(Vector3(450*Scl/10,0,0),Vector3(450*Scl/10,450*Scl/10,0),Normalize(GetNormal2(Vector3(0,0,0),Vector3(0,450*Scl/10,0)))));
  ps.InitParam(3,Vector3(450*Scl/10,450*Scl/10,800),Vector3(0,0.3,0),0.5);

  Result:=IOResult=0;
end;


end.
