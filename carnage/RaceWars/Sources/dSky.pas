unit dSky;

interface

uses eXgine, dglOpenGL, dParticles, dMath;

type
  TSky = class
    constructor Create;
    private
      Texture : Cardinal;
      Lines   : Cardinal;
      Shader  : TShader;
      uTexture : TShUniform;
      uLineTex : TShUniform;
      lAddTime : integer;
      procedure AddSpaceParticle;
    public
      procedure Render;
      procedure Update;
  end;


implementation

uses Variables;

{$REGION 'TSky'}
constructor TSky.Create;
begin
  lAddTime := eX.GetTime - 2000;
  Texture := tex.Load('data\textures\sky\sky.jpg');
  Lines := tex.Load('data\textures\sky\line_sky.tga');

  vfp.Clear;


  if not vfp.Add('data\shaders\sky.txt','sky') then
    Halt
  else Shader := vfp.Compile;
  vfp.Clear;

  uTexture := vfp.GetUniform(Shader,'Texture');
  uLineTex := vfp.GetUniform(Shader,'Lines');  
end;

procedure TSky.Render;
const size = 500;
      rc = 6;
var dv:single;      
begin
  dv := (size+1024) / rc;

  glDepthMask(false);

  glPushMatrix;

  glDepthMask(FALSE);

  glTranslatef(Camera.CurPos.x,Camera.CurPos.y,0.02);

  vfp.Enable(Shader);

  vfp.Uniform(uTexture,0);
  vfp.Uniform(uLineTex,1);

  tex.Enable(Texture);
  tex.Enable(Lines,1);  
  glColor3f(1,1,1);
  glDisable(GL_LIGHTING);
  glBegin(GL_QUADS);
    glTexCoord2f(Camera.CurPos.x/dv,Camera.CurPos.y/dv);
    glVertex3f(-size,-size,0);

    glTexCoord2f(Camera.CurPos.x/dv,Camera.CurPos.y/dv+rc);
    glVertex3f(-size, size,0);

    glTexCoord2f(Camera.CurPos.x/dv+rc,Camera.CurPos.y/dv+rc);
    glVertex3f( size, size,0);

    glTexCoord2f(Camera.CurPos.x/dv+rc,Camera.CurPos.y/dv);
    glVertex3f( size,-size,0);
  glEnd;

  glEnable(GL_LIGHTING);
  tex.Disable();
  glDepthMask(TRUE);

  vfp.Disable;

  glPopMatrix;

  glDepthMask(true);  
end;

procedure TSky.AddSpaceParticle;
var em : TSpaceEmitter;
    v : TVector3;
begin
  em := TSpaceEmitter.Create;
  v := vector3(random-0.5,random-0.5,0)*400;
  if (VecLength(v))<100 then
    v := normalize(v)*100;
  v := ZeroVec;
  v := v+normalize(Camera.Pos - Camera.PrevPos) * 600;

  em.Pos := Camera.Pos + v;
  em.LiveTime := 2000;
  ParticleSystem.AddEmitter(em);
end;

procedure TSky.Update;
begin
{  if eX.GetTime - lAddTime > 700 then
    begin
      lAddTime := eX.GetTime;
      AddSpaceParticle;
    end;}
end;
{$ENDREGION}


end.
