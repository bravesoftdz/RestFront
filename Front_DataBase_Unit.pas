unit Front_DataBase_Unit;

interface

uses
  IBDatabase, Db, Classes, IBSQL, kbmMemTable, Base_Display_unit, Generics.Collections,
  Pole_Display_Unit, IBQuery, IB, IBErrorCodes, IBServices, obj_QueryList, rfUser_unit,
  rfOrder_unit, RestTable_Unit;

const

  cn_StateNothing = 0;
  cn_StateInsert = 1;
  cn_StateUpdate = 2;
  cn_StateUpdateParent = 3;
  cn_ContactFolderID = 650001;

//��������� � ���������
const
  cst_CauseDelete = 'SELECT * FROM usr$mn_causedeleteorderline';

  cst_GoodList =
    ' SELECT g.id, g.name, mn.usr$cost, g.alias, g.USR$MODIFYGROUPKEY, g.USR$BEDIVIDE, ' +
    '   g.USR$PRNGROUPKEY, g.USR$NOPRINT ' +
    ' FROM usr$mn_menuline mn  ' +
    '   JOIN gd_good g on g.id = mn.usr$goodkey  ' +
    '   JOIN gd_goodgroup cg ON g.groupkey = cg.id  ' +
    '   JOIN gd_document doc on doc.id = mn.documentkey ' +
    ' WHERE mn.masterkey = :MenuKey  ' +
    '   AND cg.id = :GroupKey  ' +
    '   and (doc.disabled is null or doc.disabled = 0)  ' +
    ' ORDER BY g.name ';

  cst_AllGoodList =
    ' SELECT DISTINCT G.ID, G.NAME ' +
    ' FROM usr$mn_menu mn ' +
    ' LEFT JOIN USR$MN_MENULINE mnl ON mnl.MASTERKEY = mn.DOCUMENTKEY ' +
    ' JOIN gd_document doc on doc.id = mnl.documentkey ' +
    ' LEFT JOIN GD_GOOD G ON G.ID = mnl.USR$GOODKEY ' +
    ' WHERE (mn.usr$todate is null or mn.usr$todate >= :curdate) and (doc.documentdate <= :curdate) ' +
    '   AND ((mn.USR$TIMEBEGIN <= current_time AND mn.USR$TIMEEND >= current_time) ' +
    '     OR (mn.USR$TIMEBEGIN IS NULL AND mn.USR$TIMEEND IS NULL)) ' +
    '   AND (doc.disabled is null or doc.disabled = 0) ' +
    ' ORDER BY 2 ';

  cst_GroupList =
    ' SELECT DISTINCT cg.name name, cg.id id, cg.alias ' +
    '  FROM usr$mn_menuline mn  ' +
    '  JOIN gd_good g ON mn.usr$goodkey = g.id  ' +
    '  JOIN gd_goodgroup cg ON g.groupkey = cg.id  ' +
    '  JOIN gd_document doc on doc.id = mn.documentkey  ' +
    ' WHERE mn.masterkey = :menukey  ' +
    '  and (doc.disabled is null or doc.disabled = 0)  ' +
    ' ORDER BY 1 ';

  cst_PopularGoodList =
    ' SELECT g.id, g.name, mn.usr$cost, g.alias, g.USR$MODIFYGROUPKEY, g.USR$BEDIVIDE, ' +
    '   g.USR$PRNGROUPKEY, g.USR$NOPRINT ' +
    ' FROM GD_GOOD G ' +
    ' JOIN GD_GOODGROUP GD ON GD.ID = G.GROUPKEY ' +
    ' JOIN usr$mn_menuline mn ON g.id = mn.usr$goodkey ' +
    ' JOIN gd_document doc on doc.id = mn.documentkey ' +
    ' WHERE ((G.USR$ISPOPULAR = 1) OR (GD.USR$ISPOPULAR = 1)) ' +
    '   AND (doc.disabled is null or doc.disabled = 0) ' +
    ' ORDER BY G.NAME ';

  cst_MenuList =
    'SELECT mn.documentkey, mn.usr$todate, mnn.usr$name ' +
    '  FROM usr$mn_menu mn left join usr$mn_menuname mnn ' +
    '   ON mn.usr$menunamekey = mnn.id ' +
    '    LEFT JOIN gd_document doc on doc.id = mn.documentkey ' +
    '  WHERE (mn.usr$todate is null or mn.usr$todate >= :curdate) and (doc.documentdate <= :curdate) ' +
    '    AND ((mn.USR$TIMEBEGIN <= current_time AND mn.USR$TIMEEND >= current_time) ' +
    '      OR (mn.USR$TIMEBEGIN IS NULL AND mn.USR$TIMEEND IS NULL)) ' +
    ' and exists (select first(1) dd.id from gd_document dd where dd.parent = mn.documentkey) ' +
    ' ORDER BY mnn.usr$name ';

  cst_ReservOrderHeader =
    ' SELECT                      ' +
    '   doc.id,                   ' +
    '   doc.number,               ' +
    '   doc.sumncu,               ' +
    '   doc.usr$mn_printdate,     ' +
    '   doc.editiondate,          ' +
    '   doc.editorkey,            ' +
    '   doc.creationdate,         ' +
    '   o.usr$guestcount,         ' +
    '   r.USR$TABLEKEY            ' +
    ' FROM gd_document doc        ' +
    '   JOIN USR$MN_RESERVORDER o ON o.documentkey = doc.id  ' +
    '   LEFT JOIN USR$MN_RESERVATION R ON R.USR$ORDERKEY = O.DOCUMENTKEY ' +
    ' WHERE                       ' +
    '    o.documentkey = :id      ';

  cst_OrderHeader =
    ' SELECT                      ' +
    '   doc.id,                   ' +
    '   doc.number,               ' +
    '   doc.sumncu,               ' +
    '   doc.usr$mn_printdate,     ' +
    '   doc.editiondate,          ' +
    '   doc.editorkey,            ' +
    '   doc.creationdate,         ' +
    '   o.usr$respkey,            ' +
    '   o.usr$guestcount,         ' +
    '   o.usr$timeorder,          ' +
    '   o.usr$timecloseorder,     ' +
    '   o.usr$logicdate,          ' +
    '   o.usr$discountncu,        ' +
    '   o.usr$disccardkey,        ' +
    '   o.usr$userdisckey,        ' +
    '   o.usr$discountkey,        ' +
    '   o.usr$bonussum,           ' +
    '   o.usr$pay,                ' +
    '   o.usr$cash,               ' +
    '   o.usr$sysnum,             ' +
    '   o.usr$register,           ' +
    '   o.usr$whopayoffkey,       ' +
    '   o.usr$vip,                ' +
    '   o.usr$tablekey,           ' +
    '   o.usr$islocked AS islocked, ' +
    ' ( SELECT SUM(L.USR$SUMNCUWITHDISCOUNT) FROM USR$MN_ORDERLINE L WHERE L.MASTERKEY = doc.ID AND L.USR$CAUSEDELETEKEY IS NULL) AS USR$SUMNCUWITHDISCOUNT, ' +
    '   o.usr$computername,       ' +
    '   o.usr$avanssum,           ' +
    '   o.usr$reservkey           ' +
    ' FROM gd_document doc        ' +
    '   JOIN usr$mn_order o ON o.documentkey = doc.id  ' +
    ' WHERE                       ' +
    '    o.documentkey = :id      ';

  cst_OrderHeaderByDate =
    ' SELECT                      ' +
    '   doc.id,                   ' +
    '   doc.number,               ' +
    '   doc.sumncu,               ' +
    '   doc.usr$mn_printdate,     ' +
    '   doc.editiondate,          ' +
    '   doc.editorkey,            ' +
    '   o.usr$respkey,            ' +
    '   o.usr$guestcount,         ' +
    '   o.usr$timeorder,          ' +
    '   o.usr$timecloseorder,     ' +
    '   o.usr$logicdate,          ' +
    '   o.usr$discountncu,        ' +
    '   o.usr$disccardkey,        ' +
    '   o.usr$userdisckey,        ' +
    '   o.usr$discountkey,        ' +
    '   o.usr$bonussum,           ' +
    '   o.usr$pay,                ' +
    '   o.usr$cash,               ' +
    '   o.usr$sysnum,             ' +
    '   o.usr$register,           ' +
    '   o.usr$whopayoffkey,       ' +
    '   o.usr$vip,                ' +
    ' ( SELECT SUM(L.USR$SUMNCUWITHDISCOUNT) FROM USR$MN_ORDERLINE L WHERE L.MASTERKEY = doc.ID AND L.USR$CAUSEDELETEKEY IS NULL) AS USR$SUMNCUWITHDISCOUNT ' +
    ' FROM gd_document doc        ' +
    '   join usr$mn_order o on o.documentkey = doc.id  ' +
    ' WHERE doc.documenttypekey = :doctype             ' +
    '   AND doc.parent + 0 IS NULL ' +
    '   AND doc.companykey = :companykey ' +
    '   AND o.usr$logicdate >= :DB ' +
    '   AND o.usr$logicdate <= :DE ';

  cst_OrderLine =
    ' SELECT                                                    '+
    '  doc.id,                                                  '+
    '  doc.editiondate,                                         '+
    '  doc.editorkey,                                           '+
    '  doc.number,                                              '+
    '  doc.creationdate,                                        '+
    '  doc.usr$mn_printdate,                                    '+
    '  ol.usr$quantity,                                         '+
    '  ol.usr$costncu,                                          '+
    '  ol.usr$goodkey,                                          '+
    '  ol.usr$sumncuwithdiscount,                               '+
    '  ol.usr$sumncu,                                           '+
    '  ol.usr$costncuwithdiscount,                              '+
    '  ol.usr$sumdiscount,                                      '+
    '  ol.usr$persdiscount,                                     '+
    '  ol.usr$causedeletekey,                                   '+
    '  ol.usr$deleteamount,                                     '+
    '  ol.usr$doublebonus,                                      '+
    '  g.name goodname                                          '+
    ' FROM gd_document doc                                      '+
    ' join usr$mn_orderline ol on ol.documentkey = doc.id       '+
    ' join gd_good g on g.id = ol.usr$goodkey                   '+
    ' WHERE ol.masterkey = :id                                  '+
    ' ORDER BY doc.id ';

  cst_ReservOrderLine =
    ' SELECT                                                    '+
    '  doc.id,                                                  '+
    '  doc.editiondate,                                         '+
    '  doc.editorkey,                                           '+
    '  doc.number,                                              '+
    '  doc.creationdate,                                        '+
    '  doc.usr$mn_printdate,                                    '+
    '  ol.usr$quantity,                                         '+
    '  ol.usr$costncu,                                          '+
    '  ol.usr$goodkey,                                          '+
    '  ol.usr$sumncuwithdiscount,                               '+
    '  ol.usr$sumncu,                                           '+
    '  ol.usr$costncuwithdiscount,                              '+
    '  ol.usr$sumdiscount,                                      '+
    '  ol.usr$persdiscount,                                     '+
    '  ol.usr$doublebonus,                                      '+
    '  g.name goodname                                          '+
    ' FROM gd_document doc                                      '+
    ' join usr$mn_reservorderline ol on ol.documentkey = doc.id '+
    ' join gd_good g on g.id = ol.usr$goodkey                   '+
    ' WHERE ol.masterkey = :id                                  '+
    ' ORDER BY doc.id ';

  cst_OrderActiveLine =
    ' SELECT                                                    '+
    '  doc.id,                                                  '+
    '  doc.editiondate,                                         '+
    '  doc.editorkey,                                           '+
    '  doc.number,                                              '+
    '  doc.creationdate,                                        '+
    '  doc.usr$mn_printdate,                                    '+
    '  ol.usr$quantity,                                         '+
    '  ol.usr$costncu,                                          '+
    '  ol.usr$goodkey,                                          '+
    '  ol.usr$sumncuwithdiscount,                               '+
    '  ol.usr$sumncu,                                           '+
    '  ol.usr$costncuwithdiscount,                              '+
    '  ol.usr$sumdiscount,                                      '+
    '  ol.usr$persdiscount,                                     '+
    '  ol.usr$causedeletekey,                                   '+
    '  ol.usr$deleteamount,                                     '+
    '  ol.usr$doublebonus,                                      '+
    '  ol.usr$extramodify,                                      '+
    '  ol.usr$computername,                                     '+
    '  g.name goodname, g.usr$noprint                           '+
    ' FROM gd_document doc                                      '+
    ' join usr$mn_orderline ol on ol.documentkey = doc.id       '+
    ' join gd_good g on g.id = ol.usr$goodkey                   '+
    ' WHERE ol.masterkey = :id and                              '+
    '   ol.usr$quantity <> 0 and ol.usr$causedeletekey IS NULL   '+
    ' ORDER BY doc.id ';


type
  TOrderState = (osOrderOpen, osOrderClose, osOrderPayed);

  TFrontOptions = packed record
    OrderCurrentLDate: Boolean;
    UseCurrentDate:    Boolean;
    KassaGroupMask:    Integer;
    ManagerGroupMask:  Integer;
    WaiterGroupMask:   Integer;
    MaxGuestCount:     Integer;
    MaxOpenedOrders:   Integer;
    MinGuestCount:     Integer;
    PLFileFolder:      String;
    PLSingleFile:      Boolean;
    PrintFiscalChek:   Boolean;
    PrintLog:          Boolean;
    DiscountType:      Integer;
    LastPrintOrder:    Integer;
    // ����� ����
    DoLog:             Boolean;
    LinesLimit:        Integer;
    LogToFile:         Boolean;
    //
    NoPassword:        Boolean;
    OpenTime:          TDateTime;
    CloseTime:         TDateTime;
    BasePath:          String;
    MainCompanyID:     Integer;
    CheckLine1:        String;
    CheckLine2:        String;
    CheckLine3:        String;
    CheckLine4:        String;
    CheckLine5:        String;
    CheckLine6:        String;
    CheckLine7:        String;
    CheckLine8:        String;
    SyncTime:          Boolean;
    TimeComp:          String;
    ExtCalcCardID:     Integer;
    ExtDepotKeys:      String;
    PrintCopyCheck:    Boolean;
    SaveAllOrder:      Boolean;
    BackType:          Integer;
    UseHalls:          Boolean;
    NoPrintEmptyCheck: Boolean;
    NeedModGroup:      Boolean;
    NeedPrnGroup:      Boolean;
    //��������� �����
    SparkCash:         Integer;
    SparkNoCash:       Integer;
    SparkCredit:       Integer;
  end;

  TUserInfo = record
    CheckedUserPassword : Boolean;
    UserName            : String;
    UserKey             : Integer;
    UserInGroup         : Integer;
  end;

  TID = -1..MAXINT;

  TRUID = record
    XID: TID;
    DBID: TID;
  end;

  TRUIDRec = record
    ID: TID;
    XID: TID;
    DBID: TID;
  end;

  TPrinterInfo = record
    PrinterName: String;
    PrinterID: Integer;
  end;

  TFrontConst = record
    DocumentTypeKey_ZakazRezerv: Integer;
    DocumentTypeKey_Zakaz: Integer;
    PayType_Cash: Integer;
    PayType_Card: Integer;
    PayType_PersonalCard: Integer;
    KindType_CashDefault: Integer;
  end;

  TFrontBase = class
  private
    FDataBase: TIBDataBase;
    FReadTransaction: TIBTransaction;
    FReadSQL: TIBSQL;
    FIDSQL: TIBSQL;
    FIDTransaction: TIBTransaction;
    FCheckTransaction: TIBTransaction;
    FCheckSQL: TIBSQL;
    // ��� � ������ IB
    FIBName: String;
    FIBPassword: String;
    FIBPath: String;

   // FUserKey: Integer;
    FContactKey: Integer;
    FUserName: String;
    FUserGroup: Integer;

{ TODO : �������� ����� ������� ������ �������� � ������� ����� �� }
    FCashCode: Integer;
    FFiscalComPort: Integer;
    FCashNumber: Integer;
    FIsMainCash: Boolean;
    FFiscalLog: Boolean;
    FBaudRate: Integer;

    FCompanyKey: Integer;
    FCompanyName: String;
    FOptions: TFrontOptions;

    FDisplay: TDisplay;
    FDisplayInitialized: Boolean;

    FQueryList: TgsQueryList;

    FComputerName: String;

    CacheList: TDictionary<String, Integer>;
    FFrontConst: TFrontConst;

    function GetDisplay: TDisplay;
    function GetCashCode: Integer;
    function GetFiscalComPort: Integer;
    function GetBaudRate: Integer;
    function GetCashNumber: Integer;
    function GetIsMainCash: Boolean;
    function GetServerName: String;
    function GetReadTransaction: TIBTransaction;

    function EnsureDBConnection: Boolean;
    function GetComputerName: String;
    procedure InitFrontConst;
  public
    constructor Create;
    destructor Destroy; override;

    procedure InitDB;
    procedure InitStorage;
    function GetIBRandomString: String;
    function CheckIBUser(const IBName: String): Boolean;
    procedure CreateIBUser(const IBName, IBPass: String; ID: Integer);
    function IsComputerDBConnected(const ComputerName: String): Boolean;

    function LogIn(const UserPassword: String): Boolean; //���������� ID ������ -1 ���� �� �����
    function CheckUserPasswordWithForm: TUserInfo;
    function CheckForSession: Boolean;

    function GetNextID: Integer;
    function GetServerDateTime: TDateTime;

    { �������� ������ ��� ����������� ������������, ���� "user = -1" �� ���������� ��� �������� }
    procedure GetUserOrderList(const ContactKey: Integer; AOrderList: TList<TrfOrder>);
    function GetUserOrders(const ContactKey: Integer; const MemTable: TkbmMemTable): Boolean;
    function GetUserOrdersPrecheck(const ContactKey: Integer; const MemTable: TkbmMemTable;
      const WithPrecheck: Boolean):Boolean;

    function GetOrdersInfo(const HeaderTable, LineTable: TkbmMemTable; const DateBegin, DateEnd: TDate;
      const WithPreCheck, WithOutPreCheck, Payed, NotPayed: Boolean): Boolean;
    function GetMenuList(const MemTable: TkbmMemTable; var FMenuButtonCount: Integer): Boolean;
    procedure GetGoodByMenu(const MemTable: TkbmMemTable; const MenuKey: Integer);
    procedure UpdateMenuStopList(const MemTable: TkbmMemTable; const FChangeList: TList<Integer>);
    function GetGroupList(const MemTable: TkbmMemTable; const MenuKey: Integer): Boolean;
    function GetGoodList(const MemTable: TkbmMemTable; const MenuKey, GroupKey: Integer): Boolean;
    function GetGoodByID(const MemTable: TkbmMemTable; const GoodKey: Integer): Boolean;
    procedure GetAllGoodList(const MemTable: TkbmMemTable);
    procedure UpdateGoodPrnGroup(const GoodKey, PrnGroupKey: Integer);
    procedure UpdateGoodModifyGroup(const GoodKey, ModifyGroupKey: Integer);
    function GetPopularGoodList(const MemTable: TkbmMemTable): Boolean;
    procedure DeleteOrder(const ID: Integer);

    procedure GetHallsInfo(const MemTable: TkbmMemTable);
    procedure GetTables(const MemTable: TkbmMemTable; const HallKey: Integer);
    // ������ ����� ������ ��� ��������� ����
    function GetTableTypeList: TList<TChooseTable>;

    function LockUserOrder(const OrderKey: Integer): Boolean;
    function UnLockUserOrder(const OrderKey: Integer): Boolean;

    function GetPayKindType(const MemTable: TkbmMemTable; const PayType: Integer;
      IsPlCard: Integer = 0; const IsExternal: Boolean = False): Boolean;
    procedure GetPaymentsCount(var CardCount, NoCashCount, PercCardCount, CashCount: Integer);
    function GetCashFiscalType: Integer;
    function GetUserRuleForPayment(const PayKey: Integer): Boolean;
    procedure GetNoCashGroupList(const MemTable: TkbmMemTable);

    function CreateNewOrder(const HeaderTable, LineTable, ModifyTable: TkbmMemTable; out OrderKey: Integer; const RevertQuantity: Boolean = False): Boolean;
    function SaveAndReloadOrder(const HeaderTable, LineTable, ModifyTable: TkbmMemTable; OrderKey: Integer): Boolean;
    // ���� OrderKey = -1 �� ����� �����
    function GetOrder(const HeaderTable, LineTable, ModifyTable: TkbmMemTable; OrderKey: Integer): Boolean;
    function GetOrderInfo(const AOrderKey: Integer): TrfOrder;
    function CloseModifyTable(const ModifyTable: TkbmMemTable): Boolean;

    function GetReservOrder(const HeaderTable, LineTable, ModifyTable: TkbmMemTable; OrderKey: Integer): Boolean;
    function CreateNewReservOrder(const HeaderTable, LineTable, ModifyTable: TkbmMemTable; out OrderKey: Integer): Boolean;
    //������� ��� ���
    function OrderIsPayed(const ID: Integer): Boolean;
    function OrderIsLocked(const ID: Integer): Boolean;
    //������� ��������
    function GetCauseDeleteList(const MemTable: TkbmMemTable): Boolean;
    { ������ ���� ������������� ������ }
    procedure GetWaiterList(AOrderList: TList<TrfUser>);
    procedure GetAllUserList(const MemTable: TkbmMemTable);
    procedure GetContactList(const MemTable: TkbmMemTable);
    function SaveContact(const MemTable: TkbmMemTable; var ContactID: Integer): Boolean;
    { ������ ���� ������������� ������ � ������� �� ������ ������ ���� ������ }
    procedure GetActiveWaiterList(AOrderList: TList<TrfUser>; const WithPrecheck: Boolean);
    function GetLogicDate: TDateTime;

    function GetModificationList(const MemTable: TkbmMemTable; const GoodKey: Integer; const ModifyGroupKey: Integer): Boolean;

    function GetIDByRUID(const XID: Integer; const DBID: Integer): Integer;
    function GetRUIDRecByXID(const XID, DBID: TID): TRUIDRec;
    function GetNextOrderNum: Integer;
    function CheckCountOrderByResp(const RespID: Integer): Boolean;

    function GetDiscount(const DiscKey, GoodKey: Integer;
      DocDate: TDateTime; PersDiscount: Currency; LineTime: TTime): Currency;
    function GetDiscountList(const MemTable: TkbmMemTable): Boolean;
    procedure GetDiscountCardList(const MemTable: TkbmMemTable);
    function GetDiscountCardInfo(const MemTable: TkbmMemTable; const CardID: Integer;
      const LDate: TDateTime; const Pass: String): Boolean;
    function CalcBonusSum(const DataSet: TDataSet; FLine: TkbmMemTable; var Bonus: Boolean; var PercDisc: Currency): Boolean;
    function GetPersonalCardInfo(const MemTable: TkbmMemTable;
      const Pass: String): Boolean;
    //������ ������������� ��������
    function GetDepartmentList(const MemTable: TkbmMemTable): Boolean;
    function GetUserGroupList(const MemTable: TkbmMemTable): Boolean;
    function AddUser(const EmplTable, GroupListTable: TkbmMemTable): Boolean;
    function UpdateUser(const EmplTable, GroupListTable: TkbmMemTable; UserKey: Integer;
      const FGroupList: TList<Integer>): Boolean;
    procedure GetEditUserInfo(const EmplTable, GroupListTable: TkbmMemTable; UserKey: Integer;
      const FGroupList: TList<Integer>);
    //������ � �������������
    procedure InitDisplay;
    function GetPrinterName: String;
    function GetPrinterInfo: TPrinterInfo;
    function GetReportTemplate(const Stream: TStream; const ID: Integer): Boolean;
    function SaveReportTemplate(const Stream: TStream; const ID: Integer): Boolean;
    procedure GetReportTemplateByPrnIDAndType(const ReportType, PrinterID: Integer; const Stream: TStream);
    procedure GetCustomReportList(const MemTable: TkbmMemTable);

    function GetHallBackGround(const Stream: TStream; const HallKey: Integer): Boolean;
    procedure GetCashInfo;

    function GetNameWaiterOnID(const ID: Integer; WithGroup, TwoRows: Boolean): String;

    function SavePayment(const ContactKey, OrderKey, PayKindKey, PersonalCardKey: Integer;
      Sum: Currency; Revert: Boolean = False): Boolean;

    function SaveRegisters(const Summ1, Summ2, Summ3, Summ4, SummReturn1, SummReturn2,
      SummReturn3, SummReturn4, PayInSumm, PayOutSumm: Currency; const RNM: String): Boolean;

    //1. ������ �������
    //2. ������� �����
    //3. �������� �����
    function SaveOrderLog(const WaiterKey, ManagerKey, OrderKey, OrderLineKey, Operation: Integer): Boolean;
    //������������
    function SaveReserv(const MemTable: TkbmMemTable): Boolean;
    procedure SaveReservAvansSum(const ID: Integer; const FSum: Currency);
    procedure DeleteReservation(const ID, OrderKey: Integer);
    procedure GetReservListByTable(const TableKey: Integer; const MemTable: TkbmMemTable);
    procedure FillGoodsByReserv(const LineTable, GoodDataSet: TkbmMemTable;
      const OrderKey: Integer);
    //reports
    function SavePrintDate(const ID: Integer): Boolean;
    function GetReportList(var MemTable: TkbmMemTable): Boolean;
    function CheckExternalPay(const ID: Integer): Boolean;
    procedure CanCloseDay;
    procedure CanOpenDay;

    procedure DoOnDisconnect;
    function TryToConnect(const Count: Integer): Boolean;
    //Cache
    procedure ClearCache;

    class function GetGroupMask(const AGroupID: Integer): Integer;
    class function RoundCost(const Cost: Currency): Currency;

    property UserName: String read FUserName;
 //   property UserKey: Integer read FUserKey;
    property ContactKey: Integer read FContactKey;
    property UserGroup: Integer read FUserGroup;
    property Options: TFrontOptions read FOptions write FOptions;

    property Display: TDisplay read GetDisplay;
    property CashCode: Integer read GetCashCode;
    property FiscalComPort: Integer read GetFiscalComPort;
    property CashNumber: Integer read GetCashNumber;
    property IsMainCash: Boolean read GetIsMainCash;
    property BaudRate: Integer read GetBaudRate;
    property ServerName: String read GetServerName;
    property QueryList: TgsQueryList read FQueryList;
    property CompanyKey: Integer read FCompanyKey;
    property CompanyName: String read FCompanyName;
    property ReadTransaction: TIBTransaction read GetReadTransaction;
    property DoFiscalLog: Boolean read FFiscalLog;
    property ComputerName: String read GetComputerName;
    property FrontConst: TFrontConst read FFrontConst;
  end;

  procedure GetHeaderTable(var DS: TkbmMemTable);
  procedure GetLineTable(var DS: TkbmMemTable);
  procedure GetModificationTable(var DS: TkbmMemTable);

implementation

uses
  Windows, Sysutils, CardCodeForm_Unit, TouchMessageBoxForm_Unit, Dialogs, FrontData_Unit, rfUtils_unit,
  rfWaitWindow_unit, rfCheckDatabase;

procedure GetHeaderTable(var DS: TkbmMemTable);
begin
  DS := TkbmMemTable.Create(nil);
  DS.FieldDefs.Add('ID', ftInteger, 0);
  DS.FieldDefs.Add('NUMBER', ftString, 20);
  DS.FieldDefs.Add('SUMNCU', ftFloat, 0);
  DS.FieldDefs.Add('usr$mn_printdate', ftDateTime, 0);
  DS.FieldDefs.Add('usr$sumncuwithdiscount', ftFloat, 0);
  DS.FieldDefs.Add('usr$respkey', ftInteger, 0);
  DS.FieldDefs.Add('usr$guestcount', ftInteger, 0);
  DS.FieldDefs.Add('usr$pay', ftInteger, 0);
  DS.FieldDefs.Add('usr$timeorder', ftTime, 0);
  DS.FieldDefs.Add('usr$timecloseorder', ftTime, 0);
  DS.FieldDefs.Add('usr$logicdate', ftDate, 0);
  DS.FieldDefs.Add('usr$discountncu', ftFloat, 0);
  DS.FieldDefs.Add('usr$sysnum', ftInteger, 0);
  DS.FieldDefs.Add('usr$register', ftString, 8);
  DS.FieldDefs.Add('usr$whopayoffkey', ftInteger, 0);
  DS.FieldDefs.Add('usr$vip', ftInteger, 0);
  DS.FieldDefs.Add('usr$disccardkey', ftInteger, 0);
  DS.FieldDefs.Add('usr$userdisckey', ftInteger, 0);
  DS.FieldDefs.Add('usr$discountkey', ftInteger, 0);
  DS.FieldDefs.Add('usr$bonussum', ftFloat, 0);
  DS.FieldDefs.Add('editorkey', ftInteger, 0);
  DS.FieldDefs.Add('editiondate', ftTimeStamp, 0);
  DS.FieldDefs.Add('creationdate', ftTimeStamp, 0);
  DS.FieldDefs.Add('USR$TABLEKEY', ftInteger, 0);
  DS.FieldDefs.Add('USR$COMPUTERNAME', ftString, 20);
  DS.FieldDefs.Add('USR$AVANSSUM', ftFloat, 0);
  DS.FieldDefs.Add('USR$RESERVKEY', ftInteger, 0);
  DS.CreateTable;
end;

