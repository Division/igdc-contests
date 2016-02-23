unit dMeshes;

interface

uses eXgine,dglOpenGL,dMath, SysUtils;

type
  TFace=array[0..2] of integer;

  TMesh=class
      constructor Create;
    public
      Texture:TTexture;
      V_Count  : integer; // Количество вершин
      T_Count  : integer; // Текстур
      F_Count  : integer; // Граней
      Textured : boolean;
      BumpMap  : boolean; // Включен ли бамп
      Vertex   : array of TVector3; // Вершины
      Normal   : array of TVector3; // Нормали
      Face     : array of TFace;
      TexCoord : array of TVector2D;
      TexFace  : array of TFace;
      BinA:TShAttrib; // Аттрибут бинормалей
      procedure ReCalc; virtual; // Пересборка меша
      procedure Render; virtual; // Угадай что
      procedure SetAttribute(a:TShAttrib); virtual; // Задаем аттрибут бинормали
      procedure ResetMesh; // Освобождаем память
      procedure CalculateNormals;
      Procedure LoadFromFile(FileName:string; CalcNorm:boolean = true);
      procedure LoadTexture(FileName:string);
  end;

  TBumpedMesh=Class(TMesh)
    public
      procedure ReCalc; override;
      procedure Render; override;
      procedure RenderSlow; // Медленный рендер через glBegin/glEnd
      procedure SetAttribute(a:TShAttrib); override;
    private      
      Binormal: array of TVector3;
      Tangent : array of TVector3;
  end;

var Textr:boolean;

implementation

{$REGION 'Mesh Initialization'}
procedure TMesh.SetAttribute(a: Integer);
begin

end;

procedure TMesh.ResetMesh;
begin
  Vertex:=nil;
  Normal:=nil;
  Face:=nil;
  TexCoord:=nil;
  TexFace:=nil;
  V_Count:=0;
  T_Count:=0;
  F_Count:=0;
  if texture<>0 then  
    tex.Free(Texture);
  Textured:=false;
end;

procedure TMesh.LoadFromFile(FileName: string; CalcNorm:boolean = true);
var  F : File;
begin
  ResetMesh;
  AssignFile(F, FileName);
  Reset(F, 1);

  BlockRead(F, V_Count, SizeOf(V_Count));
  BlockRead(F, F_Count, SizeOf(F_Count));
  BlockRead(F, T_Count, SizeOf(T_Count));  

  SetLength(Vertex,V_Count);
  SetLength(Normal,V_Count);  
  SetLength(Face,F_Count);
  SetLength(TexFace,F_Count);
  SetLength(TexCoord,T_Count);  

  BlockRead(F, Face[0], F_Count * SizeOf(TFace));
  BlockRead(F, TexCoord[0], T_Count * SizeOf(TVector2D));
  BlockRead(F, TexFace[0], F_Count * SizeOf(TFace));
  BlockRead(F, Vertex[0], V_Count * SizeOf(TVector));
  if not CalcNorm then
    BlockRead(F, Normal[0], V_Count * SizeOf(TVector))
      else CalculateNormals;
  CloseFile(F);

  ReCalc;
end;

procedure TMesh.LoadTexture(FileName:string);
begin
  Textured:=true;
  Texture:=tex.Load(PCHAR(FileName));
end;

// Увидел на форуме пост XProger'a (:
procedure TMesh.ReCalc;
type
  TVert = record c,n : TVector3; t: TVector2D; end;
var
  i, j, idx : Integer;
  c,n : TVector3;
  t : TVector2D;
  v : array of TVert;
  count : Integer;
begin
  count := 0;
  SetLength(v, V_Count);
  for i := 0 to F_Count - 1 do
    for j := 0 to 2 do
    begin
      c := Vertex[Face[i][j]];
      t := TexCoord[TexFace[i][j]];
      n:= Normal[Face[i][j]];
      idx := 0;
      while idx < count do
        if (v[idx].c.X = c.X) and (v[idx].c.Y = c.Y) and (v[idx].c.Z = c.Z) and
           (v[idx].t.X = t.X) and (v[idx].t.Y = t.Y) then
          break
        else
          inc(idx);
      if idx = count then
      begin
        if Length(v) = count then
          SetLength(v, Length(v) + 128);
        v[count].c := c;
        v[count].t := t;
        v[count].n := n;
        inc(count);
      end;
      Face[i][j] := idx;
    end;
  V_Count := count;
  SetLength(Vertex, V_Count);
  SetLength(TexCoord, V_Count);
  SetLength(Normal, V_Count);
  for i := 0 to V_Count - 1 do
  begin
    Vertex[i]    := v[i].c;
    TexCoord[i] := v[i].t;
    Normal[i] := v[i].n;
  end;

