// Физический модуль By Division :)
//   Основан на статье "Продвинутая физика персонажей"
unit Physics;

interface

const P_DEFAULT   = 0;
      P_NOTLESS   = 1;
      P_NOTBIGGER = 2;

      KOEF_TR=0.4;

type
     TVector3=record
               x,y,z:single;
               procedure From(const X, Y, Z: Single);
               class operator Add(const Left, Right: TVector3): TVector3;
               class operator Divide(const Left, Right: TVector3): TVector3;
               class operator Subtract(const Left, Right: TVector3): TVector3;
               class operator Multiply(const Left, Right: TVector3): TVector3; overload;
               class operator Multiply(const Left: TVector3; right:single): TVector3; overload;
               class operator Equal(const Left: TVector3; Right:TVector3): boolean;
              end;

     TAngleParameter=record
      Enabled:boolean;
      Angle:single;
      NotBigger,Side:boolean;
     end;

     TConstraint=record
      ParticleA,ParticleB:integer;
      RestLength:Single;
      Param:byte;
      AngParam:TAngleParameter;
     end;

     PParticleSystem = ^TParticleSystem;
     TParticleSystem = object
       m_constraints : array of TConstraint; // Связи
       m_x           : array of TVector3; // Координаты частиц
       m_oldx        : array of TVector3; // Предедущая позиция
       m_a           : array of TVector3; // Ускорение по идее
       masses        : array of single;  // Массы
       PEnabled      : array of boolean; // Обрабатывать ли эти частицы
       CEnabled      : array of boolean; // Обрабатывать ли эти связи
       Fixed         : array of boolean;
       TRENIE        : array of integer; // Ну не знаю я, как будет трение на английском :)
       m_vGravity    : TVector3; // Гравитация
       m_fTimeStep   : Single;
       Bounds        : TVector3;

       PartCount       : integer;
       PartMax         : integer;
       ConstrCount     : integer;
       ConstrMax       : integer;
       IterationsCount : integer;
      public
       function AddParticle(X:TVector3; Mass:single=1):integer;
       function AddConstrain(Constr:TConstraint):integer;
       procedure DeleteParticle(P:integer);
       procedure AddAngleParameter(index:integer; Ang:Single; NotBgr:boolean);
       procedure FixParticle(index:integer);
       procedure SetPCount(x:integer); // Устанавливаем потолок частиц
       procedure SetCCount(x:integer); // Устанавливаем потолок связей
       procedure TimeStep;
       procedure Reset;

       procedure InitParam(IterCount: Integer; Bound: TVector3; Gravity:TVector3; TStep:single);
      private
       procedure Verlet;
       procedure SatisfyConstraints;
       procedure AccumulateForces;
     end;

     TCircle=record
      Radius,x,y:Single;
      Particle:integer;
     end;

     TObjectSystem = object // Коллизии, объекты
      PartSystem:PParticleSystem;
      Circles:array of TCircle;

      CircCount:integer;
      CircMax:integer;
     end;

var PS, MenuPS:TParticleSystem;
    t1,t2:TVector3;

function AddSquare(x,y,width:integer; m1:single=1;m2:single=1;m3:single=1;m4:single=1):integer;

function Dot3(v1, v2: TVector3): Single;
function Vector3(x,y,z:single):TVector3;
function Circle(r:single; p:integer):TCircle;
function Constraint(PA,PB:integer; RL:single; PM:integer=P_DEFAULT):TConstraint;
function vmax(a,b:TVector3):TVector3;
function vmin(a,b:TVector3):TVector3;
function VecLength(v1,v2:TVector3):single;
function Normalize(v:TVector3):TVector3;

function GetNormal2(x1,x2:TVector3):TVector3;

function LineVsCircle(X1,X2:TVector3; Circle:TCircle; var h:single):boolean;
function CircleVsCircle(const c1,c2:TCircle; var h:single):boolean;

function Orient(a,b,c:TVector3):single;
function SameVal(a,b:single):boolean;

