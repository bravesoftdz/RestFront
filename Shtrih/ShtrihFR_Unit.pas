﻿unit ShtrihFR_Unit;

interface

uses
  Classes, Windows, Forms, DrvFRLib_TLB, Front_DataBase_Unit, kbmMemTable, DB,
  Base_FiscalRegister_unit, TouchMessageBoxForm_Unit, FrontLog_Unit;

type
  TShtrihFR = class(TDrvFR, IBaseFiscalRegister)
  private
    FFrontBase: TFrontBase;
    FLogManager: TLogManager;
    FDriverInit: Boolean;
    IsInit: Boolean;

    function SetParams: Boolean;
    procedure ErrMessage(Err: Integer);
    procedure SetFrontBase(const Value: TFrontBase);
    function GetFrontBase: TFrontBase;
    function Get_Self: Integer;
    function CheckFiscalState: Boolean;
    function GetLogManager: TLogManager;
    procedure SetLogManager(const Value: TLogManager);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function CheckDeviceInfo: Boolean;
    function Init: Boolean;
    function PrintCheck(const Doc, DocLine, PayLine: TkbmMemTable; const FSums: TSaleSums): Boolean;
    function ReturnCheck(const Doc, DocLine, PayLine: TkbmMemTable; const FSums: TSaleSums): Boolean;
    function ReturnGoodMoney(const FSums: TSaleSums): Boolean;

    function PrintZ1ReportWithCleaning: Boolean;
    function PrintX1ReportWithOutCleaning: Boolean;
    procedure OpenDrawer;
    procedure EndSession;
    function OpenDay: Boolean;
    procedure MoneyIn(const Sum: Currency);
    procedure MoneyOut(const Sum: Currency);
    function GetDocumentNumber: Integer;
    function GetRegisterInfo: TRegisterStucture;

    property Self: Integer read Get_Self;
    property FrontBase: TFrontBase read GetFrontBase write SetFrontBase;
    property LogManager: TLogManager read GetLogManager write SetLogManager;
  end;

implementation

uses
  SysUtils, Math, Controls, Dialogs;

{ TShtrihFR }

function TShtrihFR.CheckDeviceInfo: Boolean;
begin
  Result := True;
end;

function TShtrihFR.CheckFiscalState: Boolean;
begin
  while True do
  begin
    GetShortECRStatus;
    Sleep(200);
    case ECRAdvancedMode of
      // Бумага есть, ФР не в фазе печати операции
      0:
        begin
          Result := True;
          exit;
        end;
      // Пассивное отсутствие бумаги, ККМ не в фазе печати операции
      1:
        begin
          Touch_MessageBox('Внимание', 'Бумага закончилась!', MB_OK, mtWarning);
          Result := True;
          exit;
        end;
      // Активное отсутствие бумаги  ККМ в фазе печати операции
      2:
        begin
          Touch_MessageBox('Внимание', 'Бумага закончилась, заправьте новый рулон!', MB_OK, mtWarning);
        end;
      // После активного отсутствия бумаги, ККМ ждет команду
      3:
        begin
          ContinuePrint;
          Sleep(2000);
          if (ResultCode <> 0) or (EcrMode = 8) then
          begin
            if ResultCode <> 0 then
              ErrMessage(ResultCode);
            CancelCheck;
            if ResultCode <> 0 then
              ErrMessage(ResultCode);
            if ResultCode = 88 then
            begin
              ContinuePrint;
              Sleep(2000);
              CancelCheck;
              if ResultCode <> 0 then
                ErrMessage(ResultCode);
            end;

            Result := False;
          end else
            Result := True;

          exit;
        end;
      // Фаза печати операции, ККМ не принимает от хоста команды
      4:
        begin
          Result := True;
          exit;
        end;
      // Фаза печати операции длинного отчета
      5:
        begin
          Result := True;
          exit;
        end;
    else
      begin
        Sleep(500);
        if ResultCode <> 0 then
        begin
          ErrMessage(ResultCode);
          Result := False;
        end else
          Result := True;

        exit;
      end;
    end;
  end;
