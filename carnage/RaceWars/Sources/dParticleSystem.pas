(*

    Система частиц
    Надеюсь получится что-то толковое (:

*)

unit dParticleSystem;

interface

uses dMath, dglOpenGL,eXgine, SysUtils, Windows, dShaderMan, dColor;

const START_PARTICLE_COUNT = 500;
      MIN_LEN_COUNT = 128;
      IPP = 11; // items per particle 

      // Цветовые индексы
      CI_FIRE = 0;
      CI_ROCKET_1 = 1; // РАКЕТА
      CI_ROCKET_2 = 2;
      CI_PLASMA_1 = 3;
      CI_EXPLOSION_1 = 4;      
type

  TParticleColor = array[0..3] of Single;
  CEmitter = class of TBasicEmitter;
  CParticle = class of TBasicParticle;

  // Базовая частица
  TBasicParticle = class
    constructor Create;
    public
      Pos,PrevPos,Force,Dir : TVector3;
      Size : single;
      Angle : single;
      RotSpeed : single;
      Speed : single;
      ColorIndex : integer;
      Texture : integer; // Индекс текстуры в массиве TParticleSystem.fTextures
      Dead : boolean;
      CreateTime : integer;
      LiveTime : integer;
      LifeKoef : Single; // Коэфициент прожитой жизни) 0 в начале, 1 в конце жизни

      procedure Update; virtual;
  end;

  // Базовый эмиттер. Испускает частицы (:
  TBasicEmitter = class
    constructor Create;
    destructor Destroy; override;
    protected
      fPrevPos : TVector3;
      fPos : TVector3; // Позиция эмиттера
      fDir : TVector3;
      fAngle : Single;
      fSpeed : Single;
      fParticles : array of TBasicParticle;
      fParticleCount : integer;
      fDead : boolean;
      fActive : boolean;
      fCreateTime : integer;
      fLiveTime : integer;
      fLastTime : integer;      
      fStop : boolean; // Не выпускать частицы и готовиться к смерти (:
      procedure InsertParticle(Particle : TBasicParticle);
      procedure DeleteParticle(index : integer);
      function GetParticle(Index : integer) : TBasicParticle;
    public
      procedure Reset;
      procedure Update; virtual;
      procedure Stop;

      property ParticleCount : integer read fParticleCount;
      property Dead : boolean read fDead;
      property Pos : TVector3 read fPos write fPos;
      property PrevPos : TVector3 read fPrevPos write fPrevPos;
      property Dir : TVector3 read fDir write fDir;
      property Speed : Single read fSpeed write fSpeed;
      property Particles[Index : integer] : TBasicParticle read GetParticle;
      property LiveTime : integer read fLiveTime write fLiveTime;
      property CreateTime : integer read fCreateTime write fCreateTime;
      property Active : boolean read fActive write fActive;
  end;

  // Класс, внутри которого будут происходить все манипуляции
  TParticleSystem = class
    destructor Destroy; override;
    constructor Create;
    private
      fShader : TShader;
      fTextures : array of Cardinal;
      fTextureCount : integer;
      fEmitters : array of TBasicEmitter;
      fEmitterCount : integer;

      fColorInterp : TCIManager;
      fParticleData : array of array of Single; // Сортируем по текстурам
      fParticleCount : integer; // Общее количество частиц
      fTexParticleCounts : array of integer; // Количество частиц для текстуры 
    public
      function AddTexture(Texture : Cardinal) : integer;
      procedure AddEmitter(Emitter : TBasicEmitter);
      procedure CreateEmitter(ctype : CEmitter; Pos : TVector3; Dir : TVector3; params : array of single; LiveTime : integer = 0; Speed : Single = 1);
      procedure DeleteEmitter(index : integer);
      procedure Reset;
      procedure SetShader(Shader : TShader);

      procedure Update;
      procedure Render;

      property ParticleCount : integer read fParticleCount;      
  end;

implementation

uses VARIABLES;

var PS_Time : integer;

{$REGION 'TParticleSystem'}
constructor TParticleSystem.Create;
var interp : TColorInterp;
begin
  SetLength(fParticleData,1);
  SetLength(fParticleData[0],START_PARTICLE_COUNT*IPP*4);
  SetLength(fTexParticleCounts,1);
  fColorInterp := TCIManager.Create;


  with fColorInterp.AddInterp do
    begin
      AddColor4(Color4(1,0,0,0), 0.01);
      AddColor4(Color4(1,0,0,1), 0.3);
      AddColor4(Color4(0,1,0,1), 0.7);
      AddColor4(Color4(0,0,1,1), 0.8);
      AddColor4(Color4(0,0,0,0), 0.8);
    end;

  // CI_ROCKET_1
  with fColorInterp.AddInterp do
    begin

      AddColor4(Color4(0,0,0,0), 0.0);
      AddColor4(Color4(0.3,1.0,1.0,1.0), 0.2);
      AddColor4(Color4(0.3,1.0,1.0,1.0), 0.5);
      AddColor4(Color4(0.0,0.0,0.0,0.0), 0.95);
    end;

  // CI_ROCKET_2
  with fColorInterp.AddInterp do
    begin
      AddColor4(Color4(0,0,0,0), 0.0);
      AddColor4(Color4(0.3,1.0,1.0,1.0), 0.3);
      AddColor4(Color4(0.3,1.0,1.0,1.0), 0.5);
      AddColor4(Color4(0.0,0.0,0.0,0.0), 0.9);
    end;

  // CI_PLASMA_1
  with fColorInterp.AddInterp do
    begin
      AddColor4(Color4(0.0,0,0,0), 0.0);
      AddColor4(Color4(0.0,1,0,0.5), 0.1);      
      AddColor4(Color4(0.1,1.0,1.0,1.0), 0.2);
      AddColor4(Color4(1,1.0,1.0,1.0), 0.6);
      AddColor4(Color4(0.0,0.0,0.0,0.0), 0.8);
    end;

  // CI_EXPLOSION_1
  with fColorInterp.AddInterp do
    begin
      AddColor4(Color4(0.0,0,0,0), 0.0);
      AddColor4(Color4(0.0,1,0,0.5), 0.1);
      AddColor4(Color4(0.1,1.0,1.0,1.0), 0.2);
      AddColor4(Color4(1,1.0,1.0,1.0), 0.6);
      AddColor4(Color4(0.0,0.0,0.0,0.0), 0.8);
    end;
end;

destructor TParticleSystem.Destroy;
begin
  Reset;
  fColorInterp.Destroy;
  inherited;
end;

procedure TParticleSystem.SetShader(Shader: Cardinal);
begin
  fShader := Shader;
end;

function TParticleSystem.AddTexture(Texture : Cardinal) : integer;
begin
  inc(fTextureCount);
  SetLength(fTextures,fTextureCount);
  SetLength(fParticleData,fTextureCount);
  SetLength(fTexParticleCounts,fTextureCount);    
  fTextures[fTextureCount - 1] := Texture;
end;

procedure TParticleSystem.AddEmitter(Emitter: TBasicEmitter);
var len : integer;
begin
  inc(fEmitterCount);
  len := Length(fEmitters);
  if fEmitterCount > len then
    SetLength(fEmitters,len + MIN_LEN_COUNT);
  Emitter.fCreateTime := eX.GetTime;
  Emitter.Active := true; 
  fEmitters[fEmitterCount - 1] := Emitter;
end;

procedure TParticleSystem.CreateEmitter(ctype: CEmitter; Pos: TVector3; Dir: TVector3; params:array of single; LiveTime : integer = 0; Speed: Single = 1);
var Emitter : TBasicEmitter;
begin
  Emitter := ctype.Create;
  Emitter.Pos := Pos;
  Emitter.Dir := Dir;
  Emitter.Speed := Speed;
  Emitter.LiveTime := LiveTime;
  AddEmitter(Emitter);
end;

procedure TParticleSystem.DeleteEmitter(index: Integer);
begin
  if (index > fEmitterCount - 1) or (index < 0) then
    Exit;
  fEmitters[index].Destroy;
  fEmitters[index] := nil;
  fEmitters[index] := fEmitters[fEmitterCount - 1];
  dec(fEmitterCount);
end;

procedure TParticleSystem.Reset;
var i:integer;
begin
  for i := 0 to fEmitterCount - 1 do
    fEmitters[i].Destroy;
  fEmitters := nil;
  fEmitterCount := 0;
  for i := 0 to fTextureCount - 1 do
    tex.Free(fTextures[i]);
  fTextures := nil;
  fTextureCount := 0;
  fParticleData := nil;
  fParticleCount := 0;
end;

procedure TParticleSystem.Update;
const TexCoords : array[0..3] of array[0..1] of Single = ((0,0),(0,1),(1,1),(1,0)); 
var i,j,len,k,t:integer;
    n : array of integer;
    tmp:integer;
    Color : TColor4;
begin
  PS_Time := eX.GetTime;

  for i := 0 to fEmitterCount - 1 do
    fEmitters[i].Update;

  for i := fEmitterCount - 1 downto 0 do
    if fEmitters[i].Dead then
      DeleteEmitter(i);

  // Общее количество частиц. Толку от него мало
  fParticleCount := 0;
  for i := 0 to fEmitterCount - 1 do
    fParticleCount := fParticleCount + fEmitters[i].ParticleCount;

  // Проходим по количеству текстур и обнуляем
  for i := 0 to fTextureCount - 1 do
    fTexParticleCounts[i] := 0;

  // Считаем количество частиц для каждой текстуры
  for i := 0 to fEmitterCount - 1 do
    for j := 0 to fEmitters[i].ParticleCount - 1 do
      begin
        inc(fTexParticleCounts[fEmitters[i].Particles[j].Texture]);
      end;

  // Увеличиваем размер для массива со всеми данными
  for i := 0 to fTextureCount - 1 do
    begin
      len := length(fParticleData[i]);
      if len < fTexParticleCounts[i] * IPP * 4 then
      SetLength(fParticleData[i],fTexParticleCounts[i] * IPP * 4 + MIN_LEN_COUNT); // 4 Вершины на частицу
    end;

  n := nil;
  SetLength(n,fTextureCount);
//  for i := 0 to fTextureCount - 1 do
//    n[i] := 0;

  // Подготовка массивов для рендеринга + сортировка по текстурам
  for i := 0 to fEmitterCount - 1 do
    for j := 0 to fEmitters[i].ParticleCount - 1 do
      with fEmitters[i] do
        begin
          t := fParticles[j].Texture; // Индекс текстуры
          if t>fTextureCount - 1 then
            continue;
          for k := 0 to 3 do
            begin
              // Позиция
              fParticleData[t][n[t]*IPP+0] := Particles[j].Pos.x;
              fParticleData[t][n[t]*IPP+1] := Particles[j].Pos.y;
              fParticleData[t][n[t]*IPP+2] := Particles[j].Pos.z;

              // Цвет
              Color := fColorInterp.GetColor(Particles[j].ColorIndex,Particles[j].LifeKoef);
              fParticleData[t][n[t]*IPP+3] := Color.r;
              fParticleData[t][n[t]*IPP+4] := Color.g;
              fParticleData[t][n[t]*IPP+5] := Color.b;
              fParticleData[t][n[t]*IPP+6] := Color.a;

              // Текстурные координаты
              fParticleData[t][n[t]*IPP+7] := TexCoords[k][0];
              fParticleData[t][n[t]*IPP+8] := TexCoords[k][1];

              // Размер и угол
              fParticleData[t][n[t]*IPP+9] := Particles[j].Size;
              fParticleData[t][n[t]*IPP+10] := Particles[j].Angle;

              inc(n[t]);
            end;
        end;
end;

procedure TParticleSystem.Render;
var i,j:integer;
    sh : TSh;
begin
  vfp.Enable(fShader);

  glEnable(GL_TEXTURE_2D);
  glEnableClientState(GL_VERTEX_ARRAY);
  glEnableClientState(GL_COLOR_ARRAY);

  glDisable(GL_LIGHTING);
  glDepthMask(false);
  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE,GL_ONE);
  glDisable(GL_ALPHA_TEST);

  // Частицы отсортированы по текстурам
  // Наверно лучше было бы юзать одномерный массив для всех текстур
  for i := 0 to fTextureCount - 1 do
    if fTexParticleCounts[i] > 0 then
    begin
      glClientActiveTextureARB(GL_TEXTURE0_ARB);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glBindTexture(GL_TEXTURE_2D,fTextures[i]);
      glVertexPointer(3,GL_FLOAT,IPP*SizeOf(Single),@fParticleData[i][0]);
      glColorPointer(4,GL_FLOAT,IPP*SizeOf(Single),@fParticleData[i][3]);
      glTexCoordPointer(2,GL_FLOAT,IPP*SizeOf(Single),@fParticleData[i][7]);
      glClientActiveTextureARB(GL_TEXTURE1_ARB);
      glEnableClientState(GL_TEXTURE_COORD_ARRAY);
      glTexCoordPointer(2,GL_FLOAT,IPP*SizeOf(Single),@fParticleData[i][9]);
      glDrawArrays(GL_QUADS,0,fTexParticleCounts[i]*4);
    end;

  glDepthMask(true);
  vfp.Disable;
  glDisable(GL_BLEND);
  glEnable(GL_ALPHA_TEST);
  glDisableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);

  glClientActiveTextureARB(GL_TEXTURE0_ARB);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
