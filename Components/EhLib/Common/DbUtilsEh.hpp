// CodeGear C++Builder
// Copyright (c) 1995, 2009 by Embarcadero Technologies, Inc.
// All rights reserved

// (DO NOT EDIT: machine generated header) 'Dbutilseh.pas' rev: 21.00

#ifndef DbutilsehHPP
#define DbutilsehHPP

#pragma delphiheader begin
#pragma option push
#pragma option -w-      // All warnings off
#pragma option -Vx      // Zero-length empty class member functions
#pragma pack(push,8)
#include <System.hpp>	// Pascal unit
#include <Sysinit.hpp>	// Pascal unit
#include <Variants.hpp>	// Pascal unit
#include <Ehlibvcl.hpp>	// Pascal unit
#include <Widestrings.hpp>	// Pascal unit
#include <Dbgrideh.hpp>	// Pascal unit
#include <Db.hpp>	// Pascal unit
#include <Sysutils.hpp>	// Pascal unit
#include <Classes.hpp>	// Pascal unit
#include <Typinfo.hpp>	// Pascal unit
#include <Windows.hpp>	// Pascal unit
#include <Messages.hpp>	// Pascal unit
#include <Toolctrlseh.hpp>	// Pascal unit

//-- user supplied -----------------------------------------------------------