implementation

uses Utilite, Game;

procedure TParticleSystem.InitParam(IterCount: Integer; Bound: TVector3; Gravity:TVector3; TStep:single);
begin
 IterationsCount:=IterCount;
 Bounds:=Bound;
 m_fTimeStep:=TStep;
 m_vGravity:=Gravity;
end;

procedure TParticleSystem.DeleteParticle(P: Integer);
begin
  PEnabled[P]:=false;
end;

procedure TParticleSystem.SetPCount(x: Integer);
begin
 PartMax:=x;
 SetLength(m_x,PartMax);
 SetLength(m_oldx,PartMax);
 SetLength(m_a,PartMax);
 SetLength(masses,PartMax);
 SetLength(PEnabled,PartMax);
 SetLength(Fixed,PartMax);
end;

procedure TParticleSystem.SetCCount(x: Integer);
begin
 ConstrMax:=x;
 SetLength(m_constraints,ConstrMax);
 SetLength(CEnabled,ConstrMax);
end;

procedure TParticleSystem.FixParticle(index:integer);
begin
 Fixed[index]:=true;
 m_oldx[index]:=m_x[index];
end;

function TParticleSystem.AddParticle(X: TVector3; Mass: Single = 1):integer;

begin
// index:=-1;


// if index=-1 then
   inc(PartCount);
 if PartCount>PartMax then SetPCount(PartCount);

// if index=-1 then
   Result:=PartCount-1;
// else Result:=index;

 m_x[Result]:=x;
 m_oldx[Result]:=x;
 if Mass<>0 then
   masses[Result]:=1/mass // нам нужны обратные массы)
     else masses[Result]:=1;
 PEnabled[Result]:=true;
end;

function TParticleSystem.AddConstrain(Constr: TConstraint):integer;
begin
 inc(ConstrCount);
 if ConstrCount>ConstrMax then SetCCount(ConstrCount);

 Result:=ConstrCount-1;
 m_constraints[Result]:=Constr;
 m_constraints[Result].AngParam.Enabled:=false;
 CEnabled[Result]:=true;
end;

procedure TParticleSystem.AddAngleParameter(index:integer; Ang:Single; NotBgr:boolean);
begin
 with m_Constraints[index].AngParam do
   begin
     Enabled:=true;
     Angle:=Ang;
     NotBigger:=NotBgr;
   end;
end;
                     
procedure TParticleSystem.TimeStep;
begin
 AccumulateForces;
 Verlet;
 SatisfyConstraints;
end;
                   
procedure TParticleSystem.Verlet;
var i:integer;
    x,oldx,a:^TVector3;
    temp:TVector3;
begin
 for i := 0 to PartCount-1 do
 if PEnabled[i] then 
  begin
   x:=@m_x[i];
   temp:=x^;
   oldx:=@m_oldx[i];
   a:=@m_a[i];
   x^:=x^*2-oldx^+a^*m_fTimeStep*m_fTimeStep;
   oldx^:=temp;
  end; 
end;

procedure Collisions;
var i,a,l:integer;
    j:integer;
    p1,p2:TVector3;
    v:TVector3;
    r:single;

procedure HandlePoint(p:integer;Polygon:TPolygon);
var v1,v2,p1,p2:TVector3;
    i:integer;
    r:single;
    l:integer;

begin
  with ps do
  begin
    v1 := m_oldx[p];
    v2 := m_x[p];
    l:=0;
    for i := 0 to Polygon.LineCount - 1 do
      begin
        if Distance(Polygon.Lines[i].v1,Polygon.Lines[i].v2,v2)<
           Distance(Polygon.Lines[l].v1,Polygon.Lines[l].v2,v2) then
             l:=i;
      end;
      i:=l;
      p1:=Polygon.Lines[i].v1;
      p2:=Polygon.Lines[i].v2;
      r:=Distance(p1,p2,m_x[p]);
      m_x[p]:=m_x[p]+Polygon.Lines[i].n*r;
  end;
