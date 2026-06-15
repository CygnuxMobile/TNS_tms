import 'dart:async';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../moduls/docket_page/sub_widget/bluetooth_list.dart';
import '../../app_routes.dart';
import '../../utils/tms_color.dart';
import '../../widgets/tms_button.dart';
import '../../widgets/tms_normaltext.dart';
import '../../widgets/tost.dart';
import '../../moduls/docket_page/docket_controller.dart';

class DocketScreen extends StatefulWidget {
  DocketScreen({Key? key}) : super(key: key);

  @override
  State<DocketScreen> createState() => _DocketScreenState();
}

class _DocketScreenState extends State<DocketScreen> {
  DocketController ctrl = Get.put(DocketController());
  Timer? timer;

  @override
  void initState() {
    // TODO: implement initState
    timer = Timer.periodic(Duration(seconds: 2), (Timer t) {
      checkBluetoothConnection();
    });
    super.initState();
  }

  void checkBluetoothConnection() async {
    bool isOn = await ctrl.flutterBlueClassicPlugin.value.isEnabled;
    if (!isOn) {
      TmsToast.msg("Bluetooth is turned off");
      return;
    }

    if (ctrl.bluetoothConnection != null) {
      if (ctrl.bluetoothConnection?.isConnected == false) {
        TmsToast.msg("Connection lost with device. Please reconnect.");
        ctrl.connectedDevice.value = null;
        ctrl.bluetoothConnection = null;
        ctrl.connectedDeviceId.value = "";
        ctrl.bluetoothIconColor.value = Colors.red;
        ctrl.IsScan.value = false;
      }
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.offAndToNamed(AppRoutes.dashboardScreen);
        ctrl.bluetoothConnection?.dispose();
        ctrl.bluetoothIconColor.value = Colors.red;
        ctrl.connectedDevice.value = null;
        ctrl.connectedDeviceId.value = "";
        ctrl.adapterStateSubscription.cancel();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff232F34),
            centerTitle: true,
            title: TmsText(
              text: "Print Screen",
              color: AppColor.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            leading: IconButton(
              onPressed: () async {
                Get.offAndToNamed(AppRoutes.dashboardScreen);
                ctrl.bluetoothConnection?.dispose();
                ctrl.bluetoothIconColor.value = Colors.red;
                ctrl.connectedDevice.value = null;
                ctrl.connectedDeviceId.value = "";
                ctrl.adapterStateSubscription.cancel();
              },
              icon: Icon(
                Icons.arrow_back,
                color: AppColor.white,
              ),
            ),
            actions: [
              Obx(() {
                return IconButton(
                  icon: Icon(Icons.print, color: ctrl.bluetoothIconColor.value),
                  onPressed: () async {
                    bool granted = await ctrl.requestBluetoothPermissions();

                    if (granted) {
                      if (!await checkBluetoothStatus(context)) {
                        ctrl.showBluetoothDialog(context);
                      } else {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => BluetoothScanWidget(),
                        );
                      }
                    } else {
                      TmsToast.msg("Bluetooth permission required to scan.");
                    }
                  },
                );
              }),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Column(
                            children: [
                              Form(
                                key: ctrl.formKey,
                                child: TextFormField(
                                  focusNode: ctrl.barCodeNode,
                                  cursorColor: Color(0xff232F34),
                                  controller: ctrl.docketNumber,
                                  style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xff232F34),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                    labelText: "Barcode Series",
                                    contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15), // Adjust height here
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Please enter barcode Series';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TmsButton(
                                onPressed: () {
                                  if (ctrl.formKey.currentState!.validate()) {
                                    ctrl.barCodeNode.unfocus();
                                    ctrl.docketData.clear();
                                    ctrl.docketApi();
                                  }
                                },
                                text: ' Submit',
                                size: const Size(double.infinity, 50),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Obx(() {
                        if (ctrl.dataStatus.value == DataStatus.completed) {
                          return Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0, right: 12.0, left: 12.0),
                                        child: Row(
                                          children: [
                                            TmsText(text: "P${ctrl.docketData[0].dockno}"),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                cursorColor: Color(0xff232F34),
                                                controller: ctrl.formPackageNumber,
                                                style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color(0xff232F34)),
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                                  labelText: "From",
                                                  hintText: "(e.g., 001)",
                                                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0, right: 12.0, left: 12.0),
                                        child: Row(
                                          children: [
                                            TmsText(text: "P${ctrl.docketData[0].dockno}"),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: TextFormField(
                                                cursorColor: Color(0xff232F34),
                                                controller: ctrl.toPackageNumber,
                                                style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                    borderSide: BorderSide(color: Color(0xff232F34)),
                                                    borderRadius: BorderRadius.circular(15),
                                                  ),
                                                  labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                                  labelText: "To",
                                                  hintText: "(e.g., 002)",
                                                  contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 12.0, right: 12.0, left: 12.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: TmsButton(
                                                text: "PrintAll",
                                                onPressed: () async {
                                                  if (ctrl.connectedDeviceId.isEmpty) {
                                                    Get.snackbar(
                                                      'Connection Error',
                                                      'Please connect to a Bluetooth device before printing.',
                                                      snackPosition: SnackPosition.TOP,
                                                      backgroundColor: Colors.redAccent,
                                                      colorText: Colors.white,
                                                    );
                                                  } else {
                                                  ctrl.printStatus = PrintStatus.all;
                                                  if (!await checkBluetoothStatus(context)) {
                                                    ctrl.showBluetoothDialog(context);
                                                  } else {
                                                  ctrl.printCount.value = 0;
                                                  ctrl.prnList.clear();
                                                  int pkg = ctrl.docketData[0].pkgsno.toInt();
                                                  TmsToast.msg("Sending print command...");
                                                  print("++++++++++++++++${ctrl.IsScan.value}");
                                                  for (int j = 0; j < pkg; j++) {
                                                    print(">>>>>>>>>>>>>>>>>>>>>>Loop PrnList ${ctrl.getBtlPrintData(ctrl.docketData[0], j)}");
                                                    await ctrl.sendPrintData(data: ctrl.getBtlPrintData(ctrl.docketData[0], j), totalCount: pkg);
                                                  }
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            SizedBox(
                                              width: 05,
                                            ),
                                            Expanded(
                                              child: TmsButton(
                                                text: "        Print         ",
                                                onPressed: () async {
                                                  ctrl.printStatus = PrintStatus.all;
                                                  ctrl.prnList.clear();
                                                  int pkg = ctrl.docketData[0].pkgsno.toInt();

                                                  if (ctrl.connectedDeviceId.isEmpty) {
                                                    Get.snackbar(
                                                      'Connection Error',
                                                      'Please connect to a Bluetooth device before printing.',
                                                      snackPosition: SnackPosition.TOP,
                                                      backgroundColor: Colors.redAccent,
                                                      colorText: Colors.white,
                                                    );
                                                  } else {
                                                    if (!await checkBluetoothStatus(context)) {
                                                      ctrl.showBluetoothDialog(context);
                                                    } else {
                                                  ctrl.prnList.clear();
                                                  ctrl.printCount.value = 0;
                                                  String fromInput = ctrl.formPackageNumber.text;
                                                  String toInput = ctrl.toPackageNumber.text;

                                                  if (fromInput.isEmpty && toInput.isEmpty) {
                                                    TmsToast.msg("Please enter barcode series");
                                                  } else {
                                                    int loopNumber = pkg;

                                                    print("User  from input: $fromInput");
                                                    print("User  to input: $toInput");

                                                    if (fromInput.isNotEmpty && toInput.isEmpty) {
                                                      int from = int.parse(fromInput.padLeft(3, '0'));
                                                      TmsToast.msg("Sending print command...");
                                                      print(">>>>>>>>>>>>>>>>>>>>>>Loop PrnList 1 ${ctrl.getBtlPrintData(
                                                        ctrl.docketData[0],
                                                        from - 1,
                                                      )}");

                                                      await ctrl.sendPrintData(
                                                          data: ctrl.getBtlPrintData(
                                                            ctrl.docketData[0],
                                                            from - 1,
                                                          ),
                                                          totalCount: from);
                                                      print("Updated prnList: 1${ctrl.prnList}");
                                                    }

                                                    if (ctrl.toPackageNumber.text.isNotEmpty) {
                                                      int fromPackage = int.parse(fromInput);
                                                      int toPackage = int.parse(toInput);

                                                      if (fromPackage > toPackage) {
                                                        TmsToast.msg("The 'from' package number must be less than or equal to the 'to' package number.");
                                                        return;
                                                      }
                                                      TmsToast.msg("Sending print command...");
                                                      ctrl.IsScan.value = true;
                                                      for (int i = fromPackage; i <= toPackage; i++) {
                                                        print(">>>>>>>>>>>>>>>>>>>>>>Loop PrnList 2 ${ctrl.getBtlPrintData(ctrl.docketData[0], i - 1)}");
                                                        await ctrl.sendPrintData(
                                                            data: ctrl.getBtlPrintData(
                                                              ctrl.docketData[0],
                                                              i - 1,
                                                            ),
                                                            totalCount: toPackage);
                                                      }
                                                      ctrl.IsScan.value = false;
                                                    }
                                                  }
                                                  }
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    color: Color(0xff232F34),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: TmsText(
                                        text: "Docket Details",
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  DocketDetailsText(
                                    Title: "C/No",
                                    Data: ctrl.docketData[0].dockno,
                                  ),
                                  Divider(),
                                  DocketDetailsText(
                                    Title: "Origin",
                                    Data: ctrl.docketData[0].orgncd,
                                  ),
                                  Divider(),
                                  DocketDetailsText(
                                    Title: "Destination",
                                    Data: ctrl.docketData[0].reassigNDestcd,
                                  ),
                                  Divider(),
                                  DocketDetailsText(
                                    Title: "Consignee",
                                    Data: ctrl.docketData[0].csgenm,
                                  ),
                                  Divider(),
                                  DocketDetailsText(
                                    Title: "Packages",
                                    Data: ctrl.docketData[0].pkgsno.toString(),
                                  ),
                                  Divider(),
                                  DocketDetailsText(
                                    Title: "Weight",
                                    Data: ctrl.docketData[0].actuwt.toString(),
                                  ),
                                  Divider(),
                                  DocketDetailsText(
                                    Title: "Date",
                                    Data: ctrl.docketData[0].dockdt,
                                  ),
                                  Divider(),
                                  DocketDetailsText(
                                    Title: "Boxld",
                                    Data: ctrl.docketData[0].dockno,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                        return SizedBox();
                      })
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkBluetoothStatus(BuildContext context) async {
    bool isOn = await ctrl.flutterBlueClassicPlugin.value.isEnabled;
    return isOn;
  }

  TmsDocketListView({required String text, required String image, required double height}) {
    return Row(
      children: [
        Image(
          image: AssetImage(image),
          height: height,
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: TmsText(
            text: text,
            color: Colors.black.withOpacity(0.7),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class DocketDetailsText extends StatelessWidget {
  const DocketDetailsText({super.key, required this.Title, required this.Data});

  final String Title;
  final String Data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              child: TmsText(
                text: Title,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 2,
            child: Container(
              child: TmsText(
                text: Data,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }
}
