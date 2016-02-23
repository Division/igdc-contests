unit utils;

interface

uses Variables, eXgine, dMeshes, dMap, dParticlesQ,dCars, dConsole, dCamera, ConsoleFunctions, dGameManager, dMenu;

procedure LoadMeshes;
procedure Init;
procedure FreeMeshes;

implementation

procedure LoadMeshes;
var i:integer;
begin
  CarMeshes[0] := TMesh.Create;
  CarMeshes[1] := TMesh.Create;
  CarMeshes[2] := TMesh.Create;
  CarMeshes[3] := TMesh.Create;
  CarMeshes[4] := TMesh.Create;
  CarMeshes[5] := TMesh.Create;    

  CarMeshes[0].LoadFromFile('data\meshes\player.mdl');
  CarMeshes[0].LoadTexture('data\textures\cars\player.jpg');

  CarMeshes[1].LoadFromFile('data\meshes\player.mdl');
  CarMeshes[1].LoadTexture('data\textures\cars\player2.jpg');

  CarMeshes[2].LoadFromFile('data\meshes\player.mdl');
  CarMeshes[2].LoadTexture('data\textures\cars\player3.jpg');

  CarMeshes[3].LoadFromFile('data\meshes\jeep.mdl');
  CarMeshes[3].LoadTexture('data\textures\cars\jeep.jpg');

  CarMeshes[4].LoadFromFile('data\meshes\supra.mdl');
  CarMeshes[4].LoadTexture('data\textures\cars\supra2.jpg');


  CarMeshes[5].LoadFromFile('data\meshes\supra.mdl');
  CarMeshes[5].LoadTexture('data\textures\cars\supra.jpg');

  for i := 0 to 22 do
    ObjMeshes[i]:=TMesh.Create;

  ObjMeshes[0].LoadFromFile('data\meshes\izmeritel.mdl');
  ObjMeshes[0].LoadTexture('data\textures\objects\izmeritel.jpg');

  ObjMeshes[1].LoadFromFile('data\meshes\cap.mdl',true);
  ObjMeshes[1].LoadTexture('data\textures\objects\cap.jpg');

  ObjMeshes[2].LoadFromFile('data\meshes\calendar.mdl');
  ObjMeshes[2].LoadTexture('data\textures\objects\calendar.jpg');


  ObjMeshes[3].LoadFromFile('data\meshes\telephone.mdl');
  ObjMeshes[3].LoadTexture('data\textures\objects\telephone.jpg');

  ObjMeshes[4].LoadFromFile('data\meshes\stepler.mdl');
  ObjMeshes[4].LoadTexture('data\textures\objects\stepler.jpg');

  ObjMeshes[5].LoadFromFile('data\meshes\skrepka_st.mdl');
  ObjMeshes[5].LoadTexture('data\textures\objects\skrepka_st.jpg');

  ObjMeshes[6].LoadFromFile('data\meshes\skrepka.mdl');
  ObjMeshes[6].LoadTexture('data\textures\objects\skrepka.jpg');

  ObjMeshes[7].LoadFromFile('data\meshes\cigaret.mdl');
  ObjMeshes[7].LoadTexture('data\textures\objects\cigaret.jpg');

  ObjMeshes[8].LoadFromFile('data\meshes\pen.mdl');
  ObjMeshes[8].LoadTexture('data\textures\objects\pen.jpg');

  ObjMeshes[9].LoadFromFile('data\meshes\podstavka.mdl',true);
  ObjMeshes[9].LoadTexture('data\textures\objects\podstavka.jpg');

  ObjMeshes[10].LoadFromFile('data\meshes\cigaret_box.mdl');
  ObjMeshes[10].LoadTexture('data\textures\objects\cigaret_box.jpg');

  ObjMeshes[11].LoadFromFile('data\meshes\papka.mdl');
  ObjMeshes[11].LoadTexture('data\textures\objects\papka.jpg');

  ObjMeshes[12].LoadFromFile('data\meshes\nojnici.mdl');
  ObjMeshes[12].LoadTexture('data\textures\objects\nojnici.jpg');

  ObjMeshes[13].LoadFromFile('data\meshes\monitor.mdl');
  ObjMeshes[13].LoadTexture('data\textures\objects\monitor.jpg');

  ObjMeshes[14].LoadFromFile('data\meshes\rooler.mdl');
  ObjMeshes[14].LoadTexture('data\textures\objects\rooler.jpg');

  ObjMeshes[15].LoadFromFile('data\meshes\eracer.mdl');
  ObjMeshes[15].LoadTexture('data\textures\objects\eracer.jpg');

  ObjMeshes[16].LoadFromFile('data\meshes\book.mdl');
  ObjMeshes[16].LoadTexture('data\textures\objects\book.jpg');

  ObjMeshes[17].LoadFromFile('data\meshes\disc.mdl');
  ObjMeshes[17].LoadTexture('data\textures\objects\disc.jpg');

  ObjMeshes[18].LoadFromFile('data\meshes\paper.mdl');
  ObjMeshes[18].LoadTexture('data\textures\objects\paper.jpg');

  ObjMeshes[19].LoadFromFile('data\meshes\paper_m.mdl');
  ObjMeshes[19].LoadTexture('data\textures\objects\paper.jpg');

  ObjMeshes[20].LoadFromFile('data\meshes\cube.mdl');
  ObjMeshes[20].LoadTexture('data\textures\objects\cube.jpg');

  ObjMeshes[22].LoadFromFile('data\meshes\flag.mdl');
  ObjMeshes[22].LoadTexture('data\textures\objects\flag.jpg');

  sFont := ogl.Font.Create('Arial',20);
end;

procedure FreeMeshes;
var i:integer;
begin
  CarMeshes[0].Free;
  CarMeshes[1].Free;
  CarMeshes[2].Free;
  CarMeshes[3].Free;
  CarMeshes[4].Free;
  CarMeshes[5].Free;              

  for i := 0 to 22 do
    ObjMeshes[i].Free;
end;

procedure Init;
begin
  LoadMeshes;
  PartEng:=TParticleEngine.Create;
  Console := TConsole.Create;
  Camera := TCamera.Create;  
  Map:=TMap.Create;
  InitConsole;

  GameManager:=TGameManager.Create;

  Menu := TMenu.Create;

end;

end.
