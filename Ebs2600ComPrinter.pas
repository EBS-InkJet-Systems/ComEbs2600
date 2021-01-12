unit Ebs2600ComPrinter;
interface uses
  System.SysUtils, mpHelpers, System.Classes, mpComPort, mpAscii, WinProcs, Windows, Messages, Vcl.ExtCtrls;

//==============================================================================
type
  TEbs2600ComPrinter = class;
  TReceiveThread = class(TThread)
  private
    FModemStatus: Cardinal;
    FEventMask: cardinal;
    FTEbs2600ComPrinter: TEbs2600ComPrinter;
    procedure PortEvent;
    procedure InternalReceive;
  public
    ComHandle: THandle;
    CloseEvent: THandle;
    constructor Create(CreateSuspended: boolean);
    procedure Execute; override;
  end;
//==============================================================================

  TEbs2600ComPrinter = class(TComponent)
  private
    FComPort: TMpComPort;
    FReceiveThread: TReceiveThread;
    FSeparator: char;
    FOnDataAvailable: TNotifyEvent;
    function ToBytes(const AStr: string): TBytes;
    function TBytesToString(ABytes: TBytes): string;
    function GetFrame(AFields: TStrings): TBytes;

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Open;
    procedure Close;
    procedure SendToPrinter(const AData: TStrings); overload;
    procedure SendToPrinter(const AData: string); overload;
    function ReadStatus: string;

  published
    property ComPort: TMpComPort read FComPort;
    property Separator: char read FSeparator write FSeparator default ';';
    property OnDataAvailable: TNotifyEvent read FOnDataAvailable write FOnDataAvailable;
  end;
//==============================================================================
procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Ebs2600', [TEbs2600ComPrinter]);
end;
//==============================================================================
//THREAD========================================================================
//==============================================================================

procedure TReceiveThread.PortEvent;
var
   ComStat: TComStat;
   ErrorMask: cardinal;
begin
   ClearCommError(ComHandle, ErrorMask, @ComStat);
end;
//==============================================================================

procedure TReceiveThread.InternalReceive;
begin
   if not Assigned(FTEbs2600ComPrinter.OnDataAvailable) then Exit;
end;
//==============================================================================

constructor TReceiveThread.Create(CreateSuspended: boolean);
begin
   inherited;
   CloseEvent := CreateEvent(nil, True, False, nil);
end;
//==============================================================================

procedure TReceiveThread.Execute;
begin
  if Assigned(FTEbs2600ComPrinter.OnDataAvailable) then
    Synchronize( procedure
      begin
        FTEbs2600ComPrinter.OnDataAvailable(Self)
      end);
end;
//==============================================================================
//COMPRINTER====================================================================
//==============================================================================

constructor TEbs2600ComPrinter.Create(AOwner: TComponent);
begin
  inherited;
  FComPort := TMpComPort.Create(Self);
  FComPort.SetSubComponent(true);
  FSeparator := ';';
end;
//==============================================================================

destructor TEbs2600ComPrinter.Destroy;
begin
  FComPort.Free;
  inherited;
end;
//==============================================================================

procedure TEbs2600ComPrinter.SendToPrinter(const AData: string);
var
  AStrings: TStrings;
begin
  AStrings := TStringList.Create;
  try
    AStrings.Add(AData);
    SendToPrinter(AStrings);
  finally
    AStrings.Free;
  end;

end;
//==============================================================================

procedure TEbs2600ComPrinter.Open;
begin
  FComPort.Open;
  FReceiveThread := TReceiveThread.Create(True);
  //FReceiveThread.FreeOnTerminate := true;
end;
//==============================================================================


procedure TEbs2600ComPrinter.Close;
begin
  FComPort.Close;
end;
//==============================================================================

function TEbs2600ComPrinter.ReadStatus: string;
var
  AData: TBytes;

begin
  SetLength(AData, FComPort.RxCount);
  FComPort.Read(@AData,Length(AData));
  Result := TBytesToString(AData);
end;
//==============================================================================

procedure TEbs2600ComPrinter.SendToPrinter(const AData: TStrings);
var
  ABytes: TBytes;

begin
  if not FComPort.Opened then
     raise Exception.Create('Port is Closed!');

  ABytes := GetFrame(AData);
  FComPort.Write(ABytes);
end;
//==============================================================================

function TEbs2600ComPrinter.GetFrame(AFields: TStrings): TBytes;
var
  i : integer;

begin
  Result := [];

  for i:=0 to AFields.Count-1 do begin
    Result := Result + ToBytes(AFields[i]);

    if i < (AFields.Count-1) then
      Result := Result + [Byte(Separator)]
    else
      Result := Result + [ASCII_CR];

  end;

end;
//==============================================================================

function TEbs2600ComPrinter.ToBytes(const AStr: string): TBytes;
var
  i: Integer;

begin
  Result := [];
  for i:=1 to Length(AStr) do
    Result := Result + [Byte(AStr[i])];
end;
//==============================================================================

function TEbs2600ComPrinter.TBytesToString(ABytes: TBytes): string;
var
i: integer;

begin
  for i:=1 to Length(ABytes) do
   Result := Result + IntToHex(ABytes[i]);
end;

end.
