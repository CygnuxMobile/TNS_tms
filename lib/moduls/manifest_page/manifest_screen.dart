// ignore_for_file: must_be_immutable

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app_routes.dart';
import '../../moduls/manifest_page/sub_widget/manifest_scan_dialog.dart';
import '../../widgets/app_size.dart';
import '../../widgets/dashboard_widgets/custom_drawer.dart';
import '../../widgets/manifest_widgets/custom_alertdialog.dart';
import '../../widgets/tms_button.dart';
import '../../widgets/tms_normaltext.dart';

import '../../utils/pref.dart';
import '../../widgets/custom_dropdown_search.dart';
import '../../widgets/tost.dart';
import 'manifest_controller.dart';

class ManifestScreen extends StatefulWidget {
  ManifestScreen({Key? key}) : super(key: key);

  @override
  State<ManifestScreen> createState() => _ManifestScreenState();
}

class _ManifestScreenState extends State<ManifestScreen> {
  var mfCtrl = Get.find<ManifestController>();

  TextEditingController manifestScanController = TextEditingController();

  var scaffoldKeyM = GlobalKey<ScaffoldState>();

  @override
  void dispose() {
    manifestScanController.dispose();
    super.dispose();
  }

  RxString selectFrom = ''.obs;
  RxString selectTo = ''.obs;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        mfCtrl.checkValidSerialNoDataList.clear();
        manifestScanController.dispose();
        Get.back();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          key: scaffoldKeyM,
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  mfCtrl.checkValidSerialNoDataList.clear();
                  Get.back();
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                )),
            backgroundColor: Color(0xff232F34),
            centerTitle: true,
            title: TmsText(
              text: 'Manifest',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            actions: [
              InkWell(
                onTap: () async {
                  if (Pref().getBaseLocation().isEmpty ||
                      Pref().getNextLocation().isEmpty) {
                    mflocAlertDialog(
                        context: context,
                        title: 'Warning',
                        description: 'Please Select Location',
                        onTap: () {
                          Get.back();
                        },
                        onTapText: 'OK');
                  } else {
                    Get.toNamed(AppRoutes.qRScanScreen);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 5,
                            ),
                            if (Pref().getBranchCode() == 'HQTR')
                              Obx(
                                () => Dropdown(
                                    height: 25.0.obs,
                                    image:
                                        "assets/images/dashboardimages/To.png"
                                            .obs,
                                    enabled: true.obs,
                                    isSize: false,
                                    text: Pref().getBaseLocation().isEmpty
                                        ? 'Select Location '.obs
                                        : '${Pref().getBaseLocation()}'.obs,
                                    label: "From",
                                    list: ctrl.location
                                        .map((element) =>
                                            '${element.locCode} - ${element.locName}')
                                        .toList(),
                                    onChanged: (value) async {
                                      await ctrl.getLocationCode(value!);
                                    }),
                              )
                            else
                              Flexible(
                                child: Container(
                                  alignment: Alignment.center,
                                  height: AppSize.size(context).height * 0.07,
                                  // width: AppSize.size(context).width * 0.75,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: const Color(0xFFE9ECEF),
                                  ),
                                  child: DropdownSearch(
                                    selectedItem: Pref().getBranchCode(),
                                    enabled: false,
                                    items: [Pref().getBranchCode()],
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        prefix: const Icon(
                                          Icons.location_on_outlined,
                                          color: Color(0xFF023E8A),
                                          size: 25,
                                        ),
                                        border: InputBorder.none,
                                        hintText: Pref().getBranchCode(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              height: 5,
                            ),
                            Obx(
                              () => Dropdown(
                                height: 25.0.obs,
                                image: "assets/images/dashboardimages/Form.png"
                                    .obs,
                                enabled: true.obs,
                                isSize: false,
                                text: Pref().getNextLocation().isEmpty
                                    ? 'Select To Location '.obs
                                    : '${Pref().getNextLocation()}'.obs,
                                label: "To",
                                list: ctrl.location
                                    .map((element) =>
                                        '${element.locCode} - ${element.locName}')
                                    .toList(),
                                onChanged: (value) async {
                                  await Pref().saveNextLocation(
                                      val: mfCtrl.LocationName(value));
                                  print('=====${Pref().getNextLocation()}');
                                  mfCtrl.hideTextFocus.requestFocus();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Divider(
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: TextField(
                                focusNode: mfCtrl.hideTextFocus,
                                controller: manifestScanController,
                                style: GoogleFonts.urbanist(color: Colors.black,fontWeight: FontWeight.bold),
                                cursorWidth: 1.5,
                                cursorColor: Color(0xff232F34),
                                decoration: InputDecoration(
                                  labelText: 'BoxId',

                                  hintStyle: GoogleFonts.urbanist(
                                      color: Colors.black, fontWeight: FontWeight.w500),
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
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 15,
                                        horizontal: 15)
                                ),

                                onChanged: (value) {
                                  if (Pref().getBranchCode().isNotEmpty &&
                                      Pref().getNextLocation().isNotEmpty) {
                                    mfCtrl.checkScanResult(context, value);

                                    manifestScanController.clear();
                                  } else {
                                    TmsToast.msg("Please select Location");
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 05,
                      ),
                      Obx(() => mfCtrl.checkValidSerialNoDataList.isNotEmpty
                          ? Flexible(
                              flex: 8,
                              child: ListView.builder(
                                itemCount:
                                    mfCtrl.checkValidSerialNoDataList.length,
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  String lastScan = mfCtrl.lastScanNo(index);
                                  return GestureDetector(
                                    onTap: () {
                                      mfCtrl.hideTextFocus.unfocus();
                                      ManifestScanDialog(
                                          context,
                                          mfCtrl
                                              .checkValidSerialNoDataList[index]
                                              .bcserials);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.white,
                                          border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              width: 1),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TmsText(
                                                    text: mfCtrl
                                                        .checkValidSerialNoDataList[
                                                            index]
                                                        .dockno!,
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  TmsManifestView(
                                                      color: Color(0xff646D72),
                                                      text:
                                                          "${mfCtrl.checkValidSerialNoDataList[index].docketDate}",
                                                      image:
                                                          'assets/images/dashboardimages/Calendar.png',
                                                      height: 25),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  TmsManifestView(
                                                      color: Color(0xff646D72),
                                                      text:
                                                          '${mfCtrl.countScan(index)}/${mfCtrl.checkValidSerialNoDataList[index].bcserials!.length}',
                                                      image:
                                                          'assets/images/dashboardimages/Product.png',
                                                      height: 25),
                                                  Column(
                                                    children: [
                                                      TmsText(
                                                        text: "LastScanned",
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xff646D72),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                      TmsText(
                                                        text: lastScan
                                                            .substring(mfCtrl
                                                                    .lastScanNo(
                                                                        index)
                                                                    .toString()
                                                                    .length -
                                                                3),
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Center(
                                    child: TmsText(
                                      text: '',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            )),
                    ],
                  ),
                ),
                Obx(() => mfCtrl.checkValidSerialNoDataList.isNotEmpty
                    ? Align(
                        alignment: Alignment.bottomRight,
                        child: TmsButton(
                          text: 'Submit',
                          onPressed: () {
                            print('------${Pref().getNextLocation()}');
                            print('------${Pref().getBaseLocation()}');
                            Pref().getBaseLocation().isNotEmpty
                                ? Pref().getNextLocation().isNotEmpty
                                    ? Pref().getNextLocation() !=
                                            Pref().getBaseLocation()
                                        ? mfAlertDialog(
                                            context: context,
                                            title: 'Create Manifest',
                                            description:
                                                'Are you sure, do you want to Create Manifest ?',
                                            cancelOnTap: () {
                                              Get.back();
                                            },
                                            onTap: () async {
                                              mfCtrl.docketManifestAdd();
                                              mfCtrl.prepareManifestSubmit(context);
                                              // await Pref().removeBaseLocation();
                                            },
                                            onTapText: 'Create',
                                          )
                                        : TmsToast.msg('Both Location Same')
                                    : TmsToast.msg('Select Next Location')
                                : TmsToast.msg('Select Base Location');
                          },
                          size: const Size(double.infinity, 40),
                        ),
                      )
                    : const SizedBox())
              ],
            ),
          ),
        ),
      ),
    );
  }

  TmsManifestView(
      {required String text,
      required String image,
      required double height,
      required Color color}) {
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
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