end;

begin
 with ps do
   if PolygonCount>0 then
     for i := 0 to PolygonCount-1 do
     begin
       // Проверим плеера
       with Player do
       for j := 0 to 7 do // точки плеера в полигоне?
         begin
           if PointInPolygon(m_x[Particles[j]],Polygons[i]) then
            begin
              HandlePoint(Particles[j],Polygons[i]);
              SetLength(ps.TRENIE,Length(ps.TRENIE)+1);
              ps.TRENIE[High(ps.TRENIE)]:=j;
            end;
         end;
       for j := 0 to Polygons[i].VertexCount-1 do // точки полигона в плеере?
         begin
           if PointInPolygon(Polygons[i].Vertexes[j],Player.Polygon) then
             begin
               l:=0;
               v:=Polygons[i].Vertexes[j];
               with Player do
               for a := 0 to 6 do
                 begin
                   if Distance(m_x[Particles[a]],m_x[Particles[a+1]],v)<
                      Distance(m_x[Particles[l]],m_x[Particles[l+1]],v) then
                        l:=a;
                 end;
               if Distance(m_x[Player.Particles[7]],m_x[Player.Particles[0]],v)<
                  Distance(m_x[Player.Particles[l]],m_x[Player.Particles[l+1]],v) then
                    l:=7;

               SetLength(ps.TRENIE,Length(ps.TRENIE)+1);
               ps.TRENIE[High(PS.Trenie)]:=l;
               SetLength(ps.TRENIE,Length(ps.TRENIE)+1);
               ps.TRENIE[High(PS.Trenie)]:=l+1;

               p1:=m_x[Player.Particles[l]];
               if l<>7 then
                 p2:=m_x[Player.Particles[l+1]]
               else p2:=m_x[Player.Particles[0]];

               v:=(p1+p2)*0.5;
               r:=Distance(p1,p2,Polygons[i].Vertexes[j]);
               for a := 0 to 8 do
                 if VecLength(v,m_x[Player.Particles[a]])<110 then
                   m_x[Player.Particles[a]]:=m_x[Player.Particles[a]]-Normalize(GetNormal2(p1,p2))*(r/4);
             end;
         end;

       if Verevka.Enabled then        
       for j := 0 to 19 do // Веревочку надо тоже обрабатывать (:
         begin
           if PointInPolygon(m_x[Verevka.Parts[j]],Polygons[i]) then
            begin
              HandlePoint(Verevka.Parts[j],Polygons[i]);
            end;
         end;

     end;


end;

procedure TParticleSystem.SatisfyConstraints;
var i,j:integer;
    X1,X2:^TVector3;
    Delta:TVector3;
    C:^TConstraint;
    DeltaLength,Diff:single;
    Im1,Im2:single;
begin
 TRENIE:=nil;

 for i := 0 to PartCount - 1 do
  if PEnabled[i] then
  begin
    m_x[i]:=vmin(vmax(m_x[i],Vector3(0,0,0)),Bounds);
  end;

 if IterationsCount>0 then
 for j := 0 to IterationsCount - 1 do
  begin
   if ConstrCount>0 then
   for i := 0 to ConstrCount - 1 do
   if CEnabled[i] then
   begin
     c:=@m_constraints[i];
     X1:=@m_x[c^.ParticleA];
     X2:=@m_x[c^.ParticleB];
     if (c^.Param = P_DEFAULT) or
//        ((c^.Param = P_NOTLESS) and (VecLength(X1^,X2^)<c^.RestLength)) or
        ((c^.Param = P_NOTBIGGER) and (VecLength(X1^,X2^)>c^.RestLength)) then
     begin
       Im1:=masses[c^.ParticleA];
       Im2:=masses[c^.ParticleB];

       Delta:=X2^-X1^;
       DeltaLength:=sqrt(dot3(Delta,Delta));
       Diff:=(DeltaLength-c^.RestLength)/(DeltaLength*(Im1+Im2));

       X1^:=X1^+Delta*(0.5*Diff*Im1);
       X2^:=X2^-Delta*(0.5*Diff*Im2);
     end;
   end;
   
   if Verevka.Enabled then Verevka.Update;

   Collisions;
