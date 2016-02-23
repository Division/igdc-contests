unit dParticlesQ;

interface

uses dMath,eXgine, dglOpenGL, Windows;


const GEN_EXPL_LINE = 0; // Огненные линии при взрыве
      GEN_EXPL_CIRC = 1; // Взрывная волна

      // Эффекты перед смертью частицы
      DE_NONE = 0;
      DE_ALPHA_MIN = 1;

      MAX_PARTICLES = 10000;

type

{$REGION 'Generator'}
  PParticleGenerator = ^TParticleGenerator;
  TParticleGenerator = record
    PrevPos,Pos,Dir:TVector3;
    StartTTL,TTL:integer;
    PartsPerUpdate:integer;
    InterpCreat:boolean;
    Speed:Single;
    Die:boolean;

    Kind:integer;
    procedure Update;
  end;
{$ENDREGION}

{$REGION 'TParticle'}

  PParticle = ^TParticle;
  TParticle = record
    PrevPos,Pos,Dir:TVector3;
    Speed,Size:Single;
    Color:array[0..3] of Single;

    Brake,BrakeKoef:Single;
    TTL,StartTTL:Integer;
    Die:boolean;

    EfStart,PrevAlpha,Alpha,AlphaStart:single;
    Effect:integer;

    Next:PParticle;
    Enable:boolean;
    procedure Update;
  end;

{$ENDREGION}

{$REGION 'ParticleEngine'}
  TParticleEngine=class
  constructor Create;
  destructor Destroy; override;
  public
    ParticleCount,GeneratorCount:integer;
    Particles:array[0..MAX_PARTICLES-1] of TParticle;
    Generators:array of TParticleGenerator;

    Shader : TShader; // Шейдер для билбордов (:
    function AddGenerator:PParticleGenerator;
    function AddParticle:PParticle;
    procedure Update;
    procedure DeleteGenerator(Index:integer);
    procedure RenderParticles;
    procedure Clear;
  private
    Vertexes:array of TVector3;
    TexCoord:array of TVector2D;
    Colors:array of array[0..3] of Single;
    Sizes :array of TVector3;

    DefaultTex:TTexture;


    procedure Interpolate;
    procedure PrepareArrays;
  end;
{$ENDREGION}


implementation

uses variables;

{$REGION 'TParticle'}
procedure TParticle.Update;
var k:Single;
begin
  k:=0;
  // Движение
  PrevPos:=Pos;
  if VecLength(Dir,ZeroVec)>0 then
    Pos:=Pos+Normalize(Dir)*Speed;

  // Time to Live
  TTL:=TTL-trunc(1000/UPS);
  if TTL <= 0 then
    begin
      Die:=true;
    end;

  if TTL>0 then
    begin
      k:=TTL/StartTTL;
      if k<Brake then Speed:=Speed/BrakeKoef;
    end;

  // Предсмертные эффекты
  if (Effect > 0) and (TTL>0) then
    begin
      if k<EfStart then
      case Effect of
        // Уменьшаем прозрачность
        DE_ALPHA_MIN:
          begin
            k:=AlphaStart/(UPS/1000*TTL);
            PrevAlpha:=Alpha;
            Alpha:=Alpha-k;
            if Alpha<=0 then
              Die:=true;
          end;
      end;      
    end;

//   Если следующий тухнет
//  if (Next <> nil) and Next^.Die then
//    begin
//      P:=Next;
//      Next:=Next^.Next;
//      PartEng.DeleteParticle(P);
//    end;
end;
{$ENDREGION}

{$REGION 'ParticleEngine Process'}
function TParticleEngine.AddParticle:PParticle;
var P:PParticle;
    i:integer;
