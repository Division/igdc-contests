unit vfp;

interface

uses
  Windows, OpenGL,
  sys_main, com;

type
  TVFP = class(TInterface, IShader)
    function Create: TShader; 
    procedure Free(Shader: TShader); 
    function Add(Shader: TShader; ShaderType: Integer; FileName: PChar): Boolean; overload;
    function Add(Shader: TShader; ShaderType: Integer; Name: PChar; Mem: Pointer; Size: Integer): Boolean; overload;
    function Link(Shader: TShader): Boolean;
    function GetAttrib(Shader: TShader; Name: PChar): TShAttrib; 
    function GetUniform(Shader: TShader; Name: PChar): TShUniform; 
    procedure Attrib(a: TShAttrib; x: Single); overload; 
    procedure Attrib(a: TShAttrib; x, y: Single); overload; 
    procedure Attrib(a: TShAttrib; x, y, z: Single); overload; 
    procedure Uniform(u: TShUniform; x: Single); overload; 
    procedure Uniform(u: TShUniform; x, y: Single); overload; 
    procedure Uniform(u: TShUniform; x, y, z: Single); overload; 
    procedure Uniform(u: TShUniform; i: Integer); overload;
    procedure Enable(Shader: TShader); 
    procedure Disable; 
   public
    procedure log(Text: string);
    function Error(Handle: TShader; Param: DWORD): Boolean;
    function Compile(Stream: TStream; Shader: TShader; ShaderType: Integer; Name: PChar): Boolean;
  end;

implementation

uses
  eng, ogl;

function TVFP.Create: TShader;
begin
  Result := 0;
  if not GL_ARB_shading_language then Exit;
  Result := glCreateProgramObjectARB;
  if Result = 0 then
    log('Error creating shader object')
  else
    log('Create shader object (' + IntToStr(Result) + ')');
end;

procedure TVFP.Free(Shader: TShader);
begin
  if not GL_ARB_shading_language then Exit;
  glDeleteObjectARB(Shader);
  log('Delete shader object (' + IntToStr(Shader) + ')');
end;

function TVFP.Add(Shader: TShader; ShaderType: Integer; FileName: PChar): Boolean;
var
  Stream : TFileStream;
begin
  Stream := TFileStream.Create(FileName);
  Result := Compile(Stream, Shader, ShaderType, FileName);
  Stream.Free;
end;

function TVFP.Add(Shader: TShader; ShaderType: Integer; Name: PChar; Mem: Pointer; Size: Integer): Boolean;
var
  Stream : TMemoryStream;
begin
  Stream := TMemoryStream.Create(Mem, Size);
  Result := Compile(Stream, Shader, ShaderType, Name);
  Stream.Free;
end;

function TVFP.Link(Shader: TShader): Boolean;
begin
  Result := False;
  if not GL_ARB_shading_language then Exit;
  glLinkProgramARB(Shader);
  Result := not Error(Shader, GL_OBJECT_LINK_STATUS_ARB);
  if Result then
    log('Linking (' + IntToStr(Shader) + ') shader object: successfully')
  else
    log('Error while linking (' + IntToStr(Shader) + ') shader object')
end;

function TVFP.GetAttrib(Shader: TShader; Name: PChar): TShAttrib;
begin
  Result := 0;
  if not GL_ARB_shading_language then Exit;
  Result := glGetAttribLocationARB(Shader, Name);
end;

function TVFP.GetUniform(Shader: TShader; Name: PChar): TShUniform;
begin
  Result := 0;
  if not GL_ARB_shading_language then Exit;
  Result := glGetUniformLocationARB(Shader, Name);
end;

procedure TVFP.Attrib(a: TShAttrib; x: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glVertexAttrib1fARB(a, x);
end;

procedure TVFP.Attrib(a: TShAttrib; x, y: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glVertexAttrib2fARB(a, x, y);
end;

procedure TVFP.Attrib(a: TShAttrib; x, y, z: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glVertexAttrib3fARB(a, x, y, z);
end;

procedure TVFP.Uniform(u: TShUniform; x: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glUniform1fARB(u, x);
end;

procedure TVFP.Uniform(u: TShUniform; x, y: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glUniform2fARB(u, x, y);
end;

procedure TVFP.Uniform(u: TShUniform; x, y, z: Single);
begin
  if not GL_ARB_shading_language then Exit;
  glUniform3fARB(u, x, y, z);
end;

procedure TVFP.Uniform(u: TShUniform; i: Integer);
begin
  if not GL_ARB_shading_language then Exit;
  glUniform1iARB(u, i);
end;

procedure TVFP.Enable(Shader: TShader);
begin
  if not GL_ARB_shading_language then Exit;
  glUseProgramObjectARB(Shader);
end;

procedure TVFP.Disable;
begin
  if not GL_ARB_shading_language then Exit;
  glUseProgramObjectARB(0);
end;

procedure TVFP.log(Text: string);
begin
  olog.Print(PChar('Shader  : ' + Text));
end;

function TVFP.Error(Handle: TShader; Param: DWORD): Boolean;
var
  Status : Integer;
begin
  glGetObjectParameterivARB(Handle, Param, @Status);
  Result := Status <> 1;
end;

function TVFP.Compile(Stream: TStream; Shader: TShader; ShaderType: Integer; Name: PChar): Boolean;
var
  sh   : TShader;
  Text : PChar;
begin
  Result := False;
  if not (ShaderType in [ST_VERTEX, ST_FRAGMENT]) then
  begin
    log('Incorrect ShaderType value');
    Exit;
  end;

  if GL_ARB_shading_language and Stream.Valid and (Stream.Size > 0) then
  begin
    GetMem(Text, Stream.Size + 1);
    Stream.Read(Text^, Stream.Size);
    PByteArray(Text)[Stream.Size] := 0;
    if ShaderType = ST_VERTEX then
      sh := glCreateShaderObjectARB(GL_VERTEX_SHADER_ARB)
    else
      sh := glCreateShaderObjectARB(GL_FRAGMENT_SHADER_ARB);
    glShaderSourceARB(sh, 1, @Text, nil);
    glCompileShaderARB(sh);
    Result := Error(sh, GL_OBJECT_COMPILE_STATUS_ARB);
    glAttachObjectARB(Shader, sh);
    glDeleteObjectARB(sh);
  end;

  if Result then
    case ShaderType of
      ST_VERTEX   : log('Compile vertex shader "' + Name + '"');
      ST_FRAGMENT : log('Compile fragment shader "' + Name + '"')
    end
  else
    case ShaderType of
      ST_VERTEX   : log('Can''t compile vertex shader "' + Name + '"');
      ST_FRAGMENT : log('Can''t compile fragment shader "' + Name + '"');
    end;
end;

end.
