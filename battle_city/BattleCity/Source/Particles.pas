unit Particles;

interface

uses eXgine, OpenGL, Render, Variables;



type
    Color4=array[0..3] of GLFloat;

const COLORCOUNT=6;
      COLORS:array[0..COLORCOUNT-1] of Color4=((1.0, 0.125, 0, 1.0),
                                               (1.0, 0.25,0.0, 1.0),
                                               (1.0, 0.3, 0.1, 1.0),
                                               (1.0, 0.3, 0.05,1.0),
                                               (0.2, 0.5, 0.8, 1.0),
                                               (0.5, 0.05,1.0, 1.0));
type

    PParticle=^TParticle;
    TParticle=object
     x,y,sx,sy:single;
     C:Color4;
     LifeTime,CrTime:integer;
     W,H:integer;
     Next,Prev:PParticle;
     MustDie:boolean;
     procedure Update;
    end;

var Part:array[0..63,0..63,0..3] of GLuByte;
    PTex:TTexture;
    ParticleCount:integer=0;
    Particle:PParticle;
    LastTime:integer;

function DeleteParticle(P:PParticle):PParticle;
procedure PreparePart;
function AddParticle:PPArticle;
procedure CreateExplosion(NX,NY,Count,Clr:integer; Power:single=1; Kind:byte=1);
procedure RenderParticles;
procedure UpdateParticles;
procedure ClearParticles;

implementation

procedure PreparePart;
var i,j,t:integer;
begin
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
 PTex:=tex.Create('blur.tga',4,GL_RGBA,64,64,@Part);
end;

procedure CreateExplosion(NX,NY,Count,Clr:integer; Power:single=1; Kind:byte=1);
var i:integer;
    t:integer;
begin
 for i := 0 to Count - 1 do
  with AddParticle^ do
  begin
   MustDie:=false;

   t:=i;
   if t=0 then t:=1;

   SX:=(Random(21)-10)/5*Power;
   SY:=(Random(21)-10)/5*Power;

   case kind of
    1:
     begin
      W:=64;
      H:=64;
      X:=NX+(Random(21)-10)*2.5;
      Y:=NY+(Random(21)-10)*2.5;

     end;
    2:
     begin
      W:=32;
      H:=32;
      X:=NX+(Random(21)-10)*1.5;
      Y:=NY+(Random(21)-10)*1.5;
     end;
   end;

   CrTime:=eX.GetTime;
   C:=COLORS[Clr];
   LifeTime:=trunc((Random(1000)+1000)*(t/Count));
  end;
end;


function AddParticle:PPArticle;
var P:PParticle;
begin
 inc(ParticleCount);
 New(P);

 if Particle^.Next <> nil then
  Particle^.Next^.Prev:=P;

 P^.Next:=Particle^.Next;
 P^.Prev:=Particle;
 Particle^.Next:=P;

 Result:=P;

end;

function DeleteParticle(P:PParticle):PParticle;
begin
 if P^.Next<>nil then
 begin
  Result:=P^.Next;
  P^.Prev^.Next:=P^.Next;
  P^.Next^.Prev:=P^.Prev;
  Dispose(P);
 end
 else
 begin
  Result:=nil;
  P^.Prev^.Next:=nil;
  Dispose(P);
 end;

 Dec(ParticleCount);
end;

procedure TParticle.Update;
var T:integer;
begin
 T:=eX.GetTime;

 X:=X+SX;
 Y:=Y+SY;

  if (T-CrTime)>(LifeTime/2) then
  begin
   if SX>0 then
    SX:=SX-1/(LifeTime/1000*30)*2
   else SX:=SX+1/(LifeTime/1000*30)*2;

   if SY>0 then
    SY:=SY-1/(LifeTime/1000*30)
   else SY:=SY+1/(LifeTime/1000*30);
  end;

 if T-CrTime>LifeTime then MustDie:=true;
 C[3]:=C[3]-1/(LifeTime/1000*30);

end;

procedure UpdateParticles;
var P:PParticle;
begin
 P:=Particle^.Next;
 while P<>nil do
 begin
  P^.Update;
  if P^.MustDie then P:=DeleteParticle(P)
  else P:=P^.Next;  
 end;
end;

procedure RenderParticles;
var
    Time:integer;
    a:Single;
    P:PParticle;
begin
 P:=Particle;
 while P^.Next<>nil do
 begin
  P:=P^.Next;
  with P^ do
   begin
    if GameParam.MotionInterpolation then
    begin
     Time := eX.GetTime;
     Time:= Time-LastTime;
     a:=Time/1000*30;
     glColor4fv(@C);
     DrawQuad(PTex,X+SX*a,Y+SY*a,W,H,0);
     glColor4f(1,1,1,1);
    end
    else
    begin
     glColor4fv(@C);
     DrawQuad(PTex,X,Y,W,H,0);
     glColor4f(1,1,1,1);     
    end;
   end;
 end;
end;

procedure ClearParticles;
var P:PParticle;
begin
 P:=Particle;
 while (P<>nil)do
  if P<>Particle then
   P:=DeleteParticle(P)
  else P:=P^.Next;
end;


end.
