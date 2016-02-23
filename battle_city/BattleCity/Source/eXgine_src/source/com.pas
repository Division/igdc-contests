unit com;

interface

uses
  Windows;

// Engine
type
  TProcRender  = procedure;
  TProcUpdate  = procedure;
  TProcMessage = procedure (Msg: Cardinal; wP, lP: Integer);
  TProcActive  = procedure (Active: Boolean);

const
  PROC_UPDATE  = 0;
  PROC_RENDER  = 1;
  PROC_MESSAGE = 2;
  PROC_ACTIVE  = 3;

// Input
type
  TPoint = record
    X, Y : Integer;
  end;
  
const
// לûרü
  M_WHEEL  = 256;
  M_BTN_L  = 257;
  M_BTN_R  = 258;
  M_BTN_M  = 259;
// הזמיסעטך
  J_BTN_L  = 260;
  J_BTN_R  = 261;
  J_BTN_U  = 262;
  J_BTN_D  = 263;
  J_BTN_1  = 264;
  J_BTN_2  = 265;
  J_BTN_3  = 266;
  J_BTN_4  = 267;
  J_BTN_5  = 268;
  J_BTN_6  = 269;
  J_BTN_7  = 270;
  J_BTN_8  = 271;
  J_BTN_9  = 272;
  J_BTN_10 = 273;
  J_BTN_11 = 274;
  J_BTN_12 = 275;
  J_BTN_13 = 276;
  J_BTN_14 = 277;
  J_BTN_15 = 278;
  J_BTN_16 = 279;

// Log
const
  MSG_NONE    = $00000000;
  MSG_ERROR   = $00000010;
  MSG_INFO    = $00000040;
  MSG_WARNING = $00000030;

// OpenGL
type
  TFont      = Cardinal;
  TBlendType = Integer;  // BT
const
  BT_NONE = 0;
  BT_SUB  = 1;
  BT_ADD  = 2;
  BT_MULT = 3;

// Texture
type
  TTexture   = Cardinal;
  TTexMode   = Integer;  // TM
const
// Texture Mode
  TM_COLOR = 1;
  TM_DEPTH = 2;
// Filter Type
  FT_NONE       = 0;
  FT_BILINEAR   = 1;
  FT_TRILINEAR  = 2;
  FT_ANISOTROPY = 3;

// Shader
type
  TShader    = Integer;
  TShAttrib  = Integer;
  TShUniform = Integer;
const
  ST_VERTEX   = 0;
  ST_FRAGMENT = 1;

// VBuffer
type
  TVBOid   = Integer;
const
  VBO_INDEX     = 0;
  VBO_VERTEX    = 1;
  VBO_NORMAL    = 2;
  VBO_COLOR     = 3;
  VBO_TEXCOORD  = 4;
  VBO_TEXCOORD1 = 4;
  VBO_TEXCOORD2 = 5;

// Sound
type
  TSound     = Integer;
  TChannel   = Integer;

// Vector
type
  TVector = record
    X, Y, Z : Single;
  end;

  TVector2D = record
    X, Y : Single;
  end;

const
  deg2rad = pi / 180;
  rad2deg = 180 / pi;