end;

constructor TShtrihFR.Create(AOwner: TComponent);
begin
  FDriverInit := True;
  try
    inherited Create(AOwner);
  except
    Touch_MessageBox('Внимание', 'Не установлен драйвер для ФР ''Штрих ФР''!', MB_OK, mtError);
    FDriverInit := False;
  end;
  IsInit := False;
end;

destructor TShtrihFR.Destroy;
begin

  inherited;
end;

procedure TShtrihFR.EndSession;
begin
  PrintZ1ReportWithCleaning;
end;

procedure TShtrihFR.ErrMessage(Err: Integer);
var
  ErrStr: String;
  FCheckInfo: TLogCheckInfo;
begin
  if Err <> 0 then
  begin
    ErrStr := ResultCodeDescription;
    Touch_MessageBox('Внимание', ErrStr, MB_OK, mtWarning);
    WriteLogToFile(ErrStr, FFrontBase.UserName);
    if Assigned(FLogManager) then
    begin
      FCheckInfo.OrderID := -1;
      FLogManager.DoCancelCheckLog(GetCurrentUserInfo(FFrontBase),
        FCheckInfo, ErrStr);
    end;
  end;
end;

function TShtrihFR.Get_Self: Integer;
begin
  Result := Integer(Self);
end;

function TShtrihFR.GetDocumentNumber: Integer;
begin
  try
    RegisterNumber := 152;
    GetOperationReg;
    if ResultCode = 0 then
      Result := ContentsOfOperationRegister
    else
      Result := 0;
  except
    Result := 0;
  end;
end;

function TShtrihFR.GetFrontBase: TFrontBase;
begin
  Result := FFrontBase;
end;

function TShtrihFR.GetLogManager: TLogManager;
begin
  Result := FLogManager;
end;

function TShtrihFR.GetRegisterInfo: TRegisterStucture;

  function GetResister(const RegNumber: Integer): Currency;
  begin
    try
      RegisterNumber := RegNumber;
      GetCashReg;
      if ResultCode = 0 then
        Result := ContentsOfCashRegister
      else
        Result := 0;
    except
      Result := 0;
    end;
  end;

begin
  Result.Summ1 := GetResister(193);
  Result.Summ2 := GetResister(197);
  Result.Summ3 := GetResister(201);
  Result.Summ4 := GetResister(205);
  Result.SummReturn1 := GetResister(195);
  Result.SummReturn2 := GetResister(199);
  Result.SummReturn3 := GetResister(203);
  Result.SummReturn4 := GetResister(207);
  Result.PayInSumm := GetResister(242);
  Result.PayOutSumm := GetResister(243);

  GetLongSerialNumberAndLongRNM;
  if ResultCode = 0 then
    Result.RNM := RNM
  else
    Result.RNM := '';
end;

function TShtrihFR.Init: Boolean;
begin
  Result := True;
  IsInit := SetParams;
end;

procedure TShtrihFR.MoneyIn(const Sum: Currency);
var
  Res: Integer;
begin
  if FDriverInit then
  begin
    Summ1 := Sum;
    Res := CashIncome;
    if ResultCode <> 0 then
      ErrMessage(Res);
  end;
end;

procedure TShtrihFR.MoneyOut(const Sum: Currency);
var
  Res: Integer;
begin
  if FDriverInit then
  begin
    Summ1 := Sum;
    Res := CashOutCome;
    if ResultCode <> 0 then
      ErrMessage(Res);
  end;
end;

function TShtrihFR.OpenDay: Boolean;
begin
  Result := True;
end;

procedure TShtrihFR.OpenDrawer;
var
  Res: Integer;
begin
  if FDriverInit then
  begin
    Res := Inherited OpenDrawer;
    if ResultCode <> 0 then
      ErrMessage(Res);
  end;
end;

function TShtrihFR.PrintCheck(const Doc, DocLine,
  PayLine: TkbmMemTable; const FSums: TSaleSums): Boolean;
