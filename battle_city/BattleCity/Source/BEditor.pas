unit BEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Maps, ExtCtrls, eXgine, OpenGL, Render, edit, Menus;


type
  TForm2 = class(TForm)
    Panel1: TPanel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    Timer1: TTimer;
    ComboBox1: TComboBox;
    SaveDialog1: TSaveDialog;
    Panel2: TPanel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    OpenDialog1: TOpenDialog;
    N7: TMenuItem;
    N8: TMenuItem;
    procedure N7Click(Sender: TObject);
    procedure N2Click(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure Panel2Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Timer1Timer(Sender: TObject);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

procedure Render;
var i,j:integer;
begin

 ogl.Clear;
 ogl.Set2D(0,0,512,384);
 glViewPort(0,0,512,384);


 for i := 0 to 15 do
 for j := 0 to 10 do
  if Map.Map[i,j].Kind<>BNONE then
   with map.map[i,j] do
   DrawBr(Textures[Kind],i*32,j*32,OFR,OFL,OFD,OFU);
   


 glEnable(GL_BLEND);
 ogl.Blend(BT_ADD);

 glBegin(GL_LINES);
  glColor4f(0,1,0,0.5);
  for i := 1 to 15 do
  begin
   glVertex2f(i*32,0);
   glVertex2f(i*32,384-32);
  end;
  for i := 1 to 11 do
  begin
   glVertex2f(0,i*32);
   glVertex2f(512,i*32);
  end;

 glDisable(GL_BLEND);
  glColor4f(1,1,1,1);
 glEnd;

end;

procedure TForm2.FormCreate(Sender: TObject);
var i,j:integer;
begin
  Map.Singleplayer:=true;
  OpenDialog1.InitialDir:=ExtractFilePAth(Paramstr(0));
  SaveDialog1.InitialDir:=ExtractFilePAth(Paramstr(0));
  wnd.Create(Panel1.Handle);
  eX.SetProc(PROC_RENDER, @Render);
  showcursor(true);
  LoadTextures;
  combobox1.ItemIndex:=0;
 for i := 0 to 15 do
 for j := 0 to 10 do
  Map.Map[i,j].kind := BNONE;
end;

procedure TForm2.N2Click(Sender: TObject);
begin
 if SaveDialog1.Execute then SaveToFile(Map,SaveDialog1.FileName);
end;

procedure TForm2.N3Click(Sender: TObject);
begin
 if OpenDialog1.Execute then LoadFromFile(Map,OpenDialog1.FileName);
end;

procedure TForm2.N4Click(Sender: TObject);
begin
 Close;
end;

procedure TForm2.N7Click(Sender: TObject);
var i,j:integer;
begin
 for i:=0 to 15 do
  for j := 0 to 10 do
 map.Map[i,j].Kind:=BNONE;
end;

procedure TForm2.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 if Y>384-32 then exit;

 CX:=x;
 CY:=y;
 DX:=0;
 DY:=0;
 LX:=X;
 LY:=Y;
 
 if button=mbLeft then btn:=0
  else btn:=1;
 PClick(X div 32, Y div 32);
 MDOWN:=true;
 eX.Render;
end;

procedure TForm2.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
 if not SizeEdit then
 begin
  if y>384-32 then exit;
  
  LX:=X;
  LY:=Y;
 end;

 if SizeEdit and MDOWN then
  begin
   DX:=CX-X;
   DY:=CY-Y;
  end;
 
 if MDOWN then PClick(LX div 32, LY div 32);
end;

procedure TForm2.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 MDOWN:=false;
end;

procedure TForm2.Panel2Click(Sender: TObject);
begin
 SizeEdit:=not SizeEdit;
 if SizeEdit then Panel2.BevelOuter:=bvLowered
  else Panel2.BevelOuter:=bvRaised;
  
end;

procedure TForm2.RadioButton1Click(Sender: TObject);
begin
 Map.Singleplayer:=true;
end;

procedure TForm2.RadioButton2Click(Sender: TObject);
begin
 Map.Singleplayer:=false;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
 eX.Render;
end;

end.
