import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:intl/intl.dart';
import '../../app_routes.dart';
import '../../model/drs_model/drs_update_details/drs_update_details_request.dart';
import '../../model/drs_model/drs_update_details/drs_update_details_response.dart';
import '../../model/drs_model/drs_update_list/drs_update_list_request.dart';
import '../../model/drs_model/drs_update_list/drs_update_list_response.dart';
import '../../widgets/dashboard_widgets/custom_drawer.dart';

import '../../model/drs_model/drs_submit/drs_submit_request.dart';
import '../../model/drs_model/drs_submit/drs_submit_response.dart';
import '../../model/drs_model/general_master_response.dart';
import '../../utils/date_format.dart';
import '../../utils/pref.dart';
import '../../utils/tmsapi_method.dart';
import '../../utils/tmsapp_api.dart';
import '../../widgets/submit_alert_dialog.dart';
import '../../widgets/tost.dart';
import 'drs_update/drs_update_screen.dart';

enum DataStatus { loading, done, error }

enum PendingAttempted { pending, attempted }

class DRSController extends GetxController {
  TextEditingController drsFromDateCtl = TextEditingController(
    text: DateFormat('dd MMM yyyy').format(DateTime.now().subtract(const Duration(days: 7))),
  );

  TextEditingController drsToDateCtl = TextEditingController(
    text: DateFormat('dd MMM yyyy').format(DateTime.now()),
  );
  TextEditingController drsNumberController = TextEditingController();
  TextEditingController deliveredPkgsController = TextEditingController();
  TextEditingController closeKmController = TextEditingController();
  TextEditingController drsRemarkController = TextEditingController();
  TextEditingController receiversNameController = TextEditingController();
  TextEditingController drsScanController = TextEditingController();
  TextEditingController drsUpdateScanController = TextEditingController();

  late DrsDetailData drsDetailData;

  RxList<DrsList> drsList = <DrsList>[].obs;
  List<DrsDetailList> drsDetailList = <DrsDetailList>[];
  List<GeneralMasterList> failureRemarkList = <GeneralMasterList>[];
  List<GeneralMasterList> partialRemarkList = <GeneralMasterList>[];
  List<GeneralMasterList> relationList = <GeneralMasterList>[];

  Rx<DataStatus> drsListDataStatus = DataStatus.loading.obs;
  Rx<DataStatus> docketListDataStatus = DataStatus.loading.obs;
  Rx<PendingAttempted> pendingAttemptedStatus = PendingAttempted.pending.obs;
  Rx<FutherAction> futherActionStatus = FutherAction.Success.obs;

  RxBool isShow = false.obs;
  RxInt enteredValue = 0.obs;
  String? reason;
  String? qtyReason;
  String? tapDrsNo;
  String selectFailureReason = '';
  String selectPartialReason = '';
  String selectRelation = '';
  RxList<String> images = <String>[].obs;

  clearCtrl() {
    selectFailureReason = '';
    selectPartialReason = '';
    selectRelation = '';
    images.clear();
    drsRemarkController.clear();
  }

  /// DrsList api
  Future<void> drsListApi({
    required BuildContext context,
  }) async {
    try {
      drsListDataStatus.value = DataStatus.loading;
      var response = await WebService.tmsPostRequest(
        url: ApiService.dRSUpdateList,
        body: drsUpdateListRequestToJson(
          DrsUpdateListRequest(
            baseLocationCode: Pref().getBaseLocation(),
            dateFrom: drsFromDateCtl.text,
            dateTo: drsToDateCtl.text,
            baseCompanyCode: Pref().getCompanyCode(),
            userID: Pref().getUserId(),
          ),
        ),
      );
      var jsonResponse = jsonDecode(response.data);

      int status = jsonResponse['status'];

      if (status == 200) {
        DrsUpdateListResponse drsUpdateListResponse =
            await drsUpdateListResponseFromJson(response.data);
        if (drsUpdateListResponse.status == 200) {
          drsList = drsUpdateListResponse.drsList.obs;
          drsListDataStatus.value = DataStatus.done;
          drsRemark();
          relationApi();
        } else {
          drsListDataStatus.value = DataStatus.error;
        }
      } else {
        drsListDataStatus.value = DataStatus.error;
      }
    } catch (error) {
      drsListDataStatus.value = DataStatus.error;
    }
  }

  /// Change api format
  String showDate(String date) {
    if (date.isNotEmpty) {
      String dateString = date;
      DateFormat inputFormat = DateFormat(DateAndTimeFormat.yyyyMMddTHHmmSS);
      DateTime dateTime = inputFormat.parse(dateString);
      DateFormat outputFormat = DateFormat(DateAndTimeFormat.yyyyMMdd);
      String formattedDate = outputFormat.format(dateTime);
      return formattedDate;
    } else {
      return '';
    }
  }