var
  Res: Integer;
  DocNumber, WaiterName: String;
  WasDiscount: Boolean;
  TotalDiscount: Currency;
  GoodName, DiscName: String;
  Quantity, Price, SumDiscount: Currency;
  QuantityStr, PriceStr: String;
  FUserInfo: TLogUserInfo;
  FCheckInfo: TLogCheckInfo;
begin
  Result := False;
  Assert(Assigned(FFrontBase), 'FrontBase not Assigned');

  if FDriverInit then
  begin
    if Init then
    begin
      //Если пришли в режиме продолжения печати, то допечатываем и выходим
      GetShortECRStatus;
      Sleep(200);
      if ECRAdvancedMode = 3 then
      begin
        ContinuePrint;
        Sleep(250);
        if ResultCode <> 0 then
        begin
          CancelCheck;
          ErrMessage(ResultCode);
        end;
        exit;
      end;

      //если открыт документ, то делаем его закрытие и выходим
      if ECRMode = 8 then
      begin
        CancelCheck;
        exit;
      end;

      DocNumber := Doc.FieldByName('NUMBER').AsString;
      DocNumber := StringReplace(DocNumber, '.', '', [rfReplaceAll]);
      DocNumber := StringReplace(DocNumber, ',', '', [rfReplaceAll]);
      if Length(DocNumber) > 5 then
        Delete(DocNumber, 5, Length(DocNumber));

      WaiterName := FFrontBase.UserName; // FFrontBase.GetNameWaiterOnID(Doc.FieldByName('usr$respkey').AsInteger, False, False);

      UseReceiptRibbon := True;
      StringForPrinting := 'Открыт - ' + DateToStr(Date) + ' ' + TimeToStr(Time);
      PrintString;
      StringForPrinting := 'Закрыт - ' + DateToStr(Date) + ' ' + TimeToStr(Time);
      PrintString;
      StringForPrinting := 'Кассир - ' + WaiterName;
      PrintString;
      if not CheckFiscalState then
        exit;

      Res := ResultCode;
      if Res <> 0 then
      begin
        ErrMessage(Res);
        CancelCheck;
        exit;
      end;

      TotalDiscount := 0;
      WasDiscount := False;

      if Assigned(FLogManager) then
      begin
        FUserInfo := GetCurrentUserInfo(FFrontBase);
        with FCheckInfo do
        begin
          FCheckInfo.OrderID := Doc.FieldByName('ID').AsInteger;
          FCheckInfo.OrderNumber := Doc.FieldByName('NUMBER').AsString;
        end;
      end;

      DocLine.First;
      while not DocLine.Eof do
      begin
        if DocLine.FieldByName('USR$NOPRINT').AsInteger <> 1 then
        begin
          GoodName := DocLine.FieldByName('GOODNAME').AsString;
          QuantityStr := CurrToStr(DocLine.FieldByName('usr$quantity').AsCurrency);
          PriceStr := CurrToStr(DocLine.FieldByName('usr$costncu').AsCurrency);

          GoodName := Copy(GoodName, 1, 40 - Length(' ' + QuantityStr + 'x' + PriceStr)) + ' ' +  QuantityStr + 'x' + PriceStr;
          Quantity := 1;
          Price := DocLine.FieldByName('usr$sumncu').AsCurrency;
          SumDiscount := DocLine.FieldByName('usr$sumncu').AsCurrency -
            DocLine.FieldByName('usr$sumncuwithdiscount').AsCurrency;
          TotalDiscount := TotalDiscount + SumDiscount;

          if Quantity >= 0 then
          begin
            Self.Quantity := Quantity;
            Self.Price := Price;

            Delete(GoodName, 40, Length(GoodName) - 40);
            StringForPrinting := GoodName;
            Sale;
            if not CheckFiscalState then
              exit;

            Res := ResultCode;
            if Res <> 0 then
            begin
              ErrMessage(Res);
              CancelCheck;
              exit;
            end;
            if DocLine.FieldByName('usr$persdiscount').AsCurrency <> 0 then
              WasDiscount := True;
          end;
        end;

        if Assigned(FLogManager) then
        begin
          with FCheckInfo do
          begin
            GoodID := DocLine.FieldByName('usr$goodkey').AsInteger;
            GoodName := DocLine.FieldByName('GOODNAME').AsString;
            Quantity := DocLine.FieldByName('usr$quantity').AsCurrency;
            CostNCU := DocLine.FieldByName('usr$costncu').AsCurrency;
            SumNCU := DocLine.FieldByName('usr$sumncu').AsCurrency;
            SumDiscount := DocLine.FieldByName('usr$sumncu').AsCurrency -
              DocLine.FieldByName('usr$sumncuwithdiscount').AsCurrency;
          end;
          FLogManager.DoCheckLog(FUserInfo,  FCheckInfo, ev_PrintCheck);
        end;
        DocLine.Next;
      end;

      if TotalDiscount <> 0 then
      begin
        if WasDiscount then
          DiscName := 'Скидка'
        else
          DiscName := 'Округление';

        StringForPrinting := DiscName + ' ' + CurrToStr(TotalDiscount);
        Summ1 := Abs(TotalDiscount);
        if TotalDiscount > 0 then
        begin
          Discount;
          if not CheckFiscalState then
            exit;
        end else
        begin
          Charge;
          if not CheckFiscalState then
            exit;
        end;

        Res := ResultCode;
        if Res <> 0 then
        begin
          ErrMessage(Res);
          CancelCheck;
          exit;
        end;
      end;

      CheckSubTotal;

      Self.Summ1 := FSums.FCashSum;
      Self.Summ2 := (FSums.FCreditSum + FSums.FPersonalCardSum);
      Self.Summ4 := FSums.FCardSum;
      //Summ3 - тара

      StringForPrinting := '';
      CloseCheck;
      Res := ResultCode;
      if Res <> 0 then
      begin
        ErrMessage(Res);
        CancelCheck;
      end else
        Result := True;

      if Result then
      begin
        // сохраняем чек
        if Doc.State <> dsEdit then
          Doc.Edit;
        Doc.FieldByName('USR$WHOPAYOFFKEY').AsInteger := FFrontBase.ContactKey;
        Doc.FieldByName('USR$PAY').AsInteger := 1;
        Doc.FieldByName('USR$REGISTER').AsString := IntToStr(FFrontBase.CashNumber);
        Doc.FieldByName('USR$LOGICDATE').AsDateTime := FFrontBase.GetLogicDate;
        Doc.FieldByName('USR$SYSNUM').AsInteger := GetDocumentNumber;
        if Doc.FieldByName('usr$timecloseorder').IsNull then
          Doc.FieldByName('usr$timecloseorder').AsDateTime := Now;
        try
          SavePayment(FFrontBase.ContactKey, Doc.FieldByName('ID').AsInteger,
            PayLine, FFrontBase, FSums);
        except
          {TODO: Issue 50}
          on E: Exception do
          begin
            if Assigned(FLogManager) then
              FLogManager.DoCancelCheckLog(FUserInfo, FCheckInfo, E.Message);
          end;
        end;
        Doc.Post;
      end;
    end;
  end;
