import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../moduls/quick_docket_page/quick_docket_screen.dart';
import '../../moduls/quick_docket_page/widget/pincode_search.dart';

import '../../app_routes.dart';
import '../../model/dash_board_model/location_master.dart';
import '../../model/quick_docket_model/billing_response.dart';
import '../../model/quick_docket_model/check_valid_docket_no_response.dart';
import '../../model/quick_docket_model/city_response.dart';
import '../../model/quick_docket_model/consignnor_consignee_model.dart';
import '../../model/quick_docket_model/custList_response.dart';
import '../../model/quick_docket_model/eway_bill_response.dart';
import '../../model/quick_docket_model/getEwayBillState.dart';
import '../../model/quick_docket_model/packageType.dart';
import '../../model/quick_docket_model/picode.dart';
import '../../model/quick_docket_model/product.dart';
import '../../model/quick_docket_model/quick_docket_submit_models/quick_docket_request.dart';
import '../../model/quick_docket_model/quick_docket_submit_models/quick_docket_response.dart';
import '../../model/quick_docket_model/vehicle_response.dart';
import '../../utils/date_format.dart';
import '../../utils/logging.dart';
import '../../utils/pref.dart';
import '../../utils/tmsapi_method.dart';
import '../../utils/tmsapp_api.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/submit_alert_dialog.dart';
import '../../widgets/tost.dart';
import '../docket_page/docket_controller.dart';

enum eWayBillScan { none, first, multiple }

enum docketCheck { none, right, wrong }

class QuickDocketController extends GetxController {
  final log = logger;

  List GeneralMasterTypeList = ["PAYTYP", "TRN"];

  RxList<BillingTypeList> payBasList = <BillingTypeList>[].obs;
  RxList<BillingTypeList> transportModelList = <BillingTypeList>[].obs;
  Rx<eWayBill> eWayBillStatus = eWayBill.withoutEWayBill.obs;

  // RxList<TransitMode> transitModeList = <TransitMode>[].obs;
  RxList<CustList> customerList = <CustList>[].obs;
  RxList<LocationList> location = <LocationList>[].obs;
  RxList<pinCodeObject> pinCodeList = <pinCodeObject>[].obs;
  RxList<ProductObject> productList = <ProductObject>[].obs;
  RxList<PackageTypeObject> packageTypeList = <PackageTypeObject>[].obs;
  RxList<ConCosDatum> consignorList = <ConCosDatum>[].obs;
  RxList<ConCosDatum> consigneeList = <ConCosDatum>[].obs;
  RxList<VehicleDatum> vehicleList = <VehicleDatum>[].obs;
  RxList<pinCodeObject> fromPinCodeList = <pinCodeObject>[].obs;
  RxList<pinCodeObject> toPinCodeList = <pinCodeObject>[].obs;

  TextEditingController noOfPackageController = TextEditingController();
  TextEditingController actualWeightController = TextEditingController();
  TextEditingController invoiceNoController = TextEditingController();
  TextEditingController odaCategoryController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  TextEditingController docketNoController = TextEditingController();
  TextEditingController eWayBillNoController = TextEditingController();
  TextEditingController declaredValueController = TextEditingController();
  TextEditingController valueMetricController = TextEditingController();
  TextEditingController toCityController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController breadthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController toPinCodeController = TextEditingController();
  Rx<TextEditingController> vehicleNoController = TextEditingController().obs;
  AppLoader appLoader = AppLoader();

  FocusNode noOfPackage = FocusNode();
  FocusNode actualWeight = FocusNode();
  FocusNode invoiceNumber = FocusNode();
  FocusNode destination = FocusNode();
  FocusNode odaCategory = FocusNode();
  FocusNode docketNumber = FocusNode();
  FocusNode docketFocus = FocusNode();
  FocusNode eWayBillNo = FocusNode();
  FocusNode declaredValue = FocusNode();
  FocusNode valueMetric = FocusNode();
  FocusNode noOfPKG = FocusNode();
  FocusNode length = FocusNode();
  FocusNode breadth = FocusNode();
  FocusNode height = FocusNode();

