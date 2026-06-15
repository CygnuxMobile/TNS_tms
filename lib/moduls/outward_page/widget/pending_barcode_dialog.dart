import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../model/outward_model/bc_number.dart';
import '../../../moduls/outward_page/outward_controller.dart';
import '../../../widgets/tost.dart';
import 'package:get/get.dart';
import '../../../widgets/tms_normaltext.dart';

void showPendingBarcodesDialog(
    {required BuildContext context,
    required int docketIndex,
    required List<DocketBcSerial> docketBcSerials,
    required List<DocketNumberObject> docketNumberList}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          height: 400,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TmsText(
                        text: 'Pending Barcode',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: docketBcSerials.length,
                      itemBuilder: (context, index) {
                        final baseBarcode = docketBcSerials[index].dockno;
                        final fullBarcode = docketBcSerials[index].bcSerialNo;
                        return Card(
                          color: docketBcSerials[index].isBcNumberScan.value
                              ? Colors.greenAccent
                              : Colors.white,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: TmsText(
                              text: baseBarcode,
                              color: const Color(0xff232F34),
                              fontWeight: FontWeight.bold,
                            ),
                            subtitle: TmsText(
                              text: fullBarcode,
                              fontSize: 12,
                            ),
                            leading: Checkbox(
                              value:
                                  docketBcSerials[index].isBcNumberScan.value,
                              activeColor: Color(0xff232F34),
                              onChanged: (bool? newValue) {},
                            ),
                            trailing:
                                docketBcSerials[index].isBcNumberScan.value
                                    ? IconButton(
                                        icon: Icon(Icons.remove_circle,
                                            color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            docketBcSerials[index]
                                                .isBcNumberScan
                                                .value = false;
                                          });
                                          docketNumberList[docketIndex].isChecked.value = false;
                                        },
                                      )
                                    : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

void showScanSummaryDialog({
  required BuildContext context,
  required String thcNo,
  required OutWardController outWardController,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TmsText(
                    text: "Scan Summary",
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextFormField(
                enabled: false,
                style: GoogleFonts.urbanist(
                    color: Colors.black, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: thcNo,
                  hintStyle: GoogleFonts.urbanist(
                      color: Colors.black, fontWeight: FontWeight.bold),
                  labelStyle: GoogleFonts.urbanist(
                      color: Colors.black, fontWeight: FontWeight.bold),
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TmsText(
                          text: "Dockets",
                          fontSize: 12,
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TmsText(
                              text:
                                  "${outWardController.totalDocketScanCount()} / ${outWardController.totalDocketCount()}"),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TmsText(
                          text: "Packages",
                          fontSize: 12,
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TmsText(
                              text:
                                  "${outWardController.totalBoxScanCount()} / ${outWardController.totalBoxCount()}"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(08),
                  color: const Color(0xff232F34),
                ),
                child: TextButton.icon(
                  onPressed: () {
                    showConfirmationDialog(
                      context: context,
                      onConfirm: () {
                        Get.back();
                        if (outWardController.totalBoxScanCount().value <= 0) {
                          TmsToast.msg("Please scan at least one box.");
                        } else {
                          outWardController.outWardSubmit();
                        }
                      },
                    );
                  },
                  icon: Icon(Icons.check_circle, color: Colors.white),
                  label: TmsText(
                    text: 'FINALIZE AND MAKE MF',
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showSuccessDialog({
  required BuildContext context,
  required VoidCallback onConfirm,
  required String ManifestNo,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TmsText(
              text: ManifestNo,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            TmsText(text: "Manifest generated successfully.."),
            const SizedBox(height: 20), // Add spacing
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: TmsText(
                  text: "OK",
                  color: const Color(0xff232F34),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void showConfirmationDialog(
    {required BuildContext context, required VoidCallback onConfirm}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: TmsText(text: "Do you want to create Manifest?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: TmsText(
              text: "NO",
              color: const Color(0xff232F34),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: TmsText(
              text: "YES",
              color: const Color(0xff232F34),
            ),
          ),
        ],
      );
    },
  );
}
