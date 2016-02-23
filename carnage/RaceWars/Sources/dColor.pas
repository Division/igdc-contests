unit dColor;

interface

type
  TColor4 = record
    case Integer of
      0: (Items : array[0..3] of Single); 
      1: (r,g,b,a : single);
  end;

  TColor3 = record
    case Integer of
      0: (Items : array[0..2] of Single);
      1: (r,g,b : single);
  end;

  TColorIData = record
    Color : TColor4;
    Time : Single;
  end;

  TColorInterp = class
    destructor Destroy; override;
    private
      fColors : array of TColorIData;
      fColorCount : integer;
      function NumInterp(v1,v2,t1,t2,time : single) : single;
    public
      procedure AddColor4(Color : TColor4; Time : Single);
      function GetColor(Time : Single) : TColor4;
  end;

  TCIManager = class
    destructor Destroy; override;
    private
      fInterps : array of TColorInterp;
      fInterpCount : integer;
    public
      function AddInterp : TColorInterp;
      function GetColor(index:integer; time : Single) : TColor4;
  end;
function Color4(r,g,b,a:Single) : TColor4;

const ZeroColor : TColor4 = (r:0; g:0; b:0; a:0);

implementation

function Color4(r,g,b,a:Single) : TColor4;
begin
  Result.r := r;
  Result.g := g;
  Result.b := b;
  Result.a := a;
end;

{$REGION 'ColorInterp'}
destructor TColorInterp.Destroy;
begin
  fColors := nil;
  inherited;
end;

function TColorInterp.NumInterp(v1: Single; v2: Single; t1: Single; t2: Single; time: Single) : single;
begin
  Result := v1 + (v2 - v1) * (time - t1) / (t2 - t1);
end;

procedure TColorInterp.AddColor4(Color : TColor4; Time : Single);
begin
  inc(fColorCount);
  SetLength(fColors, fColorCount);
  fColors[fColorCount - 1].Color := Color;
  fColors[fColorCount - 1].Time := Time;
end;

function TColorInterp.GetColor(Time : Single) : TColor4;
var i,j:integer;
    Res:TColor4;
begin
  if fColorCount = 0 then
    begin
      Result := ZeroColor;
      Exit;
    end;
  if (fColorCount = 1) or (Time <= fColors[0].Time) then
    begin
      Result := fColors[0].Color;
      Exit;
    end;

  for i := 0 to fColorCount - 1 do
    if Time <= fColors[i].Time then
      begin
        for j := 0 to 3 do
          begin
            Res.Items[j] := NumInterp(fColors[i-1].Color.Items[j],fColors[i].Color.Items[j],fColors[i-1].Time,fColors[i].Time,Time); 
          end;
        Result := Res;
        Exit;
      end;
  Result := ZeroColor;
end;
{$ENDREGION}

{$REGION 'CIManager'}
destructor TCIManager.Destroy;
var i:integer;
begin
  for i := 0 to fInterpCount - 1 do
    fInterps[i].Destroy;
  fInterps := nil;
end;
         
function TCIManager.AddInterp;
begin
  inc(fInterpCount);
  SetLength(fInterps,fInterpCount);
  fInterps[fInterpCount - 1] := TColorInterp.Create;
  Result := fInterps[fInterpCount - 1];
end;

function TCIManager.GetColor(index: Integer; time: Single) : TColor4;
begin
  if (index > fInterpCount -1) or (index < 0)  then
    begin
      Result := ZeroColor;
      Exit;
    end;

  Result := fInterps[index].GetColor(time);
end;
{$ENDREGION}
end.