  Rx<DataStatus> payBaseDataStatus = DataStatus.loading.obs;
  Rx<DataStatus> locationDataStatus = DataStatus.loading.obs;
  Rx<DataStatus> transportModelDataStatus = DataStatus.loading.obs;
  Rx<PinCodeDataStatus> pinCodeDataStatus = PinCodeDataStatus.none.obs;
  Rx<DataStatus> productDataStatus = DataStatus.loading.obs;
  Rx<docketCheck> docketCheckDataStatus = docketCheck.none.obs;
  Rx<DataStatus> packageTypeDataStatus = DataStatus.loading.obs;
  Rx<eWayBillScan> eWayBillScanStatus = eWayBillScan.none.obs;
  Rx<DataStatus> fromPinCodeDataStatus = DataStatus.completed.obs;
  Rx<DataStatus> toPinCodeDataStatus = DataStatus.completed.obs;
  Rx<DataStatus> toCityDataStatus = DataStatus.completed.obs;

  RxList<XFile> selectedImages = <XFile>[].obs;
  List<String> base64Images = [];
  List<City> cityList = [];
  List<City> toCityList = [];
  RxList<DocketInvoiceList> docketInvoiceList = <DocketInvoiceList>[].obs;
  RxList<GetEwayBillStateDatum> eWayBillStateList = <GetEwayBillStateDatum>[].obs;

  RxString checkBillPartyContract = "".obs;
  late EwayBillResponse eWayBillResponse;

  void onInit() {
    billingTypeApi();
    transportModelApi();
    packageTypeApi();
    productApi();
    fromCityApi();
    getEWayBillStateApi();
    consignorApi();
    consigneeApi();
    vehicleApi();
    locationMasterDataApi();
    super.onInit();
  }

  String originLocation = Pref().getBranchCode() == 'HQTR' ? Pref().getBaseLocation() : Pref().getBranchCode();
  RxString billingType = 'Select Paybase Type'.obs;
  RxString billingId = ''.obs;
  String consignorId = '';
  RxString consignorName = 'Select Billing Party'.obs;
  RxString selectTransportModel = 'Select Transport Model'.obs;
  RxString selectConsignor = 'Select Consignor'.obs;
  RxString selectConsignee = 'Select Consignee'.obs;
  RxString selectFromPinCode = 'Select From Pincode'.obs;
  RxString selectVehicleNumber = ''.obs;
  RxString selectTransportId = ''.obs;

  // RxString pinCode = 'Select Pincode'.obs;
  RxString selectedValue = "OWN".obs;
  RxString selectedTBBValue = "Consignor".obs;
  RxString selectConsignorId = ''.obs;
  RxString selectConsigneeId = ''.obs;
  RxString selectGetNO = ''.obs;
  RxString selectEWayBillState = ''.obs;
  String docketNm = "";
  String fromCity = "";
  String selectProduct = "";
  String selectPackage = "";
  String csgncd = '';
  String csgnm = '';
  String csgnAdd = '';
  String csgecd = '';
  String csgenm = '';
  String csgeAdd = '';
  String fromCityId = '';
  String destinationId = '';
  String toCityId = '';
  String toPinCode = '';
  String eWayBillExpiredDate = '';
  String eWayBillInvoiceDate = '';
  dynamic area;

  bool isProcessing = false;

  RxBool isEWayNumber = true.obs;
  RxBool isDeclared = true.obs;
  RxBool isInvoice = true.obs;
  RxBool isNumberOfPkg = true.obs;
  RxBool isActualWeight = true.obs;
  RxBool isPackage = true.obs;
  RxBool isProduct = true.obs;
  RxBool isHeight = true.obs;
  RxBool isBreadth = true.obs;
  RxBool isLength = true.obs;
  RxBool isEWBEmpty = true.obs;
  RxBool isConsignee = false.obs;
  RxBool isConsignor = false.obs;

  RxBool isValueMetrics = false.obs;

  textFocus() {
    noOfPackage.unfocus();
    actualWeight.unfocus();
    invoiceNumber.unfocus();
    eWayBillNo.unfocus();
    docketFocus.unfocus();
    height.unfocus();
    breadth.unfocus();
    length.unfocus();
    eWayBillNo.unfocus();
    noOfPKG.unfocus();
    declaredValue.unfocus();
  }

