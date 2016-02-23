unit utils;

interface

uses Variables, dShaderMan, eXgine, dMeshes, dAnimation, dMap, dCars, dConsole, dCamera, ConsoleFunctions, dGameManager, dMenu, dWeapons, dSky, dParticleSystem;

procedure LoadMeshes;
procedure Init;
procedure Finalize;
procedure FreeMeshes;

implementation

// ¬с€ эта загрузка очень напонимант говнозагрузку
// Ќадо будет придумать человеческий менеджер ресурсов

procedure LoadMeshes;
var i:integer;
    sh : PSh;
begin
  CarMeshes[0] := TOTModel.Create;
  CarMeshes[1] := TOTModel.Create;
  CarMeshes[2] := TOTModel.Create;
  CarMeshes[3] := TOTModel.Create;
  CarMeshes[4] := TOTModel.Create;
  CarMeshes[5] := TOTModel.Create;

  CarMeshes[0].Load('data\car1.otm');
  CarMeshes[1].Load('data\car2.otm');
  CarMeshes[2].Load('data\car2.otm');
  CarMeshes[3].Load('data\car3.otm');
  CarMeshes[4].Load('data\car3.otm');
  CarMeshes[5].Load('data\car1.otm');

  (CarMeshes[0].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\car1_tex.jpg'));
  (CarMeshes[1].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\car2_tex.jpg'));
  (CarMeshes[2].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\car3_tex.jpg'));
  (CarMeshes[3].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\car4_tex.jpg'));
  (CarMeshes[4].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\car5_tex.jpg'));
  (CarMeshes[5].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\car6_tex.jpg'));          

  CursorMesh := TOTModel.Create;

  for i := 0 to 2 do
    begin
      CartridgeModels[i] := TOTModel.Create;
      WeaponModels[i] := TOTModel.Create;
    end;

  for i := 0 to 3 do
    begin
      GarbageMeshes[i] := TOTModel.Create;
    end;


  for i := 0 to 22 do
    ObjMeshes[i]:=TOTModel.Create;

  CartridgeModels[W_MACHINEGUN].Load('data\weapons\MachineGun_c.otm');
  CartridgeModels[W_PLASMAGUN].Load('data\weapons\Plasma_c.otm');
  CartridgeModels[W_ROCKETLAUNCHER].Load('data\weapons\Rocket.otm');

  (CartridgeModels[W_MACHINEGUN].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\weapons\MachineGun_c.jpg'));  
  (CartridgeModels[W_ROCKETLAUNCHER].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\weapons\rocket.jpg'));
  (CartridgeModels[W_PLASMAGUN].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\weapons\plasma_c.jpg'));

//  CursorMesh.Load('data\weapons\ArrowMesh.otm');
  WeaponModels[W_MACHINEGUN].Load('data\weapons\machinegun.otm');
  (WeaponModels[W_MACHINEGUN].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\weapons\MachineGun2.jpg'));
  (WeaponModels[W_MACHINEGUN].Mesh[1] as TOTMesh).Material.AddTexture(tex.load('data\textures\weapons\MachineGun1.jpg'));  

  WeaponModels[W_PLASMAGUN].Load('data\weapons\PlasmaGun.otm');
  (WeaponModels[W_PLASMAGUN].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\weapons\Plasmagun.jpg'));

  WeaponModels[W_ROCKETLAUNCHER].Load('data\weapons\rocketlauncher.otm');
  (WeaponModels[W_ROCKETLAUNCHER].Mesh[0] as TOTMesh).Material.AddTexture(tex.load('data\textures\weapons\RocketLauncher.jpg'));



  Sh := ShMan.GetShaderByName('linebump');
  ObjMeshes[0].Load('data\Models\WeaponBase.otm',true);
  if Sh <> nil then
   with(ObjMeshes[0].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\objects\WeaponBase_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\WeaponBase_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\WeaponBase_line.jpg'));
      end;
  Sh := ShMan.GetShaderByName('linediffuse');      
  for i := 1 to 3 do
   with(ObjMeshes[0].Mesh[i] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\objects\Box_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\Box_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('linebump');
  ObjMeshes[1].Load('data\SpaceRing.otm',true);
  if Sh <> nil then
   with(ObjMeshes[1].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\rings\spacering1_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\rings\spacering1_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\rings\spacering1_line.jpg'));
      end;
   with(ObjMeshes[1].Mesh[1] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\rings\spacering1_normal_add.jpg'));
        Material.AddTexture(tex.load('data\textures\rings\spacering1_tex2.jpg'));
        Material.AddTexture(tex.load('data\textures\rings\spacering1_line_add.jpg'));
      end;

  Sh := ShMan.GetShaderByName('objbump');
  ObjMeshes[2].Load('data\SpaceRing2.otm',true);
  if Sh <> nil then
   with(ObjMeshes[2].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\rings\SpaceRing2_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\rings\SpaceRing2_add_tex.jpg'));
      end;

   Sh := ShMan.GetShaderByName('linediffuse');
   with(ObjMeshes[2].Mesh[1] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\rings\spacering2_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\rings\spacering2_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('objdiffuse');
  ObjMeshes[3].Load('data\objects\meteors.otm',true);
  if Sh <> nil then
   for i := 0 to 4 do     
   with(ObjMeshes[3].Mesh[i] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\objects\meteor_tex.JPG'));
      end;

  Sh := ShMan.GetShaderByName('linebump');
  ObjMeshes[4].Load('data\objects\satellite.otm',true);
  if Sh <> nil then
   with(ObjMeshes[4].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\objects\satelite2_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\satellite2.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\satelite2_line.jpg'));
      end;
  if Sh <> nil then
   with(ObjMeshes[4].Mesh[1] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\objects\satelite1_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\satellite1.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\satelite1_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('linebump');
  ObjMeshes[5].Load('data\objects\EpicThing.otm',false);
  if Sh <> nil then
  for i := 0 to 5 do
   with(ObjMeshes[5].Mesh[i] as TOTMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\objects\epic_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\epic_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\objects\epic_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('linediffuse');
  ObjMeshes[6].Load('data\objects\SpaceRing3.otm',true);
  if Sh <> nil then
   with(ObjMeshes[6].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\rings\spacering3_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\rings\spacering3_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('linebump');
  GarbageMeshes[0].Load('data\garbage\garbage1.otm',true);
  if Sh <> nil then
   with(GarbageMeshes[0].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\garbage\dirt1_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt1_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt1_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('linebump');
  GarbageMeshes[1].Load('data\garbage\garbage2.otm',true);
  if Sh <> nil then
   with(GarbageMeshes[1].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\garbage\dirt2_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt2_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt2_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('linebump');
  GarbageMeshes[2].Load('data\garbage\garbage3.otm',true);
  if Sh <> nil then
   with(GarbageMeshes[2].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\garbage\dirt3_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt3_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt3_line.jpg'));
      end;

  Sh := ShMan.GetShaderByName('linebump');
  GarbageMeshes[3].Load('data\garbage\garbage4.otm',true);
  if Sh <> nil then
   with(GarbageMeshes[3].Mesh[0] as TBumpMesh) do
      begin
        Material.SetShader(Sh^.Shader);
        Material.AddTexture(tex.load('data\textures\garbage\dirt3_normal.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt3_tex.jpg'));
        Material.AddTexture(tex.load('data\textures\garbage\dirt3_line.jpg'));
      end;



  sFont := ogl.Font.Create('Arial',20);
end;

procedure FreeMeshes;
var i:integer;
begin
  for i := 0 to 5 do
    begin
      CarMeshes[i].Reset;
      CarMeshes[i].Destroy;
    end;

  for i := 0 to 3 do
    begin
      GarbageMeshes[i].Reset;
      GarbageMeshes[i].Destroy;    
    end;

  CursorMesh.Reset;
  CursorMesh.Destroy;

  for i := 0 to 2 do
    begin
      WeaponModels[i].Reset;
      WeaponModels[i].Destroy;
      CartridgeModels[i].Reset;
      CartridgeModels[i].Destroy;
    end;

  for i := 0 to 22 do
    begin
      ObjMeshes[i].Reset;
      ObjMeshes[i].Destroy;
    end;
end;

procedure Init;
var sh:PSh;
begin

  ShMan := TShaderMan.Create;
  Camera := TCamera.Create;
  Console := TConsole.Create;
  Map:=TMap.Create;
  ParticleSystem := TParticleSystem.Create;
  ParticleSystem.AddTexture(tex.load('data\textures\particles\particle.bmp'));
  ParticleSystem.AddTexture(tex.load('data\textures\particles\particle1.bmp'));
  ParticleSystem.AddTexture(tex.load('data\textures\particles\particle2.tga'));
  Sh := ShMan.GetShaderByName('Particles');
  if Sh <> nil then
    ParticleSystem.SetShader(Sh.Shader);

  LoadMeshes;
  InitConsole;

  GameManager:=TGameManager.Create;

  Sky := TSky.Create;

  Menu := TMenu.Create;
end;

procedure Finalize;
begin
  ShMan.Destroy;
  Sky.Free;
  ParticleSystem.Destroy;
end;

end.