//  glBindTexture(GL_TEXTURE_2D,0);
  glClientActiveTextureARB(GL_TEXTURE1_ARB);
  glDisableClientState(GL_TEXTURE_COORD_ARRAY);
  glEnable(GL_LIGHTING);
  glActiveTexture(GL_TEXTURE0_ARB);
end;
{$ENDREGION}

{$REGION 'TBasicEmitter'}
constructor TBasicEmitter.Create;
begin
  SetLength(fParticles,START_PARTICLE_COUNT);
  fParticleCount := 0;
  fLiveTime := 0; // По умолчанию живём бесконечно долго
end;

destructor TBasicEmitter.Destroy;
begin
  Reset;
end;

procedure TBasicEmitter.Reset;
var i:integer;
begin
  for i := 0 to fParticleCount - 1 do
    fParticles[i].Destroy;
  fParticles := nil;
  fParticleCount := 0;
end;

function TBasicEmitter.GetParticle(Index : integer) : TBasicParticle;
begin
  if (Index < 0) or (Index > fParticleCount - 1) then
    begin
      Result := nil;
      Exit;
    end;
  Result := fParticles[Index]; 
end;

procedure TBasicEmitter.InsertParticle(Particle: TBasicParticle);
var len : integer;
begin
  if fStop then
    begin
      Particle.Destroy;
      Exit;
    end;

  inc(fParticleCount);
  len := Length(fParticles);
  if fParticleCount > len then
    SetLength(fParticles,len + MIN_LEN_COUNT);

  if Particle.Size = 0 then
    Particle.Size := 20;
  if Particle.LiveTime = 0 then
    Particle.LiveTime := 1000;
  fParticles[fParticleCount - 1] := Particle;
