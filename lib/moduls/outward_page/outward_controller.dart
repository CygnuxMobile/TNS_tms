import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../model/outward_model/bc_number.dart';
import '../../moduls/docket_page/docket_controller.dart';
import '../../moduls/outward_page/widget/pending_barcode_dialog.dart';
import '../../utils/pref.dart';
import '../../utils/tmsapp_api.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/tost.dart';
import '../../app_routes.dart';
import '../../model/outward_model/outward_list.dart';
import '../../model/outward_model/outward_submit.dart';
import '../../utils/tmsapi_method.dart';
import 'package:get/get.dart';

enum ScanManually { scan, manually }

class OutWardController extends GetxController {
  int flag = 0;

  TextEditingController boxScanController = TextEditingController();
  final player = AudioPlayer();

  RxList<OutWardListObject> outWardList = <OutWardListObject>[].obs;
  RxList<DocketNumberObject> docketNumberList = <DocketNumberObject>[].obs;

  Rx<DataStatus> outWardDataStatus = DataStatus.loading.obs;
  Rx<DataStatus> bcNumberDataStatus = DataStatus.loading.obs;
  Rx<ScanManually> scanManuallyStatus = ScanManually.scan.obs;

  String lsNumber = '';

  FocusNode scanFocusNode = FocusNode();

  RxInt totalBoxCount() {
    RxInt boxCount = 0.obs;

    for (var data in docketNumberList) {
      for (var bcData in data.docketBcSerials) {
        if (bcData.isBcNumberScan.isFalse) {
          boxCount++;
        }
      }
    }

    return boxCount;
  }

  RxInt totalDocketCount() {
    RxInt scanCount = 0.obs;
    for (var data in docketNumberList) {
      if (data.isChecked.isFalse) {
        scanCount++;
      }
    }

    return scanCount;
  }

  RxInt totalBoxScanCount() {
    RxInt boxCount = 0.obs;

    for (var data in docketNumberList) {
      for (var bcData in data.docketBcSerials) {
        if (bcData.isBcNumberScan.isTrue) {
          boxCount++;
        }
      }
    }

    return boxCount;
  }

  RxInt totalDocketScanCount() {
    RxInt scanCount = 0.obs;

    for (var data in docketNumberList) {
      if (data.isChecked.isTrue) {
        scanCount++;
      }
    }

    return scanCount;
  }

  RxInt bcSellScanCount(List<DocketBcSerial> docketBcSerials) {
    RxInt scanCount = 0.obs;
    for (var data in docketBcSerials) {
      if (data.isBcNumberScan.isTrue) {
        scanCount.value++;
      }
    }
    return scanCount;
  }

  boxNumberOnChange(String bcNumber) async {
    bool isMatched = false;
    bool isDocketNumber = true;

    if (bcNumber.contains('-')) {
      isDocketNumber = false;
    }

    if (isDocketNumber) {
      for (var data in docketNumberList) {
        if(data.dockno == bcNumber) {
          bool allChecked = data.docketBcSerials.every((serial) => serial.isBcNumberScan.value);

          if (allChecked) {
            data.isChecked.value = true;
            await player.play(AssetSource('audio/already_scan_package.mp3'));
            TmsToast.msg("Docket number $bcNumber is already scanned!");
          }


          if (data.dockno == bcNumber) {
            for (var bcNumber in data.docketBcSerials) {
              bcNumber.isBcNumberScan.value = true;
              isMatched = true;
            }

            if (data.docketBcSerials.every((serial) => serial.isBcNumberScan.value)) {
              data.isChecked.value = true;
            }

            await player.play(AssetSource('audio/scaning_done.mp3'));
            TmsToast.msg("Docket number $bcNumber scanned successfully!");
          }
        }
      }
    } else {
      for (var data in docketNumberList) {
        bool allChecked = data.docketBcSerials.every((serial) => serial.isBcNumberScan.value);
        if (allChecked) {
          data.isChecked.value = true;
        } else {
          for (var bcListData in data.docketBcSerials) {
            if (bcListData.bcSerialNo == bcNumber) {
              if (bcListData.isBcNumberScan.value) {
                await player.play(AssetSource('audio/already_scan_package.mp3'));
                TmsToast.msg("Box number $bcNumber is already scanned!");
                isMatched = true;
              } else {
                bcListData.isBcNumberScan.value = true;
                data.docketBcSerials[0].lastScan.value = bcListData.bcSerialNo;
                isMatched = true;

                if (data.docketBcSerials.every((serial) => serial.isBcNumberScan.value)) {
                  data.isChecked.value = true;
                }

                await player.play(AssetSource('audio/scaning_done.mp3'));
                TmsToast.msg("Box number $bcNumber scanned successfully!");
              }
              break;
            }
          }
        }

        if (isMatched) break;
      }
    }

    if (!isMatched) {
      if(isDocketNumber){
        await player.play(AssetSource('audio/invalid_qr_code.mp3'));
        TmsToast.msg("Docket number $bcNumber not found. Please try again.");
      }else{
        await player.play(AssetSource('audio/invalid_qr_code.mp3'));
        TmsToast.msg("Box number $bcNumber not found. Please try again.");
      }

    }

    boxScanController.clear();
  }

