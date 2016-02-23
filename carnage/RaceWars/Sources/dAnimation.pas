(*

    Мега модуль с Object Transform модельками.
    Мультитекстурирование, возможность задать
    каждому мешу свой шейдер

*)

unit dAnimation;

interface

uses eXgine,dglOpenGL, dMath, l_math, SysUtils, Windows, dShaderMan, dConsole;

const AA_FRAME = 0;
      AA_LOOP  = 1;
      AA_PLAY  = 2;

type

  TItemHeader = record
    itype :integer;
    data  : integer;
    name  : string;
    source_name : string;
    texture1  : string;
    texture2  : string;
    texture3  : string;
    shader  : string;
    iclass  : string;
    script  : string;

    tbn:boolean; // В файле этого нет
  end;

  PTOTModel   = ^TOTModel;
  PMesh       = ^TMesh;
  PAnimation  = ^TAnimation;
  PRenderable = ^TRenderable;

  TFace = array[0..2] of integer;

  TFrame = record
    Position : TVector3;
    Rotation : TQuat;
  end;

  TAnim = record
    Start,Finish : integer;
  end;

  TMeshTexture = record
    Texture : TTexture;
    Kind : integer;
    TexUnit:integer; // Текстурный блок этой текстуры
    SamplerName:string; // Имя соответствующего этой текстуре samplera из шейдера 
  end;

  TMeshShaderAttribute = record
    index:Cardinal;
    Size:integer;
    Normalized:boolean;
    data:Pointer;
  end;

  TMeshShaderUniform = record
    Uniform : TShUniform;
    UniType : TShUniType;
    data : Pointer;
  end;

  TMeshShader = record
    Enabled : boolean;
    Shader : TShader;
    Uniforms : array of TMeshShaderUniform;
    Attributes : array of TMeshShaderAttribute; 
  end;

  PMaterial = ^TMaterial;
  TMaterial = record

    Textures : array of TMeshTexture; // Во как! Теперь добавлять текстуры удобно! МУХАХА
    Shader   : TMeshShader; // Шейдер...

    procedure AddUniform(Uniform:TShUniform; UniType:TShUniType; data:Pointer);
    procedure AddAttribute(index:Cardinal; size:integer; Normalized:boolean; data:Pointer);
    procedure AddTexture(texture:TTexture; samplerName:string=''; kind:integer = GL_TEXTURE_2D);
    procedure SetShader(Sh:TShader);
    procedure Reset;
  end;

  TRenderable = class
    public
      name : string;
      Center : TVector3;
      procedure Render(Material:PMaterial); virtual; abstract;
  end;

  TMesh=class (TRenderable)
    protected
      CurMaterial : PMaterial;

      procedure CalculateNormals; virtual; // Расчет нормалей + дублирование вершин для разногруппных полигонов
      // Эти методы будет удобно переопределять в потомках
      procedure GeomInitRender; virtual;
      procedure GeomFinRender; virtual;
      procedure TexInitRender; virtual;
      procedure TexFinRender; virtual;
      procedure ShaderInitRender; virtual;
      procedure ShaderFinRender; virtual;
      procedure LoadFinish; virtual; // Чтобы можно было легко модифицировать в потомках

    public
      V_Count  : integer; // Количество вершин
      T_Count  : integer; // Текстур
      F_Count  : integer; // Граней
      UV_Count : integer; // Количество слоёв текстурных координат
      Frame    : array of TFrame; // Кадры анимации
      Vertex   : array of TVector3; // Вершины
      Normal   : array of TVector3; // Нормали
      Face     : array of TFace; // Грани
      TexCoord : array of TVector2; // Текстурные координаты
      TexCoord2 : array of TVector2; // Текстурные координаты
      SmGroups : array of integer; // Группы сглаживания
      MultiTex : boolean;


      NeedTBN  : boolean;
      Binormal : array of TVector3; // Бинормали
      Tangent  : array of TVector3; // Тангенты 

      procedure CalcTBN;
      procedure Render(Material:PMaterial = nil); override; // Угадай что
      procedure Reset; virtual; // Освобождаем память
      procedure Load(var F:file; K_Count : integer); virtual;
      function GetCenter:TVector3;
  end;

  TAnimation = record
    AnimStart : integer;
    AnimFinish: integer;
    CurFrame  : integer;
    NextFrame : integer;
    Action    : integer;
    CurAnim   : integer;
    Rewers    : boolean;
    FPS       : integer;
    procedure LoopAnimation(index:integer);
    procedure PlayAnimation(index:integer; reset:boolean = false);
    procedure PlayFrame(frame:integer);
    procedure Update(Mdl:PTOTModel);
  end;


  TOTModel = class (TRenderable)
    protected
      function CreateMesh:TMesh; virtual;
      procedure LoadFinish; virtual;
    public
      FPS : integer;
      Texture : TTexture;
      K_Count : integer; // Кол-во кадров
      M_Count : integer; // Количество объектов
      A_Count : integer; // Количество анимаций
      Anims : array of TAnim;
      Mesh : array of TMesh;
      Animation : TAnimation;

      procedure Update;
      procedure Load(FileName : string; bump:boolean = false); virtual;
      procedure LoadFromMap(var f:file; item_count:integer );
      procedure Render(Material:PMaterial=nil); override;
      procedure Reset;
  end;

  TOTMesh = class (TMesh)
    Header : TItemHeader;
    Material : TMaterial;
    procedure Render(Material:PMaterial = nil); override;
  end;

  TSTFMesh = class (TMesh) // Мешь, который умеет сохраняться в файл
    public
      
      SV_Count  : integer; // Количество вершин
      ST_Count  : integer; // Текстур
      SF_Count  : integer; // Граней

      SVertex   : array of TVector3; // Вершины
      SFace     : array of TFace;
      STexCoord : array of TVector2; // Текстурные координаты
      STexFace  : array of TFace; // Текстурные грани
      SSmGroups  : array of integer; // Группы сглаживания

      procedure Load(var F:File; K_Count:integer); override;
      procedure Save(var F:File; K_Count:integer);
  end;

  TSTFOTModel = class(TOTModel)
    procedure Load(FileName : string; bump:boolean = false); override;
    procedure Save(FileName : string);
  end;

