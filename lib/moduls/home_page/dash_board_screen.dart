import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:location/location.dart';
import '../../app_routes.dart';
import '../../moduls/home_page/dash_board_controller.dart';
import '../../moduls/quick_docket_page/quick_docket_controller.dart';
import '../../widgets/custom_loader.dart';
import '../../widgets/dashboard_widgets/custom_box.dart';
import '../../widgets/tms_button.dart';

import '../../utils/pref.dart';
import '../../widgets/custom_dropdown_search.dart';
import '../../widgets/dashboard_widgets/custom_drawer.dart';
import '../../widgets/tms_normaltext.dart';
import '../attendance_page/attendance_controller.dart';
import '../quick_docket_page/quick_docket_menu.dart';
import '../quick_lr_list_page/quick_lr_list_screen.dart';
import '../trecking_page/tracking_controller.dart';

enum DashBordMenuEnum { manifest, outWard, inWard, stockUpdate, stockUpdateList, drsList, drsUpdate, none }

DashBordMenuEnum dashBordMenuEnum = DashBordMenuEnum.none;

enum WebViewEnum { manifest, thc, stockUpdate, arrival, none }

WebViewEnum webViewEnum = WebViewEnum.none;

class DashBordScreen extends StatefulWidget {
  const DashBordScreen({Key? key}) : super(key: key);

  @override
  State<DashBordScreen> createState() => _DashBordScreenState();
}

class _DashBordScreenState extends State<DashBordScreen> {
  DashBoardController ctrl = Get.put(DashBoardController());
  QuickDocketController quickDocketController = Get.put(QuickDocketController());
  AttendanceController attendanceController = Get.put(AttendanceController());
  TrackingController trackingController = Get.put(TrackingController());
  AppLoader appLoader = AppLoader();