  ctrlClear() {
    noOfPackageController.clear();
    actualWeightController.clear();
    invoiceNoController.clear();
    docketNoController.clear();
    eWayBillNoController.clear();
    destinationController.clear();
    toCityController.clear();
    odaCategoryController.clear();
    docketInvoiceList.clear();
    base64Images.clear();
    selectedImages.clear();
    lengthController.clear();
    toPinCodeController.clear();
    breadthController.clear();
    heightController.clear();
    declaredValueController.clear();
    consignorName = 'Select Billing Party'.obs;
    fromCity = 'Select From City';
    selectConsignor.value = 'Select Consignor';
    selectConsignee.value = 'Select Consignee';
    consignorId = '';
    destinationId = '';
    toCityId = '';
    eWayBillExpiredDate = '';
    selectVehicleNumber.value = '';
    selectProduct = "";
    docketNm = "";
    selectPackage = "";
    selectedValue.value = "OWN";
    isEWBEmpty.value = true;
    isEWayNumber.value = true;
    isDeclared.value = true;
    isInvoice.value = true;
    isNumberOfPkg.value = true;
    isActualWeight.value = true;
    isPackage.value = true;
    isProduct.value = true;
    isHeight.value = true;
    isBreadth.value = true;
    isLength.value = true;
    isEWBEmpty.value = true;
    vehicleNoController.value.clear();
  }

