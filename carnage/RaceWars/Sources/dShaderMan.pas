(*

    Типа менеджер шойдеров.
    Реализовано криво, но зато мне удобно (:

*)

unit dShaderMan;

interface

uses eXgine, dglOpenGL, l_math;

type

  PSh = ^TSh;

  TShUni = record
    Uniform : TShUniform;
    name : string;
    UniType : TShUniType;
    data : Pointer;
  end;

  TShAttr = record
    Attrib:TShAttrib;
    name:string;
  end;

  TSh = record
    name : string;
    Shader:TShader;
    Uniforms:array of TShUni;
    UniNames:array of string;
    Attributes:array of TShAttr;
    TBN : boolean;
    function GetUniformByName(name:string):TShUniform;
    function GetAttributeByName(name:string):TShUniform;    
  end;

  TShaderMan = class
    constructor Create;
    private
      Shaders:array of TSh;

    public
      I0,I1,I2,I3:integer;
      ModelMatrix : TMatrix;

      function AddShader(filename:String; name:string):integer;
      function GetIndexByName(name:String):integer;
      function GetShaderByName(name:String):PSh;
      function GetShaderByShader(Sh:TShader):PSh;
      procedure AddAttribute(atrname:String; shname:String);      
      procedure AddUniform(uniname:String; shname:string; UniType:TShUniType; data:Pointer);
      function GetUniform(uniname:string; shname:string):TShUniform;
      function GetAttribute(atrname:string; shname:string):TShAttrib;
      procedure InitShaders; // Загружает и настраивает все шойдеры. Пока так к сожалению ):
  end;

var ShMan:TShaderMan;

implementation

uses variables;

function TSh.GetUniformByName(name: string):TShUniform;
var i:integer;
begin
  for i := 0 to Length(Uniforms) - 1 do
    if Uniforms[i].name=name then
      begin
        Result := Uniforms[i].Uniform;
        Exit;
      end;
  Result := -1;
end;

function TSh.GetAttributeByName(name: string):TShAttrib;
var i:integer;
begin
  for i := 0 to Length(Attributes) - 1 do
    if Attributes[i].name=name then
      begin
        Result := Attributes[i].Attrib;
        Exit;
      end;
  Result := -1;
end;

function TShaderMan.AddShader(filename: string; name: string):integer;
begin
  if vfp.Add(PChar(filename),PChar(name)) then
    begin
      SetLength(Shaders,Length(Shaders)+1);
      Shaders[High(Shaders)].Shader := vfp.Compile;
      Shaders[High(Shaders)].name := name;
      Shaders[High(Shaders)].TBN := false;
      Result := High(Shaders);
    end
  else
    begin
      Result := -1;
    end;
      
  vfp.Clear;
end;


function TShaderMan.GetShaderByShader(Sh: Cardinal):PSh;
var i:integer;
begin
  for i := 0 to Length(Shaders) - 1 do
    if Shaders[i].Shader = Sh then
      begin
        Result := @Shaders[i];
        Exit;
      end;
  Result := nil;
end;

function TShaderMan.GetShaderByName(name:String):PSh;
var i:integer;
begin
  for i := 0 to Length(Shaders) - 1 do
    if Shaders[i].name = name then
      begin
        Result := @Shaders[i];
        Exit;
      end;
  Result := nil;
end;

function TShaderMan.GetIndexByName(name:String):integer;
var i:integer;
begin
  for i := 0 to Length(Shaders) - 1 do
    if Shaders[i].name = name then
      begin
        Result := i;
        Exit;
      end;
  Result := -1;
end;

procedure TShaderMan.AddUniform(uniname:string; ShName:String; UniType:TShUniType; data:Pointer );
var Index:integer;
begin
  Index := GetIndexByName(shname);
  if (Index>=0) then
    with Shaders[Index] do
      begin
        SetLength(Uniforms,Length(Uniforms)+1);
        Uniforms[High(Uniforms)].Uniform := vfp.GetUniform(Shader,PChar(uniname));
        Uniforms[High(Uniforms)].name := uniname;
        Uniforms[High(Uniforms)].UniType := unitype;
        Uniforms[High(Uniforms)].data := data;                
      end;
end;

procedure TShaderMan.AddAttribute(atrname:string; ShName:String);
var Index:integer;
begin
  Index := GetIndexByName(shname);
  if (Index>=0) then
    with Shaders[Index] do
      begin
        SetLength(Attributes,Length(Attributes)+1);
        Attributes[High(Attributes)].Attrib := vfp.GetAttrib(Shader,PChar(atrname));
        Attributes[High(Attributes)].name := atrname;
      end;
end;


function TShaderMan.GetUniform(uniname: string; shname: string):TShUniform;
var sh:PSh;
begin
  sh := GetShaderByName(shname);
  if sh<>nil then
    begin
      Result := sh.GetUniformByName(uniname);
    end
  else
    begin
      Result := -1;
    end;
end;

function TShaderMan.GetAttribute(atrname: string; shname: string):TShAttrib;
var sh:PSh;
begin
  sh := GetShaderByName(shname);
  if sh<>nil then
    begin
      Result := sh.GetAttributeByName(atrname);
    end
  else
    begin
      Result := -1;
    end;
end;

constructor TShaderMan.Create;
begin
  I0 := 0;
  I1 := 1;
  I2 := 2;
  I3 := 3;
  Shaders := nil;
  InitShaders;
end;

procedure TShaderMan.InitShaders;
begin
  if AddShader('data\shaders\road.txt','road') = -1 then halt;
  AddUniform('texture','road',SU_I1,@I0);
  AddUniform('lines','road',SU_I1,@I1);
  AddUniform('normalMap','road',SU_I1,@I2);
  AddUniform('SunlightPower','road',SU_F1,@SUNLIGHT_POWER);

  if AddShader('data\shaders\line.txt','linebump') = -1 then halt;
  AddUniform('NormalMap','linebump',SU_I1,@I0);
  AddUniform('Texture','linebump',SU_I1,@I1);
  AddUniform('Lines','linebump',SU_I1,@I2);
  AddUniform('SunlightPower','linebump',SU_F1,@SUNLIGHT_POWER);  
  AddAttribute('Binormal','linebump');
  AddAttribute('Tangent','linebump');

  if AddShader('data\shaders\objbump.txt','objbump') = -1 then halt;
  AddUniform('NormalMap','objbump',SU_I1,@I0);
  AddUniform('Texture','objbump',SU_I1,@I1);
  AddAttribute('Binormal','objbump');
  AddAttribute('Tangent','objbump');
  AddUniform('SunlightPower','objbump',SU_F1,@SUNLIGHT_POWER);

  if AddShader('data\shaders\objdiffuse.txt','objdiffuse') = -1 then halt;
  AddUniform('Texture','objdiffuse',SU_I1,@I0);
  AddUniform('SunlightPower','objdiffuse',SU_F1,@SUNLIGHT_POWER);  

  if AddShader('data\shaders\linediffuse.txt','linediffuse') = -1 then halt;
  AddUniform('Texture','linediffuse',SU_I1,@I0);
  AddUniform('Lines','linediffuse',SU_I1,@I1);  
  AddUniform('SunlightPower','linediffuse',SU_F1,@SUNLIGHT_POWER);

  if AddShader('data\shaders\Particles.txt','Particles') = -1 then halt;
  AddUniform('Texture','Particles',SU_I1,@I0);
end;

end.