end;

procedure TBasicEmitter.DeleteParticle(index: Integer);
begin
  if (index > fParticleCount - 1) or (index < 0) then
    Exit;
  fParticles[index].Destroy;
  fParticles[index] := nil;
  fParticles[index] := fParticles[fParticleCount - 1];
  dec(fParticleCount);
end;

procedure TBasicEmitter.Stop;
begin
  fStop := true;
end;

procedure TBasicEmitter.Update;
var i:integer;
begin
  for i := 0 to fParticleCount - 1 do
    fParticles[i].Update;

  for i := fParticleCount - 1 downto 0 do
    if fParticles[i].Dead then
      DeleteParticle(i);

  // Пришло время остановиться
  if (fLiveTime <> 0) and (eX.GetTime - fCreateTime > fLiveTime) then
    fStop := true;

  // Если остановлены и все частицы мертвы, отправляемся в гроб
  if fStop and (fParticleCount = 0)  then
    fDead := true;
end;
{$ENDREGION}

{$REGION 'TBasicParticle'}
constructor TBasicParticle.Create;
begin
  CreateTime := PS_Time;
  LiveTime := 2000;
end;

procedure TBasicParticle.Update;
begin
  PrevPos := Pos;
  Pos := Pos + Dir + Force;
  Force := ZeroVec;
  Angle := Angle + RotSpeed;

  LifeKoef := min((PS_Time - CreateTime) / LiveTime, 1);

  if PS_Time - CreateTime > LiveTime then
    begin
      Dead := true;
    end;
end;
{$ENDREGION}

end.