end;

procedure TMesh.CalculateNormals;
var i:integer;
    N:TVector3;
begin
  for i := 0 to V_Count-1 do
    Normal[i]:=ZeroVec;

  for i := 0 to F_Count - 1 do
    begin
      N:=(Vertex[Face[i,0]]-Vertex[Face[i,1]])*(Vertex[Face[i,0]]-Vertex[Face[i,2]]);
      Normal[Face[i][0]]:=Normal[Face[i][0]]+N;
      Normal[Face[i][1]]:=Normal[Face[i][1]]+N;
      Normal[Face[i][2]]:=Normal[Face[i][2]]+N;
    end;
end;

constructor TMesh.Create;
begin

end;
{$ENDREGION}

{$REGION 'Rendering'}
// Для шустрого рендеринга юзаем glDrawElements
// VBO прикрутить труда не составит, но мне лениво (: 
procedure TMesh.Render;
begin
  if V_Count = 0 then Exit;

  if Textured then
    tex.Enable(Texture)
  else glDisable(GL_TEXTURE_2D);

  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);

  if Textured then
    begin
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glTexCoordPointer(2,GL_FLOAT,0,TexCoord);
    end;
  glVertexPointer(3,GL_FLOAT,0,Vertex);
  glNormalPointer(GL_FLOAT,0,Normal);

  glDrawElements(GL_TRIANGLES,F_Count*3,GL_UNSIGNED_INT,Face);

  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_NORMAL_ARRAY);
  if Textured then
    begin
      glDisableClientState(GL_TEXTURE_COORD_ARRAY);
      tex.Disable();
    end;
end;


{$ENDREGION}

{$REGION 'BumpedMesh'}
procedure TBumpedMesh.ReCalc;
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
begin
  inherited;
  VCount:=F_Count*3;
  SetLength(v,VCount);
  for i := 0 to F_Count - 1 do
    begin
      for j := 0 to 2 do
        with v[i*3+j] do
          begin
            Vert:=Vertex[Face[i][j]];
            tc.x:=TexCoord[Face[i][j]].x;
            tc.y:=TexCoord[Face[i][j]].y;
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
      Normal[i]:=v[i].N;      
      TexCoord[i].x:=v[i].tc.x;      
      TexCoord[i].y:=v[i].tc.y;      
      Binormal[i]:=v[i].B;
      Tangent[i]:=v[i].T
    end;
  v:=nil;  
end;

procedure TBumpedMesh.Render;
begin
  if V_Count = 0 then Exit;

  tex.Enable(Texture);
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);

  glTexCoordPointer(2,GL_FLOAT,0,TexCoord);
  glColorPointer(3,GL_FLOAT,0,Tangent);
  glEnableVertexAttribArray(BinA);
  glVertexAttribPointer(BinA,3,GL_FLOAT,true,0,Binormal);
    
  glVertexPointer(3,GL_FLOAT,0,Vertex);
  glNormalPointer(GL_FLOAT,0,Normal);

  glDrawArrays(GL_TRIANGLES,0,V_Count);

  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);  
  glDisableClientState(GL_NORMAL_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableVertexAttribArray(BinA);  
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);

  glColor3f(1,1,1);
  tex.Disable();
end;

procedure TBumpedMesh.RenderSlow;
var i:integer;
begin
  tex.Enable(Texture);
  glBegin(GL_TRIANGLES);
  for i := 0 to V_Count do
    begin
      glTexCoord2fv(@TexCoord[i]);
      glColor3fv(@Tangent[i]);
      vfp.Attrib(BinA,Binormal[i].x,Binormal[i].y,Binormal[i].z);
      glNormal3fv(@Normal[i]);
      glVertex3fv(@Vertex[i]);
    end;
  glEnd;

  glColor3f(1,1,1);
  tex.Disable(); 
end;

procedure TBumpedMesh.SetAttribute(a: TShAttrib);
begin
  BinA:=a;
end;
{$ENDREGION}

end.
