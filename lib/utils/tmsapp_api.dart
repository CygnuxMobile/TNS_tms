

import '../environments .dart';

class ApiService {
  ///baseurl
  static String  baseUrl = AppEnvironments.baseurl;

  ///subUrl
  static String login = '${baseUrl}V1/Authenticate/Login';
  static String getLocationMasterData = '${baseUrl}V1/Master/GetLocationMasterData';
  static String getBarCodePrintByGCN = '${baseUrl}V1/Operation/GetBarCodePrintByGCN';
  static String checkValidSerialNo = '${baseUrl}V1/Operation/CheckValidSerialNo';
  static String prepareManifest = '${baseUrl}V1/Operation/PrepareManifest';
  static String thcArrivalSubmit = '${baseUrl}V1/Operation/THCArrivalSubmit';
  static String thcArrivalsList = '${baseUrl}V1/Operation/THCArrivalsList';
  static String getUnloadingSheetData ='${baseUrl}V1/Operation/GetUnloadingSheetData';
  static String getPodList = '${baseUrl}V1/Operation/GetPODlist';
  static String uploadPODImage = '${baseUrl}V1/Operation/UploadPODImage';
  static String attendance = '${baseUrl}V1/Master/AttandanceClockIn';
  static String getAttendance = '${baseUrl}V1/Master/GetAttendance';
  static String stockUpdateList = '${baseUrl}V1/Operation/StockUpdateList';
  static String stockUpdateDetails ='${baseUrl}V1/Operation/StockUpdateDetails';
  static String trackingDetails = '${baseUrl}V1/Operation/DocketTracking';
  static String dRSUpdateList = '${baseUrl}V1/Operation/DRSUpdateListNew';
  static String updateDRSDetails = '${baseUrl}V1/Operation/UpdateDRSDetails';
  static String getGeneralMasterData ='${baseUrl}V1/Operation/GetGeneralMasterData';
  static String GeneralMasterData ='${baseUrl}V1/Master/GetGeneralMasterData';
  static String updateDRS = '${baseUrl}V1/Operation/UpdateDRS';
  static String checkValidDocketNo ='${baseUrl}V1/Operation/CheckValidDocketNo';
  static String GetTransportModel ='${baseUrl}V1/Master/GetTransportModel';
  static String GetProduct ='${baseUrl}V1/Master/GetProduct';
  static String GetPackageType ='${baseUrl}V1/Master/GetPackageType';
  static String GetPinCode ='${baseUrl}V1/Master/GetPinCode?search=';
  static String quickDocketAPI = '${baseUrl}V1/Operation/QuickDocketAPI';
  static String outWardListAPI = '${baseUrl}V1/Operation/UpdateLoadingSheetList';
  static String bcListAPI = '${baseUrl}V1/Operation/LoadingSheetDetail';
  static String menuAccessDetailsApi = '${baseUrl}V1/Authenticate/MenuAccessDetails';
  static String eWayBill = '${baseUrl}V1/Operation/GetEwaybillDetailsFromAPI';
  static String GetWarehouselist = '${baseUrl}V1/Master/GetWarehouselist';
  static String UpdateDocketDetails = '${baseUrl}V1/Operation/UpdateDocketDetails';
  static String DocketDetail = '${baseUrl}V1/Operation/GetDockDetForMisrt';
  static String misRouteDocketSubmit = '${baseUrl}V1/Operation/MisrouteDocket';
  static String versionCheck = '${baseUrl}V1/Master/GetGeneralMasterData?CodeType=CUSTOMERAPKVERSION';
  static String getPRSList = '${baseUrl}V1/Operation/PRSList';
  static String checkPRSNo = '${baseUrl}V1/Operation/CheckPRSValidSerialNo';
  static String prsSubmit = '${baseUrl}V1/Operation/PreparePRS';
  static String getBcSerialDetailsForPrint = '${baseUrl}V1/Operation/GetBcSerialDetailsForPrint';
  static String outScanDRSList = '${baseUrl}V1/Operation/OutScanDRSList';
  static String outScanDRSDetails = '${baseUrl}V1/Operation/OutScanDRSDetails';
  static String CheckOutscanDRSValidSerialNo = '${baseUrl}V1/Operation/CheckOutscanDRSValidSerialNo';
  static String DRSUpdate = '${baseUrl}V1/Operation/DRSUpdate';
  static String AvalabledocketinPRS = '${baseUrl}V1/Operation/AvalabledocketinPRS';
  static String bcNumberAPI = '${baseUrl}V1/Operation/DocketBCSerialsScan';
  static String removeBocAPI = '${baseUrl}V1/Operation/RemoveDocketBCSerialsScan';
  static String QuickDocketBookedList = '${baseUrl}V1/Operation/QuickDocketBookedList';
  static String GetPinCodeFromCity = '${baseUrl}V1/Master/GetPinCodeFromCity?City=';
  static String GetEwayBillState = '${baseUrl}V1/Master/GetEwayBillState';
}