implementation

uses Variables,dMeshes;

{$REGION 'Header'}
function ReadItemHeader(var f:file) : TItemHeader;
var len:integer;
begin
  with Result do
    begin
      BlockRead(f,itype,sizeof(itype));
      BlockRead(f,data,sizeof(data));
      BlockRead(f,len,sizeof(len));
      SetLength(name,len);
      if len>0 then
        BlockRead(f,name[1],len);
      // source_name
      BlockRead(f,len,sizeof(len));
      SetLength(source_name,len);
      if len>0 then
        BlockRead(f,source_name[1],len);
      // texture1
      BlockRead(f,len,sizeof(len));
      SetLength(texture1,len);
      if len>0 then
        BlockRead(f,texture1[1],len);
      // texture2
      BlockRead(f,len,sizeof(len));
      SetLength(texture2,len);
      if len>0 then
        BlockRead(f,texture2[1],len);
      // texture3
      BlockRead(f,len,sizeof(len));
      SetLength(texture3,len);
      if len>0 then
        BlockRead(f,texture3[1],len);
      // shader
      BlockRead(f,len,sizeof(len));
      SetLength(shader,len);
      if len>0 then
        BlockRead(f,shader[1],len);
      // class
      BlockRead(f,len,sizeof(len));
      SetLength(iclass,len);
      if len>0 then
        BlockRead(f,iclass[1],len);
      // script
      BlockRead(f,len,sizeof(len));
      SetLength(script,len);
      if len>0 then
        BlockRead(f,script[1],len);
    end;
end;
{$ENDREGION}

{$REGION 'TMaterial'}