// Если что-то фиксировано, пусть остается на месте
   for i := 0 to PartCount - 1 do
     if Fixed[i] and PEnabled[i] then
       m_x[i]:=m_oldx[i];


  end;
end;


procedure TParticleSystem.AccumulateForces;
var i:integer;
begin
 for i := 0 to PartCount - 1 do
   if PEnabled[i] then
      m_a[i] := m_vGravity;  {?}

 if Length(TRENIE)>0 then
 for i := 0 to High(TRENIE) do
   begin
     m_oldx[TRENIE[i]]:=m_x[TRENIE[i]]-((m_x[TRENIE[i]]-m_oldx[TRENIE[i]])*KOEF_TR);
   end;
end;

procedure TParticleSystem.Reset;
begin
  SetLength(m_constraints,0);
  SetLength(m_x,0);
  SetLength(m_oldx,0);
  SetLength(m_a,0);
  SetLength(masses,0);
  SetLength(PEnabled,0);
  SetLength(CEnabled,0);
  SetLength(Fixed,0);
  PartCount:=0;
  ConstrCount:=0;              
end;

function VecLength(v1,v2:TVector3):single;
begin
// Странно, но я тут написал для двухмерного случая) Даже не знаю, почему :)
 result:=sqrt((v1.x-v2.x)*(v1.x-v2.x)+(v1.y-v2.y)*(v1.y-v2.y));
end;

function Dot3(v1, v2: TVector3): Single;
begin
  Result := v1.X * v2.X + v1.Y * v2.Y + v1.Z * v2.Z;
end;


function Constraint(PA,PB:integer; RL:single; PM:integer=P_DEFAULT):TConstraint;
begin
 Result.ParticleA  := PA;
 Result.ParticleB  := PB;
 Result.RestLength := RL;
 Result.Param      := PM;
end;

function Vector3(x,y,z:single):TVector3;
begin
 Result.x:=x;
 Result.y:=y;
 Result.z:=z;
end;

function vmax(a,b:TVector3):TVector3;
begin
 if a.x>b.x then result.x:=a.x
  else result.x:=b.x;
 if a.y>b.y then result.y:=a.y
  else result.y:=b.y;
 if a.z>b.z then result.z:=a.z
  else result.z:=b.z;
end;

function vmin(a,b:TVector3):TVector3;
begin
 if a.x<b.x then result.x:=a.x
  else result.x:=b.x;
 if a.y<b.y then result.y:=a.y
  else result.y:=b.y;
 if a.z<b.z then result.z:=a.z
  else result.z:=b.z;
end;

procedure TVector3.From(const X, Y, Z: Single);
begin
  Self.X := X;
  Self.Y := Y;
  Self.Z := Z;
end;