procedure GetLineTable(var DS: TkbmMemTable);
begin
  DS := TkbmMemTable.Create(nil);
  DS.FieldDefs.Add('ID', ftInteger, 0);
  DS.FieldDefs.Add('number', ftString, 20);
  DS.FieldDefs.Add('GOODNAME', ftString, 40);
  DS.FieldDefs.Add('usr$mn_printdate', ftDateTime, 0);
  DS.FieldDefs.Add('usr$quantity', ftFloat, 0);
  DS.FieldDefs.Add('usr$costncu', ftFloat, 0);
  DS.FieldDefs.Add('usr$goodkey', ftInteger, 0);
  DS.FieldDefs.Add('usr$sumncuwithdiscount', ftFloat, 0);
  DS.FieldDefs.Add('usr$sumncu', ftFloat, 0);
  DS.FieldDefs.Add('usr$costncuwithdiscount', ftFloat, 0);
  DS.FieldDefs.Add('usr$sumdiscount', ftFloat, 0);
  DS.FieldDefs.Add('usr$persdiscount', ftFloat, 0);
  DS.FieldDefs.Add('usr$causedeletekey', ftInteger, 0);
  DS.FieldDefs.Add('usr$deleteamount', ftFloat, 0);
  DS.FieldDefs.Add('usr$doublebonus', ftInteger, 0);
  DS.FieldDefs.Add('editorkey', ftInteger, 0);
  DS.FieldDefs.Add('editiondate', ftTimeStamp, 0);
  DS.FieldDefs.Add('oldquantity', ftFloat, 0);
  DS.FieldDefs.Add('LINEKEY', ftInteger, 0);
  DS.FieldDefs.Add('STATEFIELD', ftInteger, 0);
  DS.FieldDefs.Add('MODIFYSTRING', ftString, 1024);
  DS.FieldDefs.Add('PARENT', ftInteger, 0);
  DS.FieldDefs.Add('EXTRAMODIFY', ftString, 60);
  DS.FieldDefs.Add('USR$COMPUTERNAME', ftString, 20);
  DS.FieldDefs.Add('creationdate', ftTimeStamp, 0);
  DS.FieldDefs.Add('USR$NOPRINT', ftInteger, 0);
  DS.CreateTable;
end;

procedure GetModificationTable(var DS: TkbmMemTable);
begin
  DS := TkbmMemTable.Create(nil);
  DS.FieldDefs.Add('MASTERKEY', ftInteger, 0);
  DS.FieldDefs.Add('MODIFYKEY', ftInteger, 0);
  DS.FieldDefs.Add('NAME', ftString, 40);
  DS.FieldDefs.Add('CLOSETIME', ftTime, 0);
  DS.CreateTable;
end;

{ TFrontBase }

constructor TFrontBase.Create;
begin
  inherited;

  FComputerName := '';

  FReadTransaction := TIBTransaction.Create(nil);
  FReadTransaction.Params.Add('read_committed');
  FReadTransaction.Params.Add('read');
  FReadTransaction.Params.Add('rec_version');
  FReadTransaction.Params.Add('nowait');

  FDataBase := TIBDataBase.Create(nil);
  FDataBase.LoginPrompt := False;
  FDataBase.DefaultTransaction := FReadTransaction;
  FReadTransaction.DefaultDatabase := FDataBase;

  FReadSQL := TIBSQL.Create(nil);
  FReadSQL.Transaction := FReadTransaction;

  FCheckTransaction := TIBTransaction.Create(nil);
  FCheckTransaction.DefaultDatabase := FDataBase;

  FCheckTransaction.Params.Add('concurrency');
  FCheckTransaction.Params.Add('nowait');
  FCheckTransaction.Params.Add('write');

  FCheckSQL := TIBSQL.Create(nil);
  FCheckSQL.Transaction := FCheckTransaction;

  FIDTransaction := TIBTransaction.Create(nil);
  FIDTransaction.DefaultDatabase := FDataBase;
  FIDTransaction.Params.Add('read_committed');
  FIDTransaction.Params.Add('read');
  FIDTransaction.Params.Add('rec_version');
  FIDTransaction.Params.Add('nowait');

  FIDSQL := TIBSQl.Create(nil);
  FIDSQL.Transaction := FIDTransaction;
  FIDSQL.SQL.Text := 'SELECT gen_id(gd_g_unique, 1) as id FROM rdb$database';

  try
    InitDB;
    CheckVersion(FDataBase);
    InitStorage;
    InitFrontConst;
  except
    raise;
  end;
  FDisplayInitialized := False;
  FCashCode := -1;
  FFiscalComPort := -1;
  FCashNumber := -1;
  FIsMainCash := False;

  try
    FQueryList := TgsQueryList.Create(FDataBase, nil, True);
    FrontData.BaseQueryList := FQueryList;
  except
    raise;
  end;

  CacheList := TDictionary<String, Integer>.Create();
end;

function TFrontBase.CreateNewOrder(const HeaderTable,
  LineTable, ModifyTable: TkbmMemTable; out OrderKey: Integer;
  const RevertQuantity: Boolean = False): Boolean;
var
  InsDoc, InsOrder, InsOrderLine, InsModify, DelModify, UpdParent:TIBSQL;
  updOrder, updDoc, UpdOrderLine: TIBSQL;
  MasterID, LineState, LineID: Integer;
const
  DocInsert =
    ' insert into gd_document (  ' +
    '     id,                    ' +
    '     parent,                ' +
    '     documenttypekey,       ' +
    '     number,                ' +
    '     documentdate,          ' +
    '     afull,                 ' +
    '     achag,                 ' +
    '     aview,                 ' +
    '     companykey,            ' +
    '     creatorkey,            ' +
    '     creationdate,          ' +
    '     editorkey,             ' +
    '     editiondate,           ' +
    '     usr$mn_printdate)      ' +
    '   values (                 ' +
    '     :id,                   ' +
    '     :parent,               ' +
    '     :documenttypekey,      ' +
    '     :number,               ' +
    '     current_date,          ' +
    '     -1,                    ' +
    '     -1,                    ' +
    '     -1,                    ' +
    '     :companykey,           ' +
    '     :creatorkey,           ' +
    '     current_timestamp,     ' +
    '     :editorkey,            ' +
    '     current_timestamp,     ' +
    '     :usr$mn_printdate)     ' ;

  DocUpdate =
    '  update gd_document          ' +
    '  set editorkey = :editorkey, ' +
    '    editiondate = current_timestamp, ' +
    '    number = :number          ' +
    '  where id = :id              ';

  OrderInsert =
    '   insert into usr$mn_order (   ' +
    '       documentkey,             ' +
    '       usr$respkey,             ' +
    '       usr$guestcount,          ' +
    '       usr$timeorder,           ' +
    '       usr$timecloseorder,      ' +
    '       usr$logicdate,           ' +
    '       usr$discountncu,         ' +
    '       usr$disccardkey,         ' +
    '       usr$userdisckey,         ' +
    '       usr$discountkey,         ' +
    '       usr$bonussum,            ' +
    '       usr$tablekey,            ' +
    '       usr$computername,        ' +
    '       USR$WHOPAYOFFKEY,        ' +
    '       USR$AVANSSUM,            ' +
    '       USR$RESERVKEY)           ' +
    '     values (                   ' +
    '       :documentkey,            ' +
    '       :usr$respkey,            ' +
    '       :usr$guestcount,         ' +
    '       current_time,            ' +
    '       :usr$timecloseorder,     ' +
    '       :usr$logicdate,          ' +
    '       :usr$discountncu,        ' +
    '       :usr$disccardkey,        ' +
    '       :usr$userdisckey,        ' +
    '       :usr$discountkey,        ' +
    '       :usr$bonussum,           ' +
    '       :usr$tablekey,           ' +
    '       :usr$computername,       ' +
    '       :USR$WHOPAYOFFKEY,       ' +
    '       :USR$AVANSSUM,           ' +
    '       :USR$RESERVKEY)          ' ;

  OrderLineInsert =
    '  insert into usr$mn_orderline (    ' +
    '      documentkey,                  ' +
    '      masterkey,                    ' +
    '      usr$quantity,                 ' +
    '      usr$costncu,                  ' +
    '      usr$goodkey,                  ' +
    '      usr$sumncuwithdiscount,       ' +
    '      usr$sumncu,                   ' +
    '      usr$costncuwithdiscount,      ' +
    '      usr$sumdiscount,              ' +
    '      usr$persdiscount,             ' +
    '      usr$causedeletekey,           ' +
    '      usr$deleteamount,             ' +
    '      usr$costeqwithdiscount,       ' +
    '      usr$costeq,                   ' +
    '      usr$register,                 ' +
    '      usr$logicdate,                ' +
    '      usr$depotkey,                 ' +
    '      usr$doublebonus,              ' +
    '      usr$extramodify,              ' +
    '      usr$computername)             ' +
    '    values (                        ' +
    '      :documentkey,                 ' +
    '      :masterkey,                   ' +
    '      :usr$quantity,                ' +
    '      :usr$costncu,                 ' +
    '      :usr$goodkey,                 ' +
    '      :usr$sumncuwithdiscount,      ' +
    '      :usr$sumncu,                  ' +
    '      :usr$costncuwithdiscount,     ' +
    '      :usr$sumdiscount,             ' +
    '      :usr$persdiscount,            ' +
    '      :usr$causedeletekey,          ' +
    '      :usr$deleteamount,            ' +
    '      :usr$costeqwithdiscount,      ' +
    '      :usr$costeq,                  ' +
    '      :usr$register,                ' +
    '      :usr$logicdate,               ' +
    '      :usr$depotkey,                ' +
    '      :usr$doublebonus,             ' +
    '      :usr$extramodify,             ' +
    '      :usr$computername)            ' ;

  UpdateOrder =
    '      update usr$mn_order                      ' +
    '      set usr$respkey = :usr$respkey,          ' +
    '          usr$guestcount = :usr$guestcount,    ' +
    '          usr$timeorder = :usr$timeorder,      ' +
    '          usr$logicdate = :usr$logicdate,      ' +
    '          usr$discountncu = :usr$discountncu,  ' +
    '          usr$disccardkey = :usr$disccardkey,  ' +
    '          usr$userdisckey = :usr$userdisckey,  ' +
    '          usr$discountkey = :usr$discountkey,  ' +
    '          usr$bonussum = :usr$bonussum,        ' +
    '          usr$timecloseorder = :usr$timecloseorder, ' +
    '          usr$pay = :usr$pay,                  ' +
    '          usr$computername = :usr$computername,' +
    '          USR$ISLOCKED = 0,                    ' +
    '          usr$tablekey = :usr$tablekey,        ' +
    '          usr$sysnum = :usr$sysnum,            ' +
    '          usr$register = :usr$register,        ' +
    '          USR$WHOPAYOFFKEY = :USR$WHOPAYOFFKEY ' +
    '      where (documentkey = :documentkey)       ';

  UpdateOrderLine =
    '      update usr$mn_orderline                                   ' +
    '      set masterkey = :masterkey,                               ' +
    '          usr$quantity = :usr$quantity,                         ' +
    '          usr$costncu = :usr$costncu,                           ' +
    '          usr$goodkey = :usr$goodkey,                           ' +
    '          usr$sumncuwithdiscount = :usr$sumncuwithdiscount,     ' +
    '          usr$sumncu = :usr$sumncu,                             ' +
    '          usr$costncuwithdiscount = :usr$costncuwithdiscount,   ' +
    '          usr$sumdiscount = :usr$sumdiscount,                   ' +
    '          usr$persdiscount = :usr$persdiscount,                 ' +
    '          usr$causedeletekey = :usr$causedeletekey,             ' +
    '          usr$deleteamount = :usr$deleteamount,                 ' +
    '          usr$logicdate = :usr$logicdate,                       ' +
    '          usr$doublebonus = :usr$doublebonus,                   ' +
    '          usr$extramodify = :usr$extramodify                    ' +
    '      where (documentkey = :documentkey)                        ';

  DeleteModify = ' DELETE FROM USR$CROSS509_157767346 ' +
    ' WHERE usr$mn_orderlinekey = :PosKey ';

  InsertModify = ' INSERT INTO USR$CROSS509_157767346 (usr$mn_orderlinekey, usr$mn_modifykey) ' +
    ' VALUES (:LineKey, :ModKey) ';

  UpdateParent =
    ' EXECUTE BLOCK ' +
    ' AS ' +
    ' DECLARE VARIABLE ID INTEGER; ' +
    ' DECLARE VARIABLE PARENT INTEGER; ' +
    ' BEGIN ' +
    '   ID = %s; ' +
    '   PARENT = %s; ' +
    '   ' +
    '   UPDATE GD_DOCUMENT ' +
    '   SET PARENT = :PARENT ' +
    '   WHERE ID = :ID; ' +
    '                   ' +
    '   UPDATE usr$mn_orderline ' +
    '   SET MASTERKEY = :PARENT ' +
    '   WHERE DOCUMENTKEY = :ID; ' +
    ' END ';

begin
  Result := False;
  //���� ����� ������ ��� ID, ������ ������ INSERT, ����� UPDATE
  //��� ������� ������� ���� ���������
  //0 ������ � ������ �������� �� ������
  //1 ���� �������� ������� � ��������
  //2 ������ update �������

  //��� ����������� ����� ���������?
  //��� ����� logicdate?

  InsDoc := TIBSQL.Create(nil);
  InsDoc.Transaction := FCheckTransaction;
  InsDoc.SQL.Text := DocInsert;

  updDoc := TIBSQL.Create(nil);
  updDoc.Transaction := FCheckTransaction;
  updDoc.SQL.Text := DocUpdate;

  InsOrder := TIBSQL.Create(nil);
  InsOrder.Transaction := FCheckTransaction;
  InsOrder.SQL.Text := OrderInsert;

  InsOrderLine := TIBSQL.Create(nil);
  InsOrderLine.Transaction := FCheckTransaction;
  InsOrderLine.SQL.Text := OrderLineInsert;

  updOrder := TIBSQL.Create(nil);
  updOrder.Transaction := FCheckTransaction;
  updOrder.SQL.Text := UpdateOrder;

  UpdOrderLine := TIBSQL.Create(nil);
  UpdOrderLine.Transaction := FCheckTransaction;
  UpdOrderLine.SQL.Text := UpdateOrderLine;

  InsModify := TIBSQL.Create(nil);
  InsModify.Transaction := FCheckTransaction;
  InsModify.SQL.Text := InsertModify;

  DelModify := TIBSQL.Create(nil);
  DelModify.Transaction := FCheckTransaction;
  DelModify.SQL.Text := DeleteModify;

  UpdParent := TIBSQL.Create(nil);
  UpdParent.Transaction := FCheckTransaction;
  UpdParent.ParamCheck := False;

  try
    try
      if not FCheckTransaction.InTransaction then
        FCheckTransaction.StartTransaction;

      MasterID := -1;
      HeaderTable.First;
      if not HeaderTable.Eof then
      begin
        if HeaderTable.FieldByName('ID').AsInteger <> 0 then
        begin
          MasterID := HeaderTable.FieldByName('ID').AsInteger;
          //��������� �����
          updOrder.ParamByName('usr$respkey').Value := HeaderTable.FieldByName('usr$respkey').Value;
          updOrder.ParamByName('usr$guestcount').AsInteger := HeaderTable.FieldByName('usr$guestcount').AsInteger;
          updOrder.ParamByName('usr$timeorder').Value := HeaderTable.FieldByName('usr$timeorder').Value; //????
          updOrder.ParamByName('usr$logicdate').Value := HeaderTable.FieldByName('usr$logicdate').Value; //????
          updOrder.ParamByName('usr$discountncu').AsCurrency := HeaderTable.FieldByName('usr$discountncu').AsCurrency;
          updOrder.ParamByName('usr$disccardkey').Value := HeaderTable.FieldByName('usr$disccardkey').Value;
          updOrder.ParamByName('usr$userdisckey').Value := HeaderTable.FieldByName('usr$userdisckey').Value;
          updOrder.ParamByName('usr$discountkey').Value := HeaderTable.FieldByName('usr$discountkey').Value;
          updOrder.ParamByName('usr$bonussum').AsCurrency := HeaderTable.FieldByName('usr$bonussum').AsCurrency;
          updOrder.ParamByName('usr$timecloseorder').Value := HeaderTable.FieldByName('usr$timecloseorder').Value;
          updOrder.ParamByName('documentkey').AsInteger := HeaderTable.FieldByName('ID').AsInteger;
          updOrder.ParamByName('usr$pay').AsInteger := HeaderTable.FieldByName('usr$pay').AsInteger;
          updOrder.ParamByName('usr$computername').AsString := ComputerName;
          updOrder.ParamByName('usr$tablekey').AsInteger := HeaderTable.FieldByName('usr$tablekey').AsInteger;
          updOrder.ParamByName('usr$sysnum').AsInteger := HeaderTable.FieldByName('usr$sysnum').AsInteger;
          updOrder.ParamByName('usr$register').AsString := HeaderTable.FieldByName('usr$register').AsString;
          updOrder.ParamByName('USR$WHOPAYOFFKEY').Value := HeaderTable.FieldByName('USR$WHOPAYOFFKEY').Value;
          updOrder.ExecQuery;

          updDoc.Close;
          updDoc.ParamByName('ID').AsInteger := HeaderTable.FieldByName('ID').AsInteger;
          updDoc.ParamByName('NUMBER').AsString := HeaderTable.FieldByName('NUMBER').AsString;
          updDoc.ParamByName('editorkey').AsInteger := FContactKey;
          updDoc.ExecQuery;
        end else
        begin
          MasterID := GetNextID;

          InsDoc.ParamByName('ID').AsInteger := MasterID;
          InsDoc.ParamByName('PARENT').AsVariant := '';
          InsDoc.ParamByName('documenttypekey').AsInteger := FrontConst.DocumentTypeKey_Zakaz;
          InsDoc.ParamByName('NUMBER').AsString := HeaderTable.FieldByName('NUMBER').AsString;
          InsDoc.ParamByName('companykey').AsInteger := FCompanyKey;
          InsDoc.ParamByName('creatorkey').AsInteger := FContactKey;
          InsDoc.ParamByName('editorkey').AsInteger := FContactKey;
          InsDoc.ParamByName('usr$mn_printdate').Value := HeaderTable.FieldByName('usr$mn_printdate').Value;
          InsDoc.ExecQuery;

          InsOrder.ParamByName('usr$respkey').Value := FContactKey;
          InsOrder.ParamByName('usr$guestcount').AsInteger := HeaderTable.FieldByName('usr$guestcount').AsInteger;
          InsOrder.ParamByName('usr$logicdate').AsDate := GetLogicDate;
          InsOrder.ParamByName('usr$discountncu').AsCurrency := HeaderTable.FieldByName('usr$discountncu').AsCurrency;
          InsOrder.ParamByName('usr$disccardkey').Value := HeaderTable.FieldByName('usr$disccardkey').Value;
          InsOrder.ParamByName('usr$userdisckey').Value := HeaderTable.FieldByName('usr$userdisckey').Value;
          InsOrder.ParamByName('usr$discountkey').Value := HeaderTable.FieldByName('usr$discountkey').Value;
          InsOrder.ParamByName('usr$bonussum').AsCurrency := HeaderTable.FieldByName('usr$bonussum').AsCurrency;
          InsOrder.ParamByName('usr$timecloseorder').Value := HeaderTable.FieldByName('usr$timecloseorder').Value;
          InsOrder.ParamByName('documentkey').AsInteger := MasterID;
          InsOrder.ParamByName('usr$tablekey').AsInteger := HeaderTable.FieldByName('usr$tablekey').AsInteger;
          if HeaderTable.FieldByName('USR$COMPUTERNAME').AsString <> '' then
            InsOrder.ParamByName('usr$computername').AsString := HeaderTable.FieldByName('USR$COMPUTERNAME').AsString
          else
            InsOrder.ParamByName('usr$computername').AsString := ComputerName;
          InsOrder.ParamByName('USR$WHOPAYOFFKEY').Value := HeaderTable.FieldByName('USR$WHOPAYOFFKEY').Value;
          InsOrder.ParamByName('USR$AVANSSUM').AsCurrency := HeaderTable.FieldByName('USR$AVANSSUM').AsCurrency;
          InsOrder.ParamByName('USR$RESERVKEY').Value := HeaderTable.FieldByName('USR$RESERVKEY').Value;
          InsOrder.ExecQuery;
        end;
      end;

      Assert(MasterID <> -1, 'wrong master ID');

      LineTable.First;
      while not LineTable.Eof do
      begin
        LineState := LineTable.FieldByName('STATEFIELD').AsInteger;
        case LineState of
          cn_StateNothing:
            begin
              //������ �� ������
            end;
          cn_StateInsert:
            begin
              //��������� ������
              InsDoc.Close;
              InsOrderLine.Close;

              if LineTable.FieldByName('ID').IsNull then
                LineID := GetNextID
              else
                LineID := LineTable.FieldByName('ID').AsInteger;
              InsDoc.ParamByName('ID').AsInteger := LineID;
              InsDoc.ParamByName('PARENT').AsInteger := MasterID;
              InsDoc.ParamByName('documenttypekey').AsInteger := FrontConst.DocumentTypeKey_Zakaz;
              InsDoc.ParamByName('NUMBER').AsString := HeaderTable.FieldByName('NUMBER').AsString;
              InsDoc.ParamByName('companykey').AsInteger := FCompanyKey;
              InsDoc.ParamByName('creatorkey').AsInteger := FContactKey;
              InsDoc.ParamByName('editorkey').AsInteger := FContactKey;
              InsDoc.ParamByName('usr$mn_printdate').Value := LineTable.FieldByName('usr$mn_printdate').Value;
              InsDoc.ExecQuery;

              InsOrderLine.ParamByName('masterkey').AsInteger := MasterID;
              if RevertQuantity then
              begin
                InsOrderLine.ParamByName('usr$quantity').AsCurrency := -LineTable.FieldByName('usr$quantity').AsCurrency;
                InsOrderLine.ParamByName('usr$sumncu').AsCurrency := -LineTable.FieldByName('usr$sumncu').AsCurrency;
                InsOrderLine.ParamByName('usr$sumncuwithdiscount').AsCurrency := -LineTable.FieldByName('usr$sumncuwithdiscount').AsCurrency;
                InsOrderLine.ParamByName('usr$costncuwithdiscount').AsCurrency := -LineTable.FieldByName('usr$costncuwithdiscount').AsCurrency;
              end else
              begin
                InsOrderLine.ParamByName('usr$quantity').AsCurrency := LineTable.FieldByName('usr$quantity').AsCurrency;
                InsOrderLine.ParamByName('usr$sumncu').AsCurrency := LineTable.FieldByName('usr$sumncu').AsCurrency;
                InsOrderLine.ParamByName('usr$sumncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$sumncuwithdiscount').AsCurrency;
                InsOrderLine.ParamByName('usr$costncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$costncuwithdiscount').AsCurrency;
              end;
              InsOrderLine.ParamByName('usr$costncu').AsCurrency := LineTable.FieldByName('usr$costncu').AsCurrency;
              InsOrderLine.ParamByName('usr$goodkey').Value := LineTable.FieldByName('usr$goodkey').Value;
              InsOrderLine.ParamByName('usr$sumdiscount').AsCurrency := LineTable.FieldByName('usr$sumdiscount').AsCurrency;
              InsOrderLine.ParamByName('usr$persdiscount').AsCurrency := LineTable.FieldByName('usr$persdiscount').AsCurrency;
              InsOrderLine.ParamByName('usr$causedeletekey').Value := LineTable.FieldByName('usr$causedeletekey').Value;
              InsOrderLine.ParamByName('usr$deleteamount').AsCurrency := LineTable.FieldByName('usr$deleteamount').AsCurrency;
              InsOrderLine.ParamByName('usr$logicdate').AsDate := GetLogicDate;
              InsOrderLine.ParamByName('usr$doublebonus').AsInteger := LineTable.FieldByName('usr$doublebonus').AsInteger;
              InsOrderLine.ParamByName('documentkey').AsInteger := LineID;
              InsOrderLine.ParamByName('usr$register').AsVariant := ''; //????
              InsOrderLine.ParamByName('usr$costeqwithdiscount').AsVariant := ''; //????
              InsOrderLine.ParamByName('usr$costeq').AsVariant := '';  //????
              InsOrderLine.ParamByName('usr$depotkey').AsVariant := ''; //????
              InsOrderLine.ParamByName('usr$extramodify').AsString := LineTable.FieldByName('extramodify').AsString;
              if LineTable.FieldByName('USR$COMPUTERNAME').AsString <> '' then
                InsOrderLine.ParamByName('usr$computername').AsString := LineTable.FieldByName('USR$COMPUTERNAME').AsString
              else
                InsOrderLine.FieldByName('USR$COMPUTERNAME').AsString := ComputerName;
              InsOrderLine.ExecQuery;

              ModifyTable.First;
              while not ModifyTable.Eof do
              begin
                InsModify.Close;
                InsModify.ParamByName('LINEKEY').AsInteger := LineID;
                InsModify.ParamByName('MODKEY').AsInteger := ModifyTable.FieldByName('MODIFYKEY').AsInteger;
                InsModify.ExecQuery;

                ModifyTable.Next;
              end;
            end;
          cn_StateUpdate:
            begin
              //��������� ������
              UpdOrderLine.Close;
              UpdOrderLine.ParamByName('masterkey').AsInteger := MasterID;
              UpdOrderLine.ParamByName('usr$quantity').AsCurrency := LineTable.FieldByName('usr$quantity').AsCurrency;
              UpdOrderLine.ParamByName('usr$costncu').AsCurrency := LineTable.FieldByName('usr$costncu').AsCurrency;
              UpdOrderLine.ParamByName('usr$goodkey').Value := LineTable.FieldByName('usr$goodkey').Value;
              UpdOrderLine.ParamByName('usr$sumncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$sumncuwithdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$sumncu').AsCurrency := LineTable.FieldByName('usr$sumncu').AsCurrency;
              UpdOrderLine.ParamByName('usr$costncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$costncuwithdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$sumdiscount').AsCurrency := LineTable.FieldByName('usr$sumdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$persdiscount').AsCurrency := LineTable.FieldByName('usr$persdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$causedeletekey').Value := LineTable.FieldByName('usr$causedeletekey').Value;
              UpdOrderLine.ParamByName('usr$deleteamount').AsCurrency := LineTable.FieldByName('usr$deleteamount').AsCurrency;
              UpdOrderLine.ParamByName('usr$logicdate').AsDate := GetLogicDate; //????
              UpdOrderLine.ParamByName('usr$doublebonus').AsInteger := LineTable.FieldByName('usr$doublebonus').AsInteger;
              UpdOrderLine.ParamByName('usr$extramodify').AsString := LineTable.FieldByName('extramodify').AsString;
              UpdOrderLine.ParamByName('documentkey').AsInteger := LineTable.FieldByName('ID').AsInteger;
              UpdOrderLine.ExecQuery;

              updDoc.Close;
              updDoc.ParamByName('ID').AsInteger := LineTable.FieldByName('ID').AsInteger;
              updDoc.ParamByName('editorkey').AsInteger := FContactKey;
              updDoc.ExecQuery;

              DelModify.Close;
              DelModify.ParamByName('POSKEY').AsInteger := LineTable.FieldByName('ID').AsInteger;
              DelModify.ExecQuery;
              // �� ������ ������
              if ModifyTable.TransactionLevel > 0 then
                ModifyTable.Commit;
              ModifyTable.First;
              while not ModifyTable.Eof do
              begin
                InsModify.Close;
                InsModify.ParamByName('LINEKEY').AsInteger := LineTable.FieldByName('ID').AsInteger;
                InsModify.ParamByName('MODKEY').AsInteger := ModifyTable.FieldByName('MODIFYKEY').AsInteger;
                InsModify.ExecQuery;

                ModifyTable.Next;
              end;
            end;

          cn_StateUpdateParent: // �������� parent
            begin
              UpdParent.Close;
              UpdParent.SQL.Text := Format(UpdateParent,
                [LineTable.FieldByName('ID').AsString, LineTable.FieldByName('PARENT').AsString]);
              UpdParent.ExecQuery;
            end;
        else
          Assert(False, 'wrong type state field');
        end;

        LineTable.Next;
      end;
      Result := True;
      OrderKey := MasterID;
    except
      on E: EIBInterBaseError do
      begin
        if (E.IBErrorCode = isc_lost_db_connection) or (E.IBErrorCode = isc_net_read_err)
          or (E.IBErrorCode = isc_net_read_err) or (E.IBErrorCode = isc_net_write_err) then
            DoOnDisconnect
        else begin
          Touch_MessageBox('��������', '������ ��� ���������� ���� ' + E.Message, MB_OK, mtError);
          FCheckTransaction.Rollback;
        end;
      end;
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ���� ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    try
      if FCheckTransaction.InTransaction then
        FCheckTransaction.Commit;
    except
      on E: EIBInterBaseError do
      begin
        if (E.IBErrorCode = isc_lost_db_connection) or (E.IBErrorCode = isc_net_read_err)
          or (E.IBErrorCode = isc_net_read_err) or (E.IBErrorCode = isc_net_write_err) then
          // ������ �� ������
        else
          raise;
      end;
    end;

    InsDoc.Free;
    updDoc.Free;
    InsOrder.Free;
    InsOrderLine.Free;
    updOrder.Free;
    UpdOrderLine.Free;
    InsModify.Free;
    DelModify.Free;
    UpdParent.Free;
  end;
end;

function TFrontBase.CreateNewReservOrder(const HeaderTable, LineTable,
  ModifyTable: TkbmMemTable; out OrderKey: Integer): Boolean;
var
  InsDoc, InsOrder, InsOrderLine: TIBSQL;
  updOrder, updDoc, UpdOrderLine, UpdReserv: TIBSQL;
  MasterID, LineState, LineID: Integer;
