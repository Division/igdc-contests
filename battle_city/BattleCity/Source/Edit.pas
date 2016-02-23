unit Edit;

interface

uses OpenGL, Maps, eXgine,Render;

const
      BNONE = -1;       // Пустое место
      BSIMPLE1 =0 ;    // Разрушаемый, кирпич
      BSIMPLE2 = 1;   // Разрушаемый, ещё не придумал
      BWATER = 2;    // Неразрушаемый, непроходимый, пропускает патроны
      BWEB1=3;      // Неразрушаемый, проходимый, для красоты нужен
      BWEB2=4;      // То же самое
      BSTRONG1=5;   // Неразрушаемый, непроходимый
      BSTRONG2=6;   // То же самое, текстура другая
      BEAGLE1 = 7; // Орёл, на него идёт охота :)
      BEAGLE2 = 8; // Может Deathmatch сделать?
      BP1ST = 10;    // Рождение Плеера 1;
      BP2ST = 11;    // Рождение Плеера 2;
      BCOMST= 9;    // Рождение врагов



var  Map:SAVEDMAP;
     Textures:array[0..12] of TTexture;
     MDOWN:boolean;
     btn:byte;
     SizeEdit:boolean;
     CX,CY,DX,DY,LX,LY:integer;

procedure LoadTextures;
procedure PClick(X,Y:integer);
procedure DrawBr(Tex:TTexture; X,Y,OFR,OFL,OFD,OFU:integer);

implementation

uses BEDITOR, StdCtrls;

procedure LoadTextures;
begin
 Textures[BSIMPLE1]:= tex.Load('Graphics\Wall1.bmp',false,false);
 Textures[BSIMPLE2]:= tex.Load('Graphics\Wall2.bmp',false,false);
 Textures[BSTRONG1]:= tex.Load('Graphics\Wall5.bmp',false,false);
 Textures[BSTRONG2]:= tex.Load('Graphics\Wall6.bmp',false,false);
 Textures[BWATER]:= tex.Load('Graphics\Water.bmp',false,false);
 Textures[BWEB1]:= tex.Load('Graphics\Web1.tga',false,false);
 Textures[BWEB2]:= tex.Load('Graphics\Web2.tga',false,false);
 Textures[BEAGLE1]:= tex.Load('Graphics\Eagle.tga',false,false);
 Textures[BEAGLE2]:= tex.Load('Graphics\Eagle.tga',false,false);

end;

procedure DrawBr(Tex:TTexture; X,Y,OFR,OFL,OFD,OFU:integer);
begin
 DrawQuad(Tex,X,Y,32,32,0,OFR,OFL,OFD,OFU);
end;

procedure PClick(X,Y:integer);
begin
 if x>15 then exit;
 if y>10 then exit;
 if x<0 then exit;
 if y<0 then exit;


 if not SizeEdit then
 with Map.Map[X,Y] do
 begin
  if btn=0 then
   Kind:=form2.Combobox1.ItemIndex
  else Kind:=BNONE;
 OFD:=0;
 OFU:=0;
 OFL:=0;
 OFR:=0;
 end
 else
 begin
  if DX>0 then
   Map.Map[X,Y].OFR:=DX div 5;
  if DX<0 then
   Map.Map[X,Y].OFL:=abs(DX) div 5;

  if DY>0 then
   Map.Map[X,Y].OFD:=DY div 5;
  if DY<0 then
   Map.Map[X,Y].OFU:=abs(DY) div 5;

  if  Map.Map[X,Y].OFR>3 then Map.Map[X,Y].OFR:=3;
  if  Map.Map[X,Y].OFL>3 then Map.Map[X,Y].OFL:=3;
  if  Map.Map[X,Y].OFD>3 then Map.Map[X,Y].OFD:=3;
  if  Map.Map[X,Y].OFU>3 then Map.Map[X,Y].OFU:=3;

 end;
end;



end.
