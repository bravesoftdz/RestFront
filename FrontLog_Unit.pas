unit FrontLog_Unit;

interface

uses
  Front_DataBase_Unit, Classes, SysUtils, Forms;

{
��� ������ ����� ���:
1. ��� ������, ������ ��� ������ � �����, ����� ��� ���������. ����� ����� ��������� ��� �������?
2. ��� ��������.
3. ��� ������� ����.

�������� � ����� ������ ������ ������ � �� TFrontBase
��� ���������� ������ �����, ��� ���������� - �������.

 }
{type
  TFrontLogType = (LogIn, Exit, ErrorPass);     }

type
  TFrontLog = class(TObject)
  private
    FFrontBase: TFrontBase;
    FDoLog: Boolean;
    FLinesLimit: Integer;
    FLogToFile: Boolean;
    procedure SetFrontBase(const Value: TFrontBase);
  protected
    procedure WriteLogToBase(const Str: String; const UserKey: Integer);
    procedure WriteLogToFile(const Str: String; const UserKey: Integer);
  public
    constructor Create;
    destructor Destroy; override;
//    procedure WriteLog(const LogType: TFrontLogType; const Msg: String);
    property FrontBase: TFrontBase read FFrontBase write SetFrontBase;
  end;



const
  LogFileName = 'FrontLog.log';
  cn_l_LogIn = '���� � �������';
  cn_l_Exit = '����� �� �������';
  cn_l_ErrorPass = '�������� ������';

{const
  TLogText: array [TFrontLogType] of String =
  ('���� � �������', '����� �� �������', '�������� ������'
  );     }

procedure WriteLog(const FFrontBase: TFrontBase;
  const MsgType: String{TFrontLogType}; const Msg: String);

implementation

procedure WriteLogToBase(const Str: String; const UserKey: Integer);
begin
{ TODO -oAlexander : ����������� }
end;

procedure WriteLogToFile(const Str: String; const UserKey, LinesLimit: Integer);
var
  LStrings: TStrings;
  FullFileName: String;
  I: Integer;
begin
  try
    LStrings := TStringList.Create;
    try
      FullFileName := ExtractFileDir(Application.ExeName)+ '\' + LogFileName;
      if FileExists(FullFileName) then
        LStrings.LoadFromFile(FullFileName);
      LStrings.Add('----------------'#13#10 + DateTimeToStr(Now) + #13#10 +
        '������������: ' + IntToStr(UserKey) + #13#10 + Str);

      if (LinesLimit > 0) then
        for I := LStrings.Count - 1 downto LinesLimit do
          LStrings.Delete(0);
      try
        LStrings.SaveToFile(FullFileName);
      except
      end;
    finally
      LStrings.Free;
    end;
  except
    // ����� ��
  end;
end;

procedure WriteLog(const FFrontBase: TFrontBase;
  const MsgType: String {TFrontLogType}; const Msg: String);
var
  Str: String;
  UserKey: Integer;
begin
  if Assigned(FFrontBase) then
  begin
    if FFrontBase.Options.DoLog then
    begin
      // ���������� ���������
      Str := MsgType;
  //    Str := TLogText[LogType];
      if Msg <> '' then
        Str := Str + ' ' + Msg;
      UserKey := FFrontBase.ContactKey;
      if FFrontBase.Options.LogToFile then
        WriteLogToFile(Str, UserKey, FFrontBase.Options.LinesLimit)
      else
        WriteLogToBase(Str, UserKey);
    end;
  end;  
end;

{ TFrontLog }

constructor TFrontLog.Create;
begin
  FFrontBase := nil;
end;

destructor TFrontLog.Destroy;
begin
//
  inherited;
end;

procedure TFrontLog.SetFrontBase(const Value: TFrontBase);
begin
  FFrontBase := Value;
end;

{procedure TFrontLog.WriteLog(const LogType: TFrontLogType;
  const Msg: String);
begin
//
end;  }

procedure TFrontLog.WriteLogToBase(const Str: String;
  const UserKey: Integer);
begin
//
end;

procedure TFrontLog.WriteLogToFile(const Str: String;
  const UserKey: Integer);
begin
//
end;

end.