const
  DocInsert =
    ' insert into gd_document (  ' +
    '     id,                    ' +
    '     parent,                ' +
    '     documenttypekey,       ' +
    '     number,                ' +
    '     documentdate,          ' +
    '     afull,                 ' +
    '     achag,                 ' +
    '     aview,                 ' +
    '     companykey,            ' +
    '     creatorkey,            ' +
    '     creationdate,          ' +
    '     editorkey,             ' +
    '     editiondate,           ' +
    '     usr$mn_printdate)      ' +
    '   values (                 ' +
    '     :id,                   ' +
    '     :parent,               ' +
    '     :documenttypekey,      ' +
    '     :number,               ' +
    '     current_date,          ' +
    '     -1,                    ' +
    '     -1,                    ' +
    '     -1,                    ' +
    '     :companykey,           ' +
    '     :creatorkey,           ' +
    '     current_timestamp,     ' +
    '     :editorkey,            ' +
    '     current_timestamp,     ' +
    '     :usr$mn_printdate)     ' ;

  DocUpdate =
    '  update gd_document          ' +
    '  set editorkey = :editorkey, ' +
    '    editiondate = current_timestamp, ' +
    '    number = :number          ' +
    '  where id = :id              ';

  OrderInsert =
    '   insert into USR$MN_RESERVORDER ( ' +
    '       documentkey,             ' +
    '       usr$guestcount)          ' +
    '     values (                   ' +
    '       :documentkey,            ' +
    '       :usr$guestcount)         ' ;

  OrderLineInsert =
    '  insert into usr$mn_reservorderline (    ' +
    '      documentkey,                  ' +
    '      masterkey,                    ' +
    '      usr$quantity,                 ' +
    '      usr$costncu,                  ' +
    '      usr$goodkey,                  ' +
    '      usr$sumncuwithdiscount,       ' +
    '      usr$sumncu,                   ' +
    '      usr$costncuwithdiscount,      ' +
    '      usr$sumdiscount,              ' +
    '      usr$persdiscount,             ' +
    '      usr$logicdate,                ' +
    '      usr$doublebonus)              ' +
    '    values (                        ' +
    '      :documentkey,                 ' +
    '      :masterkey,                   ' +
    '      :usr$quantity,                ' +
    '      :usr$costncu,                 ' +
    '      :usr$goodkey,                 ' +
    '      :usr$sumncuwithdiscount,      ' +
    '      :usr$sumncu,                  ' +
    '      :usr$costncuwithdiscount,     ' +
    '      :usr$sumdiscount,             ' +
    '      :usr$persdiscount,            ' +
    '      :usr$logicdate,               ' +
    '      :usr$doublebonus)             ' ;

  UpdateOrder =
    '      update usr$mn_order                      ' +
    '      set USR$ISLOCKED = 0,                    ' +
    '          USR$GUESTCOUNT = :USR$GUESTCOUNT     ' +
    '      where (documentkey = :documentkey)       ';

  UpdateOrderLine =
    '      update usr$mn_reservorderline                             ' +
    '      set masterkey = :masterkey,                               ' +
    '          usr$quantity = :usr$quantity,                         ' +
    '          usr$costncu = :usr$costncu,                           ' +
    '          usr$goodkey = :usr$goodkey,                           ' +
    '          usr$sumncuwithdiscount = :usr$sumncuwithdiscount,     ' +
    '          usr$sumncu = :usr$sumncu,                             ' +
    '          usr$costncuwithdiscount = :usr$costncuwithdiscount,   ' +
    '          usr$sumdiscount = :usr$sumdiscount,                   ' +
    '          usr$persdiscount = :usr$persdiscount,                 ' +
    '          usr$logicdate = :usr$logicdate,                       ' +
    '          usr$doublebonus = :usr$doublebonus                    ' +
    '      where (documentkey = :documentkey)                        ';

  UpdateReserv =
    ' UPDATE USR$MN_RESERVATION R ' +
    ' SET R.USR$ORDERKEY = :DOC ' +
    ' WHERE R.ID = :ID ';

begin
  Result := False;
  //���� ����� ������ ��� ID, ������ ������ INSERT, ����� UPDATE
  //��� ������� ������� ���� ���������
  //0 ������ � ������ �������� �� ������
  //1 ���� �������� ������� � ��������
  //2 ������ update �������

  InsDoc := TIBSQL.Create(nil);
  InsDoc.Transaction := FCheckTransaction;
  InsDoc.SQL.Text := DocInsert;

  updDoc := TIBSQL.Create(nil);
  updDoc.Transaction := FCheckTransaction;
  updDoc.SQL.Text := DocUpdate;

  InsOrder := TIBSQL.Create(nil);
  InsOrder.Transaction := FCheckTransaction;
  InsOrder.SQL.Text := OrderInsert;

  InsOrderLine := TIBSQL.Create(nil);
  InsOrderLine.Transaction := FCheckTransaction;
  InsOrderLine.SQL.Text := OrderLineInsert;

  updOrder := TIBSQL.Create(nil);
  updOrder.Transaction := FCheckTransaction;
  updOrder.SQL.Text := UpdateOrder;

  UpdOrderLine := TIBSQL.Create(nil);
  UpdOrderLine.Transaction := FCheckTransaction;
  UpdOrderLine.SQL.Text := UpdateOrderLine;

  UpdReserv := TIBSQL.Create(nil);
  UpdReserv.Transaction := FCheckTransaction;
  UpdReserv.SQL.Text := UpdateReserv;
  try
    try
      if not FCheckTransaction.InTransaction then
        FCheckTransaction.StartTransaction;

      MasterID := -1;
      HeaderTable.First;
      if not HeaderTable.Eof then
      begin
        if HeaderTable.FieldByName('ID').AsInteger <> 0 then
        begin
          MasterID := HeaderTable.FieldByName('ID').AsInteger;
          //��������� �����;
          updOrder.ParamByName('USR$GUESTCOUNT').AsInteger := HeaderTable.FieldByName('USR$GUESTCOUNT').AsInteger;
          updOrder.ExecQuery;

          updDoc.Close;
          updDoc.ParamByName('ID').AsInteger := HeaderTable.FieldByName('ID').AsInteger;
          updDoc.ParamByName('NUMBER').AsString := HeaderTable.FieldByName('NUMBER').AsString;
          updDoc.ParamByName('editorkey').AsInteger := FContactKey;
          updDoc.ExecQuery;
        end else
        begin
          MasterID := GetNextID;

          InsDoc.ParamByName('ID').AsInteger := MasterID;
          InsDoc.ParamByName('PARENT').AsVariant := '';
          InsDoc.ParamByName('documenttypekey').AsInteger := FrontConst.DocumentTypeKey_ZakazRezerv;
          InsDoc.ParamByName('NUMBER').AsString := HeaderTable.FieldByName('NUMBER').AsString;
          InsDoc.ParamByName('companykey').AsInteger := FCompanyKey;
          InsDoc.ParamByName('creatorkey').AsInteger := FContactKey;
          InsDoc.ParamByName('editorkey').AsInteger := FContactKey;
          InsDoc.ParamByName('usr$mn_printdate').Value := HeaderTable.FieldByName('usr$mn_printdate').Value;
          InsDoc.ExecQuery;

          InsOrder.ParamByName('documentkey').AsInteger := MasterID;
          InsOrder.ParamByName('USR$GUESTCOUNT').AsInteger := HeaderTable.FieldByName('USR$GUESTCOUNT').AsInteger;
          InsOrder.ExecQuery;

          UpdReserv.ParamByName('ID').AsInteger := HeaderTable.FieldByName('USR$RESERVKEY').AsInteger;
          UpdReserv.ParamByName('DOC').AsInteger := MasterID;
          UpdReserv.ExecQuery;
        end;
      end;

      Assert(MasterID <> -1, 'wrong master ID');

      LineTable.First;
      while not LineTable.Eof do
      begin
        LineState := LineTable.FieldByName('STATEFIELD').AsInteger;
        case LineState of
          cn_StateNothing:
            begin
              //������ �� ������
            end;
          cn_StateInsert:
            begin
              //��������� ������
              InsDoc.Close;
              InsOrderLine.Close;

              if LineTable.FieldByName('ID').IsNull then
                LineID := GetNextID
              else
                LineID := LineTable.FieldByName('ID').AsInteger;
              InsDoc.ParamByName('ID').AsInteger := LineID;
              InsDoc.ParamByName('PARENT').AsInteger := MasterID;
              InsDoc.ParamByName('documenttypekey').AsInteger := FrontConst.DocumentTypeKey_ZakazRezerv;
              InsDoc.ParamByName('NUMBER').AsString := HeaderTable.FieldByName('NUMBER').AsString;
              InsDoc.ParamByName('companykey').AsInteger := FCompanyKey;
              InsDoc.ParamByName('creatorkey').AsInteger := FContactKey;
              InsDoc.ParamByName('editorkey').AsInteger := FContactKey;
              InsDoc.ParamByName('usr$mn_printdate').Value := LineTable.FieldByName('usr$mn_printdate').Value;
              InsDoc.ExecQuery;

              InsOrderLine.ParamByName('masterkey').AsInteger := MasterID;
              InsOrderLine.ParamByName('usr$quantity').AsCurrency := LineTable.FieldByName('usr$quantity').AsCurrency;
              InsOrderLine.ParamByName('usr$sumncu').AsCurrency := LineTable.FieldByName('usr$sumncu').AsCurrency;
              InsOrderLine.ParamByName('usr$sumncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$sumncuwithdiscount').AsCurrency;
              InsOrderLine.ParamByName('usr$costncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$costncuwithdiscount').AsCurrency;
              InsOrderLine.ParamByName('usr$costncu').AsCurrency := LineTable.FieldByName('usr$costncu').AsCurrency;
              InsOrderLine.ParamByName('usr$goodkey').Value := LineTable.FieldByName('usr$goodkey').Value;
              InsOrderLine.ParamByName('usr$sumdiscount').AsCurrency := LineTable.FieldByName('usr$sumdiscount').AsCurrency;
              InsOrderLine.ParamByName('usr$persdiscount').AsCurrency := LineTable.FieldByName('usr$persdiscount').AsCurrency;
              InsOrderLine.ParamByName('usr$logicdate').AsDate := GetLogicDate;
              InsOrderLine.ParamByName('usr$doublebonus').AsInteger := LineTable.FieldByName('usr$doublebonus').AsInteger;
              InsOrderLine.ParamByName('documentkey').AsInteger := LineID;
              InsOrderLine.ExecQuery;
            end;
          cn_StateUpdate:
            begin
              //��������� ������
              UpdOrderLine.Close;
              UpdOrderLine.ParamByName('masterkey').AsInteger := MasterID;
              UpdOrderLine.ParamByName('usr$quantity').AsCurrency := LineTable.FieldByName('usr$quantity').AsCurrency;
              UpdOrderLine.ParamByName('usr$costncu').AsCurrency := LineTable.FieldByName('usr$costncu').AsCurrency;
              UpdOrderLine.ParamByName('usr$goodkey').Value := LineTable.FieldByName('usr$goodkey').Value;
              UpdOrderLine.ParamByName('usr$sumncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$sumncuwithdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$sumncu').AsCurrency := LineTable.FieldByName('usr$sumncu').AsCurrency;
              UpdOrderLine.ParamByName('usr$costncuwithdiscount').AsCurrency := LineTable.FieldByName('usr$costncuwithdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$sumdiscount').AsCurrency := LineTable.FieldByName('usr$sumdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$persdiscount').AsCurrency := LineTable.FieldByName('usr$persdiscount').AsCurrency;
              UpdOrderLine.ParamByName('usr$logicdate').AsDate := GetLogicDate;
              UpdOrderLine.ParamByName('usr$doublebonus').AsInteger := LineTable.FieldByName('usr$doublebonus').AsInteger;
              UpdOrderLine.ParamByName('documentkey').AsInteger := LineTable.FieldByName('ID').AsInteger;
              UpdOrderLine.ExecQuery;

              updDoc.Close;
              updDoc.ParamByName('ID').AsInteger := LineTable.FieldByName('ID').AsInteger;
              updDoc.ParamByName('editorkey').AsInteger := FContactKey;
              updDoc.ExecQuery;
            end;
        else
          Assert(False, 'wrong type state field');
        end;

        LineTable.Next;
      end;
      Result := True;
      OrderKey := MasterID;
    except
      on E: EIBInterBaseError do
      begin
        if (E.IBErrorCode = isc_lost_db_connection) or (E.IBErrorCode = isc_net_read_err)
          or (E.IBErrorCode = isc_net_read_err) or (E.IBErrorCode = isc_net_write_err) then
            DoOnDisconnect
        else begin
          Touch_MessageBox('��������', '������ ��� ���������� ���� ' + E.Message, MB_OK, mtError);
          FCheckTransaction.Rollback;
        end;
      end;
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ���� ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    try
      if FCheckTransaction.InTransaction then
        FCheckTransaction.Commit;
    except
      on E: EIBInterBaseError do
      begin
        if (E.IBErrorCode = isc_lost_db_connection) or (E.IBErrorCode = isc_net_read_err)
          or (E.IBErrorCode = isc_net_read_err) or (E.IBErrorCode = isc_net_write_err) then
          // ������ �� ������
        else
          raise;
      end;
    end;

    InsDoc.Free;
    updDoc.Free;
    InsOrder.Free;
    InsOrderLine.Free;
    updOrder.Free;
    UpdOrderLine.Free;
    UpdReserv.Free;
  end;
end;

procedure TFrontBase.DeleteOrder(const ID: Integer);
var
  IsDelete: Boolean;
begin
  FCheckSQL.Close;
  try
    if not FCheckSQL.Transaction.InTransaction then
      FCheckSQL.Transaction.StartTransaction;

    //���������, ����� � ��� ���� ������ ������ �� ��������
    FCheckSQL.SQL.Text :=
      ' SELECT FIRST(1) L.DOCUMENTKEY ' +
      ' FROM USR$MN_ORDERLINE L ' +
      ' WHERE L.MASTERKEY = :ID ';
    FCheckSQL.ParamByName('ID').AsInteger := ID;
    FCheckSQL.ExecQuery;

    IsDelete := FCheckSQL.Eof;
    FCheckSQL.Close;
    if IsDelete then
      FCheckSQL.SQL.Text := 'DELETE FROM GD_DOCUMENT DOC ' +
        'WHERE DOC.ID = :ID '
    else
      FCheckSQL.SQL.Text :=
        ' UPDATE USR$MN_ORDER R ' +
        ' SET R.USR$PAY = 1 ' +
        ' WHERE R.DOCUMENTKEY = :ID ';

    FCheckSQL.ParamByName('ID').AsInteger := ID;
    FCheckSQL.ExecQuery;

    FCheckSQL.Transaction.Commit;
    FCheckSQL.Close;
  except
    on E: Exception do
    begin
      FCheckSQL.Transaction.Rollback;
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
    end;
  end;
end;

procedure TFrontBase.DeleteReservation(const ID, OrderKey: Integer);
begin
  FCheckSQL.Close;
  try
    if not FCheckSQL.Transaction.InTransaction then
      FCheckSQL.Transaction.StartTransaction;

    FCheckSQL.SQL.Text := ' DELETE FROM USR$MN_RESERVATION ' +
      ' WHERE ID = :ID ';
    FCheckSQL.ParamByName('ID').AsInteger := ID;
    FCheckSQL.ExecQuery;

    FCheckSQL.SQL.Text := ' DELETE FROM GD_DOCUMENT ' +
      ' WHERE ID = :ID ';
    FCheckSQL.ParamByName('ID').AsInteger := OrderKey;
    FCheckSQL.ExecQuery;

    FCheckSQL.Transaction.Commit;
    FCheckSQL.Close;
  except
    on E: Exception do
    begin
      FCheckSQL.Transaction.Rollback;
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
    end;
  end;
end;

destructor TFrontBase.Destroy;
begin
  FReadSQL.Free;
  FReadTransaction.Free;

  FCheckSQL.Free;
  FCheckTransaction.Free;

  if FIDTransaction.InTransaction then
    FIDTransaction.Commit;

  FIDSQL.Free;
  FIDTransaction.Free;

  FDataBase.Free;

  if Assigned(FDisplay) then
    FDisplay.Free;

  FQueryList.Free;
//  FGoodHashList.Free;
  CacheList.Free;

  inherited;
end;

procedure TFrontBase.DoOnDisconnect;
begin
  FDataBase.ForceClose;
  if not TryToConnect(5) then
{ TODO : ���������� }
    ;
end;

function TFrontBase.EnsureDBConnection: Boolean;
begin
  Result := FDataBase.TestConnected;
  if not Result then
  begin
    try
      FDataBase.ForceClose;
      WaitWindowThread.Start;
      try
        Result := TryToConnect(5);
      finally
        WaitWindowThread.Finish;
      end;
    except
      raise;
    end;
  end;
end;

procedure TFrontBase.FillGoodsByReserv(const LineTable, GoodDataSet: TkbmMemTable;
  const OrderKey: Integer);
var
  FSQL: TIBSQL;
  GoodKey: Integer;
  FLineID: Integer;
begin
  FLineID := 1;
  FSQL := TIBSQL.Create(nil);
  try
    FSQL.Transaction := ReadTransaction;
    if not FSQL.Transaction.InTransaction then
      FSQL.Transaction.StartTransaction;

    FSQL.SQL.Text :=
      ' SELECT ' +
      '   L.DOCUMENTKEY, ' +
      '   L.USR$GOODKEY, ' +
      '   L.USR$QUANTITY ' +
      ' FROM USR$MN_RESERVORDERLINE L ' +
      ' WHERE L.MASTERKEY = :ID ' +
      '   AND L.USR$QUANTITY <> 0 ' +
      ' ORDER BY L.DOCUMENTKEY ';
    FSQL.ParamByName('ID').AsInteger := OrderKey;
    FSQL.ExecQuery;
    while not FSQL.Eof do
    begin
      GoodKey := FSQL.FieldByName('USR$GOODKEY').AsInteger;
      if not GoodDataSet.Locate('ID', GoodKey, []) then
        GetGoodByID(GoodDataSet, GoodKey);
      //���� ����� ������, �� ���������
      if GoodDataSet.Locate('ID', GoodKey, []) then
      begin
        LineTable.Insert;
        LineTable.FieldByName('LINEKEY').AsInteger := FLineID;
        LineTable.FieldByName('STATEFIELD').AsInteger := cn_StateInsert;
        LineTable.FieldByName('usr$goodkey').AsInteger := GoodKey;
        LineTable.FieldByName('GOODNAME').AsString := GoodDataSet.FieldByName('NAME').AsString;
        LineTable.FieldByName('usr$quantity').AsCurrency := FSQL.FieldByName('USR$QUANTITY').AsCurrency;
        LineTable.FieldByName('usr$costncu').AsCurrency := GoodDataSet.FieldByName('COST').AsCurrency;
        LineTable.FieldByName('USR$COMPUTERNAME').AsString := ComputerName;
        LineTable.Post;

        Inc(FLineID);
      end;
      FSQL.Next;
    end;
  finally
    FSQL.Free;
  end;
end;

function TFrontBase.GetCauseDeleteList(const MemTable: TkbmMemTable): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := cst_CauseDelete;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetComputerName: String;
begin
  if FComputerName = '' then
    FComputerName := GetLocalComputerName;

  Result := FComputerName;
end;

procedure TFrontBase.GetContactList(const MemTable: TkbmMemTable);
begin
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT CON.ID, CON.NAME ' +
        ' FROM GD_CONTACT CON ' +
        ' JOIN GD_PEOPLE PL ON CON.ID = PL.CONTACTKEY ' +
        ' WHERE CON.CONTACTTYPE = 2 ' +
        '   AND PL.WCOMPANYKEY IS NULL ' +
        ' ORDER BY 2 ';
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetCustomReportList(const MemTable: TkbmMemTable);
var
  FPrinterID: Integer;
