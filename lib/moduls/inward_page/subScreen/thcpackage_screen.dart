import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../moduls/inward_page/subScreen/thc_summary.dart';
import '../../../widgets/tms_normaltext.dart';
import '../../../../utils/tms_color.dart';
import '../../outward_page/outward_controller.dart';
import '../inward_controller.dart';
import '../widget/scan_dialog.dart';

class LSPackagesScreen extends StatelessWidget {
  InwardController inwardController = Get.find<InwardController>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff232F34),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TmsText(text: 'Scan LS Packages', color: Colors.white, fontWeight: FontWeight.bold),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          inwardController.scanManuallyStatus.value = ScanManually.scan;
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: inwardController.scanManuallyStatus.value == ScanManually.scan ? Color(0xff232F34) : Colors.white,
                            border: Border.all(color: const Color(0xff232F34)),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: TmsText(
                              text: 'SCAN',
                              color: inwardController.scanManuallyStatus.value == ScanManually.scan ? Colors.white : Color(0xff232F34),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          inwardController.scanManuallyStatus.value = ScanManually.manually;
                        },
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: inwardController.scanManuallyStatus.value == ScanManually.manually ? Color(0xff232F34) : Colors.white,
                            border: Border.all(color: const Color(0xff232F34)),
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Center(
                            child: TmsText(
                              text: 'MANUALLY',
                              color: inwardController.scanManuallyStatus.value == ScanManually.manually ? Colors.white : Color(0xff232F34),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
                          Obx(() {
                            return TmsText(
                              text: '${inwardController.pendingDocketCount()}/${inwardController.pendingBoxScanCount()}',
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            );
                          }),
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
                          text: '${inwardController.completedDocketCount()}/${inwardController.completedBoxScanCount()}',
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (inwardController.scanManuallyStatus.value == ScanManually.scan)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: inwardController.boxScanController,
                            focusNode: inwardController.scanFocusNode,
                            style: GoogleFonts.urbanist(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            onChanged: (value) {
                              inwardController.scanBox(boxNumber: value);
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
                                  inwardController.boxScanController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          if (inwardController.scanFocusNode.hasFocus) {
                            inwardController.scanFocusNode.unfocus();
                          } else {
                            inwardController.scanFocusNode.requestFocus();
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
                ),
              if (inwardController.scanManuallyStatus.value == ScanManually.manually)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextFormField(
                            controller: inwardController.boxScanController,
                            style: GoogleFonts.urbanist(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
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
                                  inwardController.boxScanController.clear();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final value = inwardController.boxScanController.text.trim();
                          if (value.isNotEmpty) {
                            inwardController.scanBox(boxNumber: value);
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
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ListView.builder(
                      itemCount: inwardController.docket.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                            onTap: () {
                              inwardController.docketBcSerialsList.value = inwardController.docket[index].docketBcSerials;
                              Get.to(() => ScanScreen(
                                    dockIndex: index,
                                    inwardController: inwardController,
                                  ));
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Obx(() {
                                  return Column(
                                    children: [
                                      GestureDetector(
                                          child: Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Checkbox(
                                              value: inwardController.docket[index].isFullScan.value,
                                              onChanged: (value) {},
                                              activeColor: Color(0xff232F34),
                                              checkColor: Colors.white,
                                            ),
                                            Expanded(
                                              child: Obx(() {
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    TmsText(
                                                      text: inwardController.docket[index].manifestNo,
                                                      fontSize: 16,
                                                      color: AppColor.blue,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    TmsText(
                                                      text: inwardController.docket[index].docketBcSerials[0].dockno,
                                                      fontSize: 16,
                                                      color: AppColor.blue,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                            TmsText(
                                              text: '${inwardController.bcSellScanCount(inwardController.docket[index].docketBcSerials)}/ ${inwardController.docket[index].docketBcSerials.length}',
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  );
                                }),
                              ),
                            ));
                      }),
                ),
              ),
              // Container(
              //   width: double.infinity,
              //   child: Column(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //           TmsText(
              //             text: "Misroute/Interchange",
              //             fontSize: 16,
              //             color: AppColor.black,
              //             fontWeight: FontWeight.bold,
              //           ),
              //           TmsButton(text: "Add", onPressed: (){
              //             Get.to(()=>MisRoute(),);
              //           })
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                width: double.infinity,
                color: const Color(0xff232F34),
                child: TextButton.icon(
                  onPressed: () {
                    Get.to(ThcSummary());
                  },
                  icon: Icon(Icons.check, color: Colors.white),
                  label: TmsText(
                    text: 'Finish THC/MF Scan',
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
