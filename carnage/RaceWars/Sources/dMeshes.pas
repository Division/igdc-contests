(*

    Здесь разного рода меши(потомки TMesh). Например, меш с бампом
    считает и передаёт в шейдер TBN

*)
unit dMeshes;

interface

uses dAnimation, dMath, dShaderMan, dConsole, eXgine, dglOpenGL, windows, sysutils, Variables;

type
  TBumpMesh = class(TMesh)
    protected
      procedure ShaderInitRender; override;
      procedure ShaderFinRender; override;
      procedure CalculateNormals; override;
    public
      Material : TMaterial;
      Header : TItemHeader;
      procedure Render(Material: PMaterial = nil); override;
  end;

  TReflectMesh = class(TMesh)
    protected
      procedure TexInitRender; override;
      procedure TexFinRender; override;
    public
      procedure Render(Material:PMaterial = nil); override;
  end;

function CreateMeshByHeader(header:TItemHeader):TMesh;

implementation

function CreateMeshByHeader(header:TItemHeader):TMesh;
var Sh:PSh;
begin
  Sh := ShMan.GetShaderByName(header.shader);
  if (Sh<>nil) and (Sh^.TBN) then
    begin
      Result := TBumpMesh.Create;
    end
  else if lowercase(header.iclass)='treflect' then
    begin
      Result := TReflectMesh.Create;
    end
  else
    begin
      Result := TMesh.Create;
    end;  
end;

{$REGION 'BumpMesh'}

procedure TBumpMesh.ShaderInitRender;
var sh:PSh;
    attr:TShAttrib;
begin
  inherited;
  sh := ShMan.GetShaderByShader(CurMaterial.Shader.Shader);
  attr := sh.GetAttributeByName('Binormal'); // Да, криво. Когда буду писать двиг, такого не будет (:
  glEnableVertexAttribArray(attr);
  glVertexAttribPointer(attr,3,GL_FLOAT,true,0,Binormal);
  attr :=sh.GetAttributeByName('Tangent');
  glEnableVertexAttribArray(attr);
  glVertexAttribPointer(attr,3,GL_FLOAT,true,0,Tangent);
end;

procedure TBumpMesh.ShaderFinRender;
var sh:PSh;
    attr:TShAttrib;
begin
  inherited;
  sh := ShMan.GetShaderByShader(Material.Shader.Shader);
  attr :=sh.GetAttributeByName('Binormal');
  glDisableVertexAttribArray(attr);
  attr :=sh.GetAttributeByName('Tangent');
  glDisableVertexAttribArray(attr);
  glColor4f(1,1,1,1);
end;

procedure TBumpMesh.CalculateNormals;
var i:integer;
    T,B,N:TVector3;
begin
  SetLength(Normal,V_Count);
  SetLength(Binormal,V_Count);
  SetLength(Tangent,V_Count);

  ZeroMemory(@Normal[0],V_Count*sizeof(TVector3));
  ZeroMemory(@Tangent[0],V_Count*sizeof(TVector3));
  ZeroMemory(@Binormal[0],V_Count*sizeof(TVector3));

  for i := 0 to F_Count - 1 do
    begin
      CalculateTBN(Vertex[Face[i][0]],Vertex[Face[i][1]],Vertex[Face[i][2]],TexCoord[Face[i][0]],TexCoord[Face[i][1]],TexCoord[Face[i][2]],T,B,N);
      Normal[Face[i][0]]:=Normal[Face[i][0]]+N;
      Normal[Face[i][1]]:=Normal[Face[i][1]]+N;
      Normal[Face[i][2]]:=Normal[Face[i][2]]+N;
      Binormal[Face[i][0]]:=Binormal[Face[i][0]]+B;
      Binormal[Face[i][1]]:=Binormal[Face[i][1]]+B;
      Binormal[Face[i][2]]:=Binormal[Face[i][2]]+B;
      Tangent[Face[i][0]]:=Tangent[Face[i][0]]+T;
      Tangent[Face[i][1]]:=Tangent[Face[i][1]]+T;
      Tangent[Face[i][2]]:=Tangent[Face[i][2]]+T;      
    end;

//  NeedTBN := true;

  for i := 0 to F_Count - 1 do
    begin
      Normal[Face[i][0]]:=normalize(Normal[Face[i][0]]);
      Normal[Face[i][1]]:=normalize(Normal[Face[i][1]]);
      Normal[Face[i][2]]:=normalize(Normal[Face[i][2]]);
      Binormal[Face[i][0]]:=normalize(Binormal[Face[i][0]]);
      Binormal[Face[i][1]]:=normalize(Binormal[Face[i][1]]);
      Binormal[Face[i][2]]:=normalize(Binormal[Face[i][2]]);
      Tangent[Face[i][0]]:=normalize(Tangent[Face[i][0]]);
      Tangent[Face[i][1]]:=normalize(Tangent[Face[i][1]]);
      Tangent[Face[i][2]]:=normalize(Tangent[Face[i][2]]);
    end;

end;

procedure TBumpMesh.Render(Material: PMaterial = nil);
begin
  inherited Render(@self.Material);
//  inherited Render();
end;

{$ENDREGION}

{$REGION 'ReflectMesh'}
procedure TReflectMesh.TexInitRender;
var i:integer;
begin
//  inherited; exit;
  if length(CurMaterial^.Textures) > 0 then
    begin
      for i := 0 to length(CurMaterial^.Textures) - 1 do
        begin
          glActiveTextureARB(GL_TEXTURE0_ARB + i);
          glClientActiveTextureARB(GL_TEXTURE0_ARB + i);
          glBindTexture(CurMaterial^.Textures[i].Kind,CurMaterial^.Textures[i].Texture);
          glEnable(CurMaterial^.Textures[i].Kind);
          glEnableClientState(GL_TEXTURE_COORD_ARRAY);
          glTexCoordPointer(3,GL_FLOAT,0,Vertex); // Вершины как текстурные координаты
        end;
    end
  else
    begin
      glDisable(GL_TEXTURE_2D); // Потом наверно будем кубамапы вырубать? Хотя зачем?
    end;
end;

procedure TReflectMesh.TexFinRender;
var i:integer;
begin
//  inherited; exit;
  if length(CurMaterial^.Textures) > 0 then
    begin
      for i := 0 to length(CurMaterial^.Textures) - 1 do
        begin
          glClientActiveTextureARB(GL_TEXTURE0_ARB+i);
          glActiveTextureARB(GL_TEXTURE0_ARB + i);
          glBindTexture(CurMaterial^.Textures[i].Kind,0);
          tex.Disable(i);
          glDisable(CurMaterial^.Textures[i].Kind);
          glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        end;
    end;
   glDisable(GL_TEXTURE_2D);
end;

procedure TReflectMesh.Render(Material:PMaterial = nil);
begin
  if V_Count = 0 then Exit;

  CurMaterial := Material;
  // Наконец-то поддерживаем любое количество текстур без гемора (:
  if Material<>nil then
    begin
      TexInitRender;
      ShaderInitRender;
    end;

  GeomInitRender;

  glDrawElements(GL_TRIANGLES,F_Count*3,GL_UNSIGNED_INT,Face);

  GeomFinRender;

  if Material<>nil then
    begin
      TexFinRender;
      ShaderFinRender;
    end;
end;
{$ENDREGIOn}

end.
