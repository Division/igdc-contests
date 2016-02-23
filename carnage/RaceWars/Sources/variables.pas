unit variables;

interface

uses dConsole,
     dMap,
     l_math,
     dCamera,
     dCars,
     eXgine,
     dAnimation,
     dGameManager,
     dShaderMan,
     dMenu,
     dSky,
     dParticleSystem,
     dWeapons;

const UPS = 40;

var dt:single;

    MODEL_MATRIX : TMatrix;

    Console:TConsole;

    LastTime,CurTime:integer;

    Map:TMap;
    Camera:TCamera;

    GarbageMeshes : array[0..3] of TOTModel;

    CarMeshes : array[0..5] of TOTModel;
    ObjMeshes : array[0..22] of TOTModel;

    WeaponModels : array[0..2] of TOTModel;
    CartridgeModels : array[0..2] of TOTModel;
    CursorMesh : TOTModel;

    CarColl : array of PBasicCar;

    GameManager:TGameManager;

    Menu : TMenu;

    tc : TTexture;

    ShowFPS : integer = 1;

    ObjRender : integer;

    sFont:TFont;

    SUNLIGHT_POWER : single = 1;

    ParticleSystem : TParticleSystem;

    Sky : TSky;
implementation

end.
