unit dCars;

interface

uses dPhysics, dMath, dglOpenGL, eXgine, windows;

type

TBasicCar = class
constructor Create;
private
  fPosition:TVector3;
  fDiagSize:single;
  fVertSize:single;
  fHorSize :single;
  fMoveDir : TVector3;
  fMoveNormal : TVector3;

public
  Points : array[0..3] of TPhysPoint;
  // Направления, по которым можно ехать без трения 
  Dirs : array[0..3] of TVector3;

  Fin : array[0..3] of boolean;

  WheelAng: single;
  // Применяем трение...
  procedure ApplyFriction;
  procedure SetPos(x,y:single);
  procedure UpdatePhysics;
  procedure Update;
  procedure Render;

  procedure Collision;
  property Position:TVector3 read fPosition;
end;

implementation

uses Variables, dMap;

constructor TBasicCar.Create;
var i:integer;
begin
  fVertSize := 50;
  fHorSize := 25;
  fDiagSize := VecLength(Vector3(25,50,0));  
  for i := 0 to 3 do
    PhysSetMass(Points[i],1);
end;

procedure TBasicCar.Update;
const wd = 0.0001;
var whl:boolean;
begin
  whl := false;
  
  if inp.Down(ord('W')) then
    begin
      PhysAddForce(Points[0],fMoveDir*1);
      PhysAddForce(Points[3],fMoveDir*1);
    end;
  if inp.Down(ord('S')) then
    begin
      PhysAddForce(Points[0],fMoveDir*(-1));
      PhysAddForce(Points[3],fMoveDir*(-1));
    end;
  if inp.Down(ord('A')) then
    begin
      WheelAng:=WheelAng - 0.1;
      whl := true;
    end;
  if inp.Down(ord('D')) then
    begin
      WheelAng:=WheelAng + 0.1;
      whl := true;
    end;
  if WheelAng<-1 then
    WheelAng := -1;
  if WheelAng > 1 then
    WheelAng := 1;

  if not whl then
    begin
      if WheelAng >=-wd then
        begin
          WheelAng := WheelAng - wd;
          if Abs(WheelAng)<wd then
            WheelAng :=0;
        end
      else WheelAng :=0;
      if WheelAng <= wd then
        begin
          WheelAng := WheelAng + wd;
          if Abs(WheelAng)<wd then
            WheelAng :=0;
        end
      else WheelAng :=0;
    end;

  UpdatePhysics;
end;

procedure TBasicCar.Render;
var i:integer;
    v:TVector3;
begin
  glPointSize(4);
  glPushMatrix;
  glTranslatef(-Camera.x,-Camera.y,0);
  glBegin(GL_LINE_LOOP);
    for i := 0 to 3 do
      glVertex2fv(@Points[i]);
  glEnd;
  glBegin(GL_POINTS);
    for i := 0 to 3 do
      begin
        if (i=0) or (i=3) then
          glColor3f(1,0,0)
        else glColor3f(1,1,1);  
        glVertex2fv(@Points[i]);
      end;
    glColor3f(1,0,0);
    glVertex2fv(@fPosition);  
  glEnd;
  glColor3f(1,1,1);
  
  glBegin(GL_LINES);
    v:=Points[0].Pos + Dirs[0]*15;
    glVertex2fv(@Points[0].Pos);
    glVertex2fv(@v);
    v:=Points[3].Pos + Dirs[3]*15;
    glVertex2fv(@Points[3].Pos);
    glVertex2fv(@v);
    
  glEnd;

  glPopMatrix;

  ogl.TextOut(0,10,10,PCHAR(inttostr(round(Points[1].pos.x))));
end;

procedure TBasicCar.SetPos(x,y:single);
var i:integer;
begin
  fPosition := Vector3(x,y,0);
  // Левый верхний угол
  Points[0].Pos := fPosition - Vector3(12.5,25,0);
  // Левый нижний угол
  Points[1].Pos := fPosition - Vector3(12.5,-25,0);
  // Правый нижний угол
  Points[2].Pos := fPosition + Vector3(12.5,25,0);
  // Правый верхний угол
  Points[3].Pos := fPosition - Vector3(-12.5,25,0);
  for i:=0 to 3 do
    Points[i].PrevPos := Points[i].Pos;
end;

