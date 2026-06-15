import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';

import '../../../widgets/tms_normaltext.dart';
import '../quick_docket_controller.dart';


enum PinCodeDataStatus { none, loading, completed, error }

class PinCodeSearchScreen extends StatefulWidget {
  @override
  _PinCodeSearchScreenState createState() => _PinCodeSearchScreenState();
}

class _PinCodeSearchScreenState extends State<PinCodeSearchScreen> {
  QuickDocketController quickDocketController = Get.find<QuickDocketController>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        quickDocketController.pinCodeList.clear();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TmsText(
            text: "Select Pincode",
            fontWeight: FontWeight.bold,
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
              quickDocketController.pinCodeList.clear();
            },
            icon: Icon(
              Icons.arrow_back,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 58,
                    child: TextFormField(
                      controller: quickDocketController.toPinCodeController,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          quickDocketController.pinCodeApi(value);
                        }
                      },
                      style: GoogleFonts.urbanist(
                          color: Colors.black, fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Search Pincode',
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
                  ),
                ),
                Obx(() {
                  return Expanded(
                    child: quickDocketController.pinCodeDataStatus ==
                        PinCodeDataStatus.loading
                        ? Center(child: CircularProgressIndicator())
                        : quickDocketController.pinCodeDataStatus ==
                        PinCodeDataStatus.error
                        ? Center(
                      child: TmsText(
                        text: "No Data Found",
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    )
                        : quickDocketController.pinCodeDataStatus ==
                        PinCodeDataStatus.none
                        ? SizedBox()
                        : ListView.builder(
                      itemCount: quickDocketController.pinCodeList.length,
                      itemBuilder: (context, index) {
                        final pinCodeItem =
                        quickDocketController.pinCodeList[index];

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,),
                              title: Text(
                                pinCodeItem.value,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  quickDocketController.toPinCodeController.text =
                                      pinCodeItem.value;
                                  quickDocketController
                                      .odaCategoryController.text =
                                      pinCodeItem.odAcategory;
                                  quickDocketController
                                      .destinationController.text =
                                      pinCodeItem.destination;
                                  quickDocketController
                                      .toCityController.text =
                                      pinCodeItem.toCity;
                                });
                                Get.back();
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Divider(color: Colors.black,thickness: 1,),
                            ), // Add underline after each item
                          ],
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
