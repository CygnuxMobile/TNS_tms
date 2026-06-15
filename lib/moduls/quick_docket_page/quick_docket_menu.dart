import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../../moduls/quick_docket_page/quick_docket_screen.dart';
import '../../app_routes.dart';
import '../../widgets/custom_dropdown_search.dart';
import '../../widgets/tms_normaltext.dart';
import '../../widgets/tost.dart';
import '../quick_docket_page/quick_docket_controller.dart';

class QuickDocketOptionScreen extends StatelessWidget {
  final QuickDocketController quickDocketController = Get.put(QuickDocketController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TmsText(
          text: 'Quick Docket',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff232F34),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TmsText(
              text: 'Select an option:',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xff232F34),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildOptionCard(
                    title: 'Without Eway Bill Scan',
                    icon: Icons.cancel,
                    onTap: () {
                      quickDocketController.isValueMetrics.value = false;
                      quickDocketController.isInvoice.value = true;
                      quickDocketController.isEWayNumber.value = true;
                      quickDocketController.isEWBEmpty.value = true;
                      quickDocketController.isDeclared.value = true;
                      quickDocketController.isActualWeight.value = true;
                      quickDocketController.isNumberOfPkg.value = true;
                      quickDocketController.eWayBillStatus.value = eWayBill.withoutEWayBill;
                      quickDocketController.eWayBillScanStatus.value = eWayBillScan.multiple;
                      Get.toNamed(AppRoutes.quickDocketScreen);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildOptionCard(
                    title: 'Eway Bill Scan',
                    icon: Icons.document_scanner,
                    onTap: () {
                      quickDocketController.isEWBEmpty.value = true;
                      quickDocketController.eWayBillStatus.value = eWayBill.withEWayBill;
                      quickDocketController.eWayBillScanStatus.value = eWayBillScan.first;
                      _showCustomDialog(context, quickDocketController);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 36,
                color: const Color(0xff232F34),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TmsText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff232F34),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xff232F34),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomDialog(BuildContext context, QuickDocketController quickDocketController) {
    final TextEditingController hhtController = TextEditingController();
    final GlobalKey<FormState> eWayStateFromKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    // To account for close button spacing
                    Icon(
                      Icons.qr_code_scanner,
                      size: 64,
                      color: const Color(0xff232F34),
                    ),
                    const SizedBox(height: 16),
                    TmsText(
                      text: 'Choose Scan Method',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xff232F34),
                    ),
                    const SizedBox(height: 8),
                    TmsText(
                      text: 'Select how you would like to scan the Eway Bill.',
                      textAlign: TextAlign.center,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    Obx(() {
                      return Dropdown(
                        enabled: true.obs,
                        height: 30.0.obs,
                        isSize: false,
                        text: 'Select State'.obs,
                        label: "State",
                        list: quickDocketController.eWayBillStateList.map((element) => '${element.stnm}').toList(),
                        onChanged: (value) {
                          quickDocketController.textFocus();
                          quickDocketController.selectEWayBillState.value = value!;
                          for (var data in quickDocketController.eWayBillStateList) {
                            if (data.stnm == value) {
                              quickDocketController.selectGetNO.value = data.gstRegNo;
                            }
                          }
                        },
                        globalKey: eWayStateFromKey,
                        validator: (value) {
                          if (value == null || value == '') {
                            return 'Please Select State';
                          }
                          return null;
                        },
                      );
                    }),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (eWayStateFromKey.currentState!.validate()) {
                          _showQrScannerDialog(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff232F34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const TmsText(
                        text: 'Scan EwayBill Qr',
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (eWayStateFromKey.currentState!.validate()) {
                          Get.back();
                          _showHhtDialog(context, hhtController);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const TmsText(
                        text: 'Enter EwayBill Number',
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 8,
                top: 8,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red, // Red background
                      shape: BoxShape.circle, // Circular shape
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to show the QR Scanner Dialog
  void _showQrScannerDialog(BuildContext context) {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
    QRViewController? controller;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Scan QR Code',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xff232F34),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: QRView(
                    key: qrKey,
                    onQRViewCreated: (QRViewController qrController) {
                      controller = qrController;
                      controller?.scannedDataStream.listen((scanData) {
                        String? qrCode = scanData.code;
                        if (quickDocketController.isProcessing == false) {
                          if (qrCode != null && qrCode.isNotEmpty) {
                            quickDocketController.eWayBillApi(
                                eWayNumber: qrCode,
                                stateGst: quickDocketController.selectGetNO.value,
                                isQrScan: true,
                                isMenuScreen: true,
                                context: context);
                          }
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff232F34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const TmsText(
                    text: 'Cancel',
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHhtDialog(BuildContext context, TextEditingController hhtController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TmsText(
                  text: 'HHT Scan',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xff232F34),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 58,
                  child: TextFormField(
                    autofocus: true,
                    controller: hhtController,
                    style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: 'Enter EwayBill Number',
                      labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                      hintStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w500),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xff232F34),
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const TmsText(
                        text: 'Cancel',
                        color: Colors.red,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (hhtController.text.isNotEmpty) {
                          Get.back();
                          quickDocketController.eWayBillApi(
                              eWayNumber: hhtController.text,
                              stateGst: quickDocketController.selectGetNO.value,
                              isQrScan: false,
                              isMenuScreen: true,
                              context: context);
                        } else {
                          TmsToast.msg("Please enter Eway bill number");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff232F34),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const TmsText(
                        text: 'Submit',
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
