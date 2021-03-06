unit Modification_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, kbmMemTable, DB, Front_DataBase_Unit, Contnrs,
  ActnList, AdvPanel, FrontData_Unit, AdvSmoothButton, AdvStyleIF,
  AdvSmoothToggleButton, BaseFrontForm_Unit, RKCardCodeForm_Unit, GestureMgr;

const
  btnHeight = 51;
  btnWidth = 145;

type
  TModificationForm = class(TBaseFrontForm)
    pnlTop: TAdvPanel;
    lbExtraModificator: TLabel;
    plnRight: TAdvPanel;
    pnlMain: TAdvPanel;
    aclModify: TActionList;
    actOK: TAction;
    actCancel: TAction;
    btnOK: TAdvSmoothButton;
    btnCancel: TAdvSmoothButton;
    btnInputMod: TAdvSmoothButton;
    lbCaption: TLabel;
    btnScrollUp: TAdvSmoothButton;
    btnScrollDown: TAdvSmoothButton;
    actGoodUp: TAction;
    actGoodDown: TAction;
    gmModficator: TGestureManager;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actCancelUpdate(Sender: TObject);
    procedure btnInputModClick(Sender: TObject);
    procedure actGoodUpExecute(Sender: TObject);
    procedure actGoodDownExecute(Sender: TObject);
    procedure actGoodUpUpdate(Sender: TObject);
    procedure actGoodDownUpdate(Sender: TObject);
  private
    FModificationTable: TkbmMemTable;
    FLineModifyTable: TkbmMemTable;
    FFrontBase: TFrontBase;
    FGoodKey: Integer;
    FModifyGroupKey: Integer;
    FIsEmptyLine: Boolean;
    //
    FFirstTopButton          : Integer;
    FLastLeftButton          : Integer;
    FLastTopButton           : Integer;
    FModificationButtonNumber: Integer;
    //
    FButtonList : TObjectList;
    FGoodName: String;
    FExtraModifyString: String;

    procedure SetFrontBase(Value: TFrontBase);

    procedure CreateModificationButtonList;
    procedure CheckModificationButtonList;
    procedure AddModificationButton;
    procedure SetLineModifyTable(const Value: TkbmMemTable);

    procedure ModifyButtonOnClick(Sender: TObject);
    procedure SetGoodName(const Value: String);
    procedure SetExtraModifyString(const Value: String);
    procedure ScrollControl(const FControl: TWinControl; const Down: Boolean;
      var Top: Integer; var Bottom: Integer);
  public
    property FrontBase: TFrontBase read FFrontBase write SetFrontBase;
    //���� ����������� ����������, �� ������� GoodKey
    property GoodKey: Integer read FGoodKey write FGoodKey;
    //����� MODIFYGROUPKEY
    property ModifyGroupKey: Integer read FModifyGroupKey write FModifyGroupKey;
    //
    property LineModifyTable: TkbmMemTable read FLineModifyTable write SetLineModifyTable;
    property GoodName: String read FGoodName write SetGoodName;
    property ExtraModifyString: String read FExtraModifyString write SetExtraModifyString;

    constructor CreateWithFrontBase(AOwner: TComponent; FBase: TFrontBase);

  end;

var
  ModificationForm: TModificationForm;

implementation

{$R *.dfm}

{ TModificationForm }

constructor TModificationForm.CreateWithFrontBase(AOwner: TComponent;
  FBase: TFrontBase);
begin
  inherited Create(AOwner);
  FrontBase := FBase;

  FFirstTopButton := 8;
  FLastLeftButton := 8;
  FLastTopButton  := 8;
  FModificationButtonNumber := 1;
  FExtraModifyString := '';

  FModificationTable := TkbmMemTable.Create(nil);
  FModificationTable.FieldDefs.Add('ID', ftInteger, 0);
  FModificationTable.FieldDefs.Add('NAME', ftString, 40);
  FModificationTable.CreateTable;
  FModificationTable.Open;

  FGoodKey := -1;
  FModifyGroupKey := -1;
  FIsEmptyLine := True;

  FButtonList := TObjectList.Create;

  btnScrollUp.Picture := FrontData.RestPictureContainer.FindPicture('Up');
  btnScrollDown.Picture := FrontData.RestPictureContainer.FindPicture('Down');
