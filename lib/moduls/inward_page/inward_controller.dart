import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../model/dash_board_model/location_master.dart';
import '../../model/inward_model/inward_list/inward_list_request.dart';
import '../../model/stock_update/stock_update_submit/stock_update_submit_request.dart';
import '../../moduls/docket_page/docket_controller.dart';
import '../../utils/pref.dart';
import '../../utils/tmsapi_method.dart';
import '../../utils/tmsapp_api.dart';
import 'package:intl/intl.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/submit_alert_dialog.dart';
import '../../widgets/tost.dart';
import 'package:dio/dio.dart' as dio;

import '../../app_routes.dart';
import '../../model/inward_model/Warehouselist.dart';
import '../../model/inward_model/damage_type.dart';
import '../../model/inward_model/delivery_type.dart';
import '../../model/inward_model/inward_list/inward_list_response.dart';
import '../outward_page/outward_controller.dart';

class InwardController extends GetxController {
  ///FocusNode
  FocusNode scanFocusNode = FocusNode();

  ///TextFiled
  TextEditingController boxScanController = TextEditingController();
  TextEditingController inWardFromDate = TextEditingController(text: "01 Jan 2025"/*DateFormat('dd MMM yyyy').format(DateTime.now().subtract(const Duration(days: 30)))*/);
  TextEditingController inWardToDate = TextEditingController(text: DateFormat('dd MMM yyyy').format(DateTime.now()).toString());
  TextEditingController thcNumberController = TextEditingController();

  ///List
  RxList<InWardListObject> inWardList = <InWardListObject>[].obs;

  // RxList<DocketBcSerialList> docketBcSerialsList = <DocketBcSerialList>[].obs;
  RxList<Docket> docket = <Docket>[].obs;
  RxList<LocationList> location = <LocationList>[].obs;
  RxList<DocketBcSerialList> filteredDocketList = <DocketBcSerialList>[].obs;
  RxList<DocketBcSerialList> docketBcSerialsList = <DocketBcSerialList>[].obs;
  List<DeliveryTypeObject> deliveryTypeList = [];
  List<DeliveryTypeObject> arrivalConditionList = [];
  List<DamageTypeList> damageTypeList = [];
  List<WareHouseListObject> wareHouseList = [];
  RxString selectOrigin = '${Pref().getBaseLocation()}'.obs;
  RxString selectDestination = ''.obs;
  RxString SelectPkgsNo = ''.obs;
  String destination = '';

  ///Enum
  Rx<DataStatus> inWardListApiDataStatus = DataStatus.loading.obs;
  Rx<ScanManually> scanManuallyStatus = ScanManually.scan.obs;

  ///Audio ctrl
  final player = AudioPlayer();

  ///Bool
  RxBool isAllBcSca = false.obs;
  RxBool isMisroute = false.obs;

  ///Int
  int lsIndex = 0;