procedure TMaterial.AddUniform(Uniform: Integer; UniType: Integer; data: Pointer);
begin
  with Shader do
    begin
      SetLength(Uniforms,Length(Uniforms)+1);
      Uniforms[High(Uniforms)].Uniform := Uniform;
      Uniforms[High(Uniforms)].UniType := UniType;
      Uniforms[High(Uniforms)].data := data;
    end;
end;

procedure TMaterial.AddAttribute(index:Cardinal; size:integer; Normalized:boolean; data:Pointer);
begin
  with Shader do
    begin
      SetLength(Attributes,Length(Attributes)+1);
      Attributes[High(Attributes)].index := index;
      Attributes[High(Attributes)].Size := size;
      Attributes[High(Attributes)].Normalized := Normalized;
      Attributes[High(Attributes)].data := data;
    end;
end;

procedure TMaterial.AddTexture(texture: Cardinal; samplerName:string=''; kind: Integer = GL_TEXTURE_2D);
begin
  SetLength(Textures,Length(Textures)+1);
  Textures[High(Textures)].Texture := texture;
  Textures[High(Textures)].Kind := kind;
  Textures[High(Textures)].SamplerName:= samplerName;
  Textures[High(Textures)].TexUnit := High(Textures);
end;

procedure TMaterial.SetShader(Sh: Cardinal);
var i:integer;
    shName:string;
    shd : PSh;
begin
  Shader.Enabled := true;
  Shader.Shader := Sh;
  shd := ShMan.GetShaderByShader(sh);
  if shd = nil then
    Exit;

  shName := shd.name;

  if length(shd.Uniforms) > 0 then
    for i := 0 to length(shd.Uniforms) - 1 do
      begin
        AddUniform(shd.Uniforms[i].Uniform,shd.Uniforms[i].UniType,shd.Uniforms[i].data);
      end;  
end;

procedure TMaterial.Reset;
begin
  Textures := nil;
  Shader.Uniforms := nil;
  Shader.Attributes := nil;
  Shader.Enabled := false;
end;

{$ENDREGION}

{$REGION 'TMesh'}

procedure TMesh.Reset;
begin
  NeedTBN := false;
  SmGroups := nil;
  Vertex   := nil;
  Normal   := nil;
  Face     := nil;
  TexCoord := nil;
//  TexFace  := nil;
  V_Count  := 0;
  T_Count  := 0;
  F_Count  := 0;
  MultiTex := false;
end;

function TMesh.GetCenter:TVector3;
var i:integer;
    count:integer;
    v:TVector3;
begin
  v := ZeroVec;
  count := 0;
  for i := 0 to F_Count - 1 do
    begin
      v := v + Vertex[Face[i][0]] + Vertex[Face[i][1]] + Vertex[Face[i][2]];
      inc(count,3);
    end;
  Result := v/count;
end;

procedure TMesh.LoadFinish;
begin

end;

procedure TMesh.TexInitRender;
var i:integer;
begin
  if length(CurMaterial^.Textures) > 0 then
    begin
      for i := 0 to length(CurMaterial^.Textures) - 1 do
        begin
          glActiveTextureARB(GL_TEXTURE0_ARB + i);
          glClientActiveTextureARB(GL_TEXTURE0_ARB + i);
          glBindTexture(CurMaterial^.Textures[i].Kind,CurMaterial^.Textures[i].Texture);

          glEnable(CurMaterial^.Textures[i].Kind);
          glEnableClientState(GL_TEXTURE_COORD_ARRAY);
          if (i=1) and (UV_Count>1) then
            glTexCoordPointer(2,GL_FLOAT,0,TexCoord2)
          else
            glTexCoordPointer(2,GL_FLOAT,0,TexCoord);
        end;
    end
  else
    begin
      glDisable(GL_TEXTURE_2D); // Потом наверно будем кубамапы вырубать? Хотя зачем?
    end;
end;

