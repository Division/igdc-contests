unit variables;

interface

uses dParticlesQ,
     dConsole,
     dMap,
     dCamera,
     dCars,
     eXgine,
     dMeshes,
     dGameManager,
     dMenu;

const UPS = 40;

var dt:single;
    PartEng:TParticleEngine;

    Console:TConsole;

    LastTime,CurTime:integer;

    Map:TMap;
    Camera:TCamera;

    CarMeshes : array[0..5] of TMesh;

    ObjMeshes : array[0..22] of TMesh;

    CarColl : array of PBasicCar;

    GameManager:TGameManager;

    Menu : TMenu;

    tc : TTexture;

    ShowFPS : integer = 0;

    ObjRender : integer;

    sFont:TFont;
implementation

end.