  @override
  Widget build(BuildContext context) {
    var scaffoldKey = GlobalKey<ScaffoldState>();
    Location location = Location();

    return LoaderOverlay(
      useDefaultLoading: false,
      overlayColor: Colors.black.withOpacity(0.3),
      child: Scaffold(
        key: scaffoldKey,
        drawer: drawer(context),
        appBar: AppBar(
            title: TmsText(
              text: 'Home',
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            backgroundColor: Color(0xff232F34),
            actions: [
              Obx(() {
                return InkWell(
                  onTap: () {
                    showLocationDialog();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TmsText(
                      text: "${ctrl.selectLocation}",
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                );
              }),
              SizedBox(
                width: 35,
              ),
            ],
            leading: IconButton(
              icon: Icon(
                Icons.dehaze_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                scaffoldKey.currentState!.openDrawer();
              },
            )),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Obx(() {
              if (ctrl.menuStatus.value != MenuStatus.loading) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: ctrl.menuList.isNotEmpty
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Operations Section
                                  if (ctrl.menuList.contains('Quick Docket') ||
                                      ctrl.menuList.contains('POD') ||
                                      ctrl.menuList.contains('DRS') ||
                                      ctrl.menuList.contains('Stock Update') ||
                                      ctrl.menuList.contains('Arrival') ||
                                      ctrl.menuList.contains('Manifest') ||
                                      ctrl.menuList.contains('OutwardScan') ||
                                      ctrl.menuList.contains('Inward') ||
                                      ctrl.menuList.contains('GCN') ||
                                      ctrl.menuList.contains('Attendance'))
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 15.0),
                                          child: Stack(
                                            children: [
                                              Text(
                                                'Operations',
                                                style: GoogleFonts.urbanist(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: -1,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GridView.count(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          children: [
                                            for (var module in ctrl.menuList)
                                              if (module == 'Quick Docket')
                                                DashBoardContainer(
                                                  text: 'Quick Docket',
                                                  image: 'assets/images/dashboardimages/Delivery Boy.png',
                                                  ontap: () {
                                                    Get.to(QuickDocketOptionScreen());
                                                    // Get.toNamed(AppRoutes.quickDocketScreen);
                                                  },
                                                )
                                              else if (module == 'GCN') ...[
                                                if (!Platform.isIOS)
                                                  DashBoardContainer(
                                                    text: 'GCN',
                                                    image: 'assets/images/dashboardimages/gcn.png',
                                                    ontap: () {
                                                      Get.toNamed(AppRoutes.docketDetails);
                                                    },
                                                  ),
                                              ]
                                              else if (module == 'Manifest')
                                                DashBoardContainer(
                                                  text: 'Manifest',
                                                  image: 'assets/images/dashboardimages/outward.png',
                                                  ontap: () {
                                                    dashBordMenuEnum = DashBordMenuEnum.outWard;
                                                    Get.toNamed(AppRoutes.manifestScreen);
                                                  },
                                                )
                                              else if (module == "Stock Update")
                                                DashBoardContainer(
                                                  text: "Stock Update",
                                                  image: "assets/images/dashboardimages/inward.png",
                                                  ontap: () {
                                                    Get.toNamed(
                                                      AppRoutes.inWardScreen,
                                                    );
                                                  },
                                                )
                                              else if (module == 'Arrival')
                                                DashBoardContainer(
                                                  text: 'Arrival',
                                                  image: 'assets/images/dashboardimages/arrived.png',
                                                  ontap: () {
                                                    customBottomSheetArrival(context);
                                                  },
                                                )
                                              else if (module == 'POD')
                                                DashBoardContainer(
                                                  text: 'POD',
                                                  image: 'assets/images/dashboardimages/POD.png',
                                                  ontap: () {
                                                    Get.toNamed(AppRoutes.podScreen);
                                                  },
                                                )
                                              // else if (module == 'DRS')
                                              //   DashBoardContainer(
                                              //     text: 'Docket Delivery',
                                              //     image: 'assets/images/dashboardimages/Delivery Boy.png',
                                              //     ontap: () {
                                              //       DrsBottomSheetArrival(context);
                                              //     },
                                              //   )
                                          ],
                                        )
                                      ],
                                    ),

                                  // Tracking Section
                                  if (ctrl.menuList.contains('Tracking'))
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 15.0),
                                          child: Stack(
                                            children: [
                                              Text(
                                                'Tracking',
                                                style: GoogleFonts.urbanist(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: -1,
                                                left: 0,
                                                right: 0,
                                                child: Container(
                                                  height: 2,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GridView.count(
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 20,
                                          mainAxisSpacing: 20,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          children: [
                                            for (var module in ctrl.menuList)
                                              if (module == 'Tracking')
                                                DashBoardContainer(
                                                  text: 'Docket Tracking',
                                                  image: 'assets/images/dashboardimages/Tracking.png',
                                                  ontap: () {
                                                    trackingCustomBottomSheet(context);
                                                  },
                                                ),
                                            DashBoardContainer(
                                              text: 'Quick LR List',
                                              image: 'assets/images/quick_lr_list.png',
                                              ontap: () {
                                                Get.to(() => QuickLrListScreen());
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )
                            : Center(
                                child: Text(
                                  "Oops! You don’t have access to this menu. Kindly contact your admin for help.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.amber,
                                  ),
                                ),
                              ),
                      ),
                    )
                  ],
                );
              }

              return Center(
                  child: CircularProgressIndicator(
                color: Color(0xff232F34),
              ));
            }),
          ),
        ),
      ),
    );
  }

  void showLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const TmsText(
            text: "Change From HBL",
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Dropdown(
                  image: "assets/images/dashboardimages/To.png".obs,
                  enabled: true.obs,
                  isSize: false,
                  boxDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xFFE9ECEF),
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  text: Pref().getBaseLocation().isEmpty ? 'Select Location '.obs : '${Pref().getBaseLocation()}'.obs,
                  label: "Location",
                  list: ctrl.location.map((element) => '${element.locCode} - ${element.locName}').toList(),
                  onChanged: (value) async {
                    ctrl.selectLocation.value = value!;
                  }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ctrl.selectLocation.value = Pref().getBaseLocation();
              },
              child: const TmsText(
                text: "Cancel",
                color: Color(0xff232F34),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await ctrl.getLocationCode(ctrl.selectLocation.value);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff232F34),
              ),
              child: const TmsText(
                text: "Switch",
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showGpsDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(05))),
          title: Text('GPS Not Enabled'),
          content: Text('Please enable GPS to continue.'),
          actions: <Widget>[
            TmsButton(
                text: "OK",
                onPressed: () {
                  Get.back();
                })
          ],
        );
      },
    );
  }
}