procedure TMesh.TexFinRender;
var i:integer;
begin
  if length(CurMaterial^.Textures) > 0 then
    begin
      for i := 0 to length(CurMaterial^.Textures) - 1 do
        begin
          glClientActiveTextureARB(GL_TEXTURE0_ARB+i);        
          glActiveTextureARB(GL_TEXTURE0_ARB + i);
          glBindTexture(CurMaterial^.Textures[i].Kind,0);
          tex.Disable(i);
          glDisable(GL_TEXTURE_2D);
          glDisable(CurMaterial^.Textures[i].Kind);
          glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        end;
    end;
end;

procedure TMesh.GeomInitRender;
begin
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);

  glVertexPointer(3,GL_FLOAT,0,Vertex);
  glNormalPointer(GL_FLOAT,0,Normal);
end;

procedure TMesh.GeomFinRender;
begin
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_NORMAL_ARRAY);
end;

procedure TMesh.ShaderInitRender;
var i:integer;
begin
  with CurMaterial^.Shader do
    begin
      if not Enabled then Exit;

      vfp.Enable(Shader);

      if length(Uniforms)>0 then
        for i := 0 to length(Uniforms) - 1 do
          begin
            vfp.Uniform(Uniforms[i].Uniform,Uniforms[i].data,Uniforms[i].UniType);
          end;

      if length(Attributes)>0 then
        begin
          for i := 0 to length(Attributes) - 1 do
            begin
              glEnableVertexAttribArray(Attributes[i].index);
              glVertexAttribPointer(Attributes[i].index,Attributes[i].size,GL_FLOAT,Attributes[i].Normalized,0,Attributes[i].data);
            end;
        end;
    end;
end;

procedure TMesh.ShaderFinRender;
var i:integer;

begin
  with CurMaterial^.Shader do
    begin
      if not Enabled then Exit;
      
      if length(Attributes)>0 then
        begin
          for i := 0 to length(Attributes) - 1 do
            begin
              glDisableVertexAttribArray(Attributes[i].index);
            end;
        end;
      vfp.Disable;
    end;

end;

// Для шустрого рендеринга юзаем glDrawElements
// VBO прикрутить труда не составит, но мне лениво (:
procedure TMesh.Render(Material:PMaterial = nil);
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

  // ЫЫы

//  glDisable(GL_LIGHTING);
//
//  koef := 1;
//  glCOlor3f(1,0,0);
//  glBegin(GL_LINES);
//  for i := 0 to F_Count - 1 do
//  for j := 0 to 2 do
//    begin
//      glVertex3fv(@Vertex[Face[i][j]]);
//      v:=(Vertex[Face[i][j]]+Normal[Face[i][j]])*koef;
//      glVertex3fv(@v);
//    end;
//  glEnd;
//  glCOlor3f(1,1,1);
//  glEnable(GL_LIGHTING);
end;

procedure TMesh.Load(var F:file; K_Count : integer);
begin
  Reset;

  BlockRead(F, V_Count, SizeOf(V_Count));
  BlockRead(F, F_Count, SizeOf(F_Count));
  BlockRead(F, UV_Count, SizeOf(UV_Count));
  SetLength(Vertex,V_Count);
  SetLength(Normal,V_Count);
  SetLength(Face,F_Count);
  SetLength(TexCoord,V_Count);
  SetLength(TexCoord2,V_Count);
  SetLength(Frame,K_Count);

//  BlockRead(F, SmGroups[0], F_Count * SizeOf(integer));
  BlockRead(F, Vertex[0], V_Count * SizeOf(TVector));
  BlockRead(F, Face[0], F_Count * SizeOf(TFace));
  BlockRead(F, TexCoord[0], V_Count * SizeOf(TVector2D));
  if UV_Count > 1 then
    BlockRead(F, TexCoord2[0], V_Count * SizeOf(TVector2D));

  if K_Count>0 then
    begin
      BlockRead(F, Frame[0], K_Count * SizeOf(TFrame))
    end
  else
    begin
      K_Count := 1;
      SetLength(Frame,K_Count);
      Frame[0].Position.x := 0;
      Frame[0].Position.y := 0;
      Frame[0].Position.z := 0;
      Frame[0].Rotation.X := 0;
      Frame[0].Rotation.Y := 0;
      Frame[0].Rotation.Z := 0;
      Frame[0].Rotation.W := 1;
    end;

  CalculateNormals;