end;

function TShtrihFR.PrintX1ReportWithOutCleaning: Boolean;
begin
  Result := False;
  if FDriverInit then
  begin
    GetShortECRStatus;
    if ECRAdvancedMode = 3 then
    begin
      ContinuePrint;
      Sleep(250);
      if ResultCode <> 0 then
      begin
        CancelCheck;
        ErrMessage(ResultCode);
      end;
    end;

    if (ResultCode <> 0) or (ECRMode = 8) then
    begin
      ErrMessage(ResultCode);
      CancelCheck;
    end;
    PrintReportWithoutCleaning;
    if ResultCode = 0 then
      Result := True
    else
      ErrMessage(ResultCode);
  end;
end;

function TShtrihFR.PrintZ1ReportWithCleaning: Boolean;
begin
  Result := False;
  if FDriverInit then
  begin
    GetShortECRStatus;
    if ECRAdvancedMode = 3 then
    begin
      ContinuePrint;
      Sleep(250);
      if ResultCode <> 0 then
      begin
        CancelCheck;
        ErrMessage(ResultCode);
      end;
    end;

    if (ResultCode <> 0) or (ECRMode = 8) then
    begin
      ErrMessage(ResultCode);
      CancelCheck;
    end;

    SaveRegisters(GetRegisterInfo, FrontBase);

    PrintReportWithCleaning;
    if ResultCode = 0 then
      Result := True
    else
      ErrMessage(ResultCode);
  end;