  void drsUpdateDetail({
    required String docketNo,
    required String updateType,
    required String value,
  }) async {
    final body = {"dockno": docketNo, "updateType": updateType, "value": value};

    try {
      final response = await WebService.tmsPostRequest(
        url: ApiService.UpdateDocketDetails,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print("Update successful: ${response.data}");
      } else {
        print("Update failed: ${response.statusCode}");
      }
    } catch (e) {
      print("Error occurred: $e");
    }
  }

  deliveredPkgsValidation(newValue, index) {
    if (newValue.isNotEmpty) {
      enteredValue.value = int.parse(newValue);
      if (enteredValue.value < 0) {
        deliveredPkgsController.text = '0';
      } else if (enteredValue.value >= drsDetailList[index].pkgsArrived) {
        deliveredPkgsController.text = "${drsDetailList[index].pkgsArrived}";
        isShow.value = false;
      } else {
        enteredValue.value = int.parse(newValue);
        if (enteredValue.value <= drsDetailList[index].pkgsArrived) {
          isShow.value = true;
        } else {
          isShow.value = false;
        }
      }
    }
  }

  /// Drs update Api
  Future<void> updateDrsApi({
    required BuildContext context,
    required String drsId,
  }) async {
    print(
        "`````````````````````````````````````````````````````````````````````````````````````call api");
    var response = await WebService.tmsPostRequest(
      url: ApiService.updateDRSDetails,
      body: drsUpdateDetailsRequestToJson(
        DrsUpdateDetailsRequest(
          drsId: drsId,
          baseLocationCode: '${Pref().getBaseLocation()}',
        ),
      ),
    );
    try {
      if (response.statusCode == 200) {
        DrsUpdateDetailsResponse drsUpdateDetailsResponse =
            drsUpdateDetailsResponseFromJson(response.data);
        if (drsUpdateDetailsResponse.statusCode == 200) {
          drsDetailData = drsUpdateDetailsResponse.drsDetailData;
          drsDetailList = drsDetailData.drsDetailList;
          docketListDataStatus.value = DataStatus.done;
          if (drsDetailList.isEmpty) {
            print("Enter second api 22222222222222222222222222222222222222222222");
            Get.toNamed(AppRoutes.drsListScreen);
            drsListDataStatus.value = DataStatus.loading;
            drsListApi(context: context);
          }
        } else {
          docketListDataStatus.value = DataStatus.error;
          TmsToast.msg(drsUpdateDetailsResponse.message);
        }
      } else {
        docketListDataStatus.value = DataStatus.error;
        TmsToast.msg(response.statusMessage!);
      }
    } catch (error) {
      if (response.data == null) {
        TmsToast.msg('No data Found');
      } else {
        docketListDataStatus.value = DataStatus.error;
        TmsToast.msg(error.toString());
      }
    }
  }

  /// drs update screen scan
  void drsUpdateScan(context, String qrScanNumber, bool isQr) {
    bool isScanTrue = drsDetailList.any((element) => element.dockno == qrScanNumber);
    int index = drsDetailList.indexWhere((element) => element.dockno == qrScanNumber);
    if (isScanTrue) {
      if (isQr) {
        Get.back();
      }
      Get.toNamed(
        AppRoutes.drsUpdateScreen,
        arguments: index,
      );
    } else {
      TmsToast.msg('Please Scan Right Qrcode');
    }
  }

  /// Modify the drsRemark method to accept a list of code types
  Future<void> drsRemark() async {
    String baseUrl = "${ApiService.baseUrl}V1/Master/GetGeneralMasterData";
    final List<String> codeTypes = ["PART_D", "UNDELY"];

    for (String codeType in codeTypes) {
      String url = "$baseUrl?CodeType=$codeType";

      try {
        final dio.Response response = await WebService.tmsGetRequest(url);
        if (response.statusCode == 200) {
          GeneralMasterResponse generalMasterResponse =
              generalMasterResponseFromJson(response.data);
          if (codeType == 'UNDELY') {
            failureRemarkList = generalMasterResponse.generalMasterList;
          }

          if (codeType == "PART_D") {
            partialRemarkList = generalMasterResponse.generalMasterList;
          }
        } else {
          print(response.statusMessage);
        }
      } catch (error) {
        if (kDebugMode) {
          print(error.reactive);
        }
      }
    }
  }