class operator TVector3.Add(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X + Right.X;
  Result.Y := Left.Y + Right.Y;
  Result.Z := Left.Z + Right.Z;
end;

class operator TVector3.Subtract(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X - Right.X;
  Result.Y := Left.Y - Right.Y;
  Result.Z := Left.Z - Right.Z;
end;

class operator TVector3.Divide(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X / Right.X;
  Result.Y := Left.Y / Right.Y;
  Result.Z := Left.Z / Right.Z;
end;

class operator TVector3.Multiply(const Left, Right: TVector3): TVector3;
begin
  Result.X := Left.X * Right.X;
  Result.Y := Left.Y * Right.Y;
  Result.Z := Left.Z * Right.Z;
end;

class operator TVector3.Multiply(const Left: TVector3; Right:single): TVector3;
begin
  Result.X := Left.X * Right;
  Result.Y := Left.Y * Right;
  Result.Z := Left.Z * Right;
end;

class operator TVector3.Equal(const Left: TVector3; Right:TVector3): boolean;
begin
  Result:=(Left.x=Right.x) and (Left.y=Right.y) and (Left.z=Right.z);
end;


function AddSquare(x,y,width:integer; m1:single=1;m2:single=1;m3:single=1;m4:single=1):integer;
var p1,p2,p3,p4:integer;
begin
 p1:=ps.AddParticle(Vector3(x,y,0),m1);
 p2:=ps.AddParticle(Vector3(x+width,y,0),m2);
 p3:=ps.AddParticle(Vector3(x+width,y+width,0),m3);
 p4:=ps.AddParticle(Vector3(x,y+width,0),m4);

 ps.AddConstrain(Constraint(p1,p2,width)); // Добавляем 4 грани
 ps.AddConstrain(Constraint(p2,p3,width)); // *~*
 ps.AddConstrain(Constraint(p3,p4,width)); // *~*
 ps.AddConstrain(Constraint(p4,p1,width)); // *~*
 ps.AddConstrain(Constraint(p1,p3,sqrt(2*width*width))); // И 2 диагонали
 ps.AddConstrain(Constraint(p2,p4,sqrt(2*width*width))); // *~*

 result:=p1;
end;

function Normalize(v:TVector3):TVector3;
var l:single;
begin
  l:=VecLength(v,Vector3(0,0,0));
  With Result do
  begin
    x:=v.x/l;
    y:=v.y/l;
    z:=v.z/l;
  end;
end;

function LineVsCircle(X1,X2:TVector3; Circle:TCircle; var h:single):boolean;
var a,b,c,tmp:single;
begin
  c:=VecLength(X2,X1);
  a:=VecLength(X1,Vector3(Circle.X,Circle.Y,0));
  b:=VecLength(X2,Vector3(Circle.X,Circle.Y,0));

  tmp:=(b*b+c*c-a*a)/(2*c);
  h:=sqrt(b*b-tmp*tmp);

  if h<=Circle.Radius then Result:=true
  else Result:=false;

  if x2.x>x1.x then
   begin
     if (Circle.x>x2.x+Circle.Radius) or (Circle.x<x1.x-Circle.Radius) then Result:=false;
   end
   else
   begin
     if (Circle.x<x2.x-Circle.Radius) or (Circle.x>x1.x+Circle.Radius) then Result:=false;
   end;

  if x2.y>x1.y then
   begin
     if (Circle.y>x2.y+Circle.Radius) or (Circle.y<x1.y-Circle.Radius) then Result:=false;
   end
   else
   begin
     if (Circle.y<x2.y-Circle.Radius) or (Circle.y>x1.y+Circle.Radius) then Result:=false;
   end;

end;

function GetNormal2(x1,x2:TVector3):TVector3;
var d:TVector3;
begin
  d.x:=x1.y-x2.y;
  d.y:=x2.x-x1.x;
  result:=d;   
end;

//double orient(DOT2D* a, DOT2D* b, DOT2D* c)
{
return (a->x - c->x)*(b->y - c->y) - (a->y - c->y) * (b->x - c->x);
}

function SameVal(a,b:single):boolean;
begin
  result:=((a<0) and (b<0)) or ((a>0) and (b>0)){ or ((a=0) and (b=0))};
end;

function Orient(a,b,c:TVector3):single;
begin
  result:=(a.x - c.x)*(b.y - c.y) - (a.y - c.y)*(b.x-c.x);
end;

function Circle(r:single; p:integer):TCircle;
begin
  result.Radius:=r;
  result.Particle:=p;
end;

function CircleVsCircle(const c1,c2:TCircle; var h:single):boolean;
var RLen:Single;
begin
  h:=0;
  Result:=false;
  RLen:=VecLength(Vector3(c1.x,c1.y,0),Vector3(c2.x,c2.y,0));
  if RLen<c1.Radius+c2.Radius then
    begin
      Result:=true;
      h:=c1.Radius+c2.Radius-RLen;
    end;  
end;



end.
