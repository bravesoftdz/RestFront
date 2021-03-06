unit SplitOrderForm_Unit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, Front_DataBase_Unit, DB, kbmMemTable,
  StdCtrls, FrontData_Unit, AdvPanel, AdvSmoothButton, Grids, BaseFrontForm_Unit,
  AdvObj, BaseGrid, AdvGrid, DBAdvGrid;


type
  TSplitOrder = class(TBaseFrontForm)
    pnlLeft: TAdvPanel;
    pnlRight: TAdvPanel;
    pnlBottom: TAdvPanel;
    pnlLeftTop: TAdvPanel;
    pnlRightTop: TAdvPanel;
    dsLeft: TDataSource;
    dsRight: TDataSource;
    pnlCenter: TAdvPanel;
    btnRight: TAdvSmoothButton;
    btnAllRight: TAdvSmoothButton;
    btnLeft: TAdvSmoothButton;
    btnAllLeft: TAdvSmoothButton;
    btnOK: TAdvSmoothButton;
    DBGrLeft: TDBAdvGrid;
    DBGrRight: TDBAdvGrid;
    btnCancel: TAdvSmoothButton;
    lbLeftCount: TLabel;
    lbRightCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DBGrRightDblClick(Sender: TObject);
    procedure DBGrLeftDblClick(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
    procedure btnRightClick(Sender: TObject);
    procedure btnLeftClick(Sender: TObject);
    procedure btnAllRightClick(Sender: TObject);
    procedure btnAllLeftClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    FFrontBase: TFrontBase;
    FLeftDoc: TkbmMemTable;
    FLeftDocLine: TkbmMemTable;
    FRightDoc: TkbmMemTable;
    FRightDocLine: TkbmMemTable;
    FLeftModificationDataSet: TkbmMemTable;
    FRightModificationDataSet: TkbmMemTable;
    FLeftMasterDataSource: TDataSource;
    FRightMasterDataSource: TDataSource;

    FGoodDataSet: TkbmMemTable;

    FOrderKey: Integer;
    FMainOrderKey: Integer;
    FManagerKey: Integer;
    procedure SetFrontBase(const Value: TFrontBase);
    procedure CopyDS(const SourceDS, DestDS: TkbmMemTable; Parent: Integer; All: Boolean = False);
    procedure OnBeforePostLeftLine(DataSet: TDataSet);
    procedure OnBeforePostRightLine(DataSet: TDataSet);
    procedure RefreshDataSets;
  public
    property MainOrderKey: Integer read FMainOrderKey write FMainOrderKey;
    property OrderKey: Integer read FOrderKey write FOrderKey;
    property FrontBase: TFrontBase write SetFrontBase;
    property ManagerKey: Integer read FManagerKey write FManagerKey;
  end;

var
  SplitOrder: TSplitOrder;

implementation

uses
  DevideForm_Unit;

{$R *.dfm}

procedure TSplitOrder.CopyDS(const SourceDS, DestDS: TkbmMemTable;
  Parent: Integer; All: Boolean);
var
  I: Integer;
  FForm: TDevideForm;
  Quantity: Currency;
  GoodKey: Integer;
  FCanDevide: Boolean;
begin
  if not SourceDS.IsEmpty then
  begin
    FFrontBase.SaveOrderLog(FFrontBase.ContactKey, ManagerKey,
      Parent, SourceDS.FieldByName('ID').AsInteger, 2);

    GoodKey := SourceDS.FieldByName('usr$goodkey').AsInteger;
    if not FGoodDataSet.Locate('ID', GoodKey, []) then
    begin
      FFrontBase.GetGoodByID(FGoodDataSet, GoodKey);
      if FGoodDataSet.Locate('ID', GoodKey, []) then
        FCanDevide := (FGoodDataSet.FieldByName('BEDIVIDE').AsInteger = 1)
      else
        FCanDevide := False;
    end else
    begin
      FCanDevide := (FGoodDataSet.FieldByName('BEDIVIDE').AsInteger = 1);
    end;

    {
      ������� ��������
      1.���� ����� �� ����� ���� ������� � ���-�� ������ 1 => �� ����� ����� ���-��,
        ����� ��������� ���������
      2.���� ����� ����� ���� ������� � ���-�� ������ ���� ����� 1 => �� ����� ����� ���-��
      3.���� ����� ����� ���� ������� � ���-�� ������ => ��������� ���������
    }
    if ((SourceDS.FieldByName('usr$quantity').AsCurrency > 1) or (FCanDevide and
      (SourceDS.FieldByName('usr$quantity').AsCurrency >= 1))) and (not All) then
    begin
      FForm := TDevideForm.Create(nil);
      try
        FForm.LabelCaption := '����������';
        FForm.CanDevided := FCanDevide;
        FForm.edtNumber.Text := CurrToStr(SourceDS.FieldByName('usr$quantity').AsCurrency);
        FForm.ShowModal;

        if FForm.ModalResult = mrOK then
        begin
          Quantity := StrToCurr(FForm.Number);
          if (Quantity > 0) and (SourceDS.FieldByName('usr$quantity').AsCurrency >= Quantity) then
          begin
            SourceDS.Edit;
            SourceDS.FieldByName('usr$quantity').AsCurrency :=
              SourceDS.FieldByName('usr$quantity').AsCurrency - Quantity;
            SourceDS.Post;

            //������ ������� ������.
            DestDS.Append;
            for I := 0 to DestDS.FieldCount - 1 do
            begin
            if SourceDS.Fields[I].IsNull then
              DestDS.Fields[I].Value := SourceDS.Fields[I].Value
            else
              DestDS.Fields[I].AsString := SourceDS.Fields[I].AsString;
            end;
            DestDS.FieldByName('usr$quantity').AsCurrency := Quantity;
            DestDS.FieldByName('PARENT').AsInteger := Parent;
            if SourceDS.FieldByName('usr$quantity').AsCurrency = 0 then
              DestDS.FieldByName('STATEFIELD').AsInteger := cn_StateUpdateParent
            else begin
              DestDS.FieldByName('STATEFIELD').AsInteger := cn_StateInsert;
              DestDS.FieldByName('ID').AsInteger := FFrontBase.GetNextID;
            end;
            DestDS.Post;

            if SourceDS = FLeftDocLine then
            begin
              FLeftModificationDataSet.First;
              while not FLeftModificationDataSet.Eof do
              begin
                FRightModificationDataSet.Append;
                FRightModificationDataSet.FieldByName('MODIFYKEY').AsInteger :=
                  FLeftModificationDataSet.FieldByName('MODIFYKEY').AsInteger;
                FRightModificationDataSet.Post;

                FLeftModificationDataSet.Next;
              end;
            end else
            begin
              FRightModificationDataSet.First;
              while not FRightModificationDataSet.Eof do
              begin
                FLeftModificationDataSet.Append;
                FLeftModificationDataSet.FieldByName('MODIFYKEY').AsInteger :=
                  FRightModificationDataSet.FieldByName('MODIFYKEY').AsInteger;
                FLeftModificationDataSet.Post;

                FRightModificationDataSet.Next;
              end;
            end;

            if SourceDS.FieldByName('usr$quantity').AsCurrency = 0 then
              SourceDS.Delete;
          end;
        end;
      finally
        FForm.Free;
      end;
    end else
    begin
      DestDS.Append;
      for I := 0 to DestDS.FieldCount - 1 do
      begin
        if SourceDS.Fields[I].IsNull then
          DestDS.Fields[I].Value := SourceDS.Fields[I].Value
        else
          DestDS.Fields[I].AsString := SourceDS.Fields[I].AsString;
      end;
      DestDS.FieldByName('PARENT').AsInteger := Parent;
      DestDS.FieldByName('STATEFIELD').AsInteger := cn_StateUpdateParent;
      DestDS.Post;

      if SourceDS = FLeftDocLine then
      begin
        FLeftModificationDataSet.First;
        while not FLeftModificationDataSet.Eof do
        begin
          FRightModificationDataSet.Append;
          FRightModificationDataSet.FieldByName('MODIFYKEY').AsInteger :=
            FLeftModificationDataSet.FieldByName('MODIFYKEY').AsInteger;
          FRightModificationDataSet.Post;

          FLeftModificationDataSet.Next;
        end;
      end else
      begin
        FRightModificationDataSet.First;
        while not FRightModificationDataSet.Eof do
        begin
          FLeftModificationDataSet.Append;
          FLeftModificationDataSet.FieldByName('MODIFYKEY').AsInteger :=
            FRightModificationDataSet.FieldByName('MODIFYKEY').AsInteger;
          FLeftModificationDataSet.Post;

          FRightModificationDataSet.Next;
        end;
      end;
      SourceDS.Delete;
    end;  
  end;
end;

procedure TSplitOrder.FormCreate(Sender: TObject);
begin
  //����� � �������
  GetHeaderTable(FLeftDoc);
  FLeftDoc.Open;

  GetLineTable(FLeftDocLine);
  FLeftDocLine.BeforePost := OnBeforePostLeftLine;
  FLeftDocLine.Open;

  FLeftMasterDataSource := TDataSource.Create(nil);
  FLeftMasterDataSource.DataSet := FLeftDocLine;

  GetModificationTable(FLeftModificationDataSet);
  FLeftModificationDataSet.MasterSource := FLeftMasterDataSource;
  FLeftModificationDataSet.MasterFields := 'LINEKEY';
  FLeftModificationDataSet.DetailFields := 'MASTERKEY';
  FLeftModificationDataSet.Open;
  //2.
  GetHeaderTable(FRightDoc);
  FRightDoc.Open;

  GetLineTable(FRightDocLine);
  FRightDocLine.BeforePost := OnBeforePostRightLine;
  FRightDocLine.Open;

  FRightMasterDataSource := TDataSource.Create(nil);
  FRightMasterDataSource.DataSet := FRightDocLine;

  GetModificationTable(FRightModificationDataSet);
  FRightModificationDataSet.MasterSource := FRightMasterDataSource;
  FRightModificationDataSet.MasterFields := 'LINEKEY';
  FRightModificationDataSet.DetailFields := 'MASTERKEY';
  FRightModificationDataSet.Open;

  dsLeft.DataSet := FLeftDocLine;
  dsRight.DataSet := FRightDocLine;

  FGoodDataSet := TkbmMemTable.Create(nil);
  FGoodDataSet.FieldDefs.Add('ID', ftInteger, 0);
  FGoodDataSet.FieldDefs.Add('NAME', ftString, 60);
  FGoodDataSet.FieldDefs.Add('ALIAS', ftString, 16);
  FGoodDataSet.FieldDefs.Add('COST', ftCurrency, 0);
  FGoodDataSet.FieldDefs.Add('MODIFYGROUPKEY', ftInteger, 0);
  FGoodDataSet.FieldDefs.Add('ISNEEDMODIFY', ftInteger, 0);
  FGoodDataSet.FieldDefs.Add('BEDIVIDE', ftInteger, 0);
  FGoodDataSet.FieldDefs.Add('PRNGROUPKEY', ftInteger, 0);
  FGoodDataSet.FieldDefs.Add('NOPRINT', ftInteger, 0);
  FGoodDataSet.CreateTable;
  FGoodDataSet.Open;

  pnlLeft.Width := (Width div 2) - 50;
  pnlRight.Width := (Width div 2) - 50;

  btnLeft.Picture := FrontData.RestPictureContainer.FindPicture('Left');
  btnAllLeft.Picture := FrontData.RestPictureContainer.FindPicture('AllLeft');
  btnRight.Picture := FrontData.RestPictureContainer.FindPicture('Right');
  btnAllRight.Picture := FrontData.RestPictureContainer.FindPicture('AllRight');

  SetupAdvGrid(DBGrLeft);
  SetupAdvGrid(DBGrRight);
end;

procedure TSplitOrder.FormDestroy(Sender: TObject);
begin
  FLeftDoc.Free;
  FLeftDocLine.Free;
  FRightDoc.Free;
  FRightDocLine.Free;
  FLeftModificationDataSet.Free;
  FLeftMasterDataSource.Free;
  FRightModificationDataSet.Free;
  FRightMasterDataSource.Free;
  FGoodDataSet.Free;
end;

procedure TSplitOrder.FormShow(Sender: TObject);
begin
  Assert(Assigned(FFrontBase), 'FrontBase not assigned!');

  FFrontBase.GetOrder(FLeftDoc, FLeftDocLine, FLeftModificationDataSet, MainOrderKey);
  pnlLeftTop.Text := '<FONT  size="14" face="Times New Roman">' + '� ' +
    FLeftDoc.FieldByName('NUMBER').AsString + '. ' +
    FFrontBase.GetNameWaiterOnID(FLeftDoc.FieldByName('usr$respkey').AsInteger, False, False) + '</FONT>';

  FFrontBase.GetOrder(FRightDoc, FRightDocLine, FRightModificationDataSet, OrderKey);
  pnlRightTop.Text := '<FONT  size="14" face="Times New Roman">' + '� ' +
    FRightDoc.FieldByName('NUMBER').AsString + '. ' +
    FFrontBase.GetNameWaiterOnID(FRightDoc.FieldByName('usr$respkey').AsInteger, False, False) + '</FONT>';
  RefreshDataSets;
end;

procedure TSplitOrder.SetFrontBase(const Value: TFrontBase);
begin
  FFrontBase := Value;
end;

procedure TSplitOrder.DBGrRightDblClick(Sender: TObject);
begin
  CopyDS(FRightDocLine, FLeftDocLine, FMainOrderKey);
  RefreshDataSets;
end;

procedure TSplitOrder.DBGrLeftDblClick(Sender: TObject);
begin
  CopyDS(FLeftDocLine, FRightDocLine, FOrderKey);
  RefreshDataSets;
end;

procedure TSplitOrder.btnOKClick(Sender: TObject);
var
  OrderKey: Integer;
begin
  FFrontBase.CreateNewOrder(FLeftDoc, FLeftDocLine, FLeftModificationDataSet, OrderKey);
  FFrontBase.CreateNewOrder(FRightDoc, FRightDocLine, FRightModificationDataSet, OrderKey);
  ModalResult := mrOK;
end;

procedure TSplitOrder.btnRightClick(Sender: TObject);
begin
  CopyDS(FLeftDocLine, FRightDocLine, FOrderKey);
  RefreshDataSets;
end;

procedure TSplitOrder.btnLeftClick(Sender: TObject);
begin
  CopyDS(FRightDocLine, FLeftDocLine, FMainOrderKey);
  RefreshDataSets;
end;

procedure TSplitOrder.btnAllRightClick(Sender: TObject);
begin
  FLeftDocLine.First;
  while not FLeftDocLine.Eof do
  begin
    CopyDS(FLeftDocLine, FRightDocLine, FOrderKey, True);
//    FLeftDocLine.Next;
  end;
  RefreshDataSets;
end;

procedure TSplitOrder.btnCancelClick(Sender: TObject);
begin
  inherited;
  ModalResult := mrCancel;
end;

procedure TSplitOrder.btnAllLeftClick(Sender: TObject);
begin
  FRightDocLine.First;
  while not FRightDocLine.Eof do
  begin
    CopyDS(FRightDocLine, FLeftDocLine, FMainOrderKey, True);
//    FLeftDocLine.Next;
  end;
  RefreshDataSets;
end;


procedure TSplitOrder.OnBeforePostLeftLine(DataSet: TDataSet);
begin
  //1. ��������� �� ������
//  if FLeftDoc.FieldByName('USR$DISCOUNTKEY').AsInteger > 0 then
    DataSet.FieldByName('USR$PERSDISCOUNT').AsCurrency :=
      FFrontBase.GetDiscount(FLeftDoc.FieldByName('USR$DISCOUNTKEY').AsInteger,
        DataSet.FieldByName('usr$goodkey').AsInteger,
        FLeftDoc.FieldByName('usr$logicdate').AsDateTime,
        DataSet.FieldByName('usr$persdiscount').AsCurrency,
        DataSet.FieldByName('creationdate').AsDateTime);
//  else
//    DataSet.FieldByName('USR$PERSDISCOUNT').AsCurrency := 0;

{ TODO : ������� �����? }
  if DataSet.FieldByName('STATEFIELD').AsInteger = 0 then
    DataSet.FieldByName('STATEFIELD').AsInteger := 2; //����������

  DataSet.FieldByName('USR$SUMNCU').AsCurrency := FFrontBase.RoundCost
    (DataSet.FieldBYName('USR$COSTNCU').AsCurrency *
    DataSet.FieldBYName('USR$QUANTITY').AsCurrency);

  DataSet.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency :=
    FFrontBase.RoundCost(DataSet.FieldByName('USR$SUMNCU').AsCurrency *
    (1 - DataSet.FieldBYName('USR$PERSDISCOUNT').AsCurrency /100.00));

  if DataSet.FieldBYName('USR$QUANTITY').AsCurrency <> 0 then
    DataSet.FieldBYName('USR$COSTNCUWITHDISCOUNT').AsCurrency :=
      DataSet.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency /
      DataSet.FieldBYName('USR$QUANTITY').AsCurrency
  else
    DataSet.FieldBYName('USR$COSTNCUWITHDISCOUNT').AsCurrency :=
      DataSet.FieldBYName('USR$COSTNCU').AsCurrency;

  DataSet.FieldByName('USR$SUMDISCOUNT').AsCurrency :=
    DataSet.FieldByName('USR$SUMNCU').AsCurrency -
    DataSet.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency;
end;

procedure TSplitOrder.OnBeforePostRightLine(DataSet: TDataSet);
begin
  //1. ��������� �� ������
//  if FRightDoc.FieldByName('USR$DISCOUNTKEY').AsInteger > 0 then
    DataSet.FieldByName('USR$PERSDISCOUNT').AsCurrency :=
      FFrontBase.GetDiscount(FRightDoc.FieldByName('USR$DISCOUNTKEY').AsInteger,
        DataSet.FieldByName('usr$goodkey').AsInteger,
        FRightDoc.FieldByName('usr$logicdate').AsDateTime,
        DataSet.FieldByName('usr$persdiscount').AsCurrency,
        DataSet.FieldByName('creationdate').AsDateTime);
//  else
//    DataSet.FieldByName('USR$PERSDISCOUNT').AsCurrency := 0;

{ TODO : ������� �����? }
  if DataSet.FieldByName('STATEFIELD').AsInteger = 0 then
    DataSet.FieldByName('STATEFIELD').AsInteger := 2; //����������

  DataSet.FieldByName('USR$SUMNCU').AsCurrency := FFrontBase.RoundCost
    (DataSet.FieldBYName('USR$COSTNCU').AsCurrency *
    DataSet.FieldBYName('USR$QUANTITY').AsCurrency);

  DataSet.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency :=
    FFrontBase.RoundCost(DataSet.FieldByName('USR$SUMNCU').AsCurrency *
    (1 - DataSet.FieldBYName('USR$PERSDISCOUNT').AsCurrency /100.00));

  if DataSet.FieldBYName('USR$QUANTITY').AsCurrency <> 0 then
    DataSet.FieldBYName('USR$COSTNCUWITHDISCOUNT').AsCurrency :=
      DataSet.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency /
      DataSet.FieldBYName('USR$QUANTITY').AsCurrency
  else
    DataSet.FieldBYName('USR$COSTNCUWITHDISCOUNT').AsCurrency :=
      DataSet.FieldBYName('USR$COSTNCU').AsCurrency;

  DataSet.FieldByName('USR$SUMDISCOUNT').AsCurrency :=
    DataSet.FieldByName('USR$SUMNCU').AsCurrency -
    DataSet.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency;
end;

procedure TSplitOrder.RefreshDataSets;
{var
  FOrderKey: Integer;
  FMainOrderKey: Integer; }
begin
  lbRightCount.Caption := IntToStr(FRightDocLine.RecordCount);
  lbLeftCount.Caption := IntToStr(FLeftDocLine.RecordCount);
//  FFrontBase.CreateNewOrder(FLeftDoc, FLeftDocLine, FLeftModificationDataSet, FMainOrderKey);
//  FFrontBase.CreateNewOrder(FRightDoc, FRightDocLine, FRightModificationDataSet, FOrderKey);
//  FFrontBase.GetOrder(FLeftDoc, FLeftDocLine, FLeftModificationDataSet, FMainOrderKey);
//  FFrontBase.GetOrder(FRightDoc, FRightDocLine, FRightModificationDataSet, FOrderKey);
end;

end.