end;

procedure TModificationForm.ScrollControl(const FControl: TWinControl;
  const Down: Boolean; var Top, Bottom: Integer);
var
  Step: Integer;
begin
  Step := 0;
  if Down then
  begin
    while (Step < btnHeight + 8) and (Bottom + btnHeight > FControl.Height) do
    begin
      FControl.ScrollBy(0, -1);

      Dec(Bottom);
      Inc(Top);
      Inc(Step);
    end;
  end else
  begin
    while (Step < btnHeight + 8) and (Top > 8) do
    begin
      FControl.ScrollBy(0, 1);

      Inc(Bottom);
      Dec(Top);
      Inc(Step);
    end;
  end;
end;

procedure TModificationForm.SetExtraModifyString(const Value: String);
begin
  FExtraModifyString := Value;
  if Value <> '' then
    lbExtraModificator.Caption := '  �������������� �����������: ' + FExtraModifyString;
end;

procedure TModificationForm.SetFrontBase(Value: TFrontBase);
begin
  FFrontBase := Value;
end;

procedure TModificationForm.SetGoodName(const Value: String);
begin
  FGoodName := Value;
  lbCaption.Caption := '������������ ���: ' + FGoodName;
end;

procedure TModificationForm.AddModificationButton;
var
  FButton: TAdvSmoothToggleButton;
begin
  //�������� ������
  FButton := TAdvSmoothToggleButton.Create(Self);
  FButton.Appearance.BeginUpdate;
  try
    FButton.Parent := pnlMain;
    FButton.OnClick := ModifyButtonOnClick;
    FButton.Name := Format('btnModification%d', [FModificationButtonNumber]);
    FButton.GroupIndex := FModificationButtonNumber;
    FButton.Height := btnHeight;
    FButton.Width  := btnWidth;
    FButton.Appearance.Font.Name := cn_FontType;
    FButton.Appearance.Font.Size := cn_ButtonFontSize;
  //  FButton.BevelWidth := 1;
  //  FButton.BevelColor := clBlack;
  //  FButton.SetComponentStyle(tsOffice2007Silver);
    SetButtonStyle(FButton);
    //���������, ���� �� ��� ����� � ����
    if (FLastLeftButton + btnWidth) > pnlMain.Width then
    begin
      FLastTopButton := FLastTopButton + btnHeight + 8;
      FLastLeftButton := 8;

      FButton.Left := FLastLeftButton;
      FButton.Top  := FLastTopButton;
    end else
    begin
      FButton.Left := FLastLeftButton;
      FButton.Top  := FLastTopButton;
    end;

    FButton.Tag := FModificationTable.FieldByName('ID').AsInteger;
    FButton.Caption := FModificationTable.FieldByName('NAME').AsString;

    FLastLeftButton := FLastLeftButton + btnWidth + 10;
  finally
    FButton.Appearance.EndUpdate;
  end;
  FButtonList.Add(FButton);
  Inc(FModificationButtonNumber);
end;

procedure TModificationForm.btnInputModClick(Sender: TObject);
var
  FForm: TRKCardCode;
begin
  FForm := TRKCardCode.Create(nil);
  FForm.NeedPassWordChar := False;
  try
    FForm.ShowModal;
    if FForm.ModalResult = mrOk then
    begin
      FExtraModifyString := FForm.InputString;
      lbExtraModificator.Caption := '  �������������� �����������: ' + FExtraModifyString;
    end;
  finally
    FForm.Free;
  end;
end;

procedure TModificationForm.CreateModificationButtonList;
begin
  FModificationTable.First;
  while not FModificationTable.Eof do
  begin
    AddModificationButton;

    FModificationTable.Next;
  end;
end;

procedure TModificationForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  FModificationTable.Free;
  FButtonList.Free;
end;