namespace Dbutilseh
{
//-- type declarations -------------------------------------------------------
typedef System::UnicodeString __fastcall (*TDateValueToSQLStringProcEh)(Db::TDataSet* DataSet, const System::Variant &Value);

typedef StaticArray<System::UnicodeString, 16> Dbutilseh__1;

typedef StaticArray<System::UnicodeString, 16> Dbutilseh__2;

typedef System::UnicodeString __fastcall (*TOneExpressionFilterStringProcEh)(Dbgrideh::TSTFilterOperatorEh O, const System::Variant &v, System::UnicodeString FieldName, Db::TDataSet* DataSet, TDateValueToSQLStringProcEh DateValueToSQLStringProc, bool SupportsLike);

typedef TMetaClass* TDataSetClass;

class DELPHICLASS TDatasetFeaturesEh;
class PASCALIMPLEMENTATION TDatasetFeaturesEh : public System::TObject
{
	typedef System::TObject inherited;
	
private:
	TDataSetClass FDataSetClass;
	
public:
	__fastcall virtual TDatasetFeaturesEh(void);
	virtual bool __fastcall LocateText(Dbgrideh::TCustomDBGridEh* AGrid, const System::UnicodeString FieldName, const System::UnicodeString Text, Toolctrlseh::TLocateTextOptionsEh AOptions, Toolctrlseh::TLocateTextDirectionEh Direction, Toolctrlseh::TLocateTextMatchingEh Matching, Toolctrlseh::TLocateTextTreeFindRangeEh TreeFindRange);
	virtual bool __fastcall MoveRecords(System::TObject* Sender, Toolctrlseh::TBMListEh* BookmarkList, int ToRecNo, bool CheckOnly);
	virtual void __fastcall ApplySorting(System::TObject* Sender, Db::TDataSet* DataSet, bool IsReopen);
	virtual void __fastcall ApplyFilter(System::TObject* Sender, Db::TDataSet* DataSet, bool IsReopen);
	virtual void __fastcall ExecuteFindDialog(System::TObject* Sender, System::UnicodeString Text, System::UnicodeString FieldName, bool Modal);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TDatasetFeaturesEh(void) { }
	
};


class DELPHICLASS TSQLDatasetFeaturesEh;
class PASCALIMPLEMENTATION TSQLDatasetFeaturesEh : public TDatasetFeaturesEh
{
	typedef TDatasetFeaturesEh inherited;
	
private:
	bool FSortUsingFieldName;
	System::UnicodeString FSQLPropName;
	TDateValueToSQLStringProcEh FDateValueToSQLString;
	bool FSupportsLocalLike;
	
public:
	__fastcall virtual TSQLDatasetFeaturesEh(void);
	virtual void __fastcall ApplySorting(System::TObject* Sender, Db::TDataSet* DataSet, bool IsReopen);
	__property bool SortUsingFieldName = {read=FSortUsingFieldName, write=FSortUsingFieldName, nodefault};
	virtual void __fastcall ApplyFilter(System::TObject* Sender, Db::TDataSet* DataSet, bool IsReopen);
	__property System::UnicodeString SQLPropName = {read=FSQLPropName, write=FSQLPropName};
	__property TDateValueToSQLStringProcEh DateValueToSQLString = {read=FDateValueToSQLString, write=FDateValueToSQLString};
	__property bool SupportsLocalLike = {read=FSupportsLocalLike, write=FSupportsLocalLike, nodefault};
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TSQLDatasetFeaturesEh(void) { }
	
};


class DELPHICLASS TCommandTextDatasetFeaturesEh;
class PASCALIMPLEMENTATION TCommandTextDatasetFeaturesEh : public TSQLDatasetFeaturesEh
{
	typedef TSQLDatasetFeaturesEh inherited;
	
public:
	__fastcall virtual TCommandTextDatasetFeaturesEh(void);
public:
	/* TObject.Destroy */ inline __fastcall virtual ~TCommandTextDatasetFeaturesEh(void) { }
	
};


typedef TMetaClass* TDatasetFeaturesEhClass;

//-- var, const, procedure ---------------------------------------------------
extern PACKAGE Dbutilseh__1 STFilterOperatorsStrMapEh;
extern PACKAGE StaticArray<Dbgrideh::TSTOperandTypeEh, 52> STFldTypeMapEh;
extern PACKAGE Dbutilseh__2 STFilterOperatorsSQLStrMapEh;
extern PACKAGE System::UnicodeString SQLFilterMarker;
extern PACKAGE System::ResourceString _SNotOperatorEh;
#define Dbutilseh_SNotOperatorEh System::LoadResourceString(&Dbutilseh::_SNotOperatorEh)
extern PACKAGE System::ResourceString _SAndOperatorEh;
#define Dbutilseh_SAndOperatorEh System::LoadResourceString(&Dbutilseh::_SAndOperatorEh)
extern PACKAGE System::ResourceString _SOrOperatorEh;
#define Dbutilseh_SOrOperatorEh System::LoadResourceString(&Dbutilseh::_SOrOperatorEh)
extern PACKAGE System::ResourceString _SLikePredicatEh;
#define Dbutilseh_SLikePredicatEh System::LoadResourceString(&Dbutilseh::_SLikePredicatEh)
extern PACKAGE System::ResourceString _SInPredicatEh;
#define Dbutilseh_SInPredicatEh System::LoadResourceString(&Dbutilseh::_SInPredicatEh)
extern PACKAGE System::ResourceString _SNullConstEh;
#define Dbutilseh_SNullConstEh System::LoadResourceString(&Dbutilseh::_SNullConstEh)
extern PACKAGE System::ResourceString _SQuoteIsAbsentEh;
#define Dbutilseh_SQuoteIsAbsentEh System::LoadResourceString(&Dbutilseh::_SQuoteIsAbsentEh)
extern PACKAGE System::ResourceString _SLeftBracketExpectedEh;
#define Dbutilseh_SLeftBracketExpectedEh System::LoadResourceString(&Dbutilseh::_SLeftBracketExpectedEh)
extern PACKAGE System::ResourceString _SRightBracketExpectedEh;
#define Dbutilseh_SRightBracketExpectedEh System::LoadResourceString(&Dbutilseh::_SRightBracketExpectedEh)
extern PACKAGE System::ResourceString _SErrorInExpressionEh;
#define Dbutilseh_SErrorInExpressionEh System::LoadResourceString(&Dbutilseh::_SErrorInExpressionEh)
extern PACKAGE System::ResourceString _SUnexpectedExpressionBeforeNullEh;
#define Dbutilseh_SUnexpectedExpressionBeforeNullEh System::LoadResourceString(&Dbutilseh::_SUnexpectedExpressionBeforeNullEh)
extern PACKAGE System::ResourceString _SUnexpectedExpressionAfterOperatorEh;
#define Dbutilseh_SUnexpectedExpressionAfterOperatorEh System::LoadResourceString(&Dbutilseh::_SUnexpectedExpressionAfterOperatorEh)
extern PACKAGE System::ResourceString _SIncorrectExpressionEh;
#define Dbutilseh_SIncorrectExpressionEh System::LoadResourceString(&Dbutilseh::_SIncorrectExpressionEh)
extern PACKAGE System::ResourceString _SUnexpectedANDorOREh;
#define Dbutilseh_SUnexpectedANDorOREh System::LoadResourceString(&Dbutilseh::_SUnexpectedANDorOREh)
extern PACKAGE void __fastcall ClearSTFilterExpression(Dbgrideh::TSTFilterExpressionEh &FExpression);
extern PACKAGE void __fastcall InitSTFilterOperatorsStrMap(void);
extern PACKAGE bool __fastcall ParseSTFilterExpressionEh(System::UnicodeString Exp, Dbgrideh::TSTFilterExpressionEh &FExpression);
extern PACKAGE System::UnicodeString __fastcall GetExpressionAsFilterString(Dbgrideh::TCustomDBGridEh* AGrid, TOneExpressionFilterStringProcEh OneExpressionProc, TDateValueToSQLStringProcEh DateValueToSQLStringProc, bool UseFieldOrigin = false, bool SupportsLocalLike = false);
extern PACKAGE System::UnicodeString __fastcall GetOneExpressionAsLocalFilterString(Dbgrideh::TSTFilterOperatorEh O, const System::Variant &v, System::UnicodeString FieldName, Db::TDataSet* DataSet, TDateValueToSQLStringProcEh DateValueToSQLStringProc, bool SupportsLike);
extern PACKAGE System::UnicodeString __fastcall GetOneExpressionAsSQLWhereString(Dbgrideh::TSTFilterOperatorEh O, const System::Variant &v, System::UnicodeString FieldName, Db::TDataSet* DataSet, TDateValueToSQLStringProcEh DateValueToSQLStringProc, bool SupportsLike);
extern PACKAGE System::UnicodeString __fastcall DateValueToDataBaseSQLString(System::UnicodeString DataBaseName, const System::Variant &v);
extern PACKAGE void __fastcall ApplyFilterSQLBasedDataSet(Dbgrideh::TCustomDBGridEh* Grid, TDateValueToSQLStringProcEh DateValueToSQLString, bool IsReopen, System::UnicodeString SQLPropName);
extern PACKAGE bool __fastcall IsSQLBasedDataSet(Db::TDataSet* DataSet, Classes::TStrings* &SQL);
extern PACKAGE bool __fastcall IsDataSetHaveSQLLikeProp(Db::TDataSet* DataSet, System::UnicodeString SQLPropName, System::WideString &SQLPropValue);
extern PACKAGE void __fastcall ApplySortingForSQLBasedDataSet(Dbgrideh::TCustomDBGridEh* Grid, Db::TDataSet* DataSet, bool UseFieldName, bool IsReopen, System::UnicodeString SQLPropName);
extern PACKAGE bool __fastcall LocateDatasetTextEh(Dbgrideh::TCustomDBGridEh* AGrid, const System::UnicodeString FieldName, const System::UnicodeString Text, Toolctrlseh::TLocateTextOptionsEh AOptions, Toolctrlseh::TLocateTextDirectionEh Direction, Toolctrlseh::TLocateTextMatchingEh Matching, Toolctrlseh::TLocateTextTreeFindRangeEh TreeFindRange);
extern PACKAGE void __fastcall RegisterDatasetFeaturesEh(TDatasetFeaturesEhClass DatasetFeaturesClass, TDataSetClass DataSetClass);
extern PACKAGE void __fastcall UnregisterDatasetFeaturesEh(TDataSetClass DataSetClass);
extern PACKAGE TDatasetFeaturesEh* __fastcall GetDatasetFeaturesForDataSetClass(System::TClass DataSetClass);
extern PACKAGE TDatasetFeaturesEh* __fastcall GetDatasetFeaturesForDataSet(Db::TDataSet* DataSet);

}	/* namespace Dbutilseh */
using namespace Dbutilseh;
#pragma pack(pop)
#pragma option pop

#pragma delphiheader end.
//-- end unit ----------------------------------------------------------------
#endif	// DbutilsehHPP