end;

function TShtrihFR.ReturnCheck(const Doc, DocLine, PayLine: TkbmMemTable;
  const FSums: TSaleSums): Boolean;
var
  Res: Integer;
  DocNumber, WaiterName: String;
  WasDiscount: Boolean;
  TotalDiscount: Currency;
  GoodName, DiscName: String;
  Quantity, Price, SumDiscount: Currency;
  QuantityStr, PriceStr: String;
  FUserInfo: TLogUserInfo;
  FCheckInfo: TLogCheckInfo;
begin
  Result := False;
  Assert(Assigned(FFrontBase), 'FrontBase not Assigned');

  if FDriverInit then
  begin
    if Init then
    begin
      if not CheckFiscalState then
        exit;

      DocNumber := Doc.FieldByName('NUMBER').AsString;
      DocNumber := StringReplace(DocNumber, '.', '', [rfReplaceAll]);
      DocNumber := StringReplace(DocNumber, ',', '', [rfReplaceAll]);
      if Length(DocNumber) > 5 then
        Delete(DocNumber, 5, Length(DocNumber));

      WaiterName := FFrontBase.GetNameWaiterOnID(Doc.FieldByName('usr$respkey').AsInteger, False, False);

      UseReceiptRibbon := True;
      StringForPrinting := 'Открыт - ' + DateToStr(Date) + ' ' + TimeToStr(Time);
      PrintString;
      StringForPrinting := 'Закрыт - ' + DateToStr(Date) + ' ' + TimeToStr(Time);
      PrintString;
      StringForPrinting := 'Кассир - ' + WaiterName;
      PrintString;
      if not CheckFiscalState then
        exit;

      Res := ResultCode;
      if Res <> 0 then
      begin
        ErrMessage(Res);
        CancelCheck;
        exit;
      end;

      TotalDiscount := 0;
      WasDiscount := False;

      if Assigned(FLogManager) then
      begin
        FUserInfo := GetCurrentUserInfo(FFrontBase);
        with FCheckInfo do
        begin
          FCheckInfo.OrderID := Doc.FieldByName('ID').AsInteger;
          FCheckInfo.OrderNumber := Doc.FieldByName('NUMBER').AsString;
        end;
      end;

      DocLine.First;
      while not DocLine.Eof do
      begin

        GoodName := DocLine.FieldByName('GOODNAME').AsString;
        QuantityStr := CurrToStr(-DocLine.FieldByName('usr$quantity').AsCurrency);
        PriceStr := CurrToStr(DocLine.FieldByName('usr$costncu').AsCurrency);

        GoodName := Copy(GoodName, 1, 40 - Length(' ' + QuantityStr + 'x' + PriceStr)) + ' ' +  QuantityStr + 'x' + PriceStr;
        Quantity := 1;
        Price := -DocLine.FieldByName('usr$sumncu').AsCurrency;
        SumDiscount := -DocLine.FieldByName('usr$sumncu').AsCurrency +
            DocLine.FieldByName('usr$sumncuwithdiscount').AsCurrency;
        TotalDiscount := TotalDiscount + SumDiscount;

        if Quantity >= 0 then
        begin
          Self.Quantity := Quantity;
          Self.Price := Price;

          Delete(GoodName, 40, Length(GoodName) - 40);
          StringForPrinting := GoodName;
          ReturnSale;
          if not CheckFiscalState then
            exit;

          Res := ResultCode;
          if Res <> 0 then
          begin
            ErrMessage(Res);
            CancelCheck;
            exit;
          end;
          if DocLine.FieldByName('usr$persdiscount').AsCurrency <> 0 then
            WasDiscount := True;
        end;

        if Assigned(FLogManager) then
        begin
          with FCheckInfo do
          begin
            GoodID := DocLine.FieldByName('usr$goodkey').AsInteger;
            GoodName := DocLine.FieldByName('GOODNAME').AsString;
            Quantity := DocLine.FieldByName('usr$quantity').AsCurrency;
            CostNCU := DocLine.FieldByName('usr$costncu').AsCurrency;
            SumNCU := DocLine.FieldByName('usr$sumncu').AsCurrency;
            SumDiscount := DocLine.FieldByName('usr$sumncu').AsCurrency -
              DocLine.FieldByName('usr$sumncuwithdiscount').AsCurrency;
          end;
          FLogManager.DoCheckLog(FUserInfo,  FCheckInfo, ev_ReturnCheck);
        end;
        DocLine.Next;
      end;

      if TotalDiscount <> 0 then
      begin
        if WasDiscount then
          DiscName := 'Скидка'
        else
          DiscName := 'Округление';

        StringForPrinting := DiscName + ' ' + CurrToStr(TotalDiscount);
        Summ1 := Abs(TotalDiscount);
        if TotalDiscount > 0 then
        begin
          Discount;
          if not CheckFiscalState then
            exit;
        end else
        begin
          Charge;
          if not CheckFiscalState then
            exit;
        end;

        Res := ResultCode;
        if Res <> 0 then
        begin
          ErrMessage(Res);
          CancelCheck;
          exit;
        end;
      end;

      CheckSubTotal;

      Self.Summ1 := FSums.FCashSum;
      Self.Summ2 := (FSums.FCreditSum + FSums.FPersonalCardSum);
      Self.Summ4 := FSums.FCardSum;
      //Summ3 - тара

      StringForPrinting := '';
      CloseCheck;
      if not CheckFiscalState then
        exit;
      Res := ResultCode;
      if Res <> 0 then
      begin
        ErrMessage(Res);
        CancelCheck;
      end else
        Result := True;

      if Result then
      begin
        // сохраняем чек
        if Doc.State <> dsEdit then
          Doc.Edit;
        Doc.FieldByName('USR$WHOPAYOFFKEY').AsInteger := FFrontBase.ContactKey;
        Doc.FieldByName('USR$PAY').AsInteger := 1;
        Doc.FieldByName('USR$REGISTER').AsString := IntToStr(FFrontBase.CashNumber);
        Doc.FieldByName('USR$LOGICDATE').AsDateTime := FFrontBase.GetLogicDate;
        Doc.FieldByName('USR$SYSNUM').AsInteger := GetDocumentNumber;
        if Doc.FieldByName('usr$timecloseorder').IsNull then
          Doc.FieldByName('usr$timecloseorder').AsDateTime := Now;
        try
          SavePayment(FFrontBase.ContactKey, Doc.FieldByName('ID').AsInteger,
            PayLine, FFrontBase, FSums);
        except
          {TODO: Issue 50}
          on E: Exception do
          begin
            if Assigned(FLogManager) then
              FLogManager.DoCancelCheckLog(FUserInfo, FCheckInfo, E.Message);
          end;
        end;
        Doc.Post;
      end;
    end;
  end;
end;

function TShtrihFR.ReturnGoodMoney(const FSums: TSaleSums): Boolean;
begin
{ TODO : Реализовать }
  Result := True;
end;

procedure TShtrihFR.SetFrontBase(const Value: TFrontBase);
begin
  FFrontBase := Value;
end;

procedure TShtrihFR.SetLogManager(const Value: TLogManager);
begin
  FLogManager := Value;
end;

function TShtrihFR.SetParams: Boolean;
begin
  Result := True;
end;

end.