  Future<void> fromCityApi() async {
    String url = "${ApiService.baseUrl}V1/Master/GetFromToCity?type=${Pref().getBaseLocation()}";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "From City Api ${response.statusMessage}");
        CityResponse cityResponse = cityResponseFromJson(response.data);
        cityList = cityResponse.cityList;
      } else {
        log.e(jsonDecode(response.data), error: "From City Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      log.e(error, error: "From City Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> toCityApi(toCity) async {
    toCityDataStatus.value = DataStatus.loading;
    String url = "${ApiService.baseUrl}V1/Master/GetFromToCity?type=$toCity";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "From City Api ${response.statusMessage}");
        CityResponse cityResponse = cityResponseFromJson(response.data);
        toCityList = cityResponse.cityList;
        toCityDataStatus.value = DataStatus.completed;
      } else {
        log.e(jsonDecode(response.data), error: "From City Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      toCityDataStatus.value = DataStatus.error;
      log.e(error, error: "From City Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> getEWayBillStateApi() async {
    try {
      final response = await WebService.tmsGetRequest(ApiService.GetEwayBillState);

      GetEwayBillState eWayBillState = getEwayBillStateFromJson(response.data);
      if (response.statusCode == 200) {
        eWayBillStateList.value = eWayBillState.data;
      } else {
        log.e(jsonDecode(response.data), error: "EWayBill State Api ${response.statusMessage}");
      }
    } catch (error) {
      log.e(error, error: "EWayBill State Api Error");
    }
  }

  Future<void> consignorApi() async {
    String url = "${ApiService.baseUrl}V1/Master/GetConsignerconsignee?type=CSGN";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Consignor Api ${response.statusMessage}");

        ConsigneeConsignor consigneeConsignor = consigneeConsignorFromJson(response.data);
        consignorList.value = consigneeConsignor.data;
      } else {
        log.e(jsonDecode(response.data), error: "Consignor Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      log.e(error, error: "Consignor Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> consigneeApi() async {
    String url = "${ApiService.baseUrl}V1/Master/GetConsignerconsignee?type=CSGE";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Consignee Api ${response.statusMessage}");

        ConsigneeConsignor consigneeConsignor = consigneeConsignorFromJson(response.data);
        consigneeList.value = consigneeConsignor.data;
      } else {
        log.e(jsonDecode(response.data), error: "Consignee Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      log.e(error, error: "Consignee Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> vehicleApi() async {
    String url = "${ApiService.baseUrl}V1/Master/GetVehicle";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Vehicle Api ${response.statusMessage}");

        Vehicle vehicle = vehicleFromJson(response.data);
        vehicleList.value = vehicle.data;
      } else {
        log.e(jsonDecode(response.data), error: "Vehicle Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      log.e(error, error: "Vehicle Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  eWayBillApi({required String eWayNumber,required String stateGst, required bool isQrScan, required isMenuScreen, required BuildContext context}) async {
    if (isQrScan == true) {
      Get.back();
      Get.back();
    }

    AppLoader().show();
    isProcessing = true;
    var data = {
      "lsno": eWayNumber,
      "stateGst": stateGst
    };

    final response = await WebService.tmsPostRequest(
      url: ApiService.eWayBill,
      body: json.encode(data),
    );
    AppLoader().hide();
    var responseData = jsonDecode(response.data);
    try {
      if (response.statusCode == 200) {
        if (responseData['data'] != null) {
          if (responseData['data']['isExpired'] == false) {
            eWayBillResponse = ewayBillResponseFromJson(response.data);
            if (eWayBillResponse.data.status == 1) {
              if (docketInvoiceList.length <= 1) {
                odaCategoryController.text = eWayBillResponse.data.odaCategory;
                destinationController.text = eWayBillResponse.data.destcd;
                toCityController.text = eWayBillResponse.data.toCity;
                csgecd = eWayBillResponse.data.csgecd;
                eWayBillExpiredDate = eWayBillResponse.data.eWayBillExpiredDate;
                eWayBillInvoiceDate = eWayBillResponse.data.eWayBillInvoiceDate;
                csgenm = eWayBillResponse.data.csgenm;
                csgnAdd = eWayBillResponse.data.csgnAdd;
                csgeAdd = eWayBillResponse.data.csgeAdd;
                csgnm = eWayBillResponse.data.csgnm;
                area = eWayBillResponse.data.area;
                csgncd = eWayBillResponse.data.csgncd;
                fromCity = eWayBillResponse.data.fromCity;
                toPinCodeController.text = eWayBillResponse.data.toPincode.toString();
                isValueMetrics.value = eWayBillResponse.data.volYn == "Y" ? true : false;
                isEWayNumber.value = false;
                isEWBEmpty.value = true;
                isInvoice.value = false;
                isDeclared.value = false;
                isNumberOfPkg.value = true;
                isActualWeight.value = true;
                isPackage.value = true;
                isProduct.value = true;
                isHeight.value = true;
                isBreadth.value = true;
                isLength.value = true;
                isEWBEmpty.value = true;
                for (var data in payBasList) {
                  if (data.codeId == eWayBillResponse.data.paybas) {
                    billingType.value = data.codeDesc;
                  }
                }
                billingId.value = eWayBillResponse.data.paybas;
                for (var data in transportModelList) {
                  if (data.codeId == eWayBillResponse.data.transMode) {
                    selectTransportModel.value = data.codeDesc;
                    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${selectTransportModel.value}");
                  }
                }
                selectTransportId.value = eWayBillResponse.data.transMode;
                consignorName.value = eWayBillResponse.data.partyName.isEmpty ? consignorName.value : eWayBillResponse.data.partyName;
                consignorId = eWayBillResponse.data.partyCode.isEmpty ? consignorId : eWayBillResponse.data.partyCode;
                print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${consignorId}");
                print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${consignorName.value}");
                // pinCodeController.text = eWayBillResponse.data.toPincode.toString();
                eWayBillNoController.text = eWayBillResponse.data.ewaybillNo;
                invoiceNoController.text = eWayBillResponse.data.invno;
                declaredValueController.text = eWayBillResponse.data.decval.toString();
              } else {
                if (consignorId == eWayBillResponse.data.partyCode) {
                  eWayBillNoController.text = eWayBillResponse.data.ewaybillNo;
                  invoiceNoController.text = eWayBillResponse.data.invno;
                  eWayBillExpiredDate = eWayBillResponse.data.eWayBillExpiredDate;
                  eWayBillInvoiceDate = eWayBillResponse.data.eWayBillInvoiceDate;
                  declaredValueController.text = eWayBillResponse.data.decval.toString();
                  isNumberOfPkg.value = true;
                  isActualWeight.value = true;
                  isPackage.value = true;
                  isProduct.value = true;
                  isHeight.value = true;
                  isBreadth.value = true;
                  isLength.value = true;
                  isEWBEmpty.value = true;
                } else {
                  TmsToast.msg("EWayBill not match");
                }
              }

              if (isMenuScreen == true) {
                Get.toNamed(AppRoutes.quickDocketScreen);
                custListApi(context: context);
              }
              isProcessing = false;
            } else {
              TmsToast.msg("Please enter a valid eWay Bill.");
              isProcessing = false;
              eWayBillNoController.clear();
            }
          } else {
            TmsToast.msg("EWay Bill number has expired. Please enter a valid eWay Bill.");
            isProcessing = false;
            eWayBillNoController.clear();
          }
        } else {
          TmsToast.msg("Please enter a valid eWay Bill.");
          isProcessing = false;
          eWayBillNoController.clear();
        }
      } else {
        TmsToast.msg("Please enter a valid eWay Bill.");
        isProcessing = false;
        eWayBillNoController.clear();
      }
    } catch (error) {
      TmsToast.msg("Please enter a valid eWay Bill.");
      isProcessing = false;
      eWayBillNoController.clear();
    }
  }

  ///Billing Type
  Future<void> billingTypeApi() async {
    payBaseDataStatus.value = DataStatus.loading;
    String url = "${ApiService.baseUrl}V1/Master/GetGeneralMasterData?CodeType=PAYTYP";
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Billing Type Api ${response.statusMessage}");
        BillingTypeResponse billingTypeResponse = billingTypeResponseFromJson(response.data);
        payBasList.value = billingTypeResponse.data;
        payBaseDataStatus.value = DataStatus.completed;
      } else {
        payBaseDataStatus.value = DataStatus.error;
        log.e(jsonDecode(response.data), error: "Billing Type Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      payBaseDataStatus.value = DataStatus.error;
      log.e(error, error: "Billing Type Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> billingPartyCheckApi({required String billingPartyId}) async {
    AppLoader().show();
    String url =
        "${ApiService.baseUrl}V1/Master/CheckValidBillingParty?Search=$billingPartyId&Location=${Pref().getBaseLocation()}&Paybas=$billingType";
    AppLoader().hide();
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);
      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Billing Party check Api ${response.statusMessage}");
        Map<String, dynamic> data = jsonDecode(response.data);
        checkBillPartyContract.value = data["data"]["codeId"];
      } else {
        log.e(jsonDecode(response.data), error: "Billing Party check Api ${response.statusMessage}");
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      log.e(error, error: "Billing Party check Api Error");
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> fromPinCodeApi(code) async {
    fromPinCodeDataStatus.value = DataStatus.loading;
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.GetPinCodeFromCity + code);
      if (response.statusCode == 200) {
        PinCode pinCode = pinCodeFromJson(response.data);
        fromPinCodeList.value = pinCode.pinCodeList;
        fromPinCodeDataStatus.value = DataStatus.completed;
      } else {
        fromPinCodeDataStatus.value = DataStatus.error;
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      fromPinCodeDataStatus.value = DataStatus.error;
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> toPinCodeApi(code) async {
    toPinCodeDataStatus.value = DataStatus.loading;
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.GetPinCodeFromCity + code);
      if (response.statusCode == 200) {
        PinCode pinCode = pinCodeFromJson(response.data);
        toPinCodeList.value = pinCode.pinCodeList;
        toPinCodeDataStatus .value = DataStatus.completed;
      } else {
        toPinCodeDataStatus.value = DataStatus.error;
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      toPinCodeDataStatus.value = DataStatus.error;
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  /// location master data
  Future<void> locationMasterDataApi() async {
    locationDataStatus.value = DataStatus.loading;
    try {
      final dio.Response response = await WebService.tmsGetRequest("${ApiService.getLocationMasterData}?UserID=${Pref().getUserId()}");
      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        GetLocationMasterData getLocationMasterData = getLocationMasterDataFromJson(responseData);
        location.value = getLocationMasterData.data;
        locationDataStatus.value = DataStatus.completed;
      }
    } catch (error) {
      print(error);
      locationDataStatus.value = DataStatus.error;
    }
  }

  Future<void> transportModelApi() async {
    transportModelDataStatus.value = DataStatus.loading;
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.GetTransportModel);
      if (response.statusCode == 200) {
        BillingTypeResponse transportModelResponse = billingTypeResponseFromJson(response.data);
        transportModelList.value = transportModelResponse.data;
        transportModelDataStatus.value = DataStatus.completed;
      } else {
        transportModelDataStatus.value = DataStatus.error;
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      transportModelDataStatus.value = DataStatus.error;
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> pinCodeApi(String value) async {
    pinCodeDataStatus.value = PinCodeDataStatus.loading;
    try {
      final dio.Response response = await WebService.tmsGetRequest('${ApiService.GetPinCode}' + "$value");
      if (response.statusCode == 200) {
        PinCode pinCode = pinCodeFromJson(response.data);
        pinCodeList.value = pinCode.pinCodeList;
        pinCodeDataStatus.value = PinCodeDataStatus.completed;
      } else {
        pinCodeDataStatus.value = PinCodeDataStatus.error;
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      pinCodeDataStatus.value = PinCodeDataStatus.error;
      if (kDebugMode) {
        print(error.toString());
      }
    }
  }

  Future<void> productApi() async {
    productDataStatus.value = DataStatus.loading;
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.GetProduct);
      if (response.statusCode == 200) {
        GetProduct getProduct = getProductFromJson(response.data);
        productList.value = getProduct.productList;
        productDataStatus.value = DataStatus.completed;
      } else {
        productDataStatus.value = DataStatus.error;
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      productDataStatus.value = DataStatus.error;
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> packageTypeApi() async {
    packageTypeDataStatus.value = DataStatus.loading;
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.GetPackageType);
      if (response.statusCode == 200) {
        PackageType packageType = packageTypeFromJson(response.data);
        packageTypeList.value = packageType.packageTypeList;
        packageTypeDataStatus.value = DataStatus.completed;
      } else {
        packageTypeDataStatus.value = DataStatus.error;
        if (kDebugMode) {
          print(response.statusMessage);
        }
      }
    } catch (error) {
      packageTypeDataStatus.value = DataStatus.error;
      if (kDebugMode) {
        print(error.reactive);
      }
    }
  }

  Future<void> custListApi({required BuildContext context}) async {
    appLoader.show();
    String url = "${ApiService.baseUrl}V1/Master/GetCustomerList?Search=%&Location=${Pref().getBaseLocation()}&Paybas=$billingType";
    print(url);
    try {
      final dio.Response response = await WebService.tmsGetRequest(url);

      if (response.statusCode == 200) {
        log.i(jsonDecode(response.data), error: "Customer List Api ${response.statusMessage}");

        CustListResponse custListResponse = custListResponseFromJson(response.data);

        customerList.value = custListResponse.custList;
        appLoader.hide();
      } else {
        customerList.clear();
        log.e(jsonDecode(response.data), error: "Customer List Api ${response.statusMessage}");
        TmsToast.msg('Docket check error ${response.statusMessage}');
        if (kDebugMode) {
          print(response.statusMessage);
        }
        appLoader.hide();
      }
    } catch (error) {
      appLoader.hide();
      customerList.clear();
      log.e(error, error: "Customer List Api Error");
      TmsToast.msg('No Data Found');
    }
  }

  ///Quick Docket
  Future<void> docketCheckApi({
    required BuildContext context,
    required bool isPayBaseType,
    required GlobalKey<FormState> billingTypeFromKey,
    required GlobalKey<FormState> billingPartyFromKey,
    required GlobalKey<FormState> consigneeFromKey,
    required GlobalKey<FormState> consignorFromKey,
    required GlobalKey<FormState> transportModelFromKey,
    required GlobalKey<FormState> invoiceNoFromKey,
    required GlobalKey<FormState> productFromKey,
    required GlobalKey<FormState> packageTypeFromKey,
    required GlobalKey<FormState> lengthNoFromKey,
    required GlobalKey<FormState> breadthNoFromKey,
    required GlobalKey<FormState> heightNoFromKey,
    required GlobalKey<FormState> numberPkgFromKey,
    required GlobalKey<FormState> declaredValueFromKey,
    required GlobalKey<FormState> actualWeightFromKey,
    required GlobalKey<FormState> toPinCodeFromKey,
    required GlobalKey<FormState> fromPinCodeFromKey,
  }) async {
    appLoader.show();
    String addUrl = '?DocketNo=${docketNoController.text}&LocCode=${Pref().getBaseLocation()}&UserId=${Pref().getUserId()}';
    var response = await WebService.tmsPostRequest(
      url: ApiService.checkValidDocketNo + addUrl,
      body: '',
    );
    appLoader.hide();
    var decodedResponse = jsonDecode(response.data);
    if (decodedResponse["data"]["codeDesc"] != null) {
      String message = decodedResponse["data"]["codeDesc"];
      TmsToast.msg("$message");
    }

    try {
      if (response.statusCode == 200) {
        CheckValidDocketNoResponse checkValidDocketNoResponse = checkValidDocketNoResponseFromJson(response.data);

        if (checkValidDocketNoResponse.status == 200) {
          if (checkValidDocketNoResponse.data.codeId == '1') {
            if (isPayBaseType == false) {
              docketCheckDataStatus.value = docketCheck.right;
              TmsToast.msg("${docketNoController.text} is a valid docket number");
              submitValidator(
                billingTypeFromKey: billingTypeFromKey,
                billingPartyFromKey: billingPartyFromKey,
                transportModelFromKey: transportModelFromKey,
                invoiceNoFromKey: invoiceNoFromKey,
                productFromKey: productFromKey,
                packageTypeFromKey: packageTypeFromKey,
                lengthNoFromKey: lengthNoFromKey,
                breadthNoFromKey: breadthNoFromKey,
                heightNoFromKey: heightNoFromKey,
                numberPkgFromKey: numberPkgFromKey,
                declaredValueFromKey: declaredValueFromKey,
                actualWeightFromKey: actualWeightFromKey,
                toPinCodeFromKey: toPinCodeFromKey,
                consigneeFromKey: consigneeFromKey,
                consignorFromKey: consignorFromKey,
                fromPinCodeFromKey: fromPinCodeFromKey,
              );
            }
            if (isPayBaseType == true) {
              docketCheckDataStatus.value = docketCheck.right;
              TmsToast.msg("${docketNoController.text} is a valid docket number");
            }
            log.i(jsonDecode(response.data), error: "Docket Check Api ${checkValidDocketNoResponse.message}");
          } else {
            docketCheckDataStatus.value = docketCheck.wrong;
            log.e(jsonDecode(response.data), error: "Docket Check Api ${checkValidDocketNoResponse.message}");
            TmsToast.msg("${docketNoController.text} is a valid docket number");
            docketNoController.clear();
          }
        } else {
          docketCheckDataStatus.value = docketCheck.wrong;
          docketNoController.clear();
        }
      } else {
        docketCheckDataStatus.value = docketCheck.wrong;
        docketNoController.clear();
      }
    } catch (error) {
      docketCheckDataStatus.value = docketCheck.wrong;
      appLoader.hide();
      docketNoController.clear();
    }
  }

  Future<String> getLocationCode(String value) async {
    String locationName = value;
    String locationCode = locationName.split("-")[0].replaceAll(" ", '');
    return locationCode;
  }

  /// Billing Type
  billingSelectType(String value) {
    for (var data in payBasList) {
      if (data.codeDesc == value) {
        billingType.value = data.codeId;
        print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<${billingType}");
      }
    }
  }

  /// Consignor Name
  consignorSelectName(String value) {
    consignorName.value = value;
    consignorId = customerList.where((innerValue) => innerValue.custnm.contains(value)).first.custcd;
  }

  parseInputToDouble(String input) {
    if (input.isEmpty) {
      return 0.0;
    }
    return double.tryParse(input) ?? 0.0;
  }

  parseInputToInt(String input) {
    if (input.isEmpty) {
      return 0;
    }
    return int.tryParse(input) ?? 0;
  }

  ///Quick Docket Submit Request
  quickDocketApiRequest() {
    QuickDocketSubmit quickDocketSubmitRequest = QuickDocketSubmit(
      dockdt: DateAndTimeFormat().dayMonthYear,
      partYCode: consignorId,
      partyName: consignorName.value,
      orgncd: Pref().getBaseLocation(),
      destcd: destinationId,
      paybas: billingType.value,
      currFinYear: Pref().getFinYear(),
      baseCompanyCode: Pref().getCompanyCode(),
      toCity: toCityId,
      transPortModel: selectTransportId.value,
      dockno: docketNoController.text,
      pincode: selectFromPinCode.value,
      baseUserName: Pref().getUserId(),
      imageUpload: base64Images.isNotEmpty && base64Images[0].isNotEmpty ? base64Images[0] : "",
      imageUpload1: base64Images.isNotEmpty && base64Images[1].isNotEmpty ? base64Images[1] : "",
      imageUpload2: base64Images.isNotEmpty && base64Images[2].isNotEmpty ? base64Images[2] : "",
      volYn: isValueMetrics.isTrue ? "Y" : "N",
      csgeAdd: csgeAdd,
      csgecd: selectConsigneeId.value,
      csgenm: selectConsignee.value,
      csgnAdd: csgnAdd,
      csgncd: selectConsignorId.value,
      csgnm: selectConsignor.value,
      fromCity: fromCity,
      toPincode: toPinCode,
      vehicleno: selectedValue.value == "OWN"
          ? selectVehicleNumber.value
          : vehicleNoController.value.text.isEmpty
              ? ''
              : vehicleNoController.value.text,
      vehicleType: selectedValue.value,
      docketInvoiceList: docketInvoiceList,
    );
    return quickDocketSubmitRequest;
  }

  ///Quick Docket
  Future<void> quickDocketSubmitApi({required BuildContext context}) async {
    quickDocketSubmitToJson(quickDocketApiRequest());
    appLoader.show();
    var response = await WebService.tmsPostRequest(
      url: ApiService.quickDocketAPI,
      body: quickDocketSubmitToJson(quickDocketApiRequest()),
    );
    appLoader.hide();
    try {
      if (response.statusCode == 200) {
        QuickDocketSubmitResponse quickDocketSubmitResponse = quickDocketSubmitResponseFromJson(response.data);
        if (quickDocketSubmitResponse.status == 200) {
          log.i(jsonDecode(response.data), error: "Quick Docket Submit Api ${quickDocketSubmitResponse.message}");
          docketNm = quickDocketSubmitResponse.data.docketno;
          ctrlClear();
          submitAlertDialog(
            context: context,
            // isPrintShow: true,
            title: '${quickDocketSubmitResponse.data.docketno}\nDocket number create successfully',
            onTap: () {
              Get.toNamed(AppRoutes.dashboardScreen);
              ctrlClear();
            },
            // printerTap: () {
            //   Get.back();
            //   // Get.toNamed(AppRoutes.docketDetails, arguments: quickDocketSubmitResponse.data.docketno);
            // },
            onTapText: 'Done',
            image: 'assets/images/dashboardimages/succes.png',
          );
        } else {
          log.e(jsonDecode(response.data), error: "Quick Docket Submit Api ${quickDocketSubmitResponse.message}");
          var data = jsonDecode(response.data);
          TmsToast.msg(data["message"]);
        }
      } else {
        var data = jsonDecode(response.data);
        TmsToast.msg(data["message"]);
      }
    } catch (error) {
      var data = jsonDecode(response.data);
      TmsToast.msg(data["message"]);
    }
  }

  submitValidator({
    required GlobalKey<FormState> billingTypeFromKey,
    required GlobalKey<FormState> billingPartyFromKey,
    required GlobalKey<FormState> transportModelFromKey,
    required GlobalKey<FormState> invoiceNoFromKey,
    required GlobalKey<FormState> productFromKey,
    required GlobalKey<FormState> packageTypeFromKey,
    required GlobalKey<FormState> lengthNoFromKey,
    required GlobalKey<FormState> breadthNoFromKey,
    required GlobalKey<FormState> heightNoFromKey,
    required GlobalKey<FormState> numberPkgFromKey,
    required GlobalKey<FormState> declaredValueFromKey,
    required GlobalKey<FormState> actualWeightFromKey,
    required GlobalKey<FormState> consignorFromKey,
    required GlobalKey<FormState> consigneeFromKey,
    required GlobalKey<FormState> toPinCodeFromKey,
    required GlobalKey<FormState> fromPinCodeFromKey,
  }) {
    if (billingTypeFromKey.currentState!.validate() &&
        billingPartyFromKey.currentState!.validate() &&
        toPinCodeFromKey.currentState!.validate() &&
        invoiceNoFromKey.currentState!.validate() &&
        productFromKey.currentState!.validate() &&
        packageTypeFromKey.currentState!.validate() &&
        (isValueMetrics.isTrue
            ? (lengthNoFromKey.currentState!.validate() && breadthNoFromKey.currentState!.validate() && heightNoFromKey.currentState!.validate())
            : true) &&
        numberPkgFromKey.currentState!.validate() &&
        declaredValueFromKey.currentState!.validate() &&
        actualWeightFromKey.currentState!.validate()) {
      docketInvoiceList.add(DocketInvoiceList(
        invno: invoiceNoController.text,
        prodcd: selectProduct,
        pkgsty: selectPackage,
        pkgs: parseInputToInt(noOfPackageController.text),
        decval: parseInputToDouble(declaredValueController.text),
        actuwt: parseInputToDouble(actualWeightController.text),
        ewbno: eWayBillNoController.text,
        voLL: parseInputToDouble(lengthController.text),
        voLB: parseInputToDouble(breadthController.text),
        voLH: parseInputToDouble(heightController.text),
        eWayBillExpiredDate: eWayBillExpiredDate,
        eWayBillInvoiceDate: eWayBillInvoiceDate.isNotEmpty ? eWayBillInvoiceDate : "",
      ));
      quickDocketSubmitApi(context: Get.context!);
      isEWayNumber.value = true;
      isDeclared.value = true;
      isInvoice.value = true;
      invoiceNoController.clear();

      noOfPackageController.clear();

      declaredValueController.clear();

      actualWeightController.clear();

      actualWeightController.clear();
      eWayBillNoController.clear();
      breadthController.clear();
      lengthController.clear();
      heightController.clear();
    }
  }
}