  ///String
  RxString searchQuery = ''.obs;
  RxString lastBcScan = ''.obs;
  RxString lsNumber = ''.obs;
  RxString selectWareHouse = ''.obs;
  RxString selectCondition = ''.obs;
  RxString selectDeliveryType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    deliveryTypeApi();
    inWardListApi();
    locationMasterDataApi();
    // arrivalConditionApi();
    // damageTypeApi();
    // warehouseApi();
  }

  void filterDocketList(String query) {
    if (query.isEmpty) {
      filteredDocketList.value = docketBcSerialsList;
    } else {
      filteredDocketList.value = docketBcSerialsList.where((item) => item.bcSerialNo.toLowerCase().contains(query.toLowerCase())).toList();
    }
  }

  deliveryTypeApi() async {
    final response = await WebService.tmsGetRequest(ApiService.GeneralMasterData + "?CodeType=DLYPRC");
    if (response.statusCode == 200) {
      DeliveryTypeResponse deliveryTypeResponse = deliveryTypeResponseFromJson(response.data);
      deliveryTypeList = deliveryTypeResponse.deliveryTypeList;
    }
  }

  // arrivalConditionApi() async {
  //   final response = await WebService.tmsGetRequest(ApiService.GeneralMasterData + "?CodeType=ARRCAT");
  //   if (response.statusCode == 200) {
  //     DeliveryTypeResponse arrivalConditionResponse = deliveryTypeResponseFromJson(response.data);
  //     arrivalConditionList = arrivalConditionResponse.deliveryTypeList;
  //   }
  // }

  // warehouseApi() async {
  //   final response = await WebService.tmsGetRequest(ApiService.GetWarehouselist + "?LocCode=${Pref().getBaseLocation()}");
  //   if (response.statusCode == 200) {
  //     WareHouseListResponse wareHouseListResponse = wareHouseListResponseFromJson(response.data);
  //     wareHouseList = wareHouseListResponse.data;
  //   }
  // }
  //
  // damageTypeApi() async {
  //   final response = await WebService.tmsGetRequest(ApiService.GeneralMasterData + "?CodeType=DEPSTYP");
  //   if (response.statusCode == 200) {
  //     DamageTypeResponse damageTypeResponse = damageTypeResponseFromJson(response.data);
  //     damageTypeList = damageTypeResponse.damageTypeList;
  //   }
  // }

  Future<List<String>?> imagesFromGallery() async {
    final List<XFile>? selectedFiles = await ImagePicker().pickMultiImage(imageQuality: 25);
    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      return Future.wait(selectedFiles.map((file) => _fileToBase64(file)));
    }
    return null;
  }

  Future<String?> imageFromCamera() async {
    final XFile? capturedFile = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 25);
    if (capturedFile != null) {
      return _fileToBase64(capturedFile);
    }
    return null;
  }

  Future<String> _fileToBase64(XFile file) async {
    final bytes = await File(file.path).readAsBytes();
    return base64Encode(bytes);
  }

  /// location master data
  Future<void> locationMasterDataApi() async {
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.getLocationMasterData + "?UserID=${Pref().getUserId()}");
      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        GetLocationMasterData getLocationMasterData = await getLocationMasterDataFromJson(responseData);
        location.value = getLocationMasterData.data;
      } else {
        if (response.statusCode == 401) {
          // tokenExpire();
        } else {
          print('${response.statusCode} : ${response.data.toString()}');
        }
      }
    } catch (error) {
      print(error);
    }
  }

  inWardListApi() async {
    inWardList.clear();
    inWardListApiDataStatus.value = DataStatus.loading;
    final response = await WebService.tmsPostRequest(
      url: ApiService.stockUpdateList,
      body: inWardRequestToJson(
        InWardRequest(
          thcNo: "",
          fromDate: inWardFromDate.text,
          toDate: inWardToDate.text,
          transportMode: "S",
          baseComapnyCode: Pref().getCompanyCode(),
          baseLocationCode: Pref().getBaseLocation(),
        ),
      ),
    );

    try {
      if (response.statusCode == 200) {
        InWardListResponse inWardListResponse = inWardListResponseFromJson(response.data);
        if (inWardListResponse.status == 200) {
          inWardListApiDataStatus.value = DataStatus.completed;
          inWardList.value = inWardListResponse.inWardList;
        }
      } else {
        inWardListApiDataStatus.value = DataStatus.error;
      }
    } catch (error) {
      inWardListApiDataStatus.value = DataStatus.error;
    }
  }

  scanBox({required String boxNumber}) async {
    bool isMatched = false;
    bool isDocketNumber = true;

      for (var docketList in docket) {
        for (var data in docketList.docketBcSerials) {
          bool allChecked = docketList.docketBcSerials.every((serial) => serial.isScan.value);
          if (allChecked == true) {
            docketList.isFullScan.value = true;
            break;
          } else {
            if (boxNumber == data.bcSerialNo) {
              if (data.isScan.isTrue) {
                await player.play(AssetSource('audio/already_scan_package.mp3'));
                TmsToast.msg("Box number $boxNumber is already scanned!");
                isMatched = true;
                break;
              } else {
                data.isScan.value = true;
                await player.play(AssetSource('audio/scaning_done.mp3'));
                TmsToast.msg("Box number $boxNumber scanned successfully!");
                isMatched = true;
                if (docketList.docketBcSerials.every((serial) => serial.isScan.value)) {
                  docketList.isFullScan.value = true;
                }
                docketList.lastScan.value = boxNumber;
                break;
              }
            }
          }
        }
      }


    if (!isMatched) {
      if (isDocketNumber) {
        await player.play(AssetSource('audio/invalid_qr_code.mp3'));
        TmsToast.msg("Docket number $boxNumber not found. Please try again.");
      } else {
        await player.play(AssetSource('audio/invalid_qr_code.mp3'));
        TmsToast.msg("Box number $boxNumber not found. Please try again.");
      }
    }
    boxScanController.clear();
  }

  RxInt pendingDocketCount() {
    RxInt scanCount = 0.obs;
    for (var data in docket) {
      if (data.isFullScan.isFalse) {
        scanCount++;
      }
    }

    return scanCount;
  }

  RxInt pendingBoxScanCount() {
    RxInt boxCount = 0.obs;

    for (var docketData in docket) {
      bool isAnyScanned = docketData.docketBcSerials.any((bcData) => bcData.isScan.isTrue);
      if (isAnyScanned) {
        for (var bcData in docketData.docketBcSerials) {
          if (bcData.isScan.isFalse) {
            boxCount++;
          }
        }
      }
    }

    return boxCount;
  }

  RxInt completedDocketCount() {
    RxInt scanCount = 0.obs;
    for (var data in docket) {
      if (data.isFullScan.isTrue) {
        scanCount++;
      }
    }

    return scanCount;
  }

  RxInt docketScanCount() {
    RxInt docketCount = 0.obs;

    for (var docketData in docket) {
      bool isAnyScanned = docketData.docketBcSerials.any((bcData) => bcData.isScan.isTrue);
      if (isAnyScanned) {
        docketCount++;
      }
    }

    return docketCount;
  }

  RxInt docketCount() {
    RxInt docketCount = 0.obs;

    for (var docketData in docket) {
      docketCount++;
    }

    return docketCount;
  }

  RxInt completedBoxScanCount() {
    RxInt boxCount = 0.obs;

    for (var docketData in docket) {
      for (var bcData in docketData.docketBcSerials) {
        if (bcData.isScan.isTrue) {
          boxCount++;
        }
      }
    }

    return boxCount;
  }

  RxInt scanDocketBoxCount() {
    RxInt boxCount = 0.obs;

    for (var docketData in docket) {
      bool isAnyScanned = docketData.docketBcSerials.any((bcData) => bcData.isScan.isTrue);
      if (isAnyScanned) {
        for (var bcData in docketData.docketBcSerials) {
          boxCount++;
        }
      }
    }

    return boxCount;
  }

  RxInt damageScanCount() {
    RxInt boxCount = 0.obs;

    for (var docketData in docket) {
      for (var bcData in docketData.docketBcSerials) {
        if (bcData.isDamage.isTrue) {
          boxCount++;
        }
      }
    }

    return boxCount;
  }

  RxInt bcSellScanCount(List<DocketBcSerialList> docketBcSerials) {
    RxInt scanCount = 0.obs;
    for (var data in docketBcSerials) {
      if (data.isScan.isTrue) {
        scanCount.value++;
      }
    }
    return scanCount;
  }

  StockUpdateDetails inWardSubmitRequest() {
    List<StockUpdateDetail> stockUpdateDetails = [];
    List<BsSerial> bsSerials = [];
    List<AgeFileName> damageFileName = [];

    int scanCount = 0;
    int damageCount = 0;
    int shortCount = 0;
    String mf = '';
    String docksf = '';

    for (var docketList in docket) {
      damageCount = 0;
      shortCount = 0;
      scanCount = 0;
      damageFileName = [];
      for (var data in docketList.docketBcSerials) {
        if (data.isScan.isTrue) {
          scanCount++;
          mf = data.mf;
          docksf = data.docksf;
          if (data.isDamage.isTrue) {
            damageCount++;
            for (var image in data.damageImages) {
              damageFileName.add(AgeFileName(image: image, mf: mf));
            }
          }
          bsSerials.add(
            BsSerial(
              docksf: data.docksf,
              dockno: data.dockno,
              bcSerialNo: data.bcSerialNo,
              mf: data.mf,
              thc: data.thc,
            ),
          );
        } else {
          shortCount++;
        }
      }
      bool isAnyScanned = docketList.docketBcSerials.any((bcData) => bcData.isScan.isTrue);
// int index = docketList.
      if (isAnyScanned) {
        stockUpdateDetails.add(StockUpdateDetail(
            tcno: mf,
            dockNo: docketList.dockNo,
            dockSf: docksf,
            bkGPkgsno: scanCount,
            pkgsno: docketList.bkGPKGSNO.toInt(),
            bkGActuwt: docketList.bkGACTUWT.toInt(),
            actuwt: docketList.bkGACTUWT.toInt(),
            ac: selectWareHouse.value,
            wi: selectWareHouse.value,
            cdelydt: "",
            delyreason: "",
            dp: selectDeliveryType.value,
            coddodAmount: 0,
            coddodcollected: 0,
            coddod: "",
            isCounterDelivery: false,
            shortageQty: shortCount,
            shortageWeight: 0,
            shortageReason: '',
            shortageRemarks: '',
            pilferageQty: 0,
            pilferageWeight: 0,
            pilferageReason: "",
            pilferageRemarks: "",
            damageQry: damageCount,
            damageWeight: 0,
            damageReason: "",
            isMisroute: "",
            boxIds: [],
            destCD: '',
            misrtDockno: '',
            misrtpkg: 0,
            orgncd: '',
            pkgs: 0,
            damageRemarks: "",
            isCoddodChar: "",
            severity: '',
            damageType: '',
            isCODDODChar: '',
            delyperson: "",
            pilferageFileName: [],
            damageFileName: damageCount == 0 ? [] : damageFileName));
      }
    }

    return StockUpdateDetails(
        updateDate: DateFormat('d MMMM yyyy').format(DateTime.now()),
        baseUserName: Pref().getUserName(),
        baseLocationCode: Pref().getBaseLocation(),
        stockUpdateDetails: stockUpdateDetails,
        bsSerials: bsSerials);
  }

  inWardSubmit() async {
    stockUpdateDetailsToJson(inWardSubmitRequest());
    AppLoader().show();
    final response = await WebService.tmsPostTokenRequest(
      url: ApiService.stockUpdateDetails,
      body: stockUpdateDetailsToJson(inWardSubmitRequest()),
    );
    AppLoader().hide();
    try {
      if (response.statusCode == 200) {
        TmsToast.msg("Stock update successful!");
        submitAlertDialog(
          context: Get.context!,
          title: 'Success',
          onTap: () {
            Get.toNamed(AppRoutes.inWardScreen);
            inWardListApi();
          },
          onTapText: 'Done',
          image: 'assets/images/dashboardimages/succes.png',
        );
      } else {
        TmsToast.msg("Failed to update stock. Please try again.");
      }
    } catch (error) {
      TmsToast.msg("An error occurred. Please check your internet connection.");
    }
  }
}
