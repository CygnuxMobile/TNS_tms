import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../moduls/outward_page/outward_controller.dart';
import '../../../../widgets/tms_normaltext.dart';
import 'package:get/get.dart';
import '../../../../utils/tms_color.dart';
import '../../../docket_page/docket_controller.dart';
import '../../widget/pending_barcode_dialog.dart';

class LSPackagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final OutWardController outWardController = Get.find<OutWardController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff232F34),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TmsText(
          text: 'Scan LS Packages',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (outWardController.bcNumberDataStatus.value == DataStatus.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (outWardController.bcNumberDataStatus.value ==
            DataStatus.error) {
          return Center(
            child: TmsText(
              text: 'Failed to load data. Please try again.',
              color: Colors.red,
              fontSize: 16,
            ),
          );
        } else if (outWardController.bcNumberDataStatus.value ==
            DataStatus.completed) {
          return Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Obx(() {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            outWardController.scanManuallyStatus.value =
                                ScanManually.scan;
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  outWardController.scanManuallyStatus.value ==
                                          ScanManually.scan
                                      ? Color(0xff232F34)
                                      : Colors.white,
                              border:
                                  Border.all(color: const Color(0xff232F34)),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(8),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: TmsText(
                                text: 'SCAN',
                                color: outWardController
                                            .scanManuallyStatus.value ==
                                        ScanManually.scan
                                    ? Colors.white
                                    : Color(0xff232F34),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            outWardController.scanManuallyStatus.value =
                                ScanManually.manually;
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color:
                                  outWardController.scanManuallyStatus.value ==
                                          ScanManually.manually
                                      ? Color(0xff232F34)
                                      : Colors.white,
                              border:
                                  Border.all(color: const Color(0xff232F34)),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: TmsText(
                                text: 'MANUALLY',
                                color: outWardController
                                            .scanManuallyStatus.value ==
                                        ScanManually.manually
                                    ? Colors.white
                                    : Color(0xff232F34),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          TmsText(
                            text: 'PENDING',
                            color: Colors.orange,
                            fontSize: 16,
                          ),
                          TmsText(
                            text:
                                '${outWardController.totalDocketCount()}/${outWardController.totalBoxCount()}',
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        TmsText(
                          text: 'COMPLETED',
                          color: Colors.green,
                          fontSize: 16,
                        ),
                        TmsText(
                          text:
                              '${outWardController.totalDocketScanCount()}/${outWardController.totalBoxScanCount()}',
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 10.0),
                child: Obx(() {
                  return Column(
                    children: [
                      if (outWardController.scanManuallyStatus.value ==
                          ScanManually.scan) ...{
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller:
                                      outWardController.boxScanController,
                                  focusNode: outWardController.scanFocusNode,
                                  style: GoogleFonts.urbanist(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  onChanged: (value) {
                                    // Only call this in SCAN mode
                                    outWardController.boxNumberOnChange(value);
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Scan Box Number',
                                    labelStyle: GoogleFonts.urbanist(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xff232F34),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.clear),
                                      color: Colors.black,
                                      onPressed: () {
                                        outWardController.boxScanController
                                            .clear();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                if (outWardController.scanFocusNode.hasFocus) {
                                  outWardController.scanFocusNode.unfocus();
                                } else {
                                  outWardController.scanFocusNode
                                      .requestFocus();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff232F34),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Icon(
                                Icons.document_scanner_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                          ],
                        ),
                      },
                      if (outWardController.scanManuallyStatus.value ==
                          ScanManually.manually)
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: TextFormField(
                                  controller:
                                      outWardController.boxScanController,
                                  style: GoogleFonts.urbanist(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Enter Box Number',
                                    labelStyle: GoogleFonts.urbanist(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xff232F34),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 10,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.clear),
                                      color: Colors.black,
                                      onPressed: () {
                                        outWardController.boxScanController
                                            .clear();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                final value = outWardController
                                    .boxScanController.text
                                    .trim();
                                if (value.isNotEmpty) {
                                  outWardController.boxNumberOnChange(value);
                                } else {
                                  Get.snackbar(
                                    'Error',
                                    'Box number cannot be empty',
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                              child: Text(
                                'Add',
                                style: GoogleFonts.urbanist(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xff232F34),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: outWardController.docketNumberList.length,
                  itemBuilder: (context, index) {
                    final docket = outWardController.docketNumberList[index];
                    if (outWardController
                        .docketNumberList[index].docketBcSerials.isNotEmpty) {
                      return Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 2.0, horizontal: 18),
                        child: GestureDetector(
                          onTap: () {
                            showPendingBarcodesDialog(
                                context: context,
                                docketIndex: index,
                                docketBcSerials: outWardController
                                    .docketNumberList[index].docketBcSerials,
                                docketNumberList:
                                    outWardController.docketNumberList);
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Obx(() {
                                    return Checkbox(
                                      value: docket.isChecked.value,
                                      onChanged: (value) {},
                                      activeColor: Color(0xff232F34),
                                      checkColor: Colors.white,
                                    );
                                  }),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TmsText(
                                          text: docket.dockno,
                                          fontSize: 16,
                                          color: AppColor.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        if (docket.docketBcSerials.isNotEmpty &&
                                            docket.docketBcSerials[0].lastScan
                                                .isNotEmpty) ...{
                                          TmsText(
                                            text: docket.docketBcSerials[0]
                                                .lastScan.value,
                                            fontSize: 14,
                                            color: Colors.black54,
                                          ),
                                        }
                                      ],
                                    ),
                                  ),
                                  TmsText(
                                    text:
                                        '${outWardController.bcSellScanCount(docket.docketBcSerials)} / ${docket.docketBcSerials.length}',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                ),
              ),
            ],
          );
        } else {
          return Center(
            child: TmsText(
              text: 'Unexpected state. Please try again.',
              color: Colors.grey,
              fontSize: 16,
            ),
          );
        }
      }),
      bottomNavigationBar: Obx(() {
        if (outWardController.bcNumberDataStatus.value ==
            DataStatus.completed) {
          return Container(
            width: double.infinity,
            color: const Color(0xff232F34),
            child: TextButton.icon(
              onPressed: () {
                showScanSummaryDialog(
                    context: context,
                    thcNo: outWardController.outWardList[0].tcno,
                    outWardController: outWardController);
              },
              icon: Icon(Icons.check, color: Colors.white),
              label: TmsText(
                text: 'FINISH LS SCAN',
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          );
        }

        return SizedBox();
      }),
    );
  }
}