procedure TBasicCar.UpdatePhysics;
var i:integer;
begin
  Dirs[2] := Points[3].Pos-Points[2].Pos;
  Dirs[1] := Points[0].Pos-Points[1].Pos;
  Dirs[0] := fMoveDir - fMoveNormal*WheelAng;
  Dirs[3] := fMoveDir - fMoveNormal*WheelAng;

  ApplyFriction;

  for i := 0 to 3 do
    begin
      PhysMovePoint(Points[i]);
    end;

  Collision;

  for i := 0 to 3 do
    begin
      PhysHandleConstraint(Points[2],Points[0],fDiagSize);
      PhysHandleConstraint(Points[3],Points[1],fDiagSize);
      PhysHandleConstraint(Points[0],Points[1],fVertSize);
      PhysHandleConstraint(Points[1],Points[2],fHorSize);
      PhysHandleConstraint(Points[2],Points[3],fVertSize);
      PhysHandleConstraint(Points[3],Points[0],fHorSize);
    end;

//  fPosition:=Points[0].Pos;
  fPosition:=GetVArrayCenter([Points[0].Pos,Points[1].Pos,Points[2].Pos,Points[3].Pos]);

  Points[0].Pos := Points[0].Pos - fMoveNormal * WheelAng;
  Points[3].Pos := Points[3].Pos - fMoveNormal * WheelAng;   

  fMoveDir := Normalize(Points[0].Pos-Points[1].Pos);
  fMoveNormal := Normalize(GetNormal2(fMoveDir,ZeroVec));

end;

procedure TBasicCar.ApplyFriction;
var i:integer;
    n:TVector3;
    r:single;
begin
  for i := 0 to 3 do
//  if random(2) = 0 then 
    begin
//      n := Normalize(GetNormal2(Dirs[i],ZeroVec));
      n := fMoveNormal;
      n.z:=0;
//      r:=DistToLine2(Points[i].Pos-Dirs[i],Points[i].Pos+Dirs[i],Points[i].PrevPos);
      r:= Distance(Points[i].PrevPos,Points[i].Pos-fMoveDir,Points[i].Pos+fMoveDir,Vector3(0,0,100));
//      Points[i].PrevPos := ClosestPointOnLine(Points[i].Pos-Dirs[i],Points[i].Pos+Dirs[i],Points[i].PrevPos);

      if r<>0 then
        begin
          Points[i].PrevPos := Points[i].PrevPos - n*r;
        end;
    end;
end;
{
function Distance2(a,b,c:TVector3):Single;
var dx,dy,D:Single;
begin
  dx:=a.x-b.x;
  dy:=a.y-b.y;
  D:=dx*(c.y-a.y)-dy*(c.x-a.x);
  Result:=abs(D/Sqrt(dx*dx+dy*dy));
end;
}

procedure TBasicCar.Collision;
var sqrad:single;
    r:single;
    i,j:integer;

procedure HandleLines(var v1:TVector3; var v2:TVector3; const index:integer);
var w1,w2,n:TVector3;
    i:integer;
    r:single;
begin
  w1 := Map.Bounds[index].v1;
  w2 := Map.Bounds[index].v2;
  n  := Map.Bounds[index].n;
  if orient(w1,w2,v1) > 0 then
    begin
      r:=DistToSegment2(w1,w2,v1);
      if r>20 then
        r:=20;
      v1:=v1+n*r;
      console.echo(inttostr(round(r)));
    end;
  if orient(w1,w2,v2) > 0 then
    begin
      r:=DistToSegment2(w1,w2,v2);
      if r>20 then
        r:=20;
      
      v2:=v2+n*r;
      console.echo(inttostr(round(r)));
    end;
end;

begin
  sqrad := fDiagSize*fDiagSize;

  for i := 0 to 3 do
    Fin[i]:=false;

  with Map do
    for i := 0 to High(Bounds) do
      begin
        r:=DistToSegment2(Bounds[i].v1,Bounds[i].v2,fPosition);
        // Если мы возле препятствия
        if abs(r)<fDiagSize then
          begin
            for j := 0 to 2 do
            if LinesIntersect2(Bounds[i].v1,Bounds[i].v2,Points[j].Pos,Points[j+1].Pos) then
              begin
                HandleLines(Points[j].Pos,Points[j+1].Pos,i);
              end;
            if LinesIntersect2(Bounds[i].v1,Bounds[i].v2,Points[0].Pos,Points[3].Pos) then
              begin
                HandleLines(Points[0].Pos,Points[3].Pos,i);
              end;
          end;
      end;
end;

end.
