import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../moduls/drs_page/drs_controller.dart';
import '../../moduls/home_page/dash_board_screen.dart';


import '../manifest_page/manifest_controller.dart';

var ctrl = Get.find<ManifestController>();
var tampScan = '';
bool isQrScening = true;

class QrScanController extends GetxController {
  Barcode? result;
  QRViewController? controller;
  late int stockUpdateListLenth;
  RxInt scanCount = 0.obs;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  RxBool isWithDEPS = false.obs;
  Rx<bool> isCheckedDamage = false.obs;
  Rx<bool> isCheckedPilferage = false.obs;

  DRSController drsController = Get.put(DRSController());


  void onQRViewCreated(
      QRViewController controller, BuildContext context) async {
    await controller.pauseCamera().whenComplete(
          () async => await controller.resumeCamera(),
        );
    controller.scannedDataStream.listen(
      (scanData) async {

        if(!isQrScening) return;

        result = scanData;

        await controller.pauseCamera().whenComplete(() async {
          await Future.delayed(
            const Duration(milliseconds: 500),
            () async => await controller.resumeCamera(),
          );
        });

        if (dashBordMenuEnum == DashBordMenuEnum.manifest) {
          ctrl.checkScanResult(context, result!.code!.trim());
        } else if (dashBordMenuEnum == DashBordMenuEnum.drsList) {
          // drsController.drsListScan(context, result!.code!.trim(), true);
        } else {
          drsController.drsUpdateScan(context, result!.code!.trim(), true);
        }
        update();
      },
    );
  }
}