// other
type
  TRGB = record
    R, G, B : Byte;
  end;

  TRGBA = record
    R, G, B, A : Byte;
  end;

  ILog = interface
    function  Create(FileName: PChar): Boolean; 
    procedure Print(Text: PChar); 
    function  Msg(Caption, Text: PChar; ID: Cardinal = 0): Integer; 
    procedure TimeStamp(Active: Boolean = True);
    procedure Flush(Active: Boolean = True);
    procedure Free; 
  end;

  IWindow = interface
    function  Create(Caption: PChar; OnTop: Boolean = True): Boolean; overload;
    function  Create(Handle: Cardinal): Boolean; overload;
    function  Handle: Cardinal; 
    procedure Caption(Text: PChar); 
    function  Width: Integer; 
    function  Height: Integer; 
    function  Mode(FullScreen: Boolean; W, H, BPP, Freq: Integer): Boolean; 
    procedure Show(Minimized: Boolean); 
    function  Active: Boolean; 
  end;

  IInput = interface
    procedure Reset; 
    function  Down(Key: Integer): Boolean;
    function  LastKey: Integer;
    function  MDelta: TPoint; 
    function  WDelta: Integer; 
    procedure MCapture(Active: Boolean); 
  end;

  IOpenGL = interface
    function  FPS: Integer;
    procedure VSync(Active: Boolean); overload;
    function  VSync: Boolean; overload;
    procedure Clear(Color: Boolean = True; Depth: Boolean = False; Stencil: Boolean = False);
    procedure Swap;
    procedure AntiAliasing(Samples: Integer); overload;
    function  AntiAliasing: Integer; overload;
    procedure Set2D(x, y, w, h: Single);
    procedure Set3D(FOV, zNear, zFar: Single);
    procedure LightPos(ID: Integer; X, Y, Z: Single);
    procedure LightColor(ID: Integer; R, G, B: Single);
    function  FontCreate(Name: PChar; W, H: Integer): TFont;
    procedure FontFree(Font: TFont);
    procedure TextOut(Font: TFont; X, Y: Integer; Text: PChar);
    procedure Blend(BType: TBlendType);
    function  ScreenShot(FileName: PChar): Boolean;
  end;

  IVBuffer = interface
    procedure Clear;
    procedure Add(DataType: Cardinal; Count: Cardinal; Data: Pointer);
    function  Compile: TVBOid;
    procedure Free(ID: TVBOid);
    procedure Offset(ID: TVBOid; DataType: Cardinal; Offset: Cardinal);
    procedure Render(ID: TVBOid; mode: Cardinal; Count: Integer = 0);
  end;

  ITexture = interface
    function  Create(Name: PChar; c, f, W, H: Integer; Data: Pointer; Clamp: Boolean = False; MipMap: Boolean = True; Group: Integer = 0): TTexture;
    function  Load(FileName: PChar; Clamp: Boolean = False; MipMap: Boolean = True; Group: Integer = 0): TTexture; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; Clamp: Boolean = False; MipMap: Boolean = True; Group: Integer = 0): TTexture; overload;
    function  Load(FileName: PChar; var W, H, BPP: Integer; var Data: Pointer): Boolean; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; var W, H, BPP: Integer; var Data: Pointer): Boolean; overload;
    procedure Free(var Data: Pointer); overload;
    procedure Free(ID: TTexture); overload;
    procedure Enable(ID: TTexture; Channel: Integer = 0);
    procedure Disable(Channel: Integer = 0);
    procedure Update_Begin(Group: Integer);
    procedure Update_End(Group: Integer);
    procedure Filter(FilterType: Integer; Group: Integer = 0);
    function  Render_Init(TexSize: Integer): Boolean;
    procedure Render_Copy(ID: TTexture; X, Y, W, H, Format: Integer; Level: Integer = 0);
    procedure Render_Begin(ID: TTexture; Mode: TTexMode = TM_COLOR);
    procedure Render_End;
  end;

  IShader = interface
    function  Create: TShader;
    procedure Free(Shader: TShader);
    function  Add(Shader: TShader; ShaderType: Integer; FileName: PChar): Boolean; overload;
    function  Add(Shader: TShader; ShaderType: Integer; Name: PChar; Mem: Pointer; Size: Integer): Boolean; overload;
    function  Link(Shader: TShader): Boolean;
    function  GetAttrib(Shader: TShader; Name: PChar): TShAttrib;
    function  GetUniform(Shader: TShader; Name: PChar): TShUniform;
    procedure Attrib(a: TShAttrib; x: Single); overload;
    procedure Attrib(a: TShAttrib; x, y: Single); overload;
    procedure Attrib(a: TShAttrib; x, y, z: Single); overload;
    procedure Uniform(u: TShUniform; x: Single); overload;
    procedure Uniform(u: TShUniform; x, y: Single); overload;
    procedure Uniform(u: TShUniform; x, y, z: Single); overload;
    procedure Uniform(u: TShUniform; i: Integer); overload;
    procedure Enable(Shader: TShader);
    procedure Disable;
  end;

  ISound = interface
    function  Load(FileName: PChar; Group: Integer = 0): TSound; overload;
    function  Load(Name: PChar; Mem: Pointer; Size: Integer; Group: Integer = 0): TSound; overload;
    function  Free(ID: TSound): Boolean;
    function  Play(ID: TSound; X, Y, Z: Single; Loop: Boolean = False): TChannel;
    procedure Stop(ID: TChannel);
    procedure Update_Begin(Group: Integer); 
    procedure Update_End(Group: Integer); 
    procedure Volume(Value: Integer); 
    procedure Freq(Value: Integer); 
    procedure Channel_Pos(ID: TChannel; X, Y, Z: Single); 
    procedure Pos(X, Y, Z: Single); 
    procedure Dir(dX, dY, dZ, uX, uY, uZ: Single); 
    procedure Factor_Pan(Value: Single = 0.1); 
    procedure Factor_Rolloff(Value: Single = 0.005); 
    procedure PlayFile(FileName: PChar; Loop: Boolean = False); 
    procedure StopFile; 
  end;

  IVector = interface
    function Create(X, Y, Z: Single): TVector; overload;
    function Create(X, Y: Single): TVector2D; overload;
    function Add(v1, v2: TVector): TVector; 
    function Sub(v1, v2: TVector): TVector; 
    function Mult(v: TVector; x: Single): TVector; 
    function Length(v: TVector): Single; 
    function LengthQ(v: TVector): Single; 
    function Normalize(v: TVector): TVector; 
    function Dot(v1, v2: TVector): Single; 
    function Cross(v1, v2: TVector): TVector; 
    function Angle(v1, v2: TVector): Single; 
  end;

  IEngine = interface
    function  log: ILog; 
    function  wnd: IWindow; 
    function  inp: IInput; 
    function  ogl: IOpenGL;
    function  vbo: IVBuffer;
    function  tex: ITexture; 
    function  vfp: IShader; 
    function  snd: ISound; 
    function  vec: IVector; 
    function  Version: PChar; 
    procedure SetProc(ID: Integer; Proc: Pointer);
    procedure ActiveUpdate(OnlyActive: Boolean);
    function  GetTime: Integer;
    procedure ResetTimer;
    procedure MainLoop(UPS: Integer);
    procedure Update;
    procedure Render;
    procedure Quit; 
  end;

type
  TInterface = class(TInterfacedObject)
    constructor CreateEx;
  end;

implementation

constructor TInterface.CreateEx;
begin
  inherited Create;
end;

end.
