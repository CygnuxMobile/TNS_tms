// ignore_for_file: prefer_interpolation_to_compose_strings
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../model/dash_board_model/location_master.dart';
import '../../model/docket_model/docket.dart';
import '../../model/docket_model/docket_credential.dart';
import '../../model/docket_model/get_BcSerial_details_response/get_bcSerial_details_response.dart';
import '../../model/docket_model/get_BcSerial_details_response/get_bcSerial_details_response.dart';
import '../../utils/tms_color.dart';
import '../../utils/tmsapi_method.dart';
import '../../utils/tmsapp_api.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/tms_button.dart';
import '../../widgets/tost.dart';
import '../home_page/dash_board_controller.dart';

enum DataStatus { loading, completed, error }

enum PrintStatus { none, all, single }

enum PrinterEnum { gcn, quickDocket }

class DocketController extends GetxController {
  DashBoardController ctrl = Get.find<DashBoardController>();
  String docketNumbers = Get.arguments ?? '';
  MethodChannel channel = MethodChannel("tms.com/method");
  Rx<DataStatus> dataStatus = DataStatus.loading.obs;
  TextEditingController docketNumber = TextEditingController();
  TextEditingController formPackageNumber = TextEditingController();
  TextEditingController toPackageNumber = TextEditingController();
  TextEditingController pagesNumber = TextEditingController();
  FocusNode barCodeNode = FocusNode();
  PrintStatus printStatus = PrintStatus.none;
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  late StreamSubscription<BluetoothAdapterState> adapterStateSubscription;
  BluetoothConnection? bluetoothConnection;
  StreamSubscription? scanSubscription;
  bool isConnecting = false;
  RxBool isBarcode = true.obs;
  late StreamSubscription isScanningSubscription = Stream.empty().listen((_) {});
  late AnimationController animationController;
  Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);
  Rx<String> connectedDeviceId = Rx<String>('');
  Rx<bool> isScanning = Rx<bool>(false);
  Rx<bool> isDeviceConnected = Rx<bool>(false);
  Rx<Color> bluetoothIconColor = Rx<Color>(Colors.red);
  Rx<BluetoothDevice?> connectingDevice = Rx<BluetoothDevice?>(null);
  RxSet<BluetoothDevice> scanResults = <BluetoothDevice>{}.obs;
  Rx<FlutterBlueClassic> flutterBlueClassicPlugin = FlutterBlueClassic(usesFineLocation: true).obs;
  StreamSubscription? scanningStateSubscription;

  List<String> prnList = [];
  RxBool IsScan = false.obs;
  RxInt printCount = 0.obs;

  ///DocketDetail List
  RxList<DocketInfo> docketData = <DocketInfo>[].obs;
  RxList<BcSerialDatum> bcSerialDataList = <BcSerialDatum>[].obs;
  final formKey = GlobalKey<FormState>();

  Future<void> onScanPressed() async {
    if (connectedDeviceId.isEmpty) {
      scanResults.clear();
      try {
        flutterBlueClassicPlugin.value.startScan();
        animationController.repeat();
        Timer(const Duration(seconds: 10), () async {
          try {
            flutterBlueClassicPlugin.value.stopScan();
            animationController.stop();
            animationController.reset();
          } catch (e) {}
        });
      } catch (e) {}
    }
  }

  Future<void> onStopPressed() async {
    try {
      flutterBlueClassicPlugin.value.stopScan();
    } catch (e) {
      // Get.snackbar(
      //   'Stop Scan Error',
      //   'An error occurred while stopping the scan: $e',
      //   snackPosition: SnackPosition.TOP,
      //   backgroundColor: Colors.redAccent,
      //   colorText: Colors.white,
      // );
    }
  }

  Future<bool> requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.isGranted && await Permission.bluetoothConnect.isGranted) {
      return true;
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    return statuses[Permission.bluetoothScan]?.isGranted == true && statuses[Permission.bluetoothConnect]?.isGranted == true;
  }

  Future<void> onConnectPressed(BluetoothDevice device) async {
    connectingDevice.value = device;

    try {
      bluetoothConnection = await flutterBlueClassicPlugin.value.connect(device.address);
      connectedDevice.value = device;
      connectingDevice.value = null;

      connectedDeviceId.value = device.address;
      bluetoothIconColor.value = Colors.green;
    } catch (e) {
      connectingDevice.value = null;
    }
  }

  Future<void> onDisconnectPressed(BluetoothDevice device) async {
    if (bluetoothConnection != null) {
      bluetoothConnection!.dispose();
      connectedDevice.value = null;
      bluetoothConnection = null;
      connectedDeviceId.value = "";
      bluetoothIconColor.value = Colors.red;

      onScanPressed();
    }
  }

  Future<void> sendPrintData({required String data, required int totalCount}) async {
    IsScan.value = true;
    if (bluetoothConnection == null) {
      TmsToast.msg("Bluetooth connection is not established.");
      print("Bluetooth connection is null.");
      return;
    }

    try {
      bluetoothConnection?.writeString(data);
      printCount++;
      print("rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr1$printCount");
      if (printCount == totalCount) {
        print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&$printCount");
        IsScan.value = false;
      }
    } catch (e) {
      // TmsToast.msg("Failed to send print command.");
      // print("Error while sending print data: $e");
    }
  }

  Future<void> showBluetoothDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text('Bluetooth turned off', style: TextStyle()),
          content: Text('Please enable Bluetooth to use this app.'),
          actions: <Widget>[
            TmsButton(
              text: "OK",
              onPressed: () {
                Get.back();
              },
            ),
          ],
        );
      },
    );
  }

  /// list Store Docket Api data method
  docketApi() async {
    dataStatus(DataStatus.loading);
    AppLoader().show();
    final response = await WebService.tmsPostRequest(
      url: ApiService.getBarCodePrintByGCN,
      body: docketNoToJson(DocketNo(dockno: docketNumber.text)),
    );
    AppLoader().hide();
    try {
      DocketDetail docketDetail = docketDetailFromJson(response.data);
      if (docketDetail.data.isNotEmpty) {
        docketData(docketDetail.data);
        boxNumberApi();
        dataStatus(DataStatus.completed);
        TmsToast.msg("Success");
      } else {
        dataStatus(DataStatus.error);
        TmsToast.msg("No Record Found");
      }
    } catch (err) {
      dataStatus(DataStatus.error);
      // TmsToast.msg("No Record Found");
      // print(err);
      // return null;62844549-0002
    }
  }

  boxNumberApi() async {
    bcSerialDataList.clear();
    AppLoader().show();
    final response = await WebService.tmsPostRequest(
      url: ApiService.getBcSerialDetailsForPrint,
      body: docketNoToJson(DocketNo(dockno: docketNumber.text)),
    );
    AppLoader().hide();
    try {
      GetBcSerialDetailsResponse getBcSerialDetailsResponse = getBcSerialDetailsResponseFromJson(response.data);
      if (getBcSerialDetailsResponse.bcSerialData.isNotEmpty) {
        bcSerialDataList.addAll(getBcSerialDetailsResponse.bcSerialData);

        TmsToast.msg("Success");
      } else {
        TmsToast.msg("No Record Found");
      }
    } catch (err) {
      // TmsToast.msg("No Record Found");
      // print(err);
      // return null;
    }
  }

  String getBtlPrintData(argumentData, subIndex) {
    print("HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH${printStatus}");
    int index = subIndex + 1;
    int totalPkgs = argumentData.pkgsno.toInt();

    int digits;
    if (totalPkgs < 1000) {
      digits = 3;
    } else if (totalPkgs < 10000) {
      digits = 4;
    } else {
      digits = 5;
    }

    String prn = "SIZE 72.00 mm, 50.63 mm\n" +
        "GAP 3 mm, 0 mm\n" +
        "SET RIBBON OFF\n" +
        "DIRECTION 1,0\n" +
        "REFERENCE 0,0\n" +
        "OFFSET 0 mm\n" +
        "SET PEEL OFF\n" +
        "SET CUTTER OFF\n" +
        "SET PARTIAL_CUTTER OFF\n" +
        "SET TEAR ON\n" +
        "CLS\n" +
        "CODEPAGE 1252\n" +
        "SETMAG 2,2\n" +
        "TEXT 130,20,\"ROMAN.TTF\",0,20,20,\"TNS EXPRESS\"\n";

    prn += "QRCODE 220,150,L,9,A,90,M2,S7,\"" +
        "${bcSerialDataList[subIndex].bcSerialNo}" +
        "\"\n" +
        "TEXT 235,150,\"ROMAN.TTF\",0,10,10,\"Pkgs: ${index}/${argumentData.pkgsno.toInt()}\"\n" +
        "TEXT 235,210,\"ROMAN.TTF\",0,11,11,\"${bcSerialDataList[subIndex].bcSerialNo}\"\n";

    prn += "TEXT 20,95,\"ROMAN.TTF\",0,16,16,\"C/No.${argumentData.dockno}\"\n" +
        "TEXT 235,260,\"ROMAN.TTF\",0,10,10,\"Date: ${argumentData.dockdt}\"\n" +
        "TEXT 235,310,\"ROMAN.TTF\",0,10,10,\"${argumentData.partyName}\"\n" +
        "TEXT 20,350,\"ROMAN.TTF\",0,13,13,\"Origin: ${argumentData.orgncd}\"\n" +
        "TEXT 280,350,\"ROMAN.TTF\",0,13,13,\"Desti: ${argumentData.reassigNDestcd}\"\n" +
        "PRINT 1,1\n";

    return prn;
  }

  String shortenString(String input, int maxLength) {
    if (input.length <= maxLength) {
      return input;
    } else {
      return input.substring(0, maxLength - 2) + "..";
    }
  }
}
