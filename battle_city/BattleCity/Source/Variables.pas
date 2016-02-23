unit Variables;

interface

uses eXgine, Game;

const DLEFT=0;
      DRIGHT=1;
      DTOP=2;
      DDOWN=3;

      AROTATE=4;
      AMOVE=5;
      ANONE=255;
      AFIRE=6;
      DIRANGLES : array[0..3] of integer = (270,90,0,180);

      UPS=30; // Updates per second
      BSIZE=64;
      
      // �����

      BNONE = -1;       // ������ �����
      BSIMPLE1 =0 ;    // �����������, ������
      BSIMPLE2 = 1;   // �����������, ��� �� ��������
      BWATER = 2;    // �������������, ������������, ���������� �������
      BWEB1=3;      // �������������, ����������, ��� ������� �����
      BWEB2=4;      // �� �� �����
      BSTRONG1=5;   // �������������, ������������
      BSTRONG2=6;   // �� �� �����, �������� ������
      BEAGLE1 = 7; // ���, �� ���� ��� ����� :)
      BEAGLE2 = 8; // ����� Deathmatch �������?
      BP1ST = 10;  // �������� ������ 1;
      BP2ST = 11;  // �������� ������ 2;
      BCOMST= 9;   // �������� ������

      // ������������

      PYES = 0; // ���������� ���������
      PONLYBULLETS = 1; // ��������� �������
      PNO = 2; // �� ���������          

      CTANK=0;
      CPATR=1;

      RBACK=0;
      RFRONT=1;

      // ����, ����
      
      SGAME=1;
      SMENU=0;

      SCRCOUNT=3;
      // ����� ����

      MENUTEXT:array[0..SCRCOUNT-1,0..3] of string = ( ('�����','High Scores', '� ���������', '�����' ),
                                                     ('���� �����', '��� ������', '�������',       '' ),
                                                     ('����������'     , '������� ����' , ''      ,''));

      MENUCOUNT:array[0..2] of byte = (4,3,2);


      EMPTYBRICK:TBrick=(Kind   : 0;
                         OFR    : 0;
                         OFL    : 0;
                         OFD    : 0;
                         OFU    : 0;
                         Tex    : 0;
                         CanHit : false);

       RESNEED=4000;
       ADDNEED=3000;

       MWINTEXT:array[0..1] of string = ('������� �����2!', '������� �����1!');

       PARTCOUNTP=40;
       PARTCOUNTT=60;
       PARTPOWERP=0.2;// ����. ��������� �������� ������ ��� ������ �������� :)
       PARTPOWERT=0.7;// ���� �����, �� ������

       GAMEDELAY=3000; // ����� ����� ���������� � ��������� � ����, ����� ������� � ��������� �������
       // ������

       BONUSCOUNT=3;
       BONUS_SPEED=0;
       BONUS_HEALTHPLUS2=1;
       BONUS_PATRONSPEED=2;
       BONUS_DEFENCE=3;

       BONUS_STAYTIME=18000;

       LIFESCORE=5000; // ������ LIFESCORE �������� �����

       PLAYERS_HEALTH=4;
var
    PTank1,PTank2:TTank;

    LastTime:integer;

    Map:TMap;

    GameParam:TGameParam;

    TEMP:String;


    // ��������

    TankTex  :array[0..3]  of TTexture;
    BrickTex :array[0..12] of TTexture;
    PatrTex  :array[0..2] of TTexture;
    BonusTex :array[0..BONUSCOUNT-1] of TTexture;
    LogoTex:TTexture;
    Back, Eagle : TTexture;

    Patron:PPatron;// ��������� �� �������
    PatrCount : integer = 0;// ����������
    Tank:PTank;//��������� �� ����� �����
    TankCount : integer = 0;

    Menu:TMenu;

    SelectedLevel:integer=1;

    P1STX,P1STY,P2STX,P2STY:integer;

    P1Score:integer = 0;
    P2Score:integer = 0;
    GScore:integer;
    LastScore1,LastScore2:integer;
    EagleX,EagleY,Eagle2X,Eagle2Y:integer;

    ResTimer : array[1..2] of integer = (RESNEED,RESNEED);
    EnemyStart : array of TPoint;
    EnemyStartCount:integer=0;
    EnemyCount:integer=0;// � ������ ������ ������ �� ����� 
    EnemyNeed:integer=0; // ������� ������ �� ���� �������
    PrevEnemyNeed:integer=0;
    AddStart:integer;
    GameOverStart:integer; // ����� ��������� ������
    NextLevelStart:integer;// �����, � ������� ����� ���� ��������� ����

    GameIsOver:boolean;

    DEagle:integer;

    CurLevel:integer;

    P1LIVES,P2LIVES:byte;

    Bonus:TBonus;

    Scores:TScores;

    Ang:single;

    PlayerName:string;
implementation


end.