//  CalcTBN;

  Center := GetCenter;

  LoadFinish; // Переопределяется в потомках
end;

procedure TMesh.CalculateNormals;
var i:integer;
    N:TVector3;
begin
  SetLength(Normal,V_Count);

  for i := 0 to F_Count - 1 do
    begin
      Normal[Face[i][0]]:=vector3(0,0,0);
      Normal[Face[i][1]]:=vector3(0,0,0);
      Normal[Face[i][2]]:=vector3(0,0,0);
    end;

  for i := 0 to F_Count - 1 do
    begin
      N:=Normalize((Vertex[Face[i,0]]-Vertex[Face[i,1]])*(Vertex[Face[i,0]]-Vertex[Face[i,2]]));
      Normal[Face[i][0]]:=Normal[Face[i][0]]+N;
      Normal[Face[i][1]]:=Normal[Face[i][1]]+N;
      Normal[Face[i][2]]:=Normal[Face[i][2]]+N;
    end;

  for i := 0 to F_Count - 1 do
    begin
      Normal[Face[i][0]]:=normalize(Normal[Face[i][0]]);
      Normal[Face[i][1]]:=normalize(Normal[Face[i][1]]);
      Normal[Face[i][2]]:=normalize(Normal[Face[i][2]]);
    end;
end;

procedure TMesh.CalcTBN;
type
  TVertex = record
    Vert:TVector3;
    N:TVector3;
    B:TVector3;
    T:TVector3;
    tc:TVector2;
  end;

var v:array of TVertex;
    VCount:integer;
    i,j:integer;
    at,ab,an:TVector3;
    ind:integer;
begin
  VCount:=F_Count*3;
  SetLength(v,VCount);
  ind := 0;
  for i := 0 to F_Count - 1 do
    begin
      for j := 0 to 2 do
        with v[i*3+j] do
          begin
            Vert:=Vertex[Face[i][j]];
            tc.x:=TexCoord[Face[i][j]].x;
            tc.y:=TexCoord[Face[i][j]].y;
            N :=Normal[Face[i][j]];
            Face[i][j] := ind;
            inc(ind);
          end;
       CalculateTBN(v[i*3].Vert,v[i*3+1].Vert,v[i*3+2].Vert,v[i*3].tc,v[i*3+1].tc,v[i*3+2].tc,at,ab,an);
       for j := 0 to 2 do
        begin
          v[i*3+j].T:=at;
          v[i*3+j].B:=ab;
          v[i*3+j].N:=an;
        end;            
     end;

  SetLength(Vertex,VCount);
  SetLength(Normal,VCount);
  SetLength(TexCoord,VCount);
  SetLength(Binormal,VCount);
  SetLength(Tangent,VCount);

  V_Count:=VCount;

  for i := 0 to VCount - 1 do
    begin
      Vertex[i]:=v[i].Vert;
      Normal[i]:=normalize(v[i].N);
      TexCoord[i].x:=v[i].tc.x;
      TexCoord[i].y:=v[i].tc.y;
      Binormal[i]:=v[i].B;
      Tangent[i]:=v[i].T      
    end;
  v:=nil;
  NeedTBN := true;
end;

{$ENDREGION}

{$REGION 'TOTMesh'}
procedure TOTMesh.Render(Material: PMaterial = nil);
begin
  inherited Render(@self.Material);
//  inherited Render();
end;
{$ENDREGION}

{$REGION 'TOTModel'}

procedure TOTModel.Reset;
var i:integer;
begin
  if M_Count > 0 then
    for i := 0 to M_Count - 1 do
      begin
        Mesh[i].Reset;
        Mesh[i].Free;
      end;

  if Texture <> 0 then
    tex.Free(Texture);
    
  K_Count := 0;
  M_Count := 0;  