begin
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FPrinterID := GetPrinterInfo.PrinterID;

      FReadSQL.SQL.Text :=
        ' SELECT ID, USR$NAME ' +
        ' FROM USR$MN_REPORT R ' +
        ' WHERE R.USR$TYPE = 9 ' +
        '   AND (R.USR$PRNTYPEKEY IS NULL OR R.USR$PRNTYPEKEY = :PRNKEY) ';
      FReadSQL.Params[0].AsInteger := FPrinterID;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('USR$NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function IsNeedModify(const FSQL: TIBSQL; const GoodKey: Integer): Integer; inline;
begin
  Result := 0;
  FSQL.Close;
  FSQL.ParamByName('goodkey').AsInteger := GoodKey;
  FSQL.ExecQuery;
  if not FSQL.Eof then
    Result := 1;
end;

function TFrontBase.GetGoodByID(const MemTable: TkbmMemTable;
  const GoodKey: Integer): Boolean;
var
  FSQL: TIBSQL;
const
  cst_GoodByID =
    ' SELECT g.id, g.name, mn.usr$cost, g.alias, g.USR$MODIFYGROUPKEY, g.USR$BEDIVIDE, ' +
    '   g.USR$PRNGROUPKEY, g.USR$NOPRINT ' +
    ' FROM gd_good g ' +
    '   JOIN usr$mn_menuline mn ON mn.usr$goodkey = g.id ' +
    '   JOIN gd_goodgroup cg ON g.groupkey = cg.id ' +
    '   JOIN gd_document doc ON doc.id = mn.documentkey ' +
    ' WHERE G.ID = :GOODKEY ' +
    '   and (doc.disabled is null or doc.disabled = 0) ';
begin
  Result := False;
  FReadSQL.Close;
  if MemTable.State <> dsBrowse then
    MemTable.Post;

  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FSQL := TIBSQL.Create(nil);
    FSQL.Transaction := FReadSQL.Transaction;
    FSQL.SQL.Text := 'SELECT FIRST(1) * FROM USR$CROSS36_416793598 WHERE usr$gd_goodkey = :goodkey';
    try
      FReadSQL.SQL.Text := cst_GoodByID;
      FReadSQL.ParamByName('GOODKEY').AsInteger := GoodKey;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
        MemTable.FieldByName('Alias').AsString := FReadSQL.FieldByName('ALIAS').AsString;
        MemTable.FieldByName('Cost').ASCurrency := FReadSQL.FieldByName('usr$Cost').ASCurrency;
        MemTable.FieldByName('MODIFYGROUPKEY').AsInteger := FReadSQL.FieldByName('USR$MODIFYGROUPKEY').AsInteger;
        MemTable.FieldByName('ISNEEDMODIFY').AsInteger := IsNeedModify(FSQL, FReadSQL.FieldByName('ID').AsInteger);
        MemTable.FieldByName('BEDIVIDE').AsInteger := FReadSQL.FieldByName('USR$BEDIVIDE').AsInteger;
        MemTable.FieldByName('PRNGROUPKEY').AsInteger := FReadSQL.FieldByName('USR$PRNGROUPKEY').AsInteger;
        MemTable.FieldByName('NOPRINT').AsInteger := FReadSQL.FieldByName('USR$NOPRINT').AsInteger;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    finally
      FSQL.Free;
    end;
    FReadSQL.Close;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

procedure TFrontBase.GetGoodByMenu(const MemTable: TkbmMemTable;
  const MenuKey: Integer);
begin
  FReadSQL.Close;
  MemTable.Close;
//  MemTable.CreateTable;
  MemTable.Open;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FReadSQL.SQL.Text :=
      ' SELECT G.NAME, M.USR$COST, DOC.DISABLED, M.DOCUMENTKEY ' +
      ' FROM USR$MN_MENULINE M ' +
      ' JOIN GD_DOCUMENT DOC ON DOC.ID = M.DOCUMENTKEY ' +
      ' JOIN GD_GOOD G ON G.ID = M.USR$GOODKEY ' +
      ' WHERE M.MASTERKEY = :ID ORDER BY g.NAME  ';
    FReadSQL.Params[0].AsInteger := MenuKey;
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      MemTable.Append;
      MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('DOCUMENTKEY').AsInteger;
      MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
      MemTable.FieldByName('COST').AsCurrency := FReadSQL.FieldByName('USR$COST').AsCurrency;
      MemTable.FieldByName('DISABLED').AsInteger := FReadSQL.FieldByName('DISABLED').AsInteger;
      MemTable.Post;

      FReadSQL.Next;
    end;
    FReadSQL.Close;
  except
    raise;
  end;
end;

function TFrontBase.GetGoodList(const MemTable: TkbmMemTable;
  const MenuKey, GroupKey: Integer): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FSQL := TIBSQL.Create(nil);
    FSQL.Transaction := FReadSQL.Transaction;
    FSQL.SQL.Text := 'SELECT FIRST(1) * FROM USR$CROSS36_416793598 WHERE usr$gd_goodkey = :goodkey';
    try
      FReadSQL.SQL.Text := cst_GoodList;
      FReadSQL.ParamByName('MenuKey').AsInteger := MenuKey;
      FReadSQL.ParamByName('GroupKey').AsInteger := GroupKey;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
        MemTable.FieldByName('Alias').AsString := FReadSQL.FieldByName('ALIAS').AsString;
        MemTable.FieldByName('Cost').ASCurrency := FReadSQL.FieldByName('usr$Cost').ASCurrency;
        MemTable.FieldByName('MODIFYGROUPKEY').AsInteger := FReadSQL.FieldByName('USR$MODIFYGROUPKEY').AsInteger;
        MemTable.FieldByName('ISNEEDMODIFY').AsInteger := IsNeedModify(FSQL, FReadSQL.FieldByName('ID').AsInteger);
        MemTable.FieldByName('BEDIVIDE').AsInteger := FReadSQL.FieldByName('USR$BEDIVIDE').AsInteger;
        MemTable.FieldByName('PRNGROUPKEY').AsInteger := FReadSQL.FieldByName('USR$PRNGROUPKEY').AsInteger;
        MemTable.FieldByName('NOPRINT').AsInteger := FReadSQL.FieldByName('USR$NOPRINT').AsInteger;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    finally
      FSQL.Free;
    end;
    FReadSQL.Close;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

function TFrontBase.GetPopularGoodList(const MemTable: TkbmMemTable): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FSQL := TIBSQL.Create(nil);
    FSQL.Transaction := FReadSQL.Transaction;
    FSQL.SQL.Text := 'SELECT FIRST(1) * FROM USR$CROSS36_416793598 WHERE usr$gd_goodkey = :goodkey';
    try
      FReadSQL.SQL.Text := cst_PopularGoodList;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
        Result := False;

      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
        MemTable.FieldByName('Alias').AsString := FReadSQL.FieldByName('ALIAS').AsString;
        MemTable.FieldByName('Cost').ASCurrency := FReadSQL.FieldByName('usr$Cost').ASCurrency;
        MemTable.FieldByName('MODIFYGROUPKEY').AsInteger := FReadSQL.FieldByName('USR$MODIFYGROUPKEY').AsInteger;
        MemTable.FieldByName('ISNEEDMODIFY').AsInteger := IsNeedModify(FSQL, FReadSQL.FieldByName('ID').AsInteger);
        MemTable.FieldByName('BEDIVIDE').AsInteger := FReadSQL.FieldByName('USR$BEDIVIDE').AsInteger;
        MemTable.FieldByName('PRNGROUPKEY').AsInteger := FReadSQL.FieldByName('USR$PRNGROUPKEY').AsInteger;
        MemTable.FieldByName('NOPRINT').AsInteger := FReadSQL.FieldByName('USR$NOPRINT').AsInteger;
        MemTable.Post;
        FReadSQL.Next;
      end;
    finally
      FSQL.Free;
    end;
    FReadSQL.Close;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

function TFrontBase.GetGroupList(const MemTable: TkbmMemTable; const MenuKey: Integer): Boolean;
begin
  Result := False;
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FReadSQL.SQL.Text := cst_GroupList;
    FReadSQL.ParamByName('MenuKey').AsInteger := MenuKey;
    FReadSQL.ExecQuery;
    while not FReadSQL.EOF do
    begin
      MemTable.Append;
      MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
      MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
      MemTable.FieldByName('Alias').AsString := FReadSQL.FieldByName('ALIAS').AsString;
      MemTable.Post;
      FReadSQL.Next;
    end;
    Result := True;

    FReadSQL.Close;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

function TFrontBase.GetMenuList(const MemTable: TkbmMemTable;
  var FMenuButtonCount: Integer): Boolean;
var
  LogicDate: TDateTime;
begin
  LogicDate := GetLogicDate;

  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := cst_MenuList;
      FReadSQL.ParamByName('curdate').AsDateTime := LogicDate;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('documentkey').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;

        Inc(FMenuButtonCount);
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetNextID: Integer;
begin
  if not FIDSQL.Transaction.InTransaction then
    FIDSQL.Transaction.StartTransaction;

  FIDSQL.Close;
  FIDSQL.ExecQuery;
  Result := FIDSQL.FieldByName('ID').AsInteger;
end;

function TFrontBase.GetOrder(const HeaderTable, LineTable, ModifyTable: TkbmMemTable;
  OrderKey: Integer): Boolean;
var
  FSQL: TIBSQL;
  S, ES: String;
  BPost, APost: TDataSetNotifyEvent;
begin
  HeaderTable.Close;
  HeaderTable.CreateTable;
  HeaderTable.Open;

  LineTable.Close;
  LineTable.CreateTable;
  LineTable.Open;

  ModifyTable.Close;
  ModifyTable.CreateTable;
  ModifyTable.Open;

  if OrderKey  = -1 then
  begin
    Result := True;
    Exit;
  end;
  FReadSQL.Close;

  APost := HeaderTable.AfterPost;
  HeaderTable.AfterPost := nil;

  BPost := LineTable.BeforePost;
  LineTable.BeforePost := nil;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FSQL := TIBSQL.Create(nil);
      FSQL.Transaction := FReadTransaction;
      FSQL.SQL.Text :=
        ' SELECT CR.USR$MN_MODIFYKEY, m.USR$NAME, CR.USR$CLOSETIME ' +
        ' FROM USR$CROSS509_157767346 CR ' +
        ' LEFT JOIN usr$mn_modify m ON m.ID = CR.USR$MN_MODIFYKEY ' +
        ' WHERE CR.USR$MN_ORDERLINEKEY = :line ';

      try
        FReadSQL.SQL.Text := cst_OrderHeader;
        FReadSQL.ParamByName('ID').AsInteger := OrderKey;
        FReadSQL.ExecQuery;
        while not FReadSQL.EOF do
        begin
          HeaderTable.Append;
          HeaderTable.FieldByName('id').Value := FReadSQL.FieldByName('id').Value;
          HeaderTable.FieldByName('number').Value := FReadSQL.FieldByName('number').Value;
          HeaderTable.FieldByName('sumncu').Value := FReadSQL.FieldByName('sumncu').Value;
          HeaderTable.FieldByName('usr$mn_printdate').Value := FReadSQL.FieldByName('usr$mn_printdate').Value;
          HeaderTable.FieldByName('usr$sumncuwithdiscount').Value := FReadSQL.FieldByName('usr$sumncuwithdiscount').Value;
          HeaderTable.FieldByName('usr$respkey').Value := FReadSQL.FieldByName('usr$respkey').Value;
          HeaderTable.FieldByName('usr$guestcount').Value := FReadSQL.FieldByName('usr$guestcount').Value;
          HeaderTable.FieldByName('usr$pay').Value := FReadSQL.FieldByName('usr$pay').Value;
          HeaderTable.FieldByName('usr$timeorder').Value := FReadSQL.FieldByName('usr$timeorder').Value;
          HeaderTable.FieldByName('usr$timecloseorder').Value := FReadSQL.FieldByName('usr$timecloseorder').Value;
          HeaderTable.FieldByName('usr$logicdate').Value := FReadSQL.FieldByName('usr$logicdate').Value;
          HeaderTable.FieldByName('usr$discountncu').Value := FReadSQL.FieldByName('usr$discountncu').Value;
          HeaderTable.FieldByName('usr$sysnum').Value := FReadSQL.FieldByName('usr$sysnum').Value;
          HeaderTable.FieldByName('usr$register').Value := FReadSQL.FieldByName('usr$register').Value;
          HeaderTable.FieldByName('usr$whopayoffkey').Value := FReadSQL.FieldByName('usr$whopayoffkey').Value;
          HeaderTable.FieldByName('usr$vip').Value := FReadSQL.FieldByName('usr$vip').Value;
          HeaderTable.FieldByName('usr$disccardkey').Value := FReadSQL.FieldByName('usr$disccardkey').Value;
          HeaderTable.FieldByName('usr$userdisckey').Value := FReadSQL.FieldByName('usr$userdisckey').Value;
          HeaderTable.FieldByName('usr$discountkey').Value := FReadSQL.FieldByName('usr$discountkey').Value;
          HeaderTable.FieldByName('usr$bonussum').Value := FReadSQL.FieldByName('usr$bonussum').Value;
          HeaderTable.FieldByName('editorkey').Value := FReadSQL.FieldByName('editorkey').Value;
          HeaderTable.FieldByName('editiondate').Value := FReadSQL.FieldByName('editiondate').Value;
          HeaderTable.FieldByName('creationdate').Value := FReadSQL.FieldByName('creationdate').Value;
          HeaderTable.FieldByName('usr$tablekey').AsInteger := FReadSQL.FieldByName('usr$tablekey').AsInteger;
          if FReadSQL.FieldByName('usr$computername').AsString <> '' then
            HeaderTable.FieldByName('usr$computername').AsString := FReadSQL.FieldByName('usr$computername').AsString
          else
            HeaderTable.FieldByName('usr$computername').AsString := ComputerName;
          HeaderTable.FieldByName('usr$reservkey').AsInteger := FReadSQL.FieldByName('usr$reservkey').AsInteger;
          HeaderTable.FieldByName('usr$avanssum').AsCurrency := FReadSQL.FieldByName('usr$avanssum').AsCurrency;
          HeaderTable.Post;

          FReadSQL.Next;
        end;
        FReadSQL.Close;
        FReadSQL.SQL.Text := cst_OrderActiveLine; // cst_OrderLine;
        FReadSQL.ParamByName('ID').AsInteger := OrderKey;
        FReadSQL.ExecQuery;
        while not FReadSQL.EOF do
        begin
          S:= '';
          LineTable.Append;
          LineTable.FieldByName('id').Value := FReadSQL.FieldByName('id').Value;
          LineTable.FieldByName('number').Value := FReadSQL.FieldByName('number').Value;
          LineTable.FieldByName('GOODNAME').Value := FReadSQL.FieldByName('GOODNAME').Value;
          LineTable.FieldByName('usr$mn_printdate').Value := FReadSQL.FieldByName('usr$mn_printdate').Value;
          LineTable.FieldByName('usr$quantity').Value := FReadSQL.FieldByName('usr$quantity').Value;
          LineTable.FieldByName('usr$costncu').Value := FReadSQL.FieldByName('usr$costncu').Value;
          LineTable.FieldByName('usr$goodkey').Value := FReadSQL.FieldByName('usr$goodkey').Value;
          LineTable.FieldByName('usr$sumncuwithdiscount').Value := FReadSQL.FieldByName('usr$sumncuwithdiscount').Value;
          LineTable.FieldByName('usr$sumncu').Value := FReadSQL.FieldByName('usr$sumncu').Value;
          LineTable.FieldByName('usr$costncuwithdiscount').Value := FReadSQL.FieldByName('usr$costncuwithdiscount').Value;
          LineTable.FieldByName('usr$sumdiscount').Value := FReadSQL.FieldByName('usr$sumdiscount').Value;
          LineTable.FieldByName('usr$persdiscount').Value := FReadSQL.FieldByName('usr$persdiscount').Value;
          LineTable.FieldByName('usr$causedeletekey').Value := FReadSQL.FieldByName('usr$causedeletekey').Value;
          LineTable.FieldByName('usr$deleteamount').Value := FReadSQL.FieldByName('usr$deleteamount').Value;
          LineTable.FieldByName('usr$doublebonus').Value := FReadSQL.FieldByName('usr$doublebonus').Value;
          LineTable.FieldByName('editorkey').Value := FReadSQL.FieldByName('editorkey').Value;
          LineTable.FieldByName('editiondate').Value := FReadSQL.FieldByName('editiondate').Value;
          LineTable.FieldByName('oldquantity').Value := FReadSQL.FieldByName('usr$quantity').Value;
          LineTable.FieldByName('usr$computername').AsString := FReadSQL.FieldByName('usr$computername').AsString;
          LineTable.FieldByName('LINEKEY').AsInteger := FReadSQL.FieldByName('id').Value;
          LineTable.FieldByName('STATEFIELD').AsInteger := 0;
          LineTable.FieldByName('EXTRAMODIFY').AsString := FReadSQL.FieldByName('usr$extramodify').AsString;
          LineTable.FieldByName('CREATIONDATE').AsDateTime := FReadSQL.FieldByName('CREATIONDATE').AsDateTime;
          LineTable.FieldByName('USR$NOPRINT').AsInteger := FReadSQL.FieldByName('USR$NOPRINT').AsInteger;
          ES := LineTable.FieldByName('EXTRAMODIFY').AsString;
          LineTable.Post;

          FSQL.Params[0].AsInteger := FReadSQL.FieldByName('id').Value;
          FSQL.ExecQuery;

          if ModifyTable.IsVersioning then
            ModifyTable.StartTransaction;
          try
            while not FSQL.Eof do
            begin

              ModifyTable.Append;
              ModifyTable.FieldByName('MASTERKEY').AsInteger := FReadSQL.FieldByName('id').AsInteger;
              ModifyTable.FieldByName('MODIFYKEY').AsInteger := FSQL.FieldByName('USR$MN_MODIFYKEY').AsInteger;
              ModifyTable.FieldByName('NAME').AsString := FSQL.FieldByName('USR$NAME').AsString;
              ModifyTable.FieldByName('CLOSETIME').Value := FSQL.FieldByName('USR$CLOSETIME').Value;
              ModifyTable.Post;
              if S > '' then
                S := S + ', ';
              S := S + FSQL.FieldByName('USR$NAME').AsString;

              FSQL.Next;
            end;
            FSQL.Close;
          finally
            if ModifyTable.IsVersioning then
              ModifyTable.Commit;
          end;

          if ES <> '' then
          begin
            if S = '' then
              S := ES
            else
              S := S + ', ' + ES;
          end;

          if S > '' then
          begin
            LineTable.Edit;
            LineTable.FieldByName('MODIFYSTRING').AsString := S;
            LineTable.Post;
          end;

          FReadSQL.Next;
        end;
      finally
        FSQL.Free;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    HeaderTable.AfterPost := APost;
    LineTable.BeforePost := BPost;
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetOrderInfo(const AOrderKey: Integer): TrfOrder;
begin
  Result := nil;
  if AOrderKey > -1 then
  begin
    FReadSQL.Close;
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := cst_OrderHeader;
      FReadSQL.ParamByName('ID').AsInteger := AOrderKey;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        Result := TrfOrder.Create(FReadSQL.FieldByName('id').AsInteger, FReadSQL.FieldByName('number').AsString);
        Result.TimeCloseOrder := FReadSQL.FieldByName('usr$timecloseorder').AsDateTime;
        Result.ResponsibleKey := FReadSQL.FieldByName('usr$respkey').AsInteger;
        if FReadSQL.FieldByName('usr$computername').AsString <> '' then
          Result.ComputerName := FReadSQL.FieldByName('usr$computername').AsString
        else
          Result.ComputerName := ComputerName;
        Result.IsLocked := (FReadSQL.FieldByName('islocked').AsInteger = 1);
      end;
    finally
      FReadSQL.Close;
    end;
  end;
end;

function TFrontBase.GetOrdersInfo(const HeaderTable, LineTable: TkbmMemTable;
  const DateBegin, DateEnd: TDate; const WithPreCheck, WithOutPreCheck,
  Payed, NotPayed: Boolean): Boolean;
var
  SQLTextHeader: String;
  FHeaderQuery, FLineQuery: TIBQuery;
  I, K: Integer;
  FFirst: Boolean;
const
  OrderSQLText =
    'SELECT '+
    '  Z.ID, '+
    '  Z.PARENT, '+
    '  Z.DOCUMENTTYPEKEY, '+
    '  Z.TRTYPEKEY, '+
    '  Z.TRANSACTIONKEY, '+
    '  Z.NUMBER, '+
    '  Z.DOCUMENTDATE, '+
    '  Z.DESCRIPTION, '+
    '  Z.SUMNCU,'+
    '  Z.SUMCURR, '+
    '  Z.SUMEQ, '+
    '  Z.DELAYED, '+
    '  Z.AFULL, '+
    '  Z.ACHAG, '+
    '  Z.AVIEW, '+
    '  Z.CURRKEY, '+
    '  Z.COMPANYKEY,  '+
    '  Z.CREATORKEY,  '+
    '  Z.CREATIONDATE, '+
    '  Z.EDITORKEY, '+
    '  Z.EDITIONDATE, '+
    '  Z.PRINTDATE, '+
    '  Z.DISABLED, '+
    '  Z.RESERVED, '+
    '  U.DOCUMENTKEY, '+
    '  U.RESERVED, '+
    '  U.USR$BONUSSUM, '+
    '  U.USR$CASH, '+
    '  U.USR$DISCCARDKEY, '+
    '  U.USR$DISCOUNTKEY, '+
    '  U.USR$DISCOUNTNCU, '+
    '  U.USR$GRATUITY, '+
    '  U.USR$GUESTCOUNT, '+
    '  U.USR$ISLOCKED, '+
    '  U.USR$LOGICDATE, '+
    '  U.USR$MENUKEY, '+
    '  U.USR$PAY, '+
    '  U.USR$REGISTER, '+
    '  U.USR$RESPKEY, '+
    '  U.USR$SYSNUM, '+
    '  U.USR$TIMECLOSEORDER, '+
    '  U.USR$TIMEORDER, '+
    '  U.USR$USERDISCKEY, '+
    '  U.USR$VIP, '+
    '  U.USR$WHOPAYOFFKEY, '+
    '  ( SELECT  '+
    '    SUM (L.USR$SUMNCUWITHDISCOUNT ) '+
    '  FROM  '+
    '    USR$MN_ORDERLINE L  '+
    '  WHERE '+
    '    L.MASTERKEY = Z.ID AND L.USR$CAUSEDELETEKEY + 0 IS NULL) AS USR$SUMNCUWITHDISCOUNT, '+
    '  ( SELECT '+
    '    SUM ( L.USR$SUMNCUWITHDISCOUNT )  '+
    '  FROM '+
    '    USR$MN_ORDERLINE L  '+
    '  WHERE '+
    '    L.MASTERKEY  =  Z.ID AND L.USR$CAUSEDELETEKEY + 0 IS NULL) AS SUMNCUCHECK, '+
    '  Z.USR$SORTNUMBER, '+
    '  Z.USR$EQRATE, '+
    '  Z.USR$MN_PRINTDATE, '+
    '  U_USR$RESPKEY.NAME AS U_USR$RESPKEY_NAME, '+
    '  U_USR$RESPKEY.USR$SF_SECTION AS U_USR$RESPKEY_USR$SF_SECTION, '+
    '  U_USR$WHOPAYOFFKEY.NAME AS U_USR$WHOPAYOFFKEY_NAME, '+
    '  U_USR$WHOPAYOFFKEY.USR$SF_SECTION AS U_USR$WHOPAYOFFKEY_US2034109678, '+
    '  U_USR$DISCCARDKEY.USR$CODE AS U_USR$DISCCARDKEY_USR$CODE, '+
    '  U_USR$USERDISCKEY.NAME AS U_USR$USERDISCKEY_NAME, '+
    '  U_USR$USERDISCKEY.USR$SF_SECTION AS U_USR$USERDISCKEY_USR3488057747, '+
    '  U_USR$DISCOUNTKEY.USR$NAME AS U_USR$DISCOUNTKEY_USR$NAME, '+
    '  USR$DISCCARDKEY.USR$DATEEND, '+
    '  USR$DISCCARDKEY.USR$DATEBEGIN, '+
    '  USR$DISCCARDKEY.USR$DISCOUNTNAMEKEY, '+
    '  USR$DISCCARDKEY_USR$DIS12098716.USR$NAME AS USR$DISCCARDKEY_USR$D1251435647, '+
    '  USR$DISCCARDKEY.USR$CODE, '+
    '  USR$DISCCARDKEY.USR$FIRSTNAME, '+
    '  USR$DISCCARDKEY.USR$MIDDLENAME, '+
    '  USR$DISCCARDKEY.USR$SURNAME, '+
    '  USR$DISCCARDKEY.USR$ADDRESS, '+
    '  USR$DISCCARDKEY.USR$PHONE, '+
    '  USR$DISCCARDKEY.USR$EMAIL, '+
    '  USR$DISCCARDKEY.USR$BIRTHDAY, '+
    '  USR$DISCCARDKEY.USR$CARDNUM, '+
    '  USR$DISCCARDKEY.USR$BALANCE  '+
    'FROM '+
    '  GD_DOCUMENT Z '+
    '    JOIN '+
    '      USR$MN_ORDER U  '+
    '    ON '+
    '      U.DOCUMENTKEY  =  Z.ID '+
    '    LEFT JOIN '+
    '      USR$MN_DISCOUNTCARD USR$DISCCARDKEY '+
    '    ON '+
    '      USR$DISCCARDKEY.ID  =  U.USR$DISCCARDKEY '+
    '    LEFT JOIN '+
    '      GD_CONTACT U_USR$RESPKEY '+
    '    ON '+
    '      U_USR$RESPKEY.ID  =  U.USR$RESPKEY '+
    '    LEFT JOIN '+
    '      GD_CONTACT U_USR$WHOPAYOFFKEY '+
    '    ON '+
    '      U_USR$WHOPAYOFFKEY.ID  =  U.USR$WHOPAYOFFKEY '+
    '    LEFT JOIN '+
    '      USR$MN_DISCOUNTCARD U_USR$DISCCARDKEY '+
    '    ON '+
    '      U_USR$DISCCARDKEY.ID  =  U.USR$DISCCARDKEY '+
    '    LEFT JOIN '+
    '      GD_CONTACT U_USR$USERDISCKEY '+
    '    ON '+
    '      U_USR$USERDISCKEY.ID  =  U.USR$USERDISCKEY '+
    '    LEFT JOIN '+
    '      USR$MN_DISCOUNTNAME U_USR$DISCOUNTKEY '+
    '    ON '+
    '      U_USR$DISCOUNTKEY.ID  =  U.USR$DISCOUNTKEY '+
    '    LEFT JOIN '+
    '      USR$MN_DISCOUNTNAME USR$DISCCARDKEY_USR$DIS12098716 '+
    '    ON '+
    '      USR$DISCCARDKEY_USR$DIS12098716.ID  =  USR$DISCCARDKEY.USR$DISCOUNTNAMEKEY '+
    'WHERE  '+
    '  Z.DOCUMENTTYPEKEY = :doctype '+
    '     AND '+
    '  Z.PARENT + 0 IS NULL '+
    '     AND '+
    '  Z.COMPANYKEY = :COMPANYKEY '+
    '     AND '+
    '  U.USR$LOGICDATE  >=  :DB  '+
    '     AND '+
    '  U.USR$LOGICDATE  <=  :DE ';

  OrderClause =
    'ORDER BY ' +
    '   U.USR$LOGICDATE,' +
    '   U.USR$TIMEORDER ';


  LineSQLText =
    'SELECT '+
    '  Z.ID, '+
    '  Z.PARENT, '+
    '  Z.DOCUMENTTYPEKEY, '+
    '  Z.TRTYPEKEY, '+
    '  Z.TRANSACTIONKEY, '+
    '  Z.NUMBER, '+
    '  Z.DOCUMENTDATE, '+
    '  Z.DESCRIPTION, '+
    '  Z.SUMNCU, '+
    '  Z.SUMCURR, '+
    '  Z.SUMEQ, '+
    '  Z.DELAYED, '+
    '  Z.AFULL, '+
    '  Z.ACHAG, '+
    '  Z.AVIEW, '+
    '  Z.CURRKEY, '+
    '  Z.COMPANYKEY, '+
    '  Z.CREATORKEY, '+
    '  Z.CREATIONDATE, '+
    '  Z.EDITORKEY, '+
    '  Z.EDITIONDATE, '+
    '  Z.PRINTDATE, '+
    '  Z.DISABLED, '+
    '  Z.RESERVED, '+
    '  U.DOCUMENTKEY, '+
    '  U.MASTERKEY, '+
    '  U.RESERVED, '+
    ' U.USR$CAUSEDELETEKEY, '+
    '  U.USR$COSTEQ, '+
    '  U.USR$COSTEQWITHDISCOUNT, '+
    '  U.USR$COSTNCU, '+
    '  U.USR$COSTNCUWITHDISCOUNT, '+
    '  U.USR$DELETEAMOUNT, '+
    '  U.USR$DEPOTKEY, '+
    '  U.USR$DOUBLEBONUS, '+
    '  U.USR$EXTRAMODIFY, '+
    '  U.USR$GOODKEY, '+
    '  U.USR$LOGICDATE, '+
    '  U.USR$MENULINEKEY, '+
    '  U.USR$MODIFYSET, '+
    '  U.USR$PERSDISCOUNT, '+
    '  U.USR$QUANTITY, '+
    '  U.USR$REGISTER, '+
    '  U.USR$SUMDISCOUNT, '+
    '  U.USR$SUMNCU, '+
    '  U.USR$SUMNCUWITHDISCOUNT, '+
    '  MODIFY.MODIFYNAME, '+
    '  Z.USR$SORTNUMBER, '+
    '  Z.USR$EQRATE, '+
    '  Z.USR$MN_PRINTDATE, '+
    '  U_USR$GOODKEY.NAME AS U_USR$GOODKEY_NAME, '+
    '  U_USR$GOODKEY.ALIAS AS U_USR$GOODKEY_ALIAS, '+
    '  U_USR$GOODKEY.USR$BEDIVIDE AS U_USR$GOODKEY_USR$BEDIVIDE, '+
    '  U_USR$CAUSEDELETEKEY.USR$NAME AS U_USR$CAUSEDELETEKEY_USR$NAME, '+
    '  U_USR$DEPOTKEY.NAME AS U_USR$DEPOTKEY_NAME, '+
    '  U_USR$DEPOTKEY.USR$SF_SECTION AS U_USR$DEPOTKEY_USR$SF_SECTION, '+
    '  DEPOT.USR$SF_SECTION '+
    'FROM '+
    '  GD_DOCUMENT Z  '+
    '    LEFT JOIN  '+
    '      USR$MN_ORDERLINE U '+
    '    ON  '+
    '      U.DOCUMENTKEY  =  Z.ID '+
    '    LEFT JOIN '+
    '      GD_CONTACT DEPOT '+
    '    ON '+
    '      DEPOT.ID  =  U.USR$DEPOTKEY '+
    '    LEFT JOIN  '+
    '      USR$MN_MODIFYSTRING ( Z.ID ) MODIFY '+
    '    ON '+
    '      1  =  1  '+
    '    LEFT JOIN '+
    '      GD_GOOD U_USR$GOODKEY '+
    '    ON '+
    '      U_USR$GOODKEY.ID  =  U.USR$GOODKEY '+
    '    LEFT JOIN '+
    '      USR$MN_CAUSEDELETEORDERLINE U_USR$CAUSEDELETEKEY '+
    '    ON '+
    '      U_USR$CAUSEDELETEKEY.ID  =  U.USR$CAUSEDELETEKEY '+
    '    LEFT JOIN '+
    '      GD_CONTACT U_USR$DEPOTKEY '+
    '    ON '+
    '      U_USR$DEPOTKEY.ID  =  U.USR$DEPOTKEY '+
    'WHERE '+
    '  Z.PARENT =:parent '+
    '     AND  '+
    '  Z.DOCUMENTTYPEKEY = :doctype '+
    '     AND '+
    '  Z.PARENT + 0 IS NOT NULL ';

begin
  Result := False;
  HeaderTable.Close;
  LineTable.Close;
  try
    if not FReadTransaction.InTransaction then
      FReadTransaction.StartTransaction;

    FHeaderQuery := TIBQuery.Create(nil);
    FLineQuery := TIBQuery.Create(nil);
    try
      SQLTextHeader := OrderSQLText;
      if WithPreCheck then
        SQLTextHeader := SQLTextHeader + ' AND USR$TIMECLOSEORDER is not null ';
      if WithOutPreCheck then
        SQLTextHeader := SQLTextHeader + ' AND USR$TIMECLOSEORDER is null ';
      if Payed then
        SQLTextHeader := SQLTextHeader + ' AND usr$pay = 1 ';
      if NotPayed then
        SQLTextHeader := SQLTextHeader + ' AND (usr$pay = 0 or usr$pay is null) ';
      SQLTextHeader := SQLTextHeader + OrderClause;

      FHeaderQuery.SQL.Text := SQLTextHeader;
      FHeaderQuery.Transaction := FReadTransaction;
      FHeaderQuery.ParamByName('DB').AsDateTime := DateBegin;
      FHeaderQuery.ParamByName('DE').AsDateTime := DateEnd;
      FHeaderQuery.ParamByName('COMPANYKEY').AsInteger := FCompanyKey;
      FHeaderQuery.ParamByName('doctype').AsInteger := FrontConst.DocumentTypeKey_Zakaz;
      FHeaderQuery.Open;

      FLineQuery.SQL.Text := LineSQLText;
      FLineQuery.Transaction := FReadTransaction;

      HeaderTable.CreateTableAs(FHeaderQuery, [mtcpoStructure]);
      HeaderTable.IgnoreReadOnly := True;
      HeaderTable.CreateTable;
      HeaderTable.Open;
      FFirst := True;
      while not FHeaderQuery.Eof do
      begin
        HeaderTable.Append;
        I := 0;
        while I <= FHeaderQuery.FieldCount - 1 do
        begin
          HeaderTable.Fields[I].AsString := FHeaderQuery.Fields[I].AsString;
          Inc(I);
        end;
        HeaderTable.Post;

        FLineQuery.ParamByName('PARENT').AsInteger := HeaderTable.FieldByName('ID').AsInteger;
        FLineQuery.ParamByName('DOCTYPE').AsInteger := FrontConst.DocumentTypeKey_Zakaz;
        FLineQuery.Open;
        if FFirst then
        begin
          LineTable.CreateTableAs(FLineQuery, [mtcpoStructure]);
          LineTable.IgnoreReadOnly := True;
          LineTable.CreateTable;
          LineTable.Open;
          FFirst := False;
        end;
        while not FLineQuery.Eof do
        begin
          LineTable.Append;
          K := 0;
          while K <= FLineQuery.FieldCount - 1 do
          begin
            LineTable.Fields[K].AsString := FLineQuery.Fields[K].AsString;
            Inc(K);
          end;
          LineTable.Post;

          FLineQuery.Next;
        end;
        FLineQuery.Close;

        FHeaderQuery.Next;
      end;

    finally
      FHeaderQuery.Free;
      FLineQuery.Free;
    end;

  except
    raise;
  end;
end;

function TFrontBase.GetUserOrders(const ContactKey: Integer; const MemTable: TkbmMemTable): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT ' +
        '   z.id, z.number, ' +
        '   u.usr$guestcount, ' +
        '   u.usr$logicdate, ' +
        '   u.usr$pay, ' +
        '   u.usr$timecloseorder, ' +
        '   u.usr$timeorder, ' +
        '   u.usr$vip, ' +
        '   u.usr$islocked, ' +
        '   (SELECT ' +
        '      SUM(l.usr$sumncuwithdiscount) ' +
        '    FROM ' +
        '      usr$mn_orderline l ' +
        '    WHERE ' +
        '      l.masterkey = z.id ' +
        '      AND l.usr$causedeletekey + 0 IS NULL) AS usr$sumncuwithdiscount, ' +
        '   z.usr$mn_printdate, ' +
        '   u.usr$computername ' +
        ' FROM ' +
        '   gd_document z ' +
        '   JOIN usr$mn_order u ON u.documentkey = z.id ' +
        ' WHERE ' +
        '   z.documenttypekey = :ordertypekey ' +
        '   AND z.parent + 0 IS NULL ' +
        '   AND usr$respkey = :respkey ' +
        '   AND (usr$pay <> 1) ' +
        '   AND (usr$vip <> 1 ' +
        '   OR usr$vip IS NULL) ' +
        ' ORDER BY ' +
        '   u.usr$logicdate, u.usr$timeorder ';
      if ContactKey > 0 then
        FReadSQL.ParamByName('RespKey').AsInteger := ContactKey
      else
        FReadSQL.ParamByName('RespKey').AsInteger := FContactKey;

      FReadSQL.ParamByName('OrderTypeKey').AsInteger := FrontConst.DocumentTypeKey_Zakaz;

      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('TABLENAME').AsString := FReadSQL.FieldByName('NUMBER').AsString;
        MemTable.FieldByName('GuestNumbers').AsInteger := FReadSQL.FieldByName('USR$GUESTCOUNT').ASInteger;
        MemTable.FieldByName('OpenTime').ASDateTime := FReadSQL.FieldByName('USR$TIMEORDER').AsDateTime;
        MemTable.FieldByName('Summ').AsCurrency := FReadSQL.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        if FReadSQL.FieldByName('USR$PAY').ASInteger = 1 then
          MemTable.FieldByName('Status').AsInteger := Integer(osOrderPayed)
        else if not FReadSQL.FieldByName('USR$TIMECLOSEORDER').IsNull then
          MemTable.FieldByName('Status').AsInteger := Integer(osOrderClose)
        else
          MemTable.FieldByName('Status').AsInteger := Integer(osOrderOpen);
        MemTable.FieldByName('ISLOCKED').AsInteger := FReadSQL.FieldByName('USR$ISLOCKED').AsInteger;
        MemTable.FieldByName('USR$COMPUTERNAME').AsString := FReadSQL.FieldByName('USR$COMPUTERNAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetUserOrderList(const ContactKey: Integer; AOrderList: TList<TrfOrder>);
var
  Order: TrfOrder;
begin
  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT ' +
        '   z.id, z.number, ' +
        '   u.usr$guestcount, ' +
        '   u.usr$logicdate, ' +
        '   u.usr$pay, ' +
        '   u.usr$timecloseorder AS timecloseorder, ' +
        '   u.usr$timeorder, ' +
        '   u.usr$vip, ' +
        '   u.usr$islocked, ' +
        '   (SELECT ' +
        '      SUM(l.usr$sumncuwithdiscount) ' +
        '    FROM ' +
        '      usr$mn_orderline l ' +
        '    WHERE ' +
        '      l.masterkey = z.id ' +
        '      AND l.usr$causedeletekey + 0 IS NULL) AS usr$sumncuwithdiscount, ' +
        '   z.usr$mn_printdate, ' +
        '   u.usr$computername ' +
        ' FROM ' +
        '   gd_document z ' +
        '   JOIN usr$mn_order u ON u.documentkey = z.id ' +
        ' WHERE ' +
        '   z.documenttypekey = :ordertypekey ' +
        '   AND z.parent + 0 IS NULL ' +
        '   AND usr$respkey = :respkey ' +
        '   AND (usr$pay <> 1) ' +
        '   AND (usr$vip <> 1 ' +
        '   OR usr$vip IS NULL) ' +
        ' ORDER BY ' +
        '   u.usr$logicdate, u.usr$timeorder ';
      // ������������
      if ContactKey > 0 then
        FReadSQL.ParamByName('RespKey').AsInteger := ContactKey
      else
        FReadSQL.ParamByName('RespKey').AsInteger := FContactKey;
      // ��� ������
      FReadSQL.ParamByName('OrderTypeKey').AsInteger := FrontConst.DocumentTypeKey_Zakaz;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        Order := TrfOrder.Create(FReadSQL.FieldByName('id').AsInteger, FReadSQL.FieldByName('number').AsString);
        Order.TimeCloseOrder := FReadSQL.FieldByName('timecloseorder').AsDateTime;
        Order.ResponsibleKey := FReadSQL.ParamByName('RespKey').AsInteger;

        AOrderList.Add(Order);
        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetUserOrdersPrecheck(const ContactKey: Integer;
  const MemTable: TkbmMemTable; const WithPrecheck: Boolean): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT  ' +
        '   Z.ID, ' +
        '   Z.NUMBER, ' +
        '   U.USR$GUESTCOUNT, ' +
        '   U.USR$LOGICDATE,  ' +
        '   U.USR$PAY,   ' +
        '   U.USR$TIMECLOSEORDER, ' +
        '   U.USR$TIMEORDER, ' +
        '   U.USR$VIP, ' +
        '   U.USR$ISLOCKED, ' +
        '   ( SELECT ' +
        '     SUM ( L.USR$SUMNCUWITHDISCOUNT ) ' +
        '   FROM ' +
        '     USR$MN_ORDERLINE L ' +
        '   WHERE ' +
        '     L.MASTERKEY  =  Z.ID ' +
        '        AND ' +
        '      L.USR$CAUSEDELETEKEY + 0 IS NULL    ) AS USR$SUMNCUWITHDISCOUNT, ' +
        '   Z.USR$MN_PRINTDATE, U.USR$COMPUTERNAME ' +
        '  FROM ' +
        '   GD_DOCUMENT Z ' +
        '     JOIN ' +
        '       USR$MN_ORDER U ' +
        '     ON ' +
        '       U.DOCUMENTKEY  =  Z.ID ' +
        ' WHERE ' +
        '   Z.DOCUMENTTYPEKEY  =  :OrderTypeKey ' +
        '      AND ' +
        '   Z.PARENT + 0 IS NULL ' +
        '      AND ' +
        '   USR$RESPKEY  =  :RespKey ' +
        '      AND ' +
        '   ( USR$PAY  <>  1 ) ' +
        '      AND ' +
        '   ( USR$VIP  <>  1 OR   USR$VIP IS NULL ) ';
      if WithPrecheck then
        FReadSQL.SQL.Text := FReadSQL.SQL.Text +
           '  AND U.usr$timecloseorder IS NOT NULL ';

      FReadSQL.SQL.Text := FReadSQL.SQL.Text +
        ' ORDER BY ' +
        '   U.USR$LOGICDATE, ' +
        '   U.USR$TIMEORDER ';
      if ContactKey  > 0 then
        FReadSQL.ParamByName('RespKey').AsInteger := ContactKey
      else
        FReadSQL.ParamByName('RespKey').AsInteger := FContactKey;

      FReadSQL.ParamByName('OrderTypeKey').AsInteger := FrontConst.DocumentTypeKey_Zakaz;

      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('TABLENAME').AsString := FReadSQL.FieldByName('NUMBER').AsString;
        MemTable.FieldByName('GuestNumbers').AsInteger := FReadSQL.FieldByName('USR$GUESTCOUNT').ASInteger;
        MemTable.FieldByName('OpenTime').ASDateTime := FReadSQL.FieldByName('USR$TIMEORDER').AsDateTime;
        MemTable.FieldByName('Summ').AsCurrency := FReadSQL.FieldByName('USR$SUMNCUWITHDISCOUNT').AsCurrency;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        if FReadSQL.FieldByName('USR$PAY').ASInteger = 1 then
          MemTable.FieldByName('Status').AsInteger := Integer(osOrderPayed)
        else if not FReadSQL.FieldByName('USR$TIMECLOSEORDER').IsNull then
          MemTable.FieldByName('Status').AsInteger := Integer(osOrderClose)
        else
          MemTable.FieldByName('Status').AsInteger := Integer(osOrderOpen);
        MemTable.FieldByName('ISLOCKED').AsInteger := FReadSQL.FieldByName('USR$ISLOCKED').AsInteger;
        MemTable.FieldByName('USR$COMPUTERNAME').AsString := FReadSQL.FieldByName('USR$COMPUTERNAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetUserRuleForPayment(const PayKey: Integer): Boolean;
var
  FMask: Integer;
begin
  Result := True;

  FReadSQL.Close;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FReadSQL.SQL.Text :=
      ' SELECT ' +
      '   R.USR$GROUPKEY ' +
      ' FROM USR$MN_PAYMENTRULES R ' +
      ' WHERE R.USR$PAYTYPEKEY = :ID ';
    FReadSQL.Params[0].AsInteger := PayKey;
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      FMask := GetGroupMask(FReadSQL.FieldByName('USR$GROUPKEY').AsInteger);
      Result := ((FUserGroup and FMask) <> 0);
      if Result then
        exit;

      FReadSQL.Next;
    end;
  finally
    FReadSQL.Close;
  end;
end;

{ ������ ���� ������������� ������ }
procedure TFrontBase.GetWaiterList(AOrderList: TList<TrfUser>);
var
  Order: TrfUser;
begin
  FReadSQL.Close;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FReadSQL.SQL.Text :=
      ' SELECT DISTINCT ' +
      '   u.contactkey AS contactkey, ' +
      '   con.name AS fullname ' +
      ' FROM ' +
      '   gd_user u ' +
      '   JOIN gd_contact con ON con.id = u.contactkey ' +
      ' WHERE ' +
      '   u.disabled <> 1 ' +
      '   AND u.usr$mn_isfrontuser = 1 ' +
      ' ORDER BY ' +
      '   con.name ASC ';
    FReadSQL.ExecQuery;
    while not FReadSQL.EOF do
    begin
      Order := TrfUser.Create(FReadSQL.FieldByName('contactkey').AsInteger, FReadSQL.FieldByName('fullname').AsString);
      AOrderList.Add(Order);

      FReadSQL.Next;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetReservOrder(const HeaderTable, LineTable,
  ModifyTable: TkbmMemTable; OrderKey: Integer): Boolean;
var
  BPost, APost: TDataSetNotifyEvent;
begin
  HeaderTable.Close;
  HeaderTable.CreateTable;
  HeaderTable.Open;

  LineTable.Close;
  LineTable.CreateTable;
  LineTable.Open;

  ModifyTable.Close;
  ModifyTable.CreateTable;
  ModifyTable.Open;

  if OrderKey  = -1 then
  begin
    Result := True;
    Exit;
  end;
  FReadSQL.Close;

  APost := HeaderTable.AfterPost;
  HeaderTable.AfterPost := nil;

  BPost := LineTable.BeforePost;
  LineTable.BeforePost := nil;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := cst_ReservOrderHeader;
      FReadSQL.ParamByName('ID').AsInteger := OrderKey;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        HeaderTable.Append;
        HeaderTable.FieldByName('id').Value := FReadSQL.FieldByName('id').Value;
        HeaderTable.FieldByName('number').Value := FReadSQL.FieldByName('number').Value;
        HeaderTable.FieldByName('sumncu').Value := FReadSQL.FieldByName('sumncu').Value;
        HeaderTable.FieldByName('usr$mn_printdate').Value := FReadSQL.FieldByName('usr$mn_printdate').Value;
        HeaderTable.FieldByName('editorkey').Value := FReadSQL.FieldByName('editorkey').Value;
        HeaderTable.FieldByName('editiondate').Value := FReadSQL.FieldByName('editiondate').Value;
        HeaderTable.FieldByName('creationdate').Value := FReadSQL.FieldByName('creationdate').Value;
        HeaderTable.FieldByName('USR$GUESTCOUNT').AsInteger := FReadSQL.FieldByName('USR$GUESTCOUNT').AsInteger;
        HeaderTable.FieldByName('USR$TABLEKEY').AsInteger := FReadSQL.FieldByName('USR$TABLEKEY').AsInteger;
        HeaderTable.Post;
        FReadSQL.Next;
      end;
      FReadSQL.Close;
      FReadSQL.SQL.Text := cst_ReservOrderLine;
      FReadSQL.ParamByName('ID').AsInteger := OrderKey;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        LineTable.Append;
        LineTable.FieldByName('id').Value := FReadSQL.FieldByName('id').Value;
        LineTable.FieldByName('number').Value := FReadSQL.FieldByName('number').Value;
        LineTable.FieldByName('GOODNAME').Value := FReadSQL.FieldByName('GOODNAME').Value;
        LineTable.FieldByName('usr$mn_printdate').Value := FReadSQL.FieldByName('usr$mn_printdate').Value;
        LineTable.FieldByName('usr$quantity').Value := FReadSQL.FieldByName('usr$quantity').Value;
        LineTable.FieldByName('usr$costncu').Value := FReadSQL.FieldByName('usr$costncu').Value;
        LineTable.FieldByName('usr$goodkey').Value := FReadSQL.FieldByName('usr$goodkey').Value;
        LineTable.FieldByName('usr$sumncuwithdiscount').Value := FReadSQL.FieldByName('usr$sumncuwithdiscount').Value;
        LineTable.FieldByName('usr$sumncu').Value := FReadSQL.FieldByName('usr$sumncu').Value;
        LineTable.FieldByName('usr$costncuwithdiscount').Value := FReadSQL.FieldByName('usr$costncuwithdiscount').Value;
        LineTable.FieldByName('usr$sumdiscount').Value := FReadSQL.FieldByName('usr$sumdiscount').Value;
        LineTable.FieldByName('usr$persdiscount').Value := FReadSQL.FieldByName('usr$persdiscount').Value;
        LineTable.FieldByName('usr$doublebonus').Value := FReadSQL.FieldByName('usr$doublebonus').Value;
        LineTable.FieldByName('editorkey').Value := FReadSQL.FieldByName('editorkey').Value;
        LineTable.FieldByName('editiondate').Value := FReadSQL.FieldByName('editiondate').Value;
        LineTable.FieldByName('oldquantity').Value := FReadSQL.FieldByName('usr$quantity').Value;
        LineTable.FieldByName('LINEKEY').AsInteger := FReadSQL.FieldByName('id').Value;
        LineTable.FieldByName('STATEFIELD').AsInteger := 0;
        LineTable.FieldByName('CREATIONDATE').AsDateTime := FReadSQL.FieldByName('CREATIONDATE').AsDateTime;
        LineTable.Post;

        FReadSQL.Next;
      end;

      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    HeaderTable.AfterPost := APost;
    LineTable.BeforePost := BPost;
    FReadSQL.Close;
  end;
end;

{ ������ ���� ������������� ������ � ������� �� ������ ������ ���� ������ }
procedure TFrontBase.GetActiveWaiterList(AOrderList: TList<TrfUser>; const WithPrecheck: Boolean);
var
  LDate: TDateTime;
  Order: TrfUser;
begin
  FReadSQL.Close;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    LDate := GetLogicDate;
    FReadSQL.SQL.Text :=
      ' select    ' +
      '   distinct  ' +
      '   u.contactkey,    ' +
      '   /* u.ingroup,  */ ' +
      '   con.name as fullname    ' +
      ' from    ' +
      '   gd_user u    ' +
      '   join gd_contact con on con.id = u.contactkey    ' +
      ' where  ' +
      '   u.disabled <> 1    ' +
      '   and u.usr$mn_isfrontuser = 1    ' +
      '   and exists (select o.documentkey from usr$mn_order o where o.usr$pay <> 1 and o.usr$respkey = con.id ' ;
    if WithPrecheck then
      FReadSQL.SQL.Text := FReadSQL.SQL.Text +
        '   and o.usr$timecloseorder + 0 is not null ';
    if Options.OrderCurrentLDate then
      FReadSQL.SQL.Text := FReadSQL.SQL.Text + ' AND o.USR$LOGICDATE = :LDate ' ;
    FReadSQL.SQL.Text := FReadSQL.SQL.Text + '   ) ' +
      ' order by    ' +
      '   con.name asc  ';
    if Options.OrderCurrentLDate then
      FReadSQL.ParamByName('LDate').AsDateTime := LDate;

    FReadSQL.ExecQuery;
    while not FReadSQL.EOF do
    begin
      Order := TrfUser.Create(FReadSQL.FieldByName('Contactkey').AsInteger, FReadSQL.FieldByName('fullname').AsString);
      AOrderList.Add(Order);

      FReadSQL.Next;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetAllGoodList(const MemTable: TkbmMemTable);
var
  LogicDate: TDateTime;
begin
  LogicDate := GetLogicDate;

  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := cst_AllGoodList;
      FReadSQL.ParamByName('curdate').AsDateTime := LogicDate;

      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetAllUserList(const MemTable: TkbmMemTable);
const
  cn_adminID = 150001;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := 'SELECT ID, NAME FROM GD_USER WHERE ID <> :ID ORDER BY NAME';
      FReadSQL.Params[0].AsInteger := cn_adminID;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetBaudRate: Integer;
begin
  if not (FBaudRate > 0) then
    GetCashInfo;
  Result := FBaudRate;
end;

procedure TFrontBase.InitDB;
var
  I: Integer;
begin
  FFiscalLog := False;
  for I := 0 to ParamCount - 1 do
  begin
    if UpperCase(ParamStr(I)) = '/SN' then
      FIBPath := ParamStr(I + 1)
    else if UpperCase(ParamStr(I)) = '/USER' then
      FIBName := ParamStr(I + 1)
    else if UpperCase(ParamStr(I)) = '/PASSWORD' then
      FIBPassword := ParamStr(I + 1)
    else if UpperCase(ParamStr(I)) = '/FL' then
      FFiscalLog := True;
  end;

  try
    FDataBase.DatabaseName := FIBPath;
    FDatabase.Params.Add('user_name=' + FIBName);
    FDatabase.Params.Add('password=' + FIBPassword);
    FDatabase.Params.Add('lc_ctype=WIN1251');
    FDatabase.SQLDialect := 3;
    for I := 0 to 3 do
    begin
      try
        FDataBase.Open;
        Break;
      except
        if I <> 3 then
          Sleep(5000)
        else
          raise;
      end;
    end;
    FIDTransaction.StartTransaction;
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;
    FReadSQL.Close;

    FReadSQL.SQL.Text :=
      ' SELECT FIRST(1) ' +
      '   oc.companykey, c.name AS companyname ' +
      ' FROM ' +
      '   gd_ourcompany oc ' +
      '   LEFT JOIN gd_contact c ON c.id = oc.companykey ' +
      ' WHERE ' +
      '   oc.disabled = 0  ';
    FReadSQL.ExecQuery ;
    if not FReadSQL.Eof then
    begin
      FCompanyKey := FReadSQL.FieldByName('companyKey').AsInteger;
      FCompanyName := FReadSQL.FieldByName('companyname').AsString;
    end
    else
    begin
      FCompanyKey := -1;
      FCompanyName := '';
    end;
    FReadSQL.Close;
  except
    raise;
  end;
end;

function TFrontBase.LogIn(const UserPassword: String): Boolean;
begin
  Result := False;
  // ��������� ������� � �������
  if EnsureDBConnection then
  begin
    FReadSQL.Close;
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;
    try
      FReadSQL.SQL.Text :=
        ' SELECT u.ingroup,  u.id userkey, con.name, con.id contactkey ' +
        ' FROM GD_USER u ' +
        ' LEFT JOIN gd_contact con on con.id = u.contactkey ' +
        ' WHERE ' +
        '    u.passw = :Password ';
      FReadSQL.ParamBYName('Password').AsString := UserPassword;
      FReadSQL.ExecQuery;
      if not FReadSQL.EOF then
      begin
        Result := True;
     //   FUserKey := 0;//FReadSQL.FieldByName('userkey').AsInteger;
        FUserName := FReadSQL.FieldByName('Name').AsString;
        FContactKey := FReadSQL.FieldByName('contactkey').AsInteger;
        FUserGroup := FReadSQL.FieldByName('ingroup').AsInteger;
      end else
      begin
        Result := False;
//        FUserKey := -1;
        FUserName := '';
        FContactKey := -1;
        FUserGroup := -1;
      end
    finally
      FReadSQL.Close;
    end;
  end
end;

function TFrontBase.GetLogicDate: TDateTime;
var
  FSQL: TIBSQL;
begin
  GetLogicDate := Date;
  if FDataBase.Connected then
  begin
    if not Options.UseCurrentDate then
    begin
      FSQL := TIBSQL.Create(nil);
      try
        try
          FSQL.Transaction := ReadTransaction;
          FSQL.SQL.Text :=
            'select max(op.usr$logicdate) as LDate ' +
            '  from usr$mn_options op ';
          FSQL.ExecQuery;
          if not FSQL.EOF then
            GetLogicDate := FSQL.FieldByName('Ldate').AsDateTime;
          FSQL.Close;
        except
          raise;
        end;
      finally
        FSQL.Free;
      end;
    end;
  end;
end;

function TFrontBase.GetModificationList(const MemTable: TkbmMemTable;
  const GoodKey, ModifyGroupKey: Integer): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      if GoodKey <> -1 then
      begin
        FReadSQL.SQL.Text :=
          'Select ' +
          'm.usr$name, m.id, c.usr$mn_modifykey, c.usr$gd_goodkey ' +
          'FROM usr$mn_modify m ' +
          '  JOIN USR$CROSS36_416793598 c ON c.usr$mn_modifykey = m.id ' +
          'WHERE c.usr$gd_goodkey = :goodkey ' +
          'ORDER BY m.usr$name ';
        FReadSQL.ParamByName('goodkey').AsInteger := GoodKey;
        FReadSQL.ExecQuery;
        while not FReadSQL.Eof do
        begin
          MemTable.Append;
          MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
          MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
          MemTable.Post;

          FReadSQL.Next;
        end;
      end else
      if ModifyGroupKey <> -1 then
      begin
        FReadSQL.SQL.Text :=
          'SELECT m.id, m.USR$NAME FROM usr$mn_modify mn ' +
          'LEFT JOIN usr$mn_modify m ON m.LB >= mn.LB ' +
          '  AND  m.RB <= mn.RB ' +
          'WHERE m.USR$ISGROUP <> 1 ' +
          '  AND mn.ID = :modifygroupkey ' +
          'ORDER BY m.usr$name ';
        FReadSQL.ParamByName('modifygroupkey').AsInteger := ModifyGroupKey;
        FReadSQL.ExecQuery;
        while not FReadSQL.Eof do
        begin
          MemTable.Append;
          MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
          MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
          MemTable.Post;

          FReadSQL.Next;
        end;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.InitDisplay;
begin
  FDisplayInitialized := False;
  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT * FROM USR$MN_SALEDEVICE sd ' +
        ' WHERE sd.USR$COMPUTERNAME = :ComputerName and sd.usr$active = 1 ';
      FReadSQL.ParamByName('ComputerName').AsString := ComputerName;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        while not FReadSQL.Eof do
        begin
          if FReadSQL.FieldByName('USR$DEVICETYPE').AsInteger = 0 then
          begin
            FDisplay := TDisplay.Create;
            FDisplay.ComPort := FReadSQL.FieldByName('USR$COMPORT').AsInteger;
            FDisplay.Init(True, 1);

            Break;
          end;
          FReadSQL.Next;
        end;
      end else
      begin
        FDisplay := TDisplay.Create;
        FDisplay.Init(False, -1);
      end;
      FDisplayInitialized := True;
    except
      FDisplayInitialized := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.InitFrontConst;
var
  FSQL, FSQLInsRUID, FSQLDelRUID, FSQLIns: TIBSQL;
  FTransaction: TIBTransaction;
  FXID, FDBID: Integer;
begin
  if Assigned(FDataBase) and FDataBase.Connected then
  begin
    FSQL := TIBSQL.Create(nil);
    FSQLInsRUID := TIBSQL.Create(nil);
    FSQLDelRUID := TIBSQL.Create(nil);
    FSQLIns := TIBSQL.Create(nil);
    FTransaction := TIBTransaction.Create(nil);
    try

      FTransaction.DefaultDatabase := FDataBase;
      FSQL.Transaction := FTransaction;
      FSQLInsRUID.Transaction := FTransaction;
      FSQLDelRUID.Transaction := FTransaction;
      FSQLIns.Transaction := FTransaction;
      FSQLDelRUID.SQL.Text := ' DELETE FROM gd_ruid r WHERE r.xid = :xid and r.dbid = :dbid ';
      FSQLInsRUID.SQL.Text := ' insert into gd_ruid (id, xid, dbid, modified) values (:id, :xid, :dbid, current_timestamp) ';
      FTransaction.StartTransaction;

      //DocumentTypeKey
      // DocumentTypeKey_ZakazRezerv  147747477, 1650037404
      FXID := 147747477;
      FDBID := 1650037404;
      FSQL.SQL.Text := ' SELECT dt.id from gd_ruid r JOIN gd_documenttype dt ON dt.id = r.id ' +
                       ' WHERE r.xid = :XID and r.dbid = :DBID ';
      FSQL.ParamByName('xid').AsInteger := FXID;
      FSQL.ParamByName('dbid').AsInteger := FDBID;
      FSQL.ExecQuery;
      if not FSQL.EOF then
        FFrontConst.DocumentTypeKey_ZakazRezerv := FSQL.FieldByName('ID').AsInteger
      else
        raise Exception.Create('�������� ��������� ��. ����������� ������� �������� ������������');
      FSQL.Close;

      // DocumentTypeKey_Zakaz 147014509, 9263644
      FXID := 147014509;
      FDBID := 9263644;

      FSQL.ParamByName('xid').AsInteger := FXID;
      FSQL.ParamByName('dbid').AsInteger := FDBID;
      FSQL.ExecQuery;
      if not FSQL.EOF then
        FFrontConst.DocumentTypeKey_Zakaz := FSQL.FieldByName('ID').AsInteger
      else
        raise Exception.Create('�������� ��������� ��. ����������� ������� �������� �����');

      //USR$INV_PAYTYPE
      // ��������� 147142772_354772515
      FXID := 147142772;
      FDBID := 354772515;

      FSQL.Close;
      FSQL.SQL.Text := ' SELECT pt.id from gd_ruid r JOIN USR$INV_PAYTYPE pt ON pt.id = r.id ' +
                       ' WHERE r.xid = :XID and r.dbid = :DBID ';
      FSQL.ParamByName('xid').AsInteger := FXID;
      FSQL.ParamByName('dbid').AsInteger := FDBID;
      FSQL.ExecQuery;
      if not FSQL.EOF then
        FFrontConst.PayType_Cash := FSQL.FieldByName('ID').AsInteger
      else
      begin
        FSQLDelRUID.Close;
        FSQLDelRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLDelRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLDelRUID.ExecQuery;

        FSQLIns.Close;
        FSQLIns.SQL.Text := 'INSERT INTO USR$INV_PAYTYPE (ID, EDITIONDATE, EDITORKEY, USR$NAME) ' +
                            ' VALUES (:ID, current_timestamp, 650002, :Name)';
        FFrontConst.PayType_Cash := GetNextID;
        FSQLIns.ParamByName('ID').AsInteger := FFrontConst.PayType_Cash;
        FSQLIns.ParamByName('Name').AsString := '���������';
        FSQLIns.ExecQuery;

        FSQLInsRUID.Close;
        FSQLInsRUID.ParamBYName('ID').AsInteger := FFrontConst.PayType_Cash;
        FSQLInsRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLInsRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLInsRUID.ExecQuery;
      end;
      FSQL.Close;

      // ������������ ����� 147733995_1604829035
      FXID := 147733995;
      FDBID := 1604829035;

      FSQL.Close;
      FSQL.ParamByName('xid').AsInteger := FXID;
      FSQL.ParamByName('dbid').AsInteger := FDBID;
      FSQL.ExecQuery;
      if not FSQL.EOF then
        FFrontConst.PayType_PersonalCard := FSQL.FieldByName('ID').AsInteger
      else
      begin
        FSQLDelRUID.Close;
        FSQLDelRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLDelRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLDelRUID.ExecQuery;

        FSQLIns.Close;
        FSQLIns.SQL.Text := 'INSERT INTO USR$INV_PAYTYPE (ID, EDITIONDATE, EDITORKEY, USR$NAME) ' +
                            ' VALUES (:ID, current_timestamp, 650002, :Name)';
        FFrontConst.PayType_PersonalCard := GetNextID;
        FSQLIns.ParamByName('ID').AsInteger := FFrontConst.PayType_PersonalCard;
        FSQLIns.ParamByName('Name').AsString := '������������ �����';
        FSQLIns.ExecQuery;

        FSQLInsRUID.Close;
        FSQLInsRUID.ParamBYName('ID').AsInteger := FFrontConst.PayType_PersonalCard;
        FSQLInsRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLInsRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLInsRUID.ExecQuery;
      end;
      FSQL.Close;

      // ����������� ����� 147783694_1702380588
      FXID := 147783694;
      FDBID := 1702380588;
      FSQL.Close;
      FSQL.ParamByName('xid').AsInteger := FXID;
      FSQL.ParamByName('dbid').AsInteger := FDBID;
      FSQL.ExecQuery;
      if not FSQL.EOF then
        FFrontConst.PayType_Card := FSQL.FieldByName('ID').AsInteger
      else
      begin
        FSQLDelRUID.Close;
        FSQLDelRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLDelRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLDelRUID.ExecQuery;

        FSQLIns.Close;
        FSQLIns.SQL.Text := 'INSERT INTO USR$INV_PAYTYPE (ID, EDITIONDATE, EDITORKEY, USR$NAME) ' +
                            ' VALUES (:ID, current_timestamp, 650002, :Name)';
        FFrontConst.PayType_Card := GetNextID;
        FSQLIns.ParamByName('ID').AsInteger := FFrontConst.PayType_Card;
        FSQLIns.ParamByName('Name').AsString := '����������� �����';
        FSQLIns.ExecQuery;

        FSQLInsRUID.Close;
        FSQLInsRUID.ParamBYName('ID').AsInteger := FFrontConst.PayType_Card;
        FSQLInsRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLInsRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLInsRUID.ExecQuery;

        FSQLIns.Close;
        FSQLIns.SQL.Text := ' UPDATE usr$mn_kindtype SET usr$paytypekey = :usr$paytypekey WHERE usr$isplcard = 1 ';
        FSQLIns.ParamByName('usr$paytypekey').AsInteger := FFrontConst.PayType_Card;
        FSQLIns.ExecQuery;

      end;
      FSQL.Close;

  // USR$MN_KINDTYPE
  //����� �� ��������� ����� ������
  //  mn_RUBpaytypeXID = 147141777;
  //  mn_RUBpaytypeDBID = 349813242;

      FXID := 147141777;
      FDBID := 349813242;
      FSQL.SQL.Text := ' SELECT pt.id from gd_ruid r JOIN USR$MN_KINDTYPE pt ON pt.id = r.id ' +
                       ' WHERE r.xid = :XID and r.dbid = :DBID ';
      FSQL.ParamByName('xid').AsInteger := FXID;
      FSQL.ParamByName('dbid').AsInteger := FDBID;
      FSQL.ExecQuery;
      if not FSQL.EOF then
        FFrontConst.KindType_CashDefault := FSQL.FieldByName('ID').AsInteger
      else
      begin
        FSQLDelRUID.Close;
        FSQLDelRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLDelRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLDelRUID.ExecQuery;

        FSQLIns.Close;
        FSQLIns.SQL.Text := ' INSERT INTO USR$MN_KINDTYPE (ID, EDITIONDATE,        EDITORKEY, USR$NAME, USR$ALIAS, USR$PAYTYPEKEY) ' +
                            ' VALUES (:ID, current_timestamp, 650002,    ''�����'',  ''001'',     :PAYTYPEKEY)';

        FFrontConst.KindType_CashDefault := GetNextID;
        FSQLIns.ParamByName('ID').AsInteger := FFrontConst.KindType_CashDefault;
        FSQLIns.ParamByName('PAYTYPEKEY').AsInteger := FFrontConst.PayType_Cash;
        FSQLIns.ExecQuery;

        FSQLInsRUID.Close;
        FSQLInsRUID.ParamBYName('ID').AsInteger := FFrontConst.KindType_CashDefault;
        FSQLInsRUID.ParamBYName('XID').AsInteger := FXID;
        FSQLInsRUID.ParamBYName('DBID').AsInteger := FDBID;
        FSQLInsRUID.ExecQuery;
      end;
      FSQL.Close;


      FTransaction.Commit;
    finally
      FSQL.Free;
      FSQLIns.Free;
      FSQLInsRUID.Free;
      FSQLDelRUID.Free;
      FTransaction.Free;
    end;
  end;
end;

function TFrontBase.GetDisplay: TDisplay;
begin
  if not FDisplayInitialized then
    InitDisplay;

  Result := FDisplay;
end;

procedure TFrontBase.GetEditUserInfo(const EmplTable,
  GroupListTable: TkbmMemTable; UserKey: Integer; const FGroupList: TList<Integer>);
var
  InGroup: Integer;
begin
  FReadSQL.Close;
  EmplTable.Close;
  EmplTable.Open;

  InGroup := 0;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'SELECT U.PASSW, U.DISABLED, U.DISABLED, U.CONTACTKEY, ' +
        '  P.FIRSTNAME, P.MIDDLENAME, P.SURNAME, U.INGROUP ' +
        'FROM GD_USER U ' +
        'JOIN GD_PEOPLE P ON U.CONTACTKEY = P.CONTACTKEY ' +
        'WHERE U.ID = :userkey ';
      FReadSQL.Params[0].AsInteger := UserKey;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        EmplTable.Append;
        EmplTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('CONTACTKEY').AsInteger;
        EmplTable.FieldByName('FIRSTNAME').AsString := FReadSQL.FieldByName('FIRSTNAME').AsString;
        EmplTable.FieldByName('MIDDLENAME').AsString := FReadSQL.FieldByName('MIDDLENAME').AsString;
        EmplTable.FieldByName('SURNAME').AsString := FReadSQL.FieldByName('SURNAME').AsString;
        EmplTable.FieldByName('DISABLED').AsBoolean := (FReadSQL.FieldByName('DISABLED').AsInteger = 1);
        EmplTable.FieldByName('PASSW').AsString := FReadSQL.FieldByName('PASSW').AsString;
        InGroup := FReadSQL.FieldByName('INGROUP').AsInteger;
        EmplTable.Post;
      end;
      FReadSQL.Close;

      //�������� ������
      FReadSQL.SQL.Text :=
        ' SELECT ID FROM ' +
        ' gd_usergroup z ' +
        ' WHERE g_b_and(:id, g_b_shl(1, z.id - 1)) <> 0 ';
      FReadSQL.Params[0].AsInteger := InGroup;
      FReadSQL.ExecQuery;
      while not FReadSQL.Eof do
      begin
        if GroupListTable.Locate('ID', FReadSQL.FieldByName('ID').AsInteger, []) then
        begin
          GroupListTable.Edit;
          GroupListTable.FieldByName('CHECKED').AsInteger := 1;
          GroupListTable.Post;
        end
        else
          FGroupList.Add(FReadSQL.FieldByName('ID').AsInteger);
        FReadSQL.Next;
      end;
      FReadSQL.Close;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetPayKindType(const MemTable: TkbmMemTable; const PayType: Integer;
  IsPlCard: Integer = 0; const IsExternal: Boolean = False): Boolean;
var
  S: String;
  FSQL: TIBSQL;
  FTransaction: TIBTransaction;
begin
  FReadSQL.Close;

  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    if IsExternal then
    begin
      FSQL := TIBSQL.Create(nil);
      FTransaction := TIBTransaction.Create(nil);
      try
        FTransaction.DefaultDatabase := FDataBase;
        FTransaction.StartTransaction;
        FSQL.Transaction := FTransaction;
        FSQL.SQL.Text :=
          '  SELECT P.ID, CAST(:USR$PAYTYPEKEY AS INTEGER) AS USR$PAYTYPEKEY, P.USR$NOFISCAL, P.USR$NAME ' +
          '  FROM RF$EXT_GETPAYTYPELIST (:LOGICDATE, CURRENT_TIMESTAMP, :USR$PAYTYPEKEY) P ORDER BY P.USR$NAME ';
        FSQL.ParamByName('LogicDate').AsDateTime := GetLogicDate;
        FSQL.ParamByName('USR$PAYTYPEKEY').ASInteger := PayType;
        FSQL.ExecQuery;
        while not FSQL.Eof do
        begin
          MemTable.Append;
          MemTable.FieldByName('USR$NAME').AsString := FSQL.FieldByName('USR$NAME').AsString;
          MemTable.FieldByName('USR$PAYTYPEKEY').AsInteger := FSQL.FieldByName('ID').AsInteger;
          MemTable.FieldByName('USR$NOFISCAL').AsInteger := FSQL.FieldByName('USR$NOFISCAL').AsInteger;
          MemTable.Post;

          FSQL.Next;
        end;
        FSQL.Close;
        Result := True;
      finally
        if FTransaction.InTransaction then
          FTransaction.Commit;

        FSQL.Free;
        FTransaction.Free;
      end;
    end
    else
    begin
      try
        if not FReadSQL.Transaction.InTransaction then
          FReadSQL.Transaction.StartTransaction;

        S := ' SELECT K.USR$NAME, K.USR$PAYTYPEKEY, K.USR$NOFISCAL, K.ID FROM USR$MN_KINDTYPE K ' +
          ' LEFT JOIN USR$MN_PAYMENTRULES R ON R.USR$PAYTYPEKEY = K.USR$PAYTYPEKEY ';
        if IsPlCard = 1 then
          S := S + ' WHERE K.USR$ISPLCARD = 1 ' +
            ' AND (R.USR$PAYTYPEKEY IS NULL OR (BIN_AND(g_b_shl(1, R.USR$GROUPKEY - 1), :UserGroup) <> 0)) '
        else
          S := S + ' WHERE K.USR$PAYTYPEKEY = :paytype AND ((K.USR$ISPLCARD IS NULL) OR (K.USR$ISPLCARD = 0))';
        S := S + ' ORDER BY K.USR$NAME ';
        FReadSQL.SQL.Text := S;

        if IsPlCard = 1 then
          FReadSQL.ParamByName('UserGroup').AsInteger := FUserGroup
        else
          FReadSQL.ParamByName('paytype').AsInteger := PayType;

        FReadSQL.ExecQuery;
        while not FReadSQL.Eof do
        begin
          MemTable.Append;
          MemTable.FieldByName('USR$NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
          MemTable.FieldByName('USR$PAYTYPEKEY').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
          MemTable.FieldByName('USR$NOFISCAL').AsInteger := FReadSQL.FieldByName('USR$NOFISCAL').AsInteger;
          MemTable.Post;

          FReadSQL.Next;
        end;
        Result := True;
      finally
        FReadSQL.Close;
      end;
    end;
  except
    raise;
  end;
end;

procedure TFrontBase.GetPaymentsCount(var CardCount, NoCashCount,
  PercCardCount, CashCount: Integer);
begin
  FReadSQL.Close;

  CardCount := 0;
  NoCashCount := 0;
  PercCardCount := 0;
  CashCount := 0;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT ' +
        '   SUM(IIF(R.USR$PAYTYPEKEY IS NULL OR (BIN_AND(g_b_shl(1, R.USR$GROUPKEY - 1), :UserGroup) <> 0), 1, 0)) AS PayCount ' +
        ' FROM usr$mn_personalcard K ' +
        ' LEFT JOIN USR$MN_PAYMENTRULES R ON R.USR$PAYTYPEKEY = :PAYTYPEKEY ';
      //1. ������ �� ������������ �����
      FReadSQL.ParamByName('PAYTYPEKEY').AsInteger := FrontConst.PayType_PersonalCard;
      FReadSQL.ParamByName('UserGroup').AsInteger := FUserGroup;
      FReadSQL.ExecQuery;

      if not FReadSQL.EOF then
        PercCardCount := FReadSQL.FieldByName('PayCount').AsInteger;

      //2. ��������� �����
      FReadSQL.Close;
      FReadSQL.SQL.Text :=
        ' SELECT ' +
        '   SUM(IIF(R.USR$PAYTYPEKEY IS NULL OR (BIN_AND(g_b_shl(1, R.USR$GROUPKEY - 1), :UserGroup) <> 0), 1, 0)) AS PayCount ' +
        ' FROM USR$MN_KINDTYPE K' +
        ' LEFT JOIN USR$MN_PAYMENTRULES R ON R.USR$PAYTYPEKEY = K.USR$PAYTYPEKEY ' +
        ' WHERE K.USR$PAYTYPEKEY = :PAYTYPEKEY  ';

      FReadSQL.ParamByName('PAYTYPEKEY').AsInteger := FrontConst.PayType_Card;
      FReadSQL.ParamByName('UserGroup').AsInteger := FUserGroup;
      FReadSQL.ExecQuery;
      if not FReadSQL.EOF then
        CardCount := FReadSQL.FieldByName('PayCount').AsInteger;
      FReadSQL.Close;

      //2. �������� ������
      FReadSQL.Close;
      FReadSQL.ParamByName('PAYTYPEKEY').AsInteger := FrontConst.PayType_Cash;
      FReadSQL.ParamByName('UserGroup').AsInteger := FUserGroup;
      FReadSQL.ExecQuery;
      if not FReadSQL.EOF then
        CashCount := FReadSQL.FieldByName('PayCount').AsInteger;


      //4. ��������� ����� �������
      FReadSQL.Close;
      FReadSQL.SQL.Text :=
        ' SELECT ' +
        '   SUM(IIF(R.USR$PAYTYPEKEY IS NULL OR (BIN_AND(g_b_shl(1, R.USR$GROUPKEY - 1), :UserGroup) <> 0), 1, 0)) AS PayCount ' +
        ' FROM USR$MN_KINDTYPE K' +
        ' LEFT JOIN USR$MN_PAYMENTRULES R ON R.USR$PAYTYPEKEY = K.USR$PAYTYPEKEY ' +
        ' WHERE ' +
        '  K.USR$PAYTYPEKEY <> :CashType ' +
        '  AND K.USR$PAYTYPEKEY <> :CardType ' +
        '  AND K.USR$PAYTYPEKEY <> :PrersCardType ';
      FReadSQL.ParamByName('UserGroup').AsInteger := FUserGroup;
      FReadSQL.ParamByName('CashType').AsInteger := FrontConst.PayType_Cash;
      FReadSQL.ParamByName('CardType').AsInteger := FrontConst.PayType_Card;
      FReadSQL.ParamByName('PrersCardType').AsInteger := FrontConst.PayType_PersonalCard;
      FReadSQL.ExecQuery;
      if not FReadSQL.EOF then
        NoCashCount := FReadSQL.FieldByName('PayCount').AsInteger;

      FReadSQL.Close;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetPersonalCardInfo(const MemTable: TkbmMemTable;
  const Pass: String): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'SELECT C.*, T.USR$NOFISCAL, t.id kindtypekey FROM USR$MN_PERSONALCARD C ' +
        'JOIN USR$MN_KINDTYPE T ON 1 = 1 ' +
        'WHERE T.usr$paytypekey = :ID AND C.USR$CODE = :pass ';
      FReadSQL.ParamByName('pass').AsString := Pass;
      FReadSQL.ParamByName('ID').AsInteger := FrontConst.PayType_PersonalCard;
      FReadSQL.ExecQuery;
      while not FReadSQL.Eof do
      begin
        if FReadSQL.FieldByName('USR$DISABLED').AsInteger = 1 then
        begin
          Touch_MessageBox('��������', '������ ����� ���������!', MB_OK, mtWarning);
          Result := False;
          exit;
        end;
        MemTable.Append;
        MemTable.FieldByName('USR$NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
        MemTable.FieldByName('USR$CODE').AsString := FReadSQL.FieldByName('USR$CODE').AsString;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('kindtypekey').AsInteger := FReadSQL.FieldByName('kindtypekey').AsInteger;
        MemTable.FieldByName('USR$NOFISCAL').AsInteger := FReadSQL.FieldByName('USR$NOFISCAL').AsInteger;
        MemTable.Post;

        FReadSQL.Next;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetIBRandomString: String;
var
  I, Pr, C: Integer;
begin
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    SetLength(Result, 8);
    repeat
      Pr := -1;
      for I := 1 to 8 do
      begin
        repeat
          C := Random(36);
        until (C <> Pr) and ((I > 1) or (C < 26));
        Pr := C;
        if C > 25 then
          Result[I] := Chr(Ord('0') + C - 26)
        else
          Result[I] := Chr(Ord('A') + C);
      end;

      FReadSQL.Close;
      FReadSQL.SQL.Text := 'SELECT id FROM gd_user WHERE ibname=''' + Result + '''' +
        ' OR ibpassword=''' + Result + '''';
      FReadSQL.ExecQuery;
    until FReadSQL.EOF;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

function RUIDToStr(const ARUID: TRUID): String;
begin
  with ARUID do
    if (XID = -1) or (DBID = -1) then
      Result := ''
    else
      Result := IntToStr(XID) + '_' + IntToStr(DBID);
end;

function StrToRUID(const AString: String): TRUID;
var
  P: Integer;
begin
  with Result do
    if AString = '' then
    begin
      XID := -1;
      DBID := -1;
    end else begin
      P := Pos('_', AString);
      if P = 0 then
        raise Exception.Create('Invalid RUID string')
      else begin
        XID := StrToIntDef(Copy(AString, 1, P - 1), -1);
        DBID := StrToIntDef(Copy(AString, P + 1, 255), -1);
        if (XID <= 0) or (DBID <= 0) then
          raise Exception.Create('Invalid RUID string')
      end;
    end;
end;

function RUID(const XID, DBID: TID): TRUID;
begin
  Result.XID := XID;
  Result.DBID := DBID;
end;

function TFrontBase.GetIDByRUID(const XID: Integer;
  const DBID: Integer): Integer;
var
  S: String;
  RR: TRUIDRec;
begin
  if (XID = -1) and (DBID = -1) then
  begin
    Result := -1;
  end else
  begin
    S := RUIDToStr(RUID(XID, DBID));
    if not CacheList.TryGetValue(S, Result) then
    begin
      RR := GetRUIDRecByXID(XID, DBID);
      if RR.ID = -1 then
        Result := -1
      else begin
        Result := RR.ID;
        CacheList.Add(S, Result);
      end;
    end;
  end;
end;

function TFrontBase.GetRUIDRecByXID(const XID, DBID: TID): TRUIDRec;
begin
  FReadSQL.Close;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FReadSQL.SQL.Text := ' SELECT ID FROM gd_ruid WHERE xid = :xid and dbid = :dbid ' ;
    FReadSQL.ParamByName('xid').AsInteger := XID;
    FReadSQL.ParamByName('dbid').AsInteger := DBID;
    FReadSQL.ExecQuery;
    if not FReadSQL.Eof then
      Result.ID := FReadSQL.FieldByname('ID').AsInteger
    else
      Result.ID := -1;
    Result.XID := XID;
    Result.DBID := DBID;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetCashInfo;
begin
  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' select ' +
        '   first(1) ' +
        '   s.usr$cashcode as code, s.USR$COMPORT as comport, ' +
        '   s.usr$cashnumber as number, s.USR$BAUDRATE as baudrate, s.id ' +
        ' from ' +
        '   usr$mn_pointofsaleset  s  ' +
        ' where ' +
        '   upper(s.usr$computer) = upper(:comp) ' +
        '   and coalesce(s.usr$active, 0) = 0 ' +
        '   and s.usr$kassa > '''' ' +
        ' order by  ' +
        '   s.id desc ';
      FReadSQL.ParamByName('comp').AsString := ComputerName;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        FCashCode := FReadSQL.FieldByName('code').AsInteger;
        FFiscalComPort := FReadSQL.FieldByName('comport').AsInteger;
        FCashNumber := FReadSQL.FieldByName('number').AsInteger;
        FIsMainCash := True;
        FBaudRate := FReadSQL.FieldByName('baudrate').AsInteger;
      end else
      begin
        FCashCode := -1;
        FFiscalComPort := -1;
        FCashNumber := -1;
        FIsMainCash := False;
        FBaudRate := -1;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetCashCode: Integer;
begin
  if not (FCashCode > 0) then
    GetCashInfo;
  Result := FCashCode;
end;

function TFrontBase.GetCashFiscalType: Integer;
var
  FSQL: TIBSQL;
begin
  Result := 0;
  FSQL := TIBSQL.Create(nil);
  try
    try
      FSQL.Transaction := ReadTransaction;
      FSQL.SQL.Text := ' SELECT USR$NOFISCAL ' +
        ' FROM USR$MN_KINDTYPE WHERE ID = :ID ';
      FSQL.ParamByName('ID').AsInteger := FrontConst.KindType_CashDefault;
      FSQL.ExecQuery;
      Result := FSQL.FieldByName('USR$NOFISCAL').AsInteger;
      FSQL.Close;
    except
      raise;
    end;
  finally
    FSQL.Free;
  end;
end;

function TFrontBase.GetFiscalComPort: Integer;
begin
  if not (FFiscalComPort > 0) then
    GetCashInfo;
  Result := FFiscalComPort;
end;

function TFrontBase.GetCashNumber: Integer;
begin
  if not (FCashNumber > 0) then
    GetCashInfo;
  Result := FCashNumber;
end;

function TFrontBase.GetIsMainCash: Boolean;
begin
  if not FIsMainCash then
    GetCashInfo;
  Result := FIsMainCash;
end;

function TFrontBase.GetNameWaiterOnID(const ID: Integer; WithGroup,
  TwoRows: Boolean): String;
var
  S, UserInGroupName: String;
begin
  Result := '';

  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' select ' +
        '   con.name, u.ingroup ' +
        ' from ' +
        '   gd_contact con ' +
        '   join gd_user u on u.contactkey = con.id ' +
        ' where ' +
        '   con.id = :id ';
      FReadSQL.Params[0].AsInteger := ID;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        if TwoRows then
          S := #13#10
        else
          S := '';

        if WithGroup then
        begin
          if (FReadSQL.FieldByName('InGroup').AsInteger and Options.ManagerGroupMask) <> 0 then
            UserInGroupName := '��������: '
          else if (FReadSQL.FieldByName('InGroup').AsInteger and Options.KassaGroupMask) <> 0 then
            UserInGroupName := '������: '
          else
            UserInGroupName := '��������: ';

          S := UserInGroupName + S;
        end;
        Result := S + FReadSQL.FieldByName('name').AsString;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.SavePayment(const ContactKey, OrderKey,
  PayKindKey, PersonalCardKey: Integer; Sum: Currency; Revert: Boolean): Boolean;
var
  FSQL: TIBSQL;
  ExtKey: Integer;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    'insert into usr$mn_payment ( ' +
    '    editorkey, ' +
    '    usr$orderkey, ' +
    '    usr$paykindkey, ' +
    '    usr$sumncu, ' +
    '    usr$datetime, ' +
    '    usr$personalcardkey ) ' +
    '  values ( ' +
    '    :editorkey, ' +
    '    :usr$orderkey, ' +
    '    :usr$paykindkey, ' +
    '    :usr$sumncu, ' +
    '    current_timestamp, ' +
    '    :usr$perscardkey ) ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;
    // ��������� �����, ���������� ���������� ������� ������
    try
      FSQL.ParamByName('editorkey').AsInteger := ContactKey;
      FSQL.ParamByName('usr$orderkey').AsInteger := OrderKey;
      FSQL.ParamByName('usr$paykindkey').AsInteger := PayKindKey;
      if Revert then
        FSQL.ParamByName('usr$sumncu').AsCurrency := -Sum
      else
        FSQL.ParamByName('usr$sumncu').AsCurrency := Sum;

      if PersonalCardKey > 0 then
        FSQL.ParamByName('usr$perscardkey').AsInteger := PersonalCardKey
      else
        FSQL.ParamByName('usr$perscardkey').Clear;

      FSQL.ExecQuery;
      Result := True;
    except
      FCheckTransaction.Rollback;
      raise;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;

      if Result then
      begin
        FCheckTransaction.StartTransaction;
        try
          FSQL.Close;
          FSQL.SQL.Text := ' SELECT k.usr$externalkey, p.usr$externalprocess ' +
                           ' FROM                                                              ' +
                           ' USR$MN_KINDTYPE k                                                 ' +
                           '   LEFT JOIN usr$inv_paytype p on p.id = k.usr$paytypekey          ' +
                           ' WHERE k.ID = :ID                                                  ';
          FSQL.ParamByName('ID').AsInteger := PayKindKey;
          FSQL.ExecQuery;

          if FSQL.FieldByName('usr$externalprocess').AsInteger = 1 then
          begin
            try
              ExtKey := FSQL.FieldByName('usr$externalkey').AsInteger;
              FSQL.Close;
              FSQL.SQL.Text := ' EXECUTE PROCEDURE rf$ext_saveorder(:EXTKEY, :LOGICDATE, current_timestamp, :PAYSUM) ';
              FSQL.ParamByName('EXTKEY').AsInteger := ExtKey;
              FSQL.ParamByName('LOGICDATE').AsDateTime := GetLogicDate;
              FSQL.ParamByName('PAYSUM').ASCurrency := Sum;
              FSQL.ExecQuery;
            except
              on E: Exception do
                Touch_MessageBox('��������', '������ ��� ���������� ������ �� ������� �� ' + E.Message, MB_OK, mtError);
            end;
          end;
        finally
          FCheckTransaction.Commit;
        end;
      end;

    FSQL.Free;
  end;

//  EXECUTE PROCEDURE rf$ext_saveorder(:EXTKEY, :LOGICDATE, current_timestamp, :PAYSUM numeric(15,4))

end;

function TFrontBase.SaveOrderLog(const WaiterKey, ManagerKey, OrderKey,
  OrderLineKey, Operation: Integer): Boolean;
var
  FSQL: TIBSQL;
  Curr: Currency;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    'insert into usr$mn_log ( ' +
    '    usr$waiterkey, ' +
    '    usr$managerkey, ' +
    '    usr$orderkey, ' +
    '    usr$orderlinekey, ' +
    '    usr$ordersum, ' +
    '    usr$operation, ' +
    '    usr$logicdate) ' +
    '  values ( ' +
    '    :usr$waiterkey, ' +
    '    :usr$managerkey, ' +
    '    :usr$orderkey, ' +
    '    :usr$orderlinekey, ' +
    '    :usr$ordersum, ' +
    '    :usr$operation, ' +
    '    :usr$logicdate) ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;
    // ��������� �����, ���������� ���������� ������� ������
    try
      FReadSQL.Close;
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;
      try
        FReadSQL.SQL.Text :=
          ' SELECT  ' +
          '   SUM ( L.USR$SUMNCUWITHDISCOUNT ) SumWithDiscount ' +
          ' FROM ' +
          '   USR$MN_ORDERLINE L ' +
          ' WHERE  ' +
          '   L.MASTERKEY  =  :OrderKey ' +
          '      AND  ' +
          '   L.USR$CAUSEDELETEKEY + 0 IS NULL ';
        FReadSQL.ParamByName('ORDERKEY').AsInteger := OrderKey;
        FReadSQL.ExecQuery;
        Curr := FReadSQL.Fields[0].AsCurrency;
      finally
        FReadSQL.Close;
      end;

      FSQL.ParamByName('USR$WAITERKEY').AsInteger := WaiterKey;
      FSQL.ParamByName('USR$MANAGERKEY').AsInteger := ManagerKey;
      FSQL.ParamByName('USR$ORDERKEY').AsInteger := OrderKey;
      FSQL.ParamByName('USR$ORDERLINEKEY').AsInteger := OrderLineKey;
      FSQL.ParamByName('USR$OPERATION').AsInteger := Operation;
      FSQL.ParamByName('USR$LOGICDATE').AsDateTime := GetLogicDate;
      FSQL.ParamByName('USR$ORDERSUM').AsCurrency := Curr;
      FSQL.ExecQuery;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ���� ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;

    FSQL.Free;
  end;
end;

class function TFrontBase.GetGroupMask(const AGroupID: Integer): Integer;
begin
  Assert(AGroupID in [1..32], 'Invalid group ID specified. Must be between 1 and 32.');
  Result := 1 shl (AGroupID - 1);
end;

function TFrontBase.GetHallBackGround(const Stream: TStream;
  const HallKey: Integer): Boolean;
begin
  Result := False;

  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;
      FReadSQL.SQL.Text :=
        'SELECT USR$BACKGROUNDPICTURE AS backgroundpicture '  +
        'FROM USR$MN_HALL  ' +
        'WHERE ID = :ID ';
      FReadSQL.Params[0].AsInteger := HallKey;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        Result := True;
        FReadSQL.FieldByName('backgroundpicture').SaveToStream(Stream);
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetHallsInfo(const MemTable: TkbmMemTable);
begin
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
{ TODO : ������ ����������� ��� ������� ��������? }
  FReadSQL.Close;
  try
    FReadSQL.SQL.Text :=
      ' SELECT * FROM USR$MN_HALL ';
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      MemTable.Append;
      MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
      MemTable.FieldByName('USR$NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
      MemTable.FieldByName('USR$LENGTH').AsFloat := FReadSQL.FieldByName('USR$LENGTH').AsFloat;
      MemTable.FieldByName('USR$WIDTH').AsFloat := FReadSQL.FieldByName('USR$WIDTH').AsFloat;
      MemTable.FieldByName('USR$RESTAURANTKEY').AsInteger := FReadSQL.FieldByName('USR$RESTAURANTKEY').AsInteger;
      MemTable.Post;

      FReadSQL.Next;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.CheckUserPasswordWithForm: TUserInfo;
var
  FForm: TCardCode;
begin
  Result.CheckedUserPassword := False;
  // ��������� ������� � �������
  if EnsureDBConnection then
  begin
    FForm := TCardCode.Create(nil);
    try
      FForm.ShowModal;
      if FForm.ModalResult = 1 then
      begin
        FReadSQL.Close;
        if not FReadSQL.Transaction.InTransaction then
          FReadSQL.Transaction.StartTransaction;
        try
          FReadSQL.SQL.Text :=
            'select ' +
            '  con.id, con.name, usr.ingroup ' +
            'from  ' +
            '  gd_user usr  ' +
            '  join gd_contact con on con.id = usr.contactkey  ' +
            'where ' +
            '  usr.passw = :pass ' +
            '  and usr.disabled = 0  ' +
            '  and usr.usr$mn_isfrontuser = 1 ';
          FReadSQL.Params[0].AsString := FForm.InputString;
          FReadSQL.ExecQuery;
          if not FReadSQL.Eof then
          begin
            Result.CheckedUserPassword := True;
            Result.UserName := FReadSQL.FieldByName('Name').AsString;
            Result.UserKey := FReadSQL.FieldByName('ID').AsInteger;
            Result.UserInGroup := FReadSQL.FieldByName('InGroup').AsInteger;
          end else
            Touch_MessageBox('��������', '����� �������� ������!', MB_OK, mtWarning);
        finally
          FReadSQL.Close;
        end;
      end;
    finally
      FForm.Free;
    end;
  end;
end;

procedure TFrontBase.ClearCache;
begin
//  FGoodHashList.Iterate(nil, Iterate_FreeObjects);
//  FGoodHashList.Clear;
end;

function TFrontBase.CloseModifyTable(const ModifyTable: TkbmMemTable): Boolean;
var
  FSQL: TIBSQL;

const
  UpdateModify = ' UPDATE USR$CROSS509_157767346 C ' +
    ' SET C.USR$CLOSETIME = current_time       ' +
    ' WHERE C.usr$mn_orderlinekey = :linekey ';

begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text := UpdateModify;
  try
    try
      if not FCheckTransaction.InTransaction then
        FCheckTransaction.StartTransaction;

      ModifyTable.First;
      while not ModifyTable.Eof do
      begin
        if ModifyTable.FieldByName('CLOSETIME').AsString = '' then
        begin
          FSQL.ParamByName('linekey').AsInteger := ModifyTable.FieldByName('MASTERKEY').AsInteger;
          FSQL.ExecQuery;
          FSQL.Close;
        end;
        ModifyTable.Next;
      end;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ������ ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;

    FSQL.Free;
  end;
end;

function TFrontBase.SaveAndReloadOrder(const HeaderTable, LineTable,
  ModifyTable: TkbmMemTable; OrderKey: Integer): Boolean;
begin
  try
    CreateNewOrder(HeaderTable, LineTable, ModifyTable, OrderKey);
    LockUserOrder(OrderKey);
    Result := GetOrder(HeaderTable, LineTable, ModifyTable, OrderKey);
  except
    raise;
  end;
end;

function TFrontBase.SaveContact(const MemTable: TkbmMemTable; var ContactID: Integer): Boolean;
var
  FSQL: TIBSQL;
  Tr: TIBTransaction;
//  ContactID: Integer;
begin
// 1. ��������� ������ � GD_CONTACT
// 2. ��������� ������ � GD_PEOPLE
// 3. ������� IB ������
// 4. ��������� ������ � GD_USER
// 5. ��������� ������ � GD_USERCOMPANY
  FSQL := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    try
      Tr.DefaultDatabase := FDataBase;
      Tr.StartTransaction;
      FSQL.Transaction := Tr;

      ContactID := GetNextID;
      //1.
      FSQL.SQL.Text := ' INSERT INTO GD_CONTACT (ID, PARENT, CONTACTTYPE, NAME, AFULL, ACHAG, AVIEW, ' +
        ' ADDRESS, PHONE) ' +
        ' VALUES (:ID, :DEP, 2, :NAME, -1, -1, -1, :ADDRESS, :PHONE) ';
      FSQL.ParamByName('ID').AsInteger := ContactID;
      FSQL.ParamByName('DEP').AsInteger := cn_ContactFolderID;
      FSQL.ParamByName('NAME').AsString := MemTable.FieldByName('SURNAME').AsString + ' ' +
        MemTable.FieldByName('FIRSTNAME').AsString + ' ' + MemTable.FieldByName('MIDDLENAME').AsString;
      FSQL.ParamByName('ADDRESS').Value := MemTable.FieldByName('ADDRESS').Value;
      FSQL.ParamByName('PHONE').Value := MemTable.FieldByName('PHONE').Value;
      FSQL.ExecQuery;
      FSQL.Close;

      //2.
      FSQL.SQL.Text :=
        ' INSERT INTO GD_PEOPLE (CONTACTKEY, FIRSTNAME, SURNAME, MIDDLENAME, ' +
        '   HPHONE, PASSPORTNUMBER, PASSPORTISSDATE, PASSPORTEXPDATE, ' +
        '   PASSPORTISSCITY, PASSPORTISSUER) ' +
        ' VALUES (:ID, :FNAME, :SNAME, :MNAME, ' +
        '   :HPHONE, :PASSPORTNUMBER, :PASSPORTISSDATE, :PASSPORTEXPDATE, ' +
        '   :PASSPORTISSCITY, :PASSPORTISSUER) ';
      FSQL.ParamByName('ID').AsInteger := ContactID;
      FSQL.ParamByName('FNAME').AsString := MemTable.FieldByName('FIRSTNAME').AsString;
      FSQL.ParamByName('SNAME').AsString := MemTable.FieldByName('SURNAME').AsString;
      FSQL.ParamByName('MNAME').AsString := MemTable.FieldByName('MIDDLENAME').AsString;
      FSQL.ParamByName('HPHONE').Value := MemTable.FieldByName('HPHONE').Value;
      FSQL.ParamByName('PASSPORTNUMBER').Value := MemTable.FieldByName('PASSPORTNUMBER').Value;
      FSQL.ParamByName('PASSPORTISSDATE').Value := MemTable.FieldByName('PASSPORTISSDATE').Value;
      FSQL.ParamByName('PASSPORTEXPDATE').Value := MemTable.FieldByName('PASSPORTEXPDATE').Value;
      FSQL.ParamByName('PASSPORTISSCITY').Value := MemTable.FieldByName('PASSPORTISSCITY').Value;
      FSQL.ParamByName('PASSPORTISSUER').Value := MemTable.FieldByName('PASSPORTISSUER').Value;
      FSQL.ExecQuery;
      FSQL.Close;

      Tr.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� �������� ������������ ' + E.Message, MB_OK, mtError);
        Result := False;
        Tr.Rollback;
      end;
    end;
  finally
    FSQL.Free;
    Tr.Free;
  end;
end;

function TFrontBase.LockUserOrder(const OrderKey :Integer): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    ' UPDATE USR$MN_ORDER ' +
    ' SET USR$ISLOCKED = 1 ' +
    ' WHERE DOCUMENTKEY = :orderkey ';
  try
    try
      if not FCheckTransaction.InTransaction then
        FCheckTransaction.StartTransaction;

      FSQL.Params[0].AsInteger := OrderKey;
      FSQL.ExecQuery;
      FSQL.Close;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ������ ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;

    FSQL.Free;
  end;
end;

function TFrontBase.UnLockUserOrder(const OrderKey: Integer): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    ' UPDATE USR$MN_ORDER ' +
    ' SET USR$ISLOCKED = 0 ' +
    ' WHERE DOCUMENTKEY = :orderkey ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;

    FSQL.Params[0].AsInteger := OrderKey;
    try
      FSQL.ExecQuery;
      FSQL.Close;
      Result := True;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ������ ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;

    FSQL.Free;
  end;
end;

procedure TFrontBase.UpdateGoodModifyGroup(const GoodKey,
  ModifyGroupKey: Integer);
var
  FSQL: TIBSQL;
  Tr: TIBTransaction;
begin
  FSQL := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ReadTransaction.DefaultDatabase;
    Tr.StartTransaction;

    FSQL.Transaction := Tr;
    FSQL.SQL.Text := ' UPDATE GD_GOOD G ' +
      ' SET G.USR$MODIFYGROUPKEY = :ID ' +
      ' WHERE G.ID = :GOODKEY ';
    FSQL.ParamByName('ID').AsInteger := ModifyGroupKey;
    FSQL.ParamByName('GOODKEY').AsInteger := GoodKey;
    FSQL.ExecQuery;
    FSQL.Close;

    Tr.Commit;
  finally
    FSQL.Free;
    Tr.Free;
  end;
end;

procedure TFrontBase.UpdateGoodPrnGroup(const GoodKey, PrnGroupKey: Integer);
var
  FSQL: TIBSQL;
  Tr: TIBTransaction;
begin
  FSQL := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    try
      Tr.DefaultDatabase := ReadTransaction.DefaultDatabase;
      Tr.StartTransaction;

      FSQL.Transaction := Tr;
      FSQL.SQL.Text := ' UPDATE GD_GOOD G ' +
        ' SET G.USR$PRNGROUPKEY = :ID ' +
        ' WHERE G.ID = :GOODKEY ';
      FSQL.ParamByName('ID').AsInteger := PrnGroupKey;
      FSQL.ParamByName('GOODKEY').AsInteger := GoodKey;
      FSQL.ExecQuery;
      FSQL.Close;

      Tr.Commit;
    except
      raise;
    end;
  finally
    FSQL.Free;
    Tr.Free;
  end;
end;

procedure TFrontBase.UpdateMenuStopList(const MemTable: TkbmMemTable;
  const FChangeList: TList<Integer>);
var
  FSQL: TIBSQL;
  Tr: TIBTransaction;
  I, ID: Integer;
begin
  if FChangeList.Count > 0 then
  begin
    FSQL := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := ReadTransaction.DefaultDatabase;
      Tr.StartTransaction;
      try
        FSQL.Transaction := Tr;
        FSQL.SQL.Text :=
          ' UPDATE GD_DOCUMENT ' +
          ' SET DISABLED = :disabled ' +
          ' WHERE ID = :id ';
        for I := 0 to FChangeList.Count - 1 do
        begin
          ID := FChangeList.Items[I];
          if MemTable.Locate('ID', ID, []) then
          begin
            FSQL.ParamByName('DISABLED').AsInteger := MemTable.FieldByName('DISABLED').AsInteger;
            FSQL.ParamByName('ID').AsInteger := ID;
            FSQL.ExecQuery;
            FSQL.Close;
          end;
        end;
        Tr.Commit;
      except
        raise;
      end;
    finally
      FSQL.Free;
      Tr.Free;
    end;
  end;
end;

function TFrontBase.UpdateUser(const EmplTable,
  GroupListTable: TkbmMemTable; UserKey: Integer; const FGroupList: TList<Integer>): Boolean;
var
  FSQL: TIBSQL;
  Tr: TIBTransaction;
  ContactID: Integer;
  I: Integer;
begin
// 1. ��������� ������ � GD_CONTACT
// 2. ��������� ������ � GD_PEOPLE
// 3. ������� IB ������
// 4. ��������� ������ � GD_USER
// 5. ��������� ������ � GD_USERCOMPANY
  FSQL := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    try
      GroupListTable.First;

      Tr.DefaultDatabase := FDataBase;
      Tr.StartTransaction;
      FSQL.Transaction := Tr;

      ContactID := EmplTable.FieldByName('ID').AsInteger;
      //1.
      FSQL.SQL.Text := ' UPDATE GD_CONTACT ' +
        ' SET NAME = :NAME ' +
        ' WHERE ID = :ID ';
      FSQL.ParamByName('ID').AsInteger := ContactID;
      FSQL.ParamByName('NAME').AsString := EmplTable.FieldByName('SURNAME').AsString + ' ' +
        EmplTable.FieldByName('FIRSTNAME').AsString + ' ' + EmplTable.FieldByName('MIDDLENAME').AsString;
      FSQL.ExecQuery;
      FSQL.Close;

      //2.
      FSQL.SQL.Text := ' UPDATE GD_PEOPLE ' +
        ' SET FIRSTNAME = :FNAME, ' +
        '     SURNAME = :SNAME, ' +
        '     MIDDLENAME = :MNAME ' +
        ' WHERE CONTACTKEY = :ID ';
      FSQL.ParamByName('ID').AsInteger := ContactID;
      FSQL.ParamByName('FNAME').AsString := EmplTable.FieldByName('FIRSTNAME').AsString;
      FSQL.ParamByName('SNAME').AsString := EmplTable.FieldByName('SURNAME').AsString;
      FSQL.ParamByName('MNAME').AsString := EmplTable.FieldByName('MIDDLENAME').AsString;
      FSQL.ExecQuery;
      FSQL.Close;

      FSQL.SQL.Text := ' UPDATE GD_USER ' +
        ' SET ' +
        '     PASSW = :PASS, ' +
        '     DISABLED = :DISABLED, ' +
        '     INGROUP = 1 ' +
        ' WHERE ID = :ID ';
//      FSQL.ParamByName('NAME').AsString := EmplTable.FieldByName('SURNAME').AsString;
      FSQL.ParamByName('PASS').AsString := EmplTable.FieldByName('PASSW').AsString;
      if EmplTable.FieldByName('DISABLED').AsBoolean then
        FSQL.ParamByName('DISABLED').AsInteger := 1
      else
        FSQL.ParamByName('DISABLED').AsInteger := 0;
      FSQL.ParamByName('ID').AsInteger := UserKey;
      FSQL.ExecQuery;
      FSQL.Close;

      GroupListTable.First;
      while not GroupListTable.Eof do
      begin
        if GroupListTable.FieldByName('CHECKED').AsInteger = 1 then
        begin
          FSQL.SQL.Text := Format('UPDATE GD_USER SET INGROUP = G_B_OR(ingroup, %d) WHERE id=%d',
            [GetGroupMask(GroupListTable.FieldByName('ID').AsInteger), UserKey]);
          FSQL.ExecQuery;
          FSQL.Close;
        end;
        GroupListTable.Next;
      end;

      for I := 0 to FGroupList.Count - 1 do
      begin
        FSQL.SQL.Text := Format('UPDATE GD_USER SET INGROUP = G_B_OR(ingroup, %d) WHERE id=%d',
          [GetGroupMask(FGroupList.Items[I]), UserKey]);
        FSQL.ExecQuery;
        FSQL.Close;
      end;

      //�������� �� ������ ���������������
      FSQL.SQL.Text := Format('UPDATE GD_USER SET INGROUP = G_B_AND(ingroup, %d) WHERE id=%d',
        [not GetGroupMask(1), UserKey]);
      FSQL.ExecQuery;
      FSQL.Close;

      Tr.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        if (E is EIBError) and (EIBError(E).IBErrorCode = isc_no_dup) then
          Touch_MessageBox('��������', '������������ ��� ����������', MB_OK, mtError)
        else
          Touch_MessageBox('��������', '������ ��� �������� ������������ ' + E.Message, MB_OK, mtError);
        Result := False;
        Tr.Rollback;
      end;
    end;
  finally
    FSQL.Free;
    Tr.Free;
  end;
end;

function TFrontBase.GetPrinterInfo: TPrinterInfo;
begin
  Result.PrinterName := '';
  Result.PrinterID := -1;

  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'select first(1) prnset.id as prnid, ' +
        '  prnset.usr$printername, prnset.USR$ENCLOSE, prnset.usr$printerid ' +
        'from ' +
        '  usr$mn_prngroupset prnset ' +
        'where ' +
        '  prnset.usr$kassa = 1 ' +
        '  and prnset.usr$computername = :comp ';
      FReadSQL.ParamByName('comp').AsString := ComputerName;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        Result.PrinterName := FReadSQL.FieldByName('usr$printername').AsString;
        Result.PrinterID := FReadSQL.FieldByName('prnid').AsInteger;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetPrinterName: String;
begin
  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'select first(1) ' +
        '  prnset.usr$printername, prnset.USR$ENCLOSE, prnset.usr$printerid ' +
        'from ' +
        '  usr$mn_prngroupset prnset ' +
        'where ' +
        '  prnset.usr$kassa = 1 ' +
        '  and prnset.usr$computername = :comp ';
      FReadSQL.ParamByName('comp').AsString := ComputerName;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
        Result := FReadSQL.FieldByName('usr$printername').AsString
      else
        Result := '';
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetReportTemplate(const Stream: TStream; const ID: Integer): Boolean;
begin
  Result := False;

  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;
      FReadSQL.SQL.Text :=
        'SELECT USR$TEMPLATEDATA AS TEMPLATEDATA '  +
        'FROM USR$MN_REPORT  ' +
        'WHERE ID = :ID ';
      FReadSQL.Params[0].AsInteger := ID;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        Result := True;
        FReadSQL.FieldByName('templatedata').SaveToStream(Stream);
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetReportTemplateByPrnIDAndType(const ReportType,
  PrinterID: Integer; const Stream: TStream);
begin
  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;
      FReadSQL.SQL.Text :=
        ' SELECT R.USR$TEMPLATEDATA AS TEMPLATEDATA ' +
        ' FROM USR$MN_REPORT R ' +
        ' JOIN USR$MN_PRNGROUPSET G ON G.USR$PRNTYPEKEY = R.USR$PRNTYPEKEY ' +
        ' WHERE R.USR$TYPE = :RTYPE ' +
        '   AND G.ID = :ID ';
      FReadSQL.ParamByName('ID').AsInteger := PrinterID;
      FReadSQL.ParamByName('RTYPE').AsInteger := ReportType;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
      begin
        FReadSQL.FieldByName('templatedata').SaveToStream(Stream);
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetReservListByTable(const TableKey: Integer;
  const MemTable: TkbmMemTable);
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT ' +
        '   R.ID, ' +
        '   R.USR$RESERVDATE, ' +
        '   R.USR$RESERVTIME, ' +
        '   R.USR$DOCUMENTNUMBER, ' +
        '   R.USR$DOCUMENTDATE, ' +
        '   R.USR$AVANSSUM, ' +
        '   R.USR$ORDERKEY ' +
        ' FROM USR$MN_RESERVATION R ' +
        ' LEFT JOIN USR$MN_ORDER O ON O.USR$RESERVKEY = R.ID ' +
        ' WHERE R.USR$TABLEKEY = :ID ' +
        '   AND O.USR$RESERVKEY IS NULL ';
      FReadSQL.Params[0].AsInteger := TableKey;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('USR$DOCUMENTNUMBER').AsString +
          ' �� ' + FReadSQL.FieldByName('USR$DOCUMENTDATE').AsString;
        MemTable.FieldByName('USR$AVANSSUM').AsCurrency := FReadSQL.FieldByName('USR$AVANSSUM').AsCurrency;
        MemTable.FieldByName('USR$ORDERKEY').AsInteger := FReadSQL.FieldByName('USR$ORDERKEY').AsInteger;
        MemTable.FieldByName('USR$RESPKEY').AsInteger := FContactKey;
        MemTable.FieldByName('NUMBER').AsString := FReadSQL.FieldByName('USR$DOCUMENTNUMBER').AsString;
        MemTable.Post;

        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.OrderIsLocked(const ID: Integer): Boolean;
begin
  Result := False;

  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'SELECT USR$ISLOCKED FROM USR$MN_ORDER ' +
        'where documentkey = :id ';
      FReadSQL.Params[0].AsInteger := ID;
      FReadSQL.ExecQuery;
      if FReadSQL.FieldByName('USR$ISLOCKED').AsInteger = 1 then
        Result := True;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.OrderIsPayed(const ID: Integer): Boolean;
begin
  Result := False;

  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'SELECT usr$pay FROM USR$MN_ORDER ' +
        'where documentkey = :id ';
      FReadSQL.Params[0].AsInteger := ID;
      FReadSQL.ExecQuery;
      Result := (FReadSQL.FieldByName('usr$pay').AsInteger = 1);
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

class function TFrontBase.RoundCost(const Cost: Currency): Currency;
begin
  Result := Round(Cost / 10.0000 + 0.0000000001) * 10;
end;

function TFrontBase.GetDiscount(const DiscKey, GoodKey: Integer;
  DocDate: TDateTime; PersDiscount: Currency; LineTime: TTime): Currency;
begin
  Result := 0;

  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'SELECT G.DISCOUNT ' +
        'FROM USR$MN_P_GETDISCOUNT(:disckey, :goodkey, :docdate, :persdiscount, :linetime) G ';
      FReadSQL.ParamByName('disckey').AsInteger := DiscKey;
      FReadSQL.ParamByName('goodkey').AsInteger := GoodKey;
      FReadSQL.ParamByName('docdate').AsDateTime := DocDate;
      FReadSQL.ParamByName('persdiscount').AsCurrency := PersDiscount;
      FReadSQL.ParamByName('LineTime').AsTime := LineTime;
      FReadSQL.ExecQuery;
      if not FReadSQL.Eof then
        Result := FReadSQL.FieldByName('DISCOUNT').AsCurrency;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetDiscountList(const MemTable: TkbmMemTable): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := 'SELECT ID, USR$NAME FROM USR$MN_DISCOUNTNAME ORDER BY usr$NAME ';
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('USR$NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetDiscountCardInfo(const MemTable: TkbmMemTable; const CardID: Integer;
  const LDate: TDateTime; const Pass: String): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      if Pass = '' then
        FReadSQL.SQL.Text :=
          '  select first(1) ' +
          '    c.id, name.usr$name as discountname,  ' +
          '    dt.usr$percent as discpers, ' +
          '    coalesce(c.usr$surname, '''') || '' '' || coalesce(c.usr$firstname, '''') || '' '' || coalesce(c.usr$middlename, '''') as contactname, ' +
          '    dt.usr$fromdate, ' +
          '    name.id DiscKey, name.usr$bonus, c.USR$BALANCE  ' +
          '  from                                              ' +
          '    usr$mn_discountcard c                           ' +
          '    left join usr$mn_discountname name on name.id = c.usr$discountnamekey ' +
          '    left join usr$mn_discounttype dt on dt.usr$discountnamekey = name.id and dt.usr$fromdate <= :adate  ' +
          '  where c.id = :id  ' +
          '    and c.usr$datebegin <= :adate  ' +
          '    and (c.usr$dateend >= :adate or c.usr$dateend is null) ' +
          '  order by dt.usr$fromdate desc '
      else
        FReadSQL.SQL.Text :=
          '  select first(1) ' +
          '    c.id, name.usr$name as discountname,  ' +
          '    dt.usr$percent as discpers, ' +
          '    coalesce(c.usr$surname, '''') || '' '' || coalesce(c.usr$firstname, '''') || '' '' || coalesce(c.usr$middlename, '''') as contactname, ' +
          '    dt.usr$fromdate, ' +
          '    name.id DiscKey, name.usr$bonus, c.USR$BALANCE  ' +
          '  from                                              ' +
          '    usr$mn_discountcard c                           ' +
          '    left join usr$mn_discountname name on name.id = c.usr$discountnamekey ' +
          '    left join usr$mn_discounttype dt on dt.usr$discountnamekey = name.id and dt.usr$fromdate <= :adate  ' +
          '  where c.usr$code = :pass  ' +
          '    and c.usr$datebegin <= :adate  ' +
          '    and (c.usr$dateend >= :adate or c.usr$dateend is null) ' +
          '  order by dt.usr$fromdate desc ';

      FReadSQL.ParamByName('adate').AsDateTime := LDate;
      if Pass = '' then
        FReadSQL.ParamByName('id').AsInteger := CardID
      else
        FReadSQL.ParamByName('pass').AsString := Pass;
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('contactname').AsString := FReadSQL.FieldByName('contactname').AsString;
        MemTable.FieldByName('Discountname').AsString := FReadSQL.FieldByName('Discountname').AsString;
        MemTable.FieldByName('DiscPers').AsCurrency := FReadSQL.FieldByName('DiscPers').AsCurrency;
        MemTable.FieldByName('usr$bonus').AsCurrency := FReadSQL.FieldByName('usr$bonus').AsCurrency;
        MemTable.FieldByName('USR$BALANCE').AsCurrency := FReadSQL.FieldByName('USR$BALANCE').AsCurrency;
        MemTable.FieldByName('DiscKey').AsInteger := FReadSQL.FieldByName('DiscKey').AsInteger;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetDiscountCardList(const MemTable: TkbmMemTable);
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT ' +
        '   C.USR$CODE, dt.usr$percent, ' +
        '   coalesce(c.usr$surname, '''') || '' '' || coalesce(c.usr$firstname, '''') || '' '' || coalesce(c.usr$middlename, '''') as contactname ' +
        ' FROM ' +
        '   USR$MN_DISCOUNTCARD C ' +
        '   LEFT JOIN usr$mn_discounttype dt ON c.usr$discountnamekey = dt.USR$DISCOUNTNAMEKEY ' +
        ' WHERE C.USR$CODE IS NOT NULL ' +
        ' ORDER BY 3 ';
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('USR$CODE').AsString := FReadSQL.FieldByName('USR$CODE').AsString;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('contactname').AsString;
        MemTable.FieldByName('USR$PERCENT').AsString := FReadSQL.FieldByName('USR$PERCENT').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.AddUser(const EmplTable,
  GroupListTable: TkbmMemTable): Boolean;
var
  FSQL: TIBSQL;
  Tr: TIBTransaction;
  DepID, ContactID, UserID: Integer;
  IBPass, IBName: String;
begin
// 1. ��������� ������ � GD_CONTACT
// 2. ��������� ������ � GD_PEOPLE
// 3. ������� IB ������
// 4. ��������� ������ � GD_USER
// 5. ��������� ������ � GD_USERCOMPANY
  FSQL := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    try
      GroupListTable.First;

      Tr.DefaultDatabase := FDataBase;
      Tr.StartTransaction;
      FSQL.Transaction := Tr;

      FSQL.SQL.Text := ' SELECT FIRST(1) C.ID FROM GD_CONTACT C ' +
        ' WHERE C.CONTACTTYPE = 4 ' +
        '   AND C.PARENT = ' + IntToStr(FCompanyKey);
      FSQL.ExecQuery;
      DepID := FSQL.Fields[0].AsInteger;
      FSQL.Close;

      ContactID := GetNextID;
      //1.
      FSQL.SQL.Text := ' INSERT INTO GD_CONTACT (ID, PARENT, CONTACTTYPE, NAME, AFULL, ACHAG, AVIEW) ' +
        ' VALUES (:ID, :DEP, 2, :NAME, -1, -1, -1) ';
      FSQL.ParamByName('ID').AsInteger := ContactID;
      FSQL.ParamByName('DEP').AsInteger := DepID;
      FSQL.ParamByName('NAME').AsString := EmplTable.FieldByName('SURNAME').AsString + ' ' +
        EmplTable.FieldByName('FIRSTNAME').AsString + ' ' + EmplTable.FieldByName('MIDDLENAME').AsString;
      FSQL.ExecQuery;
      FSQL.Close;

      //2.
      FSQL.SQL.Text := ' INSERT INTO GD_PEOPLE (CONTACTKEY, FIRSTNAME, SURNAME, MIDDLENAME, WCOMPANYKEY) ' +
        ' VALUES (:ID, :FNAME, :SNAME, :MNAME, :COMPANYKEY) ';
      FSQL.ParamByName('ID').AsInteger := ContactID;
      FSQL.ParamByName('FNAME').AsString := EmplTable.FieldByName('FIRSTNAME').AsString;
      FSQL.ParamByName('SNAME').AsString := EmplTable.FieldByName('SURNAME').AsString;
      FSQL.ParamByName('MNAME').AsString := EmplTable.FieldByName('MIDDLENAME').AsString;
      FSQL.ParamByName('COMPANYKEY').AsInteger := FCompanyKey;
      FSQL.ExecQuery;
      FSQL.Close;

      Randomize;
      IBPass := GetIBRandomString;
      IBName := GetIBRandomString;
      //3.
      CreateIBUser(IBName, IBPass, ContactID);
      //4.
      UserID := GetNextID;
      FSQL.SQL.Text := ' INSERT INTO GD_USER (ID, NAME, PASSW, IBNAME, IBPASSWORD, CONTACTKEY, ' +
        '   CANTCHANGEPASSW, PASSWNEVEREXP, USR$MN_ISFRONTUSER, DISABLED) ' +
        ' VALUES (:ID, :NAME, :PASS, :IBPASS, :IBNAME, :CONTACTKEY, 1, 1, 1, :DISABLED) ';
      FSQL.ParamByName('ID').AsInteger := UserID;
      FSQL.ParamByName('NAME').AsString := EmplTable.FieldByName('SURNAME').AsString;
      FSQL.ParamByName('PASS').AsString := EmplTable.FieldByName('PASSW').AsString;
      if EmplTable.FieldByName('DISABLED').AsBoolean then
        FSQL.ParamByName('DISABLED').AsInteger := 1
      else
        FSQL.ParamByName('DISABLED').AsInteger := 0;
      FSQL.ParamByName('IBPASS').AsString := IBPass;
      FSQL.ParamByName('IBNAME').AsString := IBName;
      FSQL.ParamByName('CONTACTKEY').AsInteger := ContactID;
      FSQL.ExecQuery;
      FSQL.Close;

      GroupListTable.First;
      while not GroupListTable.Eof do
      begin
        if GroupListTable.FieldByName('CHECKED').AsInteger = 1 then
        begin
          FSQL.SQL.Text := Format('UPDATE GD_USER SET INGROUP = G_B_OR(ingroup, %d) WHERE id=%d',
            [GetGroupMask(GroupListTable.FieldByName('ID').AsInteger), UserID]);
          FSQL.ExecQuery;
          FSQL.Close;
        end;
        GroupListTable.Next;
      end;

       //�������� �� ������ ���������������
      FSQL.SQL.Text := Format('UPDATE GD_USER SET INGROUP = G_B_AND(ingroup, %d) WHERE id=%d',
        [not GetGroupMask(1), UserID]);
      FSQL.ExecQuery;
      FSQL.Close;

      //5.
      FSQL.SQL.Text := 'INSERT INTO gd_usercompany(userkey, companykey) VALUES (' +
        IntToStr(UserID) + ',' +
        IntToStr(FCompanyKey) + ') ';
      FSQL.ExecQuery;
      FSQL.Close;

      Tr.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        if (E is EIBError) and (EIBError(E).IBErrorCode = isc_no_dup) then
          Touch_MessageBox('��������', '������������ ��� ����������', MB_OK, mtError)
        else
          Touch_MessageBox('��������', '������ ��� �������� ������������ ' + E.Message, MB_OK, mtError);
        Result := False;
        Tr.Rollback;
      end;
    end;
  finally
    FSQL.Free;
    Tr.Free;
  end;
end;

function TFrontBase.CalcBonusSum(const DataSet: TDataSet;
  FLine: TkbmMemTable; var Bonus: Boolean;
  var PercDisc: Currency): Boolean;
var
  SumCheck: Currency;
begin
  FReadSQL.Close;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        'SELECT d.usr$bonus ' +
        'FROM usr$mn_discountname d ' +
        'where d.id = :id ';
      FReadSQL.Params[0].AsInteger := DataSet.FieldByname('USR$DISCOUNTKEY').AsInteger;
      FReadSQL.ExecQuery;

      Bonus := (FReadSQL.FieldByName('USR$BONUS').AsInteger = 1);
      if Bonus then
      begin
        SumCheck := 0;

        FLine.First;
        FReadSQL.Close;
        FReadSQL.SQL.Text :=
          'SELECT g.usr$nobonus ' +
          'FROM gd_good g ' +
          'where g.id = :id ';
        while not FLine.Eof do
        begin
          FReadSQL.Params[0].AsInteger := FLine.FieldByName('USR$GOODKEY').AsInteger;
          FReadSQL.ExecQuery;
          if FReadSQL.FieldByName('usr$nobonus').AsInteger <> 1 then
            SumCheck := SumCheck + FLine.FieldByName('usr$sumncu').AsCurrency;

          FReadSQL.Close;
          FLine.Next;
        end;

        if SumCheck <> 0 then
        begin
          PercDisc := DataSet.FieldByName('USR$BONUSSUM').AsCurrency / SumCheck * 100;
          if PercDisc > 70 then
            PercDisc := 70;
        end else
          PercDisc := 0;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.GetTables(const MemTable: TkbmMemTable;
  const HallKey: Integer);
begin
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;

  FReadSQL.Close;
  try
    FReadSQL.SQL.Text :=
      'SELECT T.*, tt.usr$width, tt.usr$length ' +
      'FROM USR$MN_TABLE T ' +
      ' LEFT JOIN usr$mn_tabletype tt ON tt.id = t.usr$type ' +
      'WHERE T.USR$HALLKEY = :ID ';
    FReadSQL.Params[0].AsInteger := HallKey;
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      MemTable.Append;
      MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
      MemTable.FieldByName('USR$NUMBER').AsString := FReadSQL.FieldByName('USR$NUMBER').AsString;
      MemTable.FieldByName('USR$POSY').AsFloat := FReadSQL.FieldByName('USR$POSY').AsFloat;
      MemTable.FieldByName('USR$POSX').AsFloat := FReadSQL.FieldByName('USR$POSX').AsFloat;
      MemTable.FieldByName('USR$WIDTH').AsFloat := FReadSQL.FieldByName('USR$WIDTH').AsFloat;
      MemTable.FieldByName('USR$LENGTH').AsFloat := FReadSQL.FieldByName('USR$LENGTH').AsFloat;
      MemTable.FieldByName('USR$TYPE').AsInteger := FReadSQL.FieldByName('USR$TYPE').AsInteger;
      MemTable.FieldByName('USR$MAINTABLEKEY').AsInteger := FReadSQL.FieldByName('USR$MAINTABLEKEY').AsInteger;
      MemTable.FieldByName('ORDERKEY').AsInteger := 0;
      MemTable.Post;

      FReadSQL.Next;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.GetTableTypeList: TList<TChooseTable>;
var
  TableType: TChooseTable;
begin
  Result := nil;

  if EnsureDBConnection then
  begin
    Result := TList<TChooseTable>.Create;

    FReadSQL.Close;
    try
      FReadSQL.SQL.Text :=
        ' SELECT id, usr$name AS name, usr$width AS width, usr$length AS height FROM usr$mn_tabletype ORDER BY usr$name ';
      FReadSQL.ExecQuery;
      while not FReadSQL.Eof do
      begin
        TableType := TChooseTable.Create(nil);
        TableType.TableTypeKey := FReadSQL.FieldByName('id').AsInteger;
        TableType.RelativeWidth := FReadSQL.FieldByName('width').AsFloat;
        TableType.RelativeHeight := FReadSQL.FieldByName('height').AsFloat;
        Result.Add(TableType);

        FReadSQL.Next;
      end;
    finally
      FReadSQL.Close;
    end;
  end;
end;

function TFrontBase.GetServerDateTime: TDateTime;
var
  IBSQL: TIBSQL;
begin
  IBSQL := TIBSQL.Create(nil);
  try
    IBSQL.Transaction := ReadTransaction;
    IBSQL.SQL.Text := ' SELECT CURRENT_TIMESTAMP AS DT FROM RDB$DATABASE ';
    IBSQL.ExecQuery;
    Result := IBSQL.FieldByName('DT').AsDateTime;
    IBSQL.Close;
  finally
    IBSQL.Free;
  end;
end;

function TFrontBase.GetServerName: String;
var
  A, B, I: Integer;
begin
  A := -1;
  for I := 1 to Length(FIBPath) do
    if FIBPath[I] = ':' then
    begin
      A := I;
      break;
    end;

  B := -1;
  for I := A + 1 to Length(FIBPath) do
    if FIBPath[I] = ':' then
    begin
      B := I;
      break;
    end;

  if A < 2 then
    Result := ''
  else begin
    Result := Copy(FIBPath, 1, A - 1);

    if B = -1 then
    begin
      if (A = 2) and (A < Length(FIBPath)) and (CharInSet(FIBPath[A + 1], ['\', '/'])) then
        Result := '';
    end;
  end;
end;

function TFrontBase.SaveRegisters(const Summ1, Summ2, Summ3, Summ4, SummReturn1,
  SummReturn2, SummReturn3, SummReturn4, PayInSumm,
  PayOutSumm: Currency; const RNM: String): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    ' INSERT INTO USR$MN_REGISTERINFO(USR$DATE, USR$SUMM1, USR$SUMM2, USR$SUMM3, USR$SUMM4, ' +
    '   USR$SUMMRETURN1, USR$SUMMRETURN2, USR$SUMMRETURN3, USR$SUMMRETURN4, ' +
    '   USR$PAYINSUMM, USR$PAYOUTSUMM, USR$CASHNUMBER, USR$COMPUTERNAME, USR$RNM) ' +
    ' VALUES (CURRENT_DATE, :SUMM1, :SUMM2, :SUMM3, :SUMM4, :SUMMRETURN1, :SUMMRETURN2, ' +
    '   :SUMMRETURN3, :SUMMRETURN4, :PAYINSUMM, :PAYOUTSUMM, :USR$CASHNUMBER, ' +
    '   :USR$COMPUTERNAME, :USR$RNM) ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;
    try
      FSQL.ParamByName('SUMM1').AsCurrency := Summ1;
      FSQL.ParamByName('SUMM2').AsCurrency := Summ2;
      FSQL.ParamByName('SUMM3').AsCurrency := Summ3;
      FSQL.ParamByName('SUMM4').AsCurrency := Summ4;
      FSQL.ParamByName('SUMMRETURN1').AsCurrency := SummReturn1;
      FSQL.ParamByName('SUMMRETURN2').AsCurrency := SummReturn2;
      FSQL.ParamByName('SUMMRETURN3').AsCurrency := SummReturn3;
      FSQL.ParamByName('SUMMRETURN4').AsCurrency := SummReturn4;
      FSQL.ParamByName('PAYINSUMM').AsCurrency := PayInSumm;
      FSQL.ParamByName('PAYOUTSUMM').AsCurrency := PayOutSumm;
      FSQL.ParamByName('USR$CASHNUMBER').AsInteger := CashNumber;
      FSQL.ParamByName('USR$COMPUTERNAME').AsString := ComputerName;
      FSQL.ParamByName('USR$RNM').AsString := RNM;
      FSQL.ExecQuery;
      Result := True;
    except
      FCheckTransaction.Rollback;
      raise;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;
    FSQL.Free;
  end;
end;

function TFrontBase.SaveReportTemplate(const Stream: TStream;
  const ID: Integer): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    'UPDATE USR$MN_REPORT ' +
    'SET USR$TEMPLATEDATA = :data ' +
    'WHERE ID = :ID ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;
    try
      FSQL.ParamByName('id').AsInteger := ID;
      FSQL.ParamByName('data').LoadFromStream(Stream);
      FSQL.ExecQuery;
      Result := True;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ������� ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;

  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;
    FSQL.Free;
  end;
end;

function TFrontBase.SaveReserv(const MemTable: TkbmMemTable): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    ' INSERT INTO USR$MN_RESERVATION(ID, USR$TABLEKEY, USR$RESERVTIME, ' +
    '   USR$RESERVDATE, USR$DOCUMENTDATE, USR$DOCUMENTNUMBER, USR$CONTACTKEY, ' +
    '   EDITORKEY, EDITIONDATE) ' +
    ' VALUES (:ID, :USR$TABLEKEY, :USR$RESERVTIME, ' +
    '   :USR$RESERVDATE, :USR$DOCUMENTDATE, :USR$DOCUMENTNUMBER, :USR$CONTACTKEY, ' +
    '   :EDITORKEY, CURRENT_TIMESTAMP) ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;

    try
      FSQL.ParamByName('ID').AsInteger := MemTable.FieldByName('ID').AsInteger;
      FSQL.ParamByName('USR$TABLEKEY').AsInteger := MemTable.FieldByName('USR$TABLEKEY').AsInteger;
      FSQL.ParamByName('USR$RESERVTIME').Value := MemTable.FieldByName('USR$RESERVTIME').Value;
      FSQL.ParamByName('USR$RESERVDATE').Value := MemTable.FieldByName('USR$RESERVDATE').Value;
      FSQL.ParamByName('USR$DOCUMENTDATE').Value := MemTable.FieldByName('USR$DOCUMENTDATE').Value;
      FSQL.ParamByName('USR$DOCUMENTNUMBER').AsString := MemTable.FieldByName('USR$DOCUMENTNUMBER').AsString;
      FSQL.ParamByName('USR$CONTACTKEY').Value := MemTable.FieldByName('USR$CONTACTKEY').Value;
      FSQL.ParamByName('EDITORKEY').AsInteger := FContactKey;
      FSQL.ExecQuery;

      Result := True;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ������������ ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;
    FSQL.Free;
  end;
end;

procedure TFrontBase.SaveReservAvansSum(const ID: Integer;
  const FSum: Currency);
var
  FSQL: TIBSQL;
begin
  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    ' UPDATE USR$MN_RESERVATION R ' +
    ' SET R.USR$AVANSSUM = :FSUM ' +
    ' WHERE R.ID = :ID ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;

    try
      FSQL.ParamByName('ID').AsInteger := ID;
      FSQL.ParamByName('FSUM').AsCurrency := FSUM;
      FSQL.ExecQuery;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ������������ ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;
    FSQL.Free;
  end;
end;

function TFrontBase.TryToConnect(const Count: Integer): Boolean;
var
  N: Integer;
begin
  Result := False;
  if Count <= 0 then
    exit;
  N := 0;

  while N <> Count - 1 do
  begin
    Sleep(1000);
    try
      FDataBase.Open;
      Result := True;
      break;
    except
      Result := False;
    end;
    Inc(N);
  end;
end;

function TFrontBase.SavePrintDate(const ID: Integer): Boolean;
var
  FSQL: TIBSQL;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := FCheckTransaction;
  FSQL.SQL.Text :=
    ' update gd_document doc ' +
    ' set doc.usr$mn_printdate = :pdate ' +
    ' where doc.parent = :docid ' +
    ' and doc.usr$mn_printdate is null ';
  try
    if not FCheckTransaction.InTransaction then
      FCheckTransaction.StartTransaction;
    try
      FSQL.ParamByName('docid').AsInteger := ID;
      FSQL.ParamByName('pdate').AsDateTime := Now;
      FSQL.ExecQuery;
    except
      on E: Exception do
      begin
        Touch_MessageBox('��������', '������ ��� ���������� ' + E.Message, MB_OK, mtError);
        FCheckTransaction.Rollback;
      end;
    end;
  finally
    if FCheckTransaction.InTransaction then
      FCheckTransaction.Commit;

    FSQL.Free;
  end;
end;

function TFrontBase.GetUserGroupList(const MemTable: TkbmMemTable): Boolean;
var
  ID: Integer;
begin
  Result := False;
  try
    FReadSQL.Close;
    MemTable.Close;
//    MemTable.CreateTable;
    MemTable.Open;
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;
    try
      FReadSQL.SQL.Text := 'SELECT G.ID, G.NAME FROM GD_USERGROUP G ' +
        ' WHERE G.DISABLED = 0 OR G.DISABLED IS NULL ORDER BY G.NAME ';
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        ID := FReadSQL.FieldByName('ID').AsInteger;
        if ((GetGroupMask(ID) and FOptions.ManagerGroupMask) <> 0) or
          ((GetGroupMask(ID) and FOptions.KassaGroupMask) <> 0) or
          ((GetGroupMask(ID) and FOptions.WaiterGroupMask) <> 0) then
        begin
          MemTable.Append;
          MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
          MemTable.FieldByName('USR$NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
          MemTable.FieldByName('CHECKED').AsInteger := 0;
          MemTable.Post;
        end;
        FReadSQL.Next;
      end;
      Result := True;
    finally
      FReadSQL.Close;
    end;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

function TFrontBase.GetDepartmentList(const MemTable: TkbmMemTable): Boolean;
begin
  Result := False;
  try
    FReadSQL.Close;
    MemTable.Close;
    MemTable.CreateTable;
    MemTable.Open;
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;
    try
      FReadSQL.SQL.Text := ' SELECT con.ID, con.NAME FROM GD_CONTACT con ' +
        ' where con.CONTACTTYPE = 4 ORDER BY con.NAME ';
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('USR$NAME').AsString := FReadSQL.FieldByName('NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    finally
      FReadSQL.Close;
    end;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

function TFrontBase.GetReadTransaction: TIBTransaction;
begin
  Result := FReadTransaction;
end;

function TFrontBase.GetReportList(var MemTable: TkbmMemTable): Boolean;
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text := 'SELECT ID, USR$NAME, USR$TYPE FROM USR$MN_REPORT ORDER BY USR$TYPE, USR$NAME ';
      FReadSQL.ExecQuery;
      while not FReadSQL.EOF do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('USR$TYPE').AsInteger := FReadSQL.FieldByName('USR$TYPE').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
        MemTable.Post;
        FReadSQL.Next;
      end;
      Result := True;
    except
      Result := False;
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.CanCloseDay;
var
  CanClose: Boolean;
  NewDate: TDateTime;
  FUserInfo: TUserInfo;
  FUpdateSQL: TIBSQL;
begin
  FReadSQL.Close;
  if not FReadSQL.Transaction.InTransaction then
    FReadSQL.Transaction.StartTransaction;
  try
    //���������, ���� �������� ������ �� ���������� ����
    FReadSQL.SQL.Text :=
      ' SELECT COUNT(*) ' +
      ' FROM USR$MN_ORDER R ' +
      ' WHERE R.USR$PAY <> 1 ' +
      '   AND R.USR$LOGICDATE = :LDATE ';
    FReadSQL.Params[0].AsDate := GetLogicDate;
    FReadSQL.ExecQuery;
    if FReadSQL.Fields[0].AsInteger > 0 then
    begin
      if Touch_MessageBox('��������', '���� ������������ ������. ����������?',
        MB_YESNO, mtWarning) = IDNO then
        exit;
    end;
    FReadSQL.Close;

    FReadSQL.SQL.Text :=
      'select max(op.usr$logicdate) as LDate ' +
      '  from usr$mn_options op ';
    FReadSQL.ExecQuery;
    if not FReadSQL.EOF then
    begin
      NewDate := FReadSQL.FieldByName('LDate').AsDateTime;
      FReadSQL.Close;
      FReadSQL.SQL.Text :=
        'select ' +
        'op.usr$off, op.usr$open ' +
        'from ' +
        'usr$mn_options op ' +
        'where ' +
        'op.usr$logicdate = :ldate ';
      FReadSQL.ParamByName('LDATE').AsDateTime := NewDate;
      FReadSQL.ExecQuery;
      if FReadSQL.FieldByName('usr$off').AsInteger = 1 then
      begin
        Touch_MessageBox('��������', '�������� ���� ' + DateToStr(NewDate) + ' ��� ������ ', MB_OK, mtWarning);
        exit;
      end;
      CanClose := True;
    end else
    begin
      CanClose := False;
      NewDate := Date;
      Touch_MessageBox('��������', '�������� ���� �� ������', MB_OK, mtWarning);
    end;

    if CanClose then
      if Touch_MessageBox('��������', '������ ������� ���� ' + DateToStr(NewDate) + '?',
        MB_YESNO, mtConfirmation) = IDYES  then
      begin
        FUserInfo := CheckUserPasswordWithForm;
        if FUserInfo.CheckedUserPassword then
        begin
          if (FUserInfo.UserInGroup and Options.KassaGroupMask) <> 0 then
          begin
            FUpdateSQL := TIBSQL.Create(nil);
            FUpdateSQL.Transaction := FCheckTransaction;
            FUpdateSQL.SQL.Text :=
              ' update usr$mn_options ' +
              ' set usr$off = 1, usr$offuser = :offuser, usr$offdatetime = :offdatetime ' +
              ' where usr$logicdate = :ldate ';
            try
              if not FCheckTransaction.InTransaction then
                FCheckTransaction.StartTransaction;

              FUpdateSQL.ParamByName('ldate').AsDateTime := NewDate;
              FUpdateSQL.ParamByName('offuser').AsInteger := FUserInfo.UserKey;
              FUpdateSQL.ParamByName('offdatetime').AsDateTime := Now;
              try
                FUpdateSQL.ExecQuery;
                FCheckTransaction.Commit;
              except
                on E: Exception do
                begin
                  Touch_MessageBox('��������', '������ ��� �������� ��� ' + E.Message, MB_OK, mtError);
                  FCheckTransaction.Rollback;
                end;
              end;
            finally
              if FCheckTransaction.InTransaction then
                FCheckTransaction.Commit;
              FUpdateSQL.Free;
            end;
          end else
            Touch_MessageBox('��������', '������ ������������ �� �������� ������� ��� �������� ���!', MB_OK, mtWarning);
        end else
          exit;
      end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.CanOpenDay;
var
  NewDate: TDateTime;
  FUserInfo: TUserInfo;
  FUpdateSQL: TIBSQL;
begin
  FReadSQL.Close;
  if not FReadSQL.Transaction.InTransaction then
    FReadSQL.Transaction.StartTransaction;
  try
    FReadSQL.SQL.Text :=
      'select max(op.usr$logicdate) as LDate ' +
      '  from usr$mn_options op ';
    FReadSQL.ExecQuery;
    if not FReadSQL.EOF then
    begin
      NewDate := FReadSQL.FieldByName('LDate').AsDateTime;
      FReadSQL.Close;
      FReadSQL.SQL.Text :=
        'select ' +
        'op.usr$off, op.usr$open ' +
        'from ' +
        'usr$mn_options op ' +
        'where ' +
        'op.usr$logicdate = :ldate ';
      FReadSQL.ParamByName('LDATE').AsDateTime := NewDate;
      FReadSQL.ExecQuery;
      if (FReadSQL.FieldByName('usr$off').AsInteger = 0) and (FReadSQL.FieldByName('usr$open').AsInteger = 1) then
      begin
        Touch_MessageBox('��������', '�������� ���� ' + DateToStr(NewDate) + ' �� ������!', MB_OK, mtWarning);
        exit;
      end;
      NewDate := NewDate + 1;
    end else
    begin
      NewDate := Date;
    end;

    if Touch_MessageBox('��������', '������ ������� ���� ' + DateToStr(NewDate) + '?',
      MB_YESNO, mtConfirmation) = IDYES then
    begin
      FUserInfo := CheckUserPasswordWithForm;
      if FUserInfo.CheckedUserPassword then
      begin
        if (FUserInfo.UserInGroup and Options.KassaGroupMask) <> 0 then
        begin
          FUpdateSQL := TIBSQL.Create(nil);
          FUpdateSQL.Transaction := FCheckTransaction;
          FUpdateSQL.SQL.Text :=
            ' INSERT INTO usr$mn_options(usr$logicdate, usr$open, usr$openuser, usr$opendatetime) ' +
            ' VALUES (:ldate, :open, :openuser, :opendate) ';
          try
            if not FCheckTransaction.InTransaction then
              FCheckTransaction.StartTransaction;

            FUpdateSQL.ParamByName('ldate').AsDateTime := NewDate;
            FUpdateSQL.ParamByName('open').AsInteger := 1;
            FUpdateSQL.ParamByName('openuser').AsInteger := FUserInfo.UserKey;
            FUpdateSQL.ParamByName('opendate').AsDateTime := Now;
            try
              FUpdateSQL.ExecQuery;
              FCheckTransaction.Commit;
            except
              on E: Exception do
              begin
                Touch_MessageBox('��������', '������ ��� �������� ��� ' + E.Message, MB_OK, mtError);
                FCheckTransaction.Rollback;
              end;
            end;
          finally
            if FCheckTransaction.InTransaction then
              FCheckTransaction.Commit;
            FUpdateSQL.Free;
          end;
        end else
          Touch_MessageBox('��������', '������ ������������ �� �������� ������� ��� �������� ���!', MB_OK, mtWarning);
      end else
        exit;
    end;
  finally
    FReadSQL.Close;
  end;
end;

procedure TFrontBase.InitStorage;
var
  FName: String;
begin
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    with FOptions do
    begin
      LastPrintOrder := -1;
    // ����� ����
      DoLog := True;
      LinesLimit := 0;
      LogToFile := True;

      BasePath := '';
      PrintLog := False;
      PLSingleFile := False;
      PLFileFolder := '';
      PrintFiscalChek := False;
      OrderCurrentLDate := False;
      MainCompanyID := -1;
      CheckLine1 := '****************';
      CheckLine2 := '��������';
      CheckLine3 := '��������';
      CheckLine4 := '****************';
      CheckLine5 := '             ';
      CheckLine6 := '�����';
      CheckLine7 := '���';
      CheckLine8 := '��������� � 12.00 �� 24.00';
      SyncTime := False;
      TimeComp := '';
      ExtCalcCardID := 0;
      ExtDepotKeys := '0';
      PrintCopyCheck := False;
      NoPassword := False;

      UseCurrentDate := False;
      DiscountType := 0;
      SaveAllOrder := False;
      BackType := 0;

      MaxOpenedOrders := 100;
      MaxGuestCount := 10;
      MinGuestCount := 1;

      UseHalls := False;
      NoPrintEmptyCheck := True;
      NeedModGroup := False;
      NeedPrnGroup := False;

      SparkCash := 8;
      SparkNoCash := 7;
      SparkCredit := 1;
    end;

    FReadSQL.Close;
    FReadSQL.SQL.Text :=
      'SELECT ' +
      '  Z.NAME, ' +
      '  Z.DATA_TYPE, ' +
      '  Z.STR_DATA, ' +
      '  Z.INT_DATA, ' +
      '  Z.DATETIME_DATA, ' +
      '  Z.CURR_DATA, ' +
      '  Z.BLOB_DATA ' +
      'FROM ' +
      '  GD_STORAGE_DATA Z ' +
      'WHERE  ' +
      '  Z.PARENT IN (SELECT S.ID from GD_STORAGE_DATA S ' +
      '    WHERE S.NAME = :name) AND  ' +
      '  Z.DATA_TYPE IN ( ''S'', ''I'', ''C'', ''D'', ''L'', ''B'' ) ';
    FReadSQL.Params[0].AsString := 'Restaurant';
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      // ���� ������� ����� ������� IF, ����� ��������
      FName := AnsiUpperCase(FReadSQL.FieldByName('NAME').AsString);
      if FName = 'OPENTIME' then
      begin
        FOptions.OpenTime := FReadSQL.FieldByName('DATETIME_DATA').AsDateTime;
      end else
      if FName = 'CLOSETIME' then
      begin
        FOptions.CloseTime := FReadSQL.FieldByName('DATETIME_DATA').AsDateTime;
      end else
      if FName = 'BASEPATH' then
      begin
        FOptions.BasePath := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'PRINTLOG' then
      begin
        FOptions.PrintLog := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'PLSINGLEFILE' then
      begin
        FOptions.PLSingleFile := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'PLFILEFOLDER' then
      begin
        FOptions.PLFileFolder := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'PRINTFISCALCHEK' then
      begin
        FOptions.PrintFiscalChek := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'ORDERCURRENTLDATE' then
      begin
        FOptions.OrderCurrentLDate := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'MAINCOMPANYID' then
      begin
        FOptions.MainCompanyID := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'CHECKLINE1' then
      begin
        FOptions.CheckLine1 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'CHECKLINE2' then
      begin
        FOptions.CheckLine2 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'CHECKLINE3' then
      begin
        FOptions.CheckLine3 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'CHECKLINE4' then
      begin
        FOptions.CheckLine4 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'CHECKLINE5' then
      begin
        FOptions.CheckLine5 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'CHECKLINE6' then
      begin
        FOptions.CheckLine6 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'CHECKLINE7' then
      begin
        FOptions.CheckLine7 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'CHECKLINE8' then
      begin
        FOptions.CheckLine8 := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'SYNCTIME' then
      begin
        FOptions.SyncTime := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'TIMECOMP' then
      begin
        FOptions.TimeComp := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'EXTCALCCARDID' then
      begin
        FOptions.ExtCalcCardID := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'EXTDEPOTKEYS' then
      begin
        FOptions.ExtDepotKeys := FReadSQL.FieldByName('STR_DATA').AsString;
      end else
      if FName = 'NOPASSWORD' then
      begin
        FOptions.NoPassword := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'USECURRENTDATE' then
      begin
        FOptions.UseCurrentDate := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'DISCOUNTTYPE' then
      begin
        FOptions.DiscountType := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'SAVEALLORDER' then
      begin
        FOptions.SaveAllOrder := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'BACKTYPE' then
      begin
        FOptions.BackType := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'PRINTCOPYCHECK' then
      begin
        FOptions.PrintCopyCheck := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'USEHALLS' then
      begin
        FOptions.UseHalls := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'NOPRINTEMPTYCHECK' then
      begin
        FOptions.NoPrintEmptyCheck := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'NEEDMODGROUP' then
      begin
        FOptions.NeedModGroup := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end else
      if FName = 'NEEDPRNGROUP' then
      begin
        FOptions.NeedPrnGroup := (FReadSQL.FieldByName('INT_DATA').AsInteger = 1);
      end;

      FReadSQL.Next;
    end;

    FReadSQL.Close;
    FReadSQL.Params[0].AsString := 'Max';    
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      FName := AnsiUpperCase(FReadSQL.FieldByName('NAME').AsString);
      if FName = 'MAXOPENEDORDERS' then
      begin
        FOptions.MaxOpenedOrders := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'MAXGUESTCOUNT' then
      begin
        FOptions.MaxGuestCount := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'MINGUESTCOUNT' then
      begin
        FOptions.MinGuestCount := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end;

      FReadSQL.Next;
    end;

    FReadSQL.Close;
    FReadSQL.Params[0].AsString := 'Groups';
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      FName := AnsiUpperCase(FReadSQL.FieldByName('NAME').AsString);
      if FName = 'WAITER' then
      begin
        FOptions.WaiterGroupMask := GetGroupMask(FReadSQL.FieldByName('INT_DATA').AsInteger);
      end else
      if FName = 'MANAGER' then
      begin
        FOptions.ManagerGroupMask := GetGroupMask(FReadSQL.FieldByName('INT_DATA').AsInteger);
      end else
      if FName = 'KASSA' then
      begin
        FOptions.KassaGroupMask := GetGroupMask(FReadSQL.FieldByName('INT_DATA').AsInteger);
      end;

      FReadSQL.Next;
    end;

    FReadSQL.Close;
    FReadSQL.Params[0].AsString := 'SPARK';
    FReadSQL.ExecQuery;
    while not FReadSQL.Eof do
    begin
      FName := AnsiUpperCase(FReadSQL.FieldByName('NAME').AsString);
      if FName = 'SPARKNOCASH' then
      begin
        FOptions.SparkNoCash := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'SPARKCASH' then
      begin
        FOptions.SparkCash := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end else
      if FName = 'SPARKCREDIT' then
      begin
        FOptions.SparkCredit := FReadSQL.FieldByName('INT_DATA').AsInteger;
      end;

      FReadSQL.Next;
    end;

  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ��� �������� �������� ' + E.Message, MB_OK, mtError);
  end;
end;

function TFrontBase.IsComputerDBConnected(const ComputerName: String): Boolean;
var
  Tr: TIBTransaction;
  FSQL: TIBSQL;
  FCN: AnsiString;
begin
  Result := False;

  FSQL := TIBSQL.Create(nil);
  Tr := TIBTransaction.Create(nil);
  try
    Tr.DefaultDatabase := ReadTransaction.DefaultDatabase;
    Tr.Params.Add('read_committed');
    Tr.Params.Add('read');
    Tr.Params.Add('rec_version');
    Tr.Params.Add('nowait');
    Tr.StartTransaction;

    FSQL.Transaction := Tr;
    FSQL.SQL.Text := ' SELECT A.MON$REMOTE_ADDRESS FROM MON$ATTACHMENTS A ';
    FSQL.ExecQuery;
    while not FSQL.Eof do
    begin
      FCN := IPAddrToName(AnsiString(FSQL.Fields[0].AsString));
      if (FCN = '') and (FSQL.Fields[0].AsString <> '') then
        FCN := AnsiString(FSQL.Fields[0].AsString);

      if AnsiString(ComputerName) = FCN then
      begin
        Result := True;
        Break;
      end;
      FSQL.Next;
    end;
    FSQL.Close;
  finally
    FSQL.Free;
    Tr.Free;
  end;
end;

function TFrontBase.GetNextOrderNum: Integer;
begin
  GetNextOrderNum := -1;
  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    FReadSQL.Close;
    FReadSQL.SQL.Text := 'SELECT gen_id(USR$MN_CHECKNUMBER, 1) id FROM rdb$database ';
    FReadSQL.ExecQuery;

    Result := FReadSQL.FieldByName('ID').AsInteger;

    FReadSQL.Close;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

procedure TFrontBase.GetNoCashGroupList(const MemTable: TkbmMemTable);
begin
  FReadSQL.Close;
  MemTable.Close;
  MemTable.CreateTable;
  MemTable.Open;
  try
    try
      if not FReadSQL.Transaction.InTransaction then
        FReadSQL.Transaction.StartTransaction;

      FReadSQL.SQL.Text :=
        ' SELECT DISTINCT P.ID, P.USR$NAME ' +
        ' FROM USR$MN_KINDTYPE K' +
        ' LEFT JOIN USR$MN_PAYMENTRULES R ON R.USR$PAYTYPEKEY = K.USR$PAYTYPEKEY ' +
        ' LEFT JOIN USR$INV_PAYTYPE P ON K.USR$PAYTYPEKEY = P.ID ' +
        ' WHERE K.USR$PAYTYPEKEY <> :PCID ' +
        '   AND K.USR$PAYTYPEKEY <> :CASHID ' +
        '   AND K.USR$PAYTYPEKEY <> :CARDID ' +
        '   AND (R.USR$PAYTYPEKEY IS NULL OR (BIN_AND(g_b_shl(1, R.USR$GROUPKEY - 1), :UserGroup) <> 0)) ' +
        ' ORDER BY 2 ';
      FReadSQL.ParamByName('UserGroup').AsInteger := FUserGroup;
      FReadSQL.ParamByName('PCID').AsInteger := FrontConst.PayType_PersonalCard;
      FReadSQL.ParamByName('CARDID').AsInteger := FrontConst.PayType_Card;
      FReadSQL.ParamByName('CASHID').AsInteger := FrontConst.PayType_Cash;
      FReadSQL.ExecQuery;
      while not FReadSQL.Eof do
      begin
        MemTable.Append;
        MemTable.FieldByName('ID').AsInteger := FReadSQL.FieldByName('ID').AsInteger;
        MemTable.FieldByName('NAME').AsString := FReadSQL.FieldByName('USR$NAME').AsString;
        MemTable.Post;

        FReadSQL.Next;
      end;
    except
      raise;
    end;
  finally
    FReadSQL.Close;
  end;
end;

function TFrontBase.CheckCountOrderByResp(const RespID: Integer): Boolean;
var
  LDate: TDateTime;
begin
  Result := True;

  try
    if not FReadSQL.Transaction.InTransaction then
      FReadSQL.Transaction.StartTransaction;

    LDate := GetLogicDate;

    FReadSQL.Close;
    FReadSQL.SQL.Text :=
      ' SELECT COUNT(*) AS countOrder ' +
      ' FROM usr$mn_order o  ' +
      ' WHERE o.usr$logicdate = :logicdate ' +
      '   AND o.usr$respkey = :respkey ' +
      '   AND o.USR$TIMECLOSEORDER IS NULL ';
    FReadSQL.ParamByName('logicdate').AsDateTime := LDate;
    FReadSQL.ParamByName('respkey').AsInteger := RespID;
    FReadSQL.ExecQuery;

    Result := (FReadSQL.FieldByName('countOrder').AsInteger > Options.MaxOpenedOrders - 1);

    FReadSQL.Close;
  except
    on E: Exception do
      Touch_MessageBox('��������', '������ ' + E.Message, MB_OK, mtError);
  end;
end;

function TFrontBase.CheckExternalPay(const ID: Integer): Boolean;
var
  FSQL: TIBSQL;
begin
  FSQL := TIBSQL.Create(nil);
  FSQL.Transaction := ReadTransaction;
  try
    Result := False;
    if not ReadTransaction.InTransaction then
      ReadTransaction.StartTransaction;

    FSQL.SQL.Text :=
      ' SELECT I.USR$EXTERNALPROCESS FROM USR$INV_PAYTYPE I WHERE I.ID = :ID ';
    FSQL.ParamByName('ID').AsInteger := ID;
    FSQL.ExecQuery;
    Result := (FSQL.FieldBYName('USR$EXTERNALPROCESS').AsInteger = 1);
    FSQL.Close;
  finally
    FSQL.Free;
  end;
end;

function TFrontBase.CheckForSession: Boolean;
var
  FSQL: TIBSQL;
begin
  Result := True;
  if not Options.UseCurrentDate then
  begin
    FSQL := TIBSQL.Create(nil);
    FSQL.Transaction := ReadTransaction;
    try
      Result := False;
      FSQL.Close;
      FSQL.SQL.Text :=
        '  select first(1) ' +
        '  op.usr$logicdate as LDate, usr$open, usr$off ' +
        '  from ' +
        '  usr$mn_options op ' +
        '  order by 1 desc ';
      FSQL.ExecQuery;

      if (IsMainCash) and ((UserGroup and Options.KassaGroupMask) <> 0) then
      begin
         if (FSQL.FieldByName('usr$open').AsCurrency = 0) or (FSQL.FieldByName('usr$off').AsCurrency = 1) then
           Touch_MessageBox('��������', '����� �� �������! ��������� ��������� ������� �����!',
             MB_OK, mtWarning)
         else begin
           Result := True;
           exit;
         end;
      end
      else
      begin
        //  �� ������� �����
        if (FSQL.FieldByName('usr$open').AsCurrency = 0) then
        begin
          Touch_MessageBox('��������', '����� �� �������! ��������� ��������� ������� �����!',
            MB_OK, mtWarning);
          exit;
        end;
        // ��� ������� �����
        if (FSQL.FieldByName('usr$off').AsCurrency = 1) then
        begin
          Touch_MessageBox('��������', '��� �������� ��� ������ �����!',
            MB_OK, mtWarning);
          exit;
        end;
        Result := True;
      end;
      FSQL.Close;
    finally
      FSQL.Free;
    end;
  end;
end;

procedure TFrontBase.CreateIBUser(const IBName, IBPass: String; ID: Integer);
var
  IBSS: TIBSecurityService;
  Q: TIBSQL;
  Tr: TIBTransaction;
begin
  if CheckIBUser(IBName) then
    exit;

  IBSS := TIBSecurityService.Create(nil);
  try
    IBSS.ServerName := ServerName;
    IBSS.LoginPrompt := False;
    if ServerName > '' then
      IBSS.Protocol := TCP
    else
      IBSS.Protocol := Local;
    IBSS.Params.Add('user_name=' + FIBName);
    IBSS.Params.Add('password=' + FIBPassword);
    IBSS.Active := True;
    try
      IBSS.UserName := IBName;
      IBSS.FirstName := '';
      IBSS.MiddleName := '';
      IBSS.LastName := '';
      IBSS.UserID := ID;
      IBSS.GroupID := 0;
      IBSS.Password := IBPass;
      IBSS.AddUser;
      while IBSS.IsServiceRunning do Sleep(100);
    finally
      IBSS.Active := False;
    end;
  finally
    IBSS.Free;
  end;

  Tr := TIBTransaction.Create(nil);
  Q := TIBSQL.Create(nil);
  try
    Tr.DefaultDatabase := FDataBase;
    Tr.StartTransaction;

    Q.Transaction := Tr;
    Q.SQL.Text := 'GRANT administrator TO ' + IBName + ' WITH ADMIN OPTION ';
    Q.ExecQuery;

    Tr.Commit;
  finally
    Q.Free;
    Tr.Free;
  end;
end;

function TFrontBase.CheckIBUser(const IBName: String): Boolean;
var
  IBSS: TIBSecurityService;
  q: TIBSQL;
  Tr: TIBTransaction;
begin
  Result := ServerName = '';
  if not Result then
  begin
    IBSS := TIBSecurityService.Create(nil);
    try
      IBSS.ServerName := ServerName;
      if IBSS.ServerName > '' then
        IBSS.Protocol := TCP
      else
        IBSS.Protocol := Local;
      IBSS.LoginPrompt := False;
      IBSS.Params.Add('user_name=' + FIBName);
      IBSS.Params.Add('password=' + FIBPassword);
      try
        IBSS.Active := True;
        try
          IBSS.UserName := IBName;
          IBSS.DisplayUser(IBSS.UserName);
          Result := IBSS.UserInfoCount > 0;
        finally
          IBSS.Active := False;
        end;
      except
        Touch_MessageBox('��������', '���������� �������� ������ � ������� ������ ������������.'#13#10 +
          '�������� ������ �������������� ���� ������ ������ �������.', MB_OK, mtError);
      end;
    finally
      IBSS.Free;
    end;
  end;

  if Result then
  begin
    q := TIBSQL.Create(nil);
    Tr := TIBTransaction.Create(nil);
    try
      Tr.DefaultDatabase := FDataBase;
      Tr.StartTransaction;

      q.Transaction := Tr;
      q.SQL.Text := 'SELECT * FROM rdb$user_privileges WHERE rdb$privilege=''M'' ' +
        'AND rdb$relation_name=''ADMINISTRATOR'' AND rdb$user=''' + IBName + '''';
      q.ExecQuery;

      if q.EOF then
      begin
        q.Close;
        q.SQL.Text := 'GRANT administrator TO ' + IBName +
          ' WITH ADMIN OPTION';
        q.ExecQuery;
      end;

      q.Close;
      Tr.Commit;
    finally
      q.Free;
      Tr.Free;
    end;
  end;
end;

end.
