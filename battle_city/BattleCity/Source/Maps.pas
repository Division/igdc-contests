unit Maps;

interface

uses Game;


type
    SAVEDMAP=record
              Singleplayer:boolean;
              Map:TMapBricks;
             end;

procedure SaveToFile(const Map:SAVEDMAP; FileName:String);
function LoadFromFile(var map:SAVEDMAP; const FileName:String):boolean;

implementation

procedure SaveToFile(const Map:SAVEDMAP; FileName:String);
var f:file of SAVEDMAP;
begin
 Assign(f, FileName);
 Rewrite(f);
 write(f,map);
 CloseFile(f);
end;

function LoadFromFile(var map:SAVEDMAP; const FileName:String):boolean;
var f:file of SAVEDMAP;
begin
 result:=true;
{$I-}
 Assign(f, FileName);
 Reset(f);
 Read(f,map);
 CloseFile(f);
{$I+}
 if IOResult<>0 then result:=false;

end;

end.