end;

procedure TOTModel.LoadFinish;
begin

end;

procedure TOTModel.Render(Material:PMaterial);
var
  i,j,k  : Integer;
  lf, nf : Integer;
  dt, t  : Single;
  Matrix : TMatrix;
  p      : TVector;
  r      : TQuat;

  Anim : PAnimation;

function v3f(v:TVector3): TVector3f;
begin
  with Result do
    begin
      x:=v.x;
      y:=v.y;
      z:=v.z;
    end;
end;  

begin
  if M_Count = 0 then exit;

  Anim := @Animation;

  dt := 1000 div FPS; // длительность одного кадра
  lf := Anim^.CurFrame;
  nf := Anim^.NextFrame;
  t := frac((eX.GetTime - Anim^.AnimStart)/dt);

  for i := 0 to M_Count - 1 do
    with Mesh[i] do
      begin
      // линейная интерполяция кватерниона и позиции
        r := Q_Lerp(Frame[lf].Rotation, Frame[nf].Rotation, t);
        p := V_Lerp(v3f(Frame[lf].Position), v3f(Frame[nf].Position), t);
      // расчёт матрицы трансформации для объекта
        Q_Matrix(r, Matrix);    // перевод кватерниона в матрицу
        Matrix[3][0] := p.X;    // дописываем позицию в последнюю строку
        Matrix[3][1] := p.Y;
        Matrix[3][2] := p.Z;

        for j := 0 to 3 do
          for k := 0 to 3 do
            MODEL_MATRIX[j][k] := Matrix[j][k];

      // отрисовка
        glPushMatrix;
        glMultMatrixf(@Matrix); // применяем матрицу

        Render(Material);

        glPopMatrix;
      end;
end;

function TOTModel.CreateMesh:TMesh;
begin
  Result := TOTMesh.Create; // В потомках может быть уже и не TOTMesh. Хотя маловероятно
end;

procedure TOTModel.Load(FileName: string; bump:boolean = false);
var f:file;
    i:integer;
begin
  AssignFile(F,FileName);
  System.Reset(F,1);

  BlockRead(F, M_Count, SizeOf(M_Count));
  SetLength(Mesh, M_Count);
  BlockRead(F, K_Count, SizeOf(K_Count));
  BlockRead(F, FPS, SizeOf(FPS));
  BlockRead(F, A_Count, SizeOf(A_Count));

  SetLength(Anims,A_Count);
  for i := 0 to A_Count - 1 do
    begin
      BlockRead(F,Anims[i],Sizeof(TAnim));
    end;

  for i := 0 to M_Count - 1 do
    begin
      if bump then
        begin
          Mesh[i] := TBumpMesh.Create;
          (Mesh[i] as TBumpMesh).Header := ReadItemHeader(f);
        end
      else
        begin
          Mesh[i] := TOTMesh.Create;
          (Mesh[i] as TOTMesh).Header := ReadItemHeader(f);
        end;

      Mesh[i].Load(f, K_Count);
    end;

  LoadFinish;

  CloseFile(f);

  LoadFinish;
end;

procedure TOTModel.LoadFromMap(var f: file; item_count: Integer);
var i:integer;
begin
  BlockRead(F, M_Count, SizeOf(M_Count));
  SetLength(Mesh, M_Count);
  BlockRead(F, K_Count, SizeOf(K_Count));
  BlockRead(F, FPS, SizeOf(FPS));
  BlockRead(F, A_Count, SizeOf(A_Count));

  SetLength(Anims,A_Count);
  for i := 0 to A_Count - 1 do
    begin
      BlockRead(F,Anims[i],Sizeof(TAnim));
    end;

  for i := 0 to M_Count - 1 do
    begin
      Mesh[i] := TOTMesh.Create;
      (Mesh[i] as TOTMesh).Header := ReadItemHeader(f);
      Mesh[i].Load(f, K_Count);
    end;

  LoadFinish;