begin
  P:=@Particles[0];
  Result:=P;

  if ParticleCount = MAX_PARTICLES then
    Exit;

  for i := 0 to MAX_PARTICLES - 1 do
    if not Particles[i].Enable then
      begin
        P:=@Particles[i];
        Result:=p;
        inc(ParticleCount);
        Break;
      end;
  // Некоторая инициализация
  if P<> nil then
  with P^ do
    begin
      Enable:=true;
      Pos:=ZeroVec;// Позиция
      PrevPos:=Pos; // Предедущая
      Die:=false; // Умирать пока рано
      Brake:=0; // Скорость не меняется
      BrakeKoef:=1.5; // Тормозной коэфизиент
      Size:=5; // Размер
      Color[0]:=1; // Цвет
      Color[1]:=1;
      Color[2]:=1;
      Color[3]:=1;
      Alpha:=1;
      PrevAlpha:=Alpha;
      AlphaStart:=Alpha;
      Effect:=DE_NONE; // Без эффектов
      EfStart:=0.5; // Начало эффектов в середине жизни
      Dir:=ZeroVec; // Напр. движения стоим на месте
      Speed:=0; // Ага, стоим
      TTL:=1000; // Секунда жизни
      StartTTL:=TTL; // Ап
    end;
end;

{procedure TParticleEngine.DeleteParticle(i:integer);
begin
//  Dispose(P);
  Particles[i].Enable:=false;
  dec(ParticleCount);
end;
}

constructor TParticleEngine.Create;
var Part:array[0..63,0..63,0..3] of GLuByte;
    i,j,t:integer;
begin
  if vfp.Add('DATA\Shaders\BillBoard.txt', 'billboard') then
    Shader := vfp.Compile;
  vfp.Clear;

  for i := 0 to 63 do
  for j := 0 to 63 do
  begin
    Part[i,j,0]:=255;
    Part[i,j,1]:=255;
    Part[i,j,2]:=255;
    t:=trunc(sqrt(sqr(i-32)+sqr(j-32))/32*255);

    if t>255 then t:=255;
    Part[i,j,3]:=255-t
  end;
  DefaultTex:=tex.Create('DefaultBlur.tga',4,GL_RGBA,64,64,@Part);
  ParticleCount:=0;
end;

destructor TParticleEngine.Destroy;
begin
  Clear;
  inherited;
end;

procedure TParticleEngine.Clear;
var i:integer;
begin
  for i := 0 to MAX_PARTICLES - 1 do
    Particles[i].Enable:=false;
  ParticleCount:=0;
end;

procedure TParticleEngine.Update;
var i:integer;
begin
  if ParticleCount <= 0 then Exit;

  for i := 0 to ParticleCount - 1 do
    if Particles[i].Enable then
      begin
        Particles[i].Update;
        if Particles[i].Die then
          begin
            Particles[i]:=Particles[ParticleCount-1];
            Particles[ParticleCount-1].Enable:=false;
            Dec(ParticleCount);
          end;
      end;

  if inp.Down(M_BTN_2) then
    Clear;
  // Подготавливаем массивы для рендеринга then

  PrepareArrays;
end;
{$ENDREGION}

{$REGION 'ParticleEngine Render'}
procedure TParticleEngine.PrepareArrays;
var    i,j,k:integer;
begin
  SetLength(Vertexes,ParticleCount*4);
  SetLength(Sizes,ParticleCount*4);
  SetLength(Colors,ParticleCount*4);
  SetLength(TexCoord,ParticleCount*4);
  // Текстурные координаты
  i:=0;
  for k := 0 to ParticleCount - 1 do
  if Particles[k].Enable then
    begin
      TexCoord[i*4].X:=0;
      TexCoord[i*4].Y:=0;
      TexCoord[i*4+1].X:=0;
      TexCoord[i*4+1].Y:=2;
      TexCoord[i*4+2].X:=2;
      TexCoord[i*4+2].Y:=2;
      TexCoord[i*4+3].X:=2;
      TexCoord[i*4+3].Y:=0;
      inc(i);
    end;
  // Размеры для шейдера и цвет
  i:=0;
  for k := 0 to ParticleCount-1 do
    if PArticles[k].Enable then
      with Particles[k] do
      begin
        for j := 0 to 3 do
          begin
            Sizes[i*4+j].x:=Size;
            Sizes[i*4+j].y:=Size;
            Sizes[i*4+j].z:=Size;

            Colors[i*4+j][0]:=Color[0];
            Colors[i*4+j][1]:=Color[1];
            Colors[i*4+j][2]:=Color[2];
            Colors[i*4+j][3]:=Color[3];                                                
          end;
        inc(i);
      end;