  relationApi() async {
    String baseUrl = "${ApiService.baseUrl}V1/Master/GetGeneralMasterData";
    String url = "$baseUrl?CodeType=DELPERSREL";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        GeneralMasterResponse generalMasterResponse = generalMasterResponseFromJson(response.data);
        relationList = generalMasterResponse.generalMasterList;
      } else {
        print(response.statusMessage);
      }
    } catch (error) {
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  ///drs submit request
  DrsSubmitRequest drsSubmitReq(int index) {
    return DrsSubmitRequest(
      drsSummary: DrsSummary(
        pdcno: drsList[index].dlypdcno,
        pdCDt: drsList[index].commDelyDt,
        deliveryBy: Pref().getUserId(),
        driverName: "",
        totalDocketsInDrs: 0,
        closeKm: int.parse(closeKmController.text.isEmpty ? "0" : closeKmController.text),
        toDate: DateAndTimeFormat().formattedDate,
        fromDate: DateAndTimeFormat().formattedDate,
        loadingCharge: 0,
        dockno: '',
        actuwt: 0,
        autoNo: 0,
        bAVendorCode: '',
        dockdt: DateAndTimeFormat().formattedDate,
        drs: '',
        drsDate: DateAndTimeFormat().formattedDate,
        drSDt: '',
        drsNoList: '',
        hdnRate: 0,
        isMathadi: false,
        isMonthly: true,
        loadingBy: '',
        mathadiAmt: 0,
        mathadiDate: DateAndTimeFormat().formattedDate,
        mathadiSlipNo: '',
        maxLimit: 0,
        pdCUpdated: '',
        pkgsno: 0,
        rate: 0,
        rateType: '',
        staff: '',
        startKm: 0,
        vehno: '',
        vendorCode: '',
        vendorName: '',
      ),
      updateDrsLits: [
        UpdateDrsLit(
          autoNo: drsList[index].autoNo.toInt(),
          dockno: drsList[index].dockno,
          bookingDate: drsList[index].bookingDate,
          orgncd: drsList[index].orgncd,
          destcd: drsList[index].destcd,
          payBasis: drsList[index].payBasis,
          csgecd: drsList[index].csgecd,
          csgenm: drsList[index].csgenm,
          csgncd: drsList[index].csgncd,
          csgnnm: drsList[index].csgnnm,
          pkgsArrived: drsList[index].pkgsPending.toInt(),
          pkgsBooked: drsList[index].pkgsBooked.toInt(),
          pkgsPending: drsList[index].pkgsPending.toInt() - int.parse(deliveredPkgsController.text),
          wtArrived: drsList[index].wtArrived.toDouble(),
          commDelyDt: drsList[index].commDelyDt,
          delydate: DateFormat('yyyy-MM-dd HH:mm')
              .format(DateTime.parse(DateAndTimeFormat().formattedDate)),
          delytime: DateFormat('HH:mm').format(DateTime.parse(DateAndTimeFormat().formattedDate)),
          delyperson: Pref().getUserName(),
          pkgsdelivered:
              deliveredPkgsController.text.isNotEmpty ? int.parse(deliveredPkgsController.text) : 0,
          remark: drsRemarkController.text,
          hDcboReason: selectFailureReason,
          cboLateReason: selectPartialReason,
          rate: 0,
          maxLimit: 0,
          docksf: drsList[index].docksf,
          actQty: 0,
          bookedWt: 0,
          cboReason: '',
          cdeldTDdmmyyyy: '',
          coDDod: '',
          coddod: true,
          coddodAmount: 0,
          coddodcollected: 0,
          coddodno: 0,
          currLoc: '',
          delyLocation: '',
          dlypdcno: '',
          dockDt: DateAndTimeFormat().formattedDate,
          dockDtDdmmyyyy: drsList[index].dockDtDdmmyyyy,
          docketTotal: 0,
          freight: 0,
          isChecked: true,
          isEnabled: true,
          isEnabledBadPodoption: true,
          newRate: 0,
          otp: '',
          payBasCode: '',
          pkgQty: 0,
          ratetype: '',
          serviceTax: 0,
          frontPod: images.isNotEmpty ? images[0] : "",
          backPod: images.isNotEmpty ? images[1] : "",
          relation: selectRelation,
        ),
      ],
      loadingCharge: 0,
      baseUserName: Pref().getUserName(),
    );
  }

  ///Drs Submit api
  Future<void> drsSubmitApi({
    required BuildContext context,
    required int index,
  }) async {
    appLoader.show();
    var response = await WebService.tmsPostRequest(
      url: ApiService.updateDRS,
      body: drsSubmitRequestToJson(drsSubmitReq(index)),
    );
    try {
      appLoader.hide();
      if (response.statusCode == 200) {
        DrsSubmitResponse drsSubmitResponse = drsSubmitResponseFromJson(response.data);
        if (drsSubmitResponse.status == 200) {
          submitAlertDialog(
            context: context,
            title: 'Success',
            onTap: () {
              docketListDataStatus.value = DataStatus.loading;
              Get.offAndToNamed(AppRoutes.drsListScreen);
              drsController.drsListApi(context: context);

              clearCtrl();
            },
            onTapText: 'Done',
            image: 'assets/images/dashboardimages/succes.png',
          );
        } else {
          TmsToast.msg(drsSubmitResponse.message);
        }
      } else {
        TmsToast.msg("Something is wrong");
      }
    } catch (error) {
      appLoader.hide();
      TmsToast.msg('Drs Submit error ${error.toString()}');
    }
  }
}
