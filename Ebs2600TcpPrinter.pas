unit Ebs2600TcpPrinter;

interface

uses
  System.SysUtils, IdTCPClient, IdTCPServer, System.Classes, IdGlobal, System.JSON;

type
  Tbs2600TcpPrinter = class;
  Tbs2600TcpPrinter = class(TComponent)
  private
    FIdTCPClient: TIdTCPClient;
    //JSonObject:TJSonObject;
    //JSonValue:TJSonValue;
    FPort: TIdPort;
    FHost: string;
    function CreateCmd(CMD: integer): string; overload;
    function CreateCmd(CMD: integer; Add: boolean): string; overload;
    function CreateCmd(CMD: integer; ProjectPath: string): string; overload;
    procedure SetConnection;
    procedure Send(Cmd: string);

    procedure SetHost(const Value: string);
    procedure SetPort(const Value: TIdPort);
  protected

  public
    GetData: TIdBytes;
    procedure Connect;
    procedure Disconnect;
    procedure CheckStatus;
    procedure CheckAutostartStatus;
    procedure ToggleAutostartStatus(Autostart: boolean);
    procedure PrintOn(Autostart: boolean);
    procedure PrintOff;
    procedure OpenExistingProject(Projectpath: string);
    procedure TurnOffSystem;
    procedure RestartSystem;
    function Read: TIdBytes;
    function IsConnected: boolean;

  published

    property IdTCPClient: TIdTCPClient read FIdTCPClient;
    property Host: string read FHost write SetHost;
    property Port: TIdPort read FPort write SetPort;

  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Ebs2600', [Tbs2600TcpPrinter]);
end;

{ Tbs2600TcpPrinter }

procedure Tbs2600TcpPrinter.Connect;
begin
  FIdTCPClient := TIdTCPClient.Create;
  FIdTCPClient.ConnectTimeout := 500;
  FIdTCPClient.ReadTimeout := 500;
  try
    FIdTCPClient.Connect(Host,Port);
  except
    raise Exception.Create('Connection Error');
  end;
end;
//==============================================================================

function Tbs2600TcpPrinter.IsConnected: boolean;
begin
  Result := FIdTCPClient.Connected;
end;

procedure Tbs2600TcpPrinter.SetHost(const Value: string);
begin
  FHost := Value;
end;
//==============================================================================

procedure Tbs2600TcpPrinter.SetPort(const Value: TIdPort);
begin
  FPort := Value;
end;
//==============================================================================
//===========================JSON===============================================

function Tbs2600TcpPrinter.CreateCmd(CMD: integer): string;
begin
  Result := '{"CMD":'+inttostr(CMD)+'}';
end;
//==============================================================================

function Tbs2600TcpPrinter.CreateCmd(CMD: integer; Add: boolean): string;
var
value: integer;
begin
  if Add then value:=1 else value:=0;
    case CMD of
      30: Result := '{"CMD":'+inttostr(CMD)+',"ForcePrint":'+inttostr(value)+'}';
      22: Result := '{"CMD":'+inttostr(CMD)+',"Autostart":'+inttostr(value)+'}';
    end;
end;
//==============================================================================

function Tbs2600TcpPrinter.CreateCmd(CMD: integer; ProjectPath: string): string;
begin
   Result := '{"CMD":'+inttostr(CMD)+',"ProjectPath":"'+ProjectPath+'"}';
end;
//==============================================================================

procedure Tbs2600TcpPrinter.Send(Cmd: string);
begin
  try
    FIdTCPClient.IOHandler.WriteLn(Cmd);
  except
    raise Exception.Create('Send Cmd Error');
  end;
end;
//==============================================================================

procedure Tbs2600TcpPrinter.Disconnect;
begin
  try
    FIdTCPClient.Disconnect;

  except
    raise Exception.Create('Disconnection Error');
  end;
  //FIdTCPClient.IOHandler.Close;
  //FIdTCPClient.IOHandler.DiscardAll;
  //FIdTCPClient.IOHandler.Destroy;
  //FIdTCPClient.Destroy;
end;

//==============================================================================

function Tbs2600TcpPrinter.Read: TIdBytes;
begin
  try
    FIdTCPClient.IOHandler.ReadBytes(Result, -1, false);
  except
    raise Exception.Create('Read Error');
  end;
end;
//==============================================================================

procedure Tbs2600TcpPrinter.CheckStatus;
var
 CMD: integer;
begin
  CMD := 20;
  Connect;
  Send(CreateCmd(CMD));
  GetData := Read;
  Disconnect;
end;

//==============================================================================
procedure Tbs2600TcpPrinter.CheckAutostartStatus;
var
  CMD: integer;
begin
  CMD := 21;
  Connect;
  Send(CreateCmd(CMD));
  GetData := Read;
  Disconnect;
end;

//==============================================================================
procedure Tbs2600TcpPrinter.ToggleAutostartStatus(Autostart: boolean);
var
  CMD: integer;
begin
  CMD := 22;
  Connect;
  Send(CreateCmd(CMD,Autostart));
  GetData := Read;
  Disconnect;
end;

//==============================================================================
procedure Tbs2600TcpPrinter.PrintOn(Autostart: boolean);
var
  CMD: integer;
begin
  CMD := 30;
  Connect;
  Send(CreateCmd(CMD,Autostart));
  GetData := Read;
  Disconnect;
end;

//==============================================================================
procedure Tbs2600TcpPrinter.PrintOff;
var
  CMD: integer;
begin
  CMD := 31;
  Connect;
  Send(CreateCmd(CMD));
  GetData := Read;
  Disconnect;
end;

//==============================================================================
procedure Tbs2600TcpPrinter.OpenExistingProject(Projectpath: string);
var
  CMD: integer;
begin
  CMD := 11010;
  Connect;
  Send(CreateCmd(CMD,Projectpath));
  GetData := Read;
  Disconnect;
end;

//==============================================================================
procedure Tbs2600TcpPrinter.TurnOffSystem;
var
  CMD: integer;
begin
  CMD := 30000;
  Connect;
  Send(CreateCmd(CMD));
  GetData := Read;
  Disconnect;
end;

//==============================================================================
procedure Tbs2600TcpPrinter.RestartSystem;
var
  CMD: integer;
begin
  CMD := 30001;
  Connect;
  Send(CreateCmd(CMD));
  GetData := Read;
  Disconnect;
end;

end.