procedure TModificationForm.FormShow(Sender: TObject);
begin
  Assert(FLineModifyTable <> nil, 'LineModifyTable not assigned');

  if Assigned(FFrontBase) then
    if FrontBase.GetModificationList(FModificationTable, GoodKey, ModifyGroupKey) then
    begin
      CreateModificationButtonList;
      CheckModificationButtonList;
    end;
end;

procedure TModificationForm.SetLineModifyTable(const Value: TkbmMemTable);
begin
  FLineModifyTable := Value;
  try
    FLineModifyTable.StartTransaction;
  except
    raise;
  end;
  FIsEmptyLine := FLineModifyTable.IsEmpty;
end;

procedure TModificationForm.ModifyButtonOnClick(Sender: TObject);
begin
  if TAdvSmoothToggleButton(Sender).Down then
  begin
    if FModificationTable.Locate('ID', TAdvSmoothToggleButton(Sender).Tag, []) then
    begin
      FLineModifyTable.Append;
      FLineModifyTable.FieldByName('MODIFYKEY').AsInteger := FModificationTable.FieldByName('ID').AsInteger;
      FLineModifyTable.FieldByName('NAME').AsString := FModificationTable.FieldByName('NAME').AsString;
      FLineModifyTable.Post;
    end;
  end else
  begin
    if FLineModifyTable.Locate('MODIFYKEY', TAdvSmoothToggleButton(Sender).Tag, []) then
      FLineModifyTable.Delete;
  end;
end;

procedure TModificationForm.actOKExecute(Sender: TObject);
begin
  try
    FLineModifyTable.Commit;
  except
    Raise;
  end;
  ModalResult := mrOk;
end;

procedure TModificationForm.actOKUpdate(Sender: TObject);
begin
  if GoodKey <> -1 then
  begin
    actOK.Enabled := not FLineModifyTable.IsEmpty;
  end else
    actOK.Enabled := True;
end;

procedure TModificationForm.actCancelExecute(Sender: TObject);
begin
  if FIsEmptyLine then
  begin
    FLineModifyTable.First;
    while not FLineModifyTable.Eof do
      FLineModifyTable.Delete;
  end;
  try
    FLineModifyTable.Rollback;
  except
    Raise;
  end;

  ModalResult := mrCancel;
end;

procedure TModificationForm.actCancelUpdate(Sender: TObject);
begin
  //Issue 128
  actCancel.Enabled := True;
{  if FModificationTable.IsEmpty then
    actCancel.Enabled := True
  else
    actCancel.Enabled := not (GoodKey <> -1); }
end;

procedure TModificationForm.actGoodDownExecute(Sender: TObject);
begin
  LockWindowUpdate(Self.Handle);
  try
    ScrollControl(pnlMain, True, FFirstTopButton, FLastTopButton);
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TModificationForm.actGoodDownUpdate(Sender: TObject);
begin
  actGoodDown.Enabled := (FLastTopButton + btnHeight > pnlMain.Height);
end;

procedure TModificationForm.actGoodUpExecute(Sender: TObject);
begin
  LockWindowUpdate(Self.Handle);
  try
    ScrollControl(pnlMain, False, FFirstTopButton, FLastTopButton);
  finally
    LockWindowUpdate(0);
  end;
end;

procedure TModificationForm.actGoodUpUpdate(Sender: TObject);
begin
  actGoodUp.Enabled := (FFirstTopButton > 8);
end;

procedure TModificationForm.CheckModificationButtonList;
var
  I: Integer;
begin
  //���������� ������ ������
  FLineModifyTable.First;
  while not FLineModifyTable.Eof do
  begin
    if FLineModifyTable.FieldByName('CLOSETIME').AsString = '' then
    begin
      for I := 0 to ComponentCount - 1 do
      begin
        if (Components[I] is TAdvSmoothToggleButton) then
          if TAdvSmoothToggleButton(Components[I]).Tag = FLineModifyTable.FieldByName('MODIFYKEY').AsInteger then
            TAdvSmoothToggleButton(Components[I]).Down := True;
      end;
    end;
    FLineModifyTable.Next;
  end;
end;

end.