end;

procedure TParticleEngine.Interpolate;
var j,k:integer;
begin
  for k := 0 to ParticleCount - 1 do
    if Particles[k].Enable then
      with Particles[k] do
        for j := 0 to 3 do
          begin
            // Позиция
//            Vertexes[k*4+j]:=PrevPos+(Pos-PrevPos)*dt-Camera.CurPos;
            // Прозрачность
            Colors[k*4+j][3]:=PrevAlpha+(Alpha-PrevAlpha)*dt;
          end;
end;

procedure TParticleEngine.RenderParticles;
begin
  if ParticleCount <= 0 then Exit;

  glDisable(GL_CULL_FACE);
  glDisable(GL_LIGHTING);
  glDepthMask(false);
  glDisable(GL_ALPHA_TEST);

  ogl.Blend(BT_ADD);
  tex.Enable(DefaultTEx);
  glEnable(GL_BLEND);

  // Включаем шойдер
  vfp.Enable(Shader);

  // Интерполируем координаты
  Interpolate;

  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);
  glEnableClientState(GL_NORMAL_ARRAY);
  glNormalPointer(GL_FLOAT,0,Sizes);
  glVertexPointer(3,GL_FLOAT,0,Vertexes);
  glTexCoordPointer(2,GL_FLOAT,0,TexCoord);
  glColorPointer(4,GL_FLOAT,0,Colors);

  glDrawArrays(GL_QUADS,0,ParticleCount*4);

  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  glDisableClientState(GL_NORMAL_ARRAY);

  vfp.Disable;
  glDepthMask(true);
  glEnable(GL_CULL_FACE);
  glDisable(GL_BLEND);
  glEnable(GL_LIGHTING);
  
  tex.Disable();

  glColor3f(1,1,1);
end;
{$ENDREGION}

{$REGION 'Generator'}
function TParticleEngine.AddGenerator:PParticleGenerator;
begin
  inc(GeneratorCount);
  SetLength(Generators,GeneratorCount);
  Result:=@Generators[High(Generators)];
end;

procedure TParticleEngine.DeleteGenerator(Index:integer);
begin
  if (Index<0) or (Index>High(Generators)) then
    Exit;
  Generators[Index]:=Generators[High(Generators)];
  dec(GeneratorCount);
  SetLength(Generators,GeneratorCount);  
end;

procedure TParticleGenerator.Update;
var i:integer;
    crDir:TVector3;
//    CR:Single;
    cp:TVector3;
    gPos,gPrevPos:TVector3;
begin
  PrevPos:=Pos;
  Pos:=Pos+Normalize(Dir)*Speed;

  gPos:=Pos;
  gPrevPos:=PrevPos;

  TTL:=TTL-trunc(1000/UPS);
  if TTL<0 then Die:=true;

  if Die then Exit;

  case Kind of
    GEN_EXPL_LINE:
      begin
        if InterpCreat then
          begin
            crDir:=gPos-gPrevPos;
//            CR:=VecLength(gPos-gPrevPos)/PartsPerUpdate;
            cp:=PrevPos;
            for i := 0 to PartsPerUpdate - 1 do
              with PartEng.AddParticle^ do
                begin
                  Pos:=cp+crDir*(i/PartsPerUpdate);
                  PrevPos:=Pos;
                  Speed:=0;
                  Size:=5;
                  Effect:=DE_ALPHA_MIN;
                  EfStart:=0.2;
                  Die:=false;
                  Color[0]:=0.6;
                  Color[1]:=0.4;
                  Color[2]:=0.2;
                  Color[3]:=0.5;
                  Alpha:=0.2;
                  PrevAlpha:=Alpha;
                  Dir:=ZeroVec;
                  TTL:=2000;
                  StartTTL:=TTL;
                end;
              end;
          end;
      end;
end;
{$ENDREGION}

end.