end;

procedure TOTModel.Update;
begin
  Animation.Update(@self);
end;

{$ENDREGION}

{$REGION 'TAnimation'}
procedure TAnimation.Update(Mdl:PTOTModel);
var dt:integer;
    kk,st:integer;
begin
  AnimFinish := trunc(Mdl^.Anims[CurAnim].Finish / Mdl.FPS * 1000);
  FPS := Mdl^.FPS;
  
  case Action of
    AA_LOOP:
      begin
        dt := 1000 div Mdl^.FPS;

        with Mdl^ do
          begin
            // Количество кадров
            kk := Anims[CurAnim].Finish-Anims[CurAnim].Start+1;
            st := Anims[CurAnim].Start;
          end;

        // Проигрываем задом наперед
        if Rewers then
          begin
            CurFrame := kk - trunc((eX.GetTime-AnimStart)/dt) mod kk; // вычисляем предыдущий кадр
            NextFrame := (CurFrame - 1) mod kk; // и следующий
          end
        else // нормально
          begin
            CurFrame := trunc((eX.GetTime-AnimStart)/dt) mod kk; // вычисляем предыдущий кадр
            NextFrame := (CurFrame + 1) mod kk; // и следующий
          end;

        inc(CurFrame,st);
        inc(NextFrame,st);
        if CurFrame > Mdl.K_Count - 1 then
          CurFrame := Mdl.K_Count - 1;
        if NextFrame > Mdl.K_Count - 1 then
          NextFrame := Mdl.K_Count - 1;
      end;

    AA_PLAY:
      begin
        dt := 1000 div Mdl^.FPS;

        with Mdl^ do
          begin
            // Количество кадров
            kk := Anims[CurAnim].Finish-Anims[CurAnim].Start+1;
            st := Anims[CurAnim].Start;
          end;

        // Проигрываем задом наперед
        if Rewers then
          begin
            CurFrame := kk - trunc((eX.GetTime-AnimStart)/dt); // вычисляем предыдущий кадр
            NextFrame := (CurFrame - 1); // и следующий
            if (CurFrame < st) then CurFrame := st;
            if (NextFrame < st) then NextFrame := st;            
          end
        else // нормально
          begin
            CurFrame := trunc((eX.GetTime-AnimStart)/dt); // вычисляем предыдущий кадр
            NextFrame := (CurFrame + 1); // и следующий
          end;

        inc(CurFrame,st);
        inc(NextFrame,st);
        if CurFrame > Mdl.K_Count - 1 then
          CurFrame := Mdl.K_Count - 1;
        if NextFrame > Mdl.K_Count - 1 then
          NextFrame := Mdl.K_Count - 1;
      end;
      
    AA_FRAME:
      begin
        NextFrame := CurFrame;
      end;  
  end;
end;

procedure TAnimation.PlayAnimation(index: Integer; reset:boolean = false);
begin
  Action := AA_PLAY;
  CurAnim := index;
  if not reset then
    AnimStart := eX.GetTime
  else AnimStart := eX.GetTime - CurFrame*(1000 div FPS);
end;

procedure TAnimation.LoopAnimation(index: Integer);
begin
  Action := AA_LOOP;
  CurAnim := index;
  AnimStart := eX.GetTime;
end;

procedure TAnimation.PlayFrame(frame: Integer);
begin
  Action := AA_FRAME;
  CurFrame := frame;
end;
{$ENDREGION}
      
{$REGION 'Save to File'}
procedure TSTFMesh.Load;
var i:integer;
begin
  Reset;

  BlockRead(F, V_Count, SizeOf(V_Count));
  BlockRead(F, F_Count, SizeOf(F_Count));
  BlockRead(F, T_Count, SizeOf(T_Count));  

  SetLength(SmGroups,F_Count);
  SetLength(Vertex,V_Count);
  SetLength(Normal,V_Count);  
  SetLength(Face,F_Count);
