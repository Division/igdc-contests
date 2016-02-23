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
      
      // Брики

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
      BP1ST = 10;  // Рождение Плеера 1;
      BP2ST = 11;  // Рождение Плеера 2;
      BCOMST= 9;   // Рождение врагов

      // Проходимость

      PYES = 0; // Проходимая местность
      PONLYBULLETS = 1; // Пролетают патроны
      PNO = 2; // Не проходимо          

      CTANK=0;
      CPATR=1;

      RBACK=0;
      RFRONT=1;

      // Меню, игра
      
      SGAME=1;
      SMENU=0;

      SCRCOUNT=3;
      // Текст меню

      MENUTEXT:array[0..SCRCOUNT-1,0..3] of string = ( ('Старт','High Scores', 'О программе', 'Выход' ),
                                                     ('Один игрок', 'Два игрока', 'Схватка',       '' ),
                                                     ('Продолжить'     , 'Главное меню' , ''      ,''));

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

       MWINTEXT:array[0..1] of string = ('Победил игрок2!', 'Победил игрок1!');

       PARTCOUNTP=40;
       PARTCOUNTT=60;
       PARTPOWERP=0.2;// Коэф. умножения скорости частиц при взрыве патронов :)
       PARTPOWERT=0.7;// Тоже самое, но танков

       GAMEDELAY=3000; // Время между проигрышем и переходом в меню, между победой и следующим уровнем
       // Бонусы

       BONUSCOUNT=3;
       BONUS_SPEED=0;
       BONUS_HEALTHPLUS2=1;
       BONUS_PATRONSPEED=2;
       BONUS_DEFENCE=3;

       BONUS_STAYTIME=18000;

       LIFESCORE=5000; // Каждые LIFESCORE получаем жизнь

       PLAYERS_HEALTH=4;
var
    PTank1,PTank2:TTank;

    LastTime:integer;

    Map:TMap;

    GameParam:TGameParam;

    TEMP:String;


    // Текстуры

    TankTex  :array[0..3]  of TTexture;
    BrickTex :array[0..12] of TTexture;
    PatrTex  :array[0..2] of TTexture;
    BonusTex :array[0..BONUSCOUNT-1] of TTexture;
    LogoTex:TTexture;
    Back, Eagle : TTexture;

    Patron:PPatron;// Указатель на патроны
    PatrCount : integer = 0;// Количество
    Tank:PTank;//Указатель на танки врага
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
    EnemyCount:integer=0;// В данный момент врагов на карте 
    EnemyNeed:integer=0; // Сколько врагов на этот уровень
    PrevEnemyNeed:integer=0;
    AddStart:integer;
    GameOverStart:integer; // Время поражения игрока
    NextLevelStart:integer;// Время, в которое игрок убил последний танк

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