  outWardListApi() async {
    outWardDataStatus.value = DataStatus.loading;

    final requestBody = {
      "brcd": "${Pref().getBaseLocation()}",
    };

    try {
      final response = await WebService.tmsPostTokenRequest(
        url: ApiService.outWardListAPI,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.data);
        if (responseData["status"] == 200) {
          OutWardList outWardListResponse = outWardListFromJson(response.data);
          outWardList.value = outWardListResponse.outWardList;
          outWardDataStatus.value = DataStatus.completed;
        } else if (responseData["status"] == 404) {
          outWardDataStatus.value = DataStatus.error;
          print("No record found: ${responseData["message"]}");
        } else {
          outWardDataStatus.value = DataStatus.error;
          print("Unexpected status: ${responseData["status"]}");
        }
      } else {
        outWardDataStatus.value = DataStatus.error;
        print("Unexpected HTTP status code: ${response.statusCode}");
      }
    } catch (error) {
      outWardDataStatus.value = DataStatus.error;
      print("An error occurred: $error");
    }
  }

  bcNumberListApi({required String lsNo}) async {
    lsNumber = lsNo;
    bcNumberDataStatus.value = DataStatus.loading;

    final requestBody = {
      "lsno": "$lsNo",
    };

    try {
      final response = await WebService.tmsPostTokenRequest(
        url: ApiService.bcListAPI,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.data);
        if (responseData["status"] == 200) {
          BcNumberList bcNumberList = bcNumberListFromJson(response.data);
          docketNumberList.value = bcNumberList.docketNumberList;
          bcNumberDataStatus.value = DataStatus.completed;
        } else if (responseData["status"] == 404) {
          bcNumberDataStatus.value = DataStatus.error;
          print("No record found: ${responseData["message"]}");
        } else {
          bcNumberDataStatus.value = DataStatus.error;
          print("Unexpected status: ${responseData["status"]}");
        }
      } else {
        bcNumberDataStatus.value = DataStatus.error;
        print("Unexpected HTTP status code: ${response.statusCode}");
      }
    } catch (error) {
      bcNumberDataStatus.value = DataStatus.error;
      print("An error occurred: $error");
    }
  }

  OutWardSubmit outWardSubmitRequest() {
    List<DocketManifest> docketManifests = [];
    List<Serial> serials = [];
    for (var data in docketNumberList) {
      RxBool anyScan = data.docketBcSerials.any((serial) => serial.isBcNumberScan.value).obs;

      docketManifests.add(DocketManifest(
        actuwt: data.actuwt,
        docketDate: data.docketDate,
        dockno: data.dockno,
        docksf: data.docksf,
        newRate: 0,
        orgCode: data.orgCode,
        packagesLb: data.packagesLb,
        pkgsno: data.pkgsno,
        ratetype: "",
        reDestCode: data.reDestCode,
        weightLb: data.weightLb,
      ));
      if (anyScan.isTrue) {
        for (var bcData in data.docketBcSerials) {
          if (bcData.isBcNumberScan.isTrue) {
            serials.add(Serial(
              bcserialNo: bcData.bcSerialNo,
              docksf: bcData.docksf,
            ));
          }
        }
      }
    }

    OutWardSubmit outWardSubmit = OutWardSubmit(
        nextloc: docketNumberList[0].reDestCode,
        baseUserName: Pref().getUserName(),
        mFTransportMode: 'S',
        vehno: "",
        vehicleType: "O",
        lsDate: '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString().replaceFirst(' ', 'T')}Z',
        baseLocationCode: Pref().getBaseLocation(),
        baseFinYear: Pref().getFinYear().substring(0, 4),
        baseCompanyCode: Pref().getCompanyCode(),
        flag: 0,
        docketManifests: docketManifests,
        serials: serials,
        type: "MF",
        lsNO:  lsNumber,
    );

    return outWardSubmit;
  }

  outWardSubmit() async {
    AppLoader().show();
    final response = await WebService.tmsPostTokenRequest(
      url: ApiService.prepareManifest,
      body: outWardSubmitToJson(outWardSubmitRequest()),
    );
    AppLoader().hide();

    try {
      if (response.statusCode == 200) {
        print("Response data: ${response.data}");

        Map<String, dynamic> jsonResponse = jsonDecode(response.data);

        String manifestNumber = jsonResponse['data'];

        print("Manifest Number: $manifestNumber");

        showSuccessDialog(
          context: Get.context!,
          ManifestNo: manifestNumber,
          onConfirm: () {
            Get.back();
            outWardListApi();
          },
        );

        TmsToast.msg("Submission successful!");
      } else {
        TmsToast.msg("Failed to submit. Please try again.");
      }
    } catch (error) {
      TmsToast.msg("An unexpected error occurred. Please try again later.");
    }
  }
}