//  SetLength(TexFace,F_Count);
  SetLength(TexCoord,T_Count);
  SetLength(Frame,K_Count);

  SV_Count := V_Count;
  SF_Count := F_Count;
  ST_Count := T_Count;
  
  SetLength(SVertex,SV_Count);
  SetLength(STexCoord,ST_Count);
  SetLength(SFace,SF_Count);
  SetLength(STexFace,SF_Count);
  SetLength(SSmGroups,SF_Count);

  BlockRead(F, SmGroups[0], F_Count * SizeOf(integer));
  BlockRead(F, Vertex[0], V_Count * SizeOf(TVector));
  BlockRead(F, Face[0], F_Count * SizeOf(TFace));
  BlockRead(F, TexCoord[0], T_Count * SizeOf(TVector2D));
//  BlockRead(F, TexFace[0], F_Count * SizeOf(TFace));
  BlockRead(F, Frame[0], K_Count * SizeOf(TFrame));

  for i := 0 to V_Count - 1 do
    SVertex[i] := Vertex[i];
  for i := 0 to T_Count - 1 do
    STexCoord[i] := TexCoord[i];
  for i := 0 to F_Count - 1 do
    begin
      SFace[i] := Face[i];
//      STexFace[i] := TexFace[i];
      SSmGroups[i] := SmGroups[i];
    end;

  CalculateNormals;
end;

procedure TSTFMesh.Save(var F: file; K_Count:integer);
begin
  BlockWrite(F, SV_Count, SizeOf(V_Count));
  BlockWrite(F, SF_Count, SizeOf(F_Count));
  BlockWrite(F, ST_Count, SizeOf(T_Count));

  BlockWrite(F, SmGroups[0], SF_Count * SizeOf(integer));
  BlockWrite(F, SVertex[0], SV_Count * SizeOf(TVector));
  BlockWrite(F, SFace[0], SF_Count * SizeOf(TFace));
  BlockWrite(F, STexCoord[0], ST_Count * SizeOf(TVector2D));
//  BlockWrite(F, TexFace[0], SF_Count * SizeOf(TFace));
  BlockWrite(F, Frame[0], K_Count * SizeOf(TFrame));
end;

procedure TSTFOTModel.Load(FileName: string; bump:boolean = false);
var f:file;
    i:integer;
begin
  AssignFile(F,FileName);
  System.Reset(F,1);

  BlockRead(F, M_Count, SizeOf(M_Count));
  SetLength(Mesh, M_Count);
  BlockRead(F, K_Count, SizeOf(K_Count));
  BlockRead(F, FPS, SizeOf(FPS));
  BlockRead(F, A_Count, SizeOf(A_Count));

  SetLength(Anims,A_Count);
  for i := 0 to A_Count - 1 do
    begin
      BlockRead(F,Anims[i],Sizeof(TAnim));
    end;

  for i := 0 to M_Count - 1 do
    begin
      Mesh[i] := TSTFMesh.Create;
      Mesh[i].Load(F, K_Count);
    end; 

  CloseFile(f);
end;

procedure TSTFOTModel.Save(FileName:String);
var F:File;
    i:integer;
begin
  AssignFile(F,FileName);
  System.Rewrite(F,1);

  BlockWrite(F, M_Count, SizeOf(M_Count));
  SetLength(Mesh, M_Count);
  BlockWrite(F, K_Count, SizeOf(K_Count));
  BlockWrite(F, FPS, SizeOf(FPS));
  BlockWrite(F, A_Count, SizeOf(A_Count));

  SetLength(Anims,A_Count);
  for i := 0 to A_Count - 1 do
    begin
      BlockWrite(F,Anims[i],Sizeof(TAnim));
    end;

  for i := 0 to M_Count - 1 do
    begin
      (Mesh[i] as TSTFMesh).Save(F, K_Count);
    end;

  CloseFile(F);
end;

{$ENDREGION}

end.
