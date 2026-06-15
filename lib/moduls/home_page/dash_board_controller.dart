import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:get/get.dart';
import '../../model/dash_board_model/dash_board_menu.dart';
import '../../moduls/manifest_page/manifest_controller.dart';
import '../../utils/tmsapi_method.dart';

import '../../app_routes.dart';
import '../../model/dash_board_model/location_master.dart';
import '../../model/docket_model/docket.dart';
import '../../model/docket_model/docket_credential.dart';
import '../../utils/logging.dart';
import '../../utils/pref.dart';
import '../../utils/tmsapp_api.dart';

enum MenuStatus { none, loading, success }

class DashBoardController extends GetxController {
  RxList<LocationList> location = <LocationList>[].obs;
  TextEditingController docketNumber = TextEditingController();
  TextEditingController thcNumber = TextEditingController();
  TextEditingController podNumber = TextEditingController();
  TextEditingController trackingNumber = TextEditingController();
  ManifestController manifestController = Get.put(ManifestController());
  Rx<MenuStatus> menuStatus = MenuStatus.none.obs;
  RxList<String> menuList = <String>[].obs;
  RxString selectLocation = '${Pref().getBaseLocation()}'.obs;
  RxList<String> fullMenu = <String>[
    "Quick Docket",
    "GCN",
    "Tracking",
    "OutwardScan",
    "Inward",
    "Manifest",
    "Arrival",
    "Stock Update",
    "Attendance",
    "DRS",
    "POD",
  ].obs;

  final log = logger;

  @override
  void onInit() async {
    dashBoardManuApi();
    await locationMasterDataApi();
    if (!(Pref().getBranchCode() == 'HQTR')) {
      Pref().saveBaseLocation(val: Pref().getBranchCode());
    }
    super.onInit();
  }

  Future<void> getLocationCode(String value) async {
    String locationName = value;
    String locationCode = locationName.split("-")[0].replaceAll(" ", '');

    await Pref().saveBaseLocation(val: locationCode);
    location.refresh();
  }

  dashBoardManuApi() async {
    menuStatus.value = MenuStatus.loading;
    menuList.clear();
    try {
      final requestBody = {
        "userID": "${Pref().getUserId()}",
      };
      final response = await WebService.tmsPostTokenRequest(
        url: ApiService.menuAccessDetailsApi,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        menuStatus.value = MenuStatus.success;
        DashBoardMenuItem dashBoardMenuItem = dashBoardMenuItemFromJson(response.data);

        List<MenuListObject> menuItemList = dashBoardMenuItem.menuList;

        for (var data in menuItemList) {
          if (data.hasAccess == true) {
            menuList.add(data.menuName);
          }
        }

        menuList.sort((a, b) {
          return fullMenu.indexOf(a).compareTo(fullMenu.indexOf(b));
        });
      } else {
        menuList.addAll(fullMenu);
      }
    } catch (error) {
      menuList.addAll(fullMenu);
      menuStatus.value = MenuStatus.success;
      print("Error occurred: $error");
    }
  }

  /// location master data
  Future<void> locationMasterDataApi() async {
    try {
      final dio.Response response = await WebService.tmsGetRequest(ApiService.getLocationMasterData + "?UserID=${Pref().getUserId()}");
      if (response.statusCode == 200) {
        dynamic responseData = response.data;
        GetLocationMasterData getLocationMasterData = await getLocationMasterDataFromJson(responseData);
        location.value = getLocationMasterData.data;
      } else {
        if (response.statusCode == 401) {
          // tokenExpire();
        } else {
          print('${response.statusCode} : ${response.data.toString()}');
        }
      }
    } catch (error) {
      print(error);
    }
  }

  /// docket detail

  ///log out
  logoutDialog() {
    Get.defaultDialog(
      onCancel: () {
        Get.back();
      },
      onConfirm: () async {
        Future.delayed(const Duration(seconds: 0), () async {
          await Pref().logout();
          Get.offAllNamed(AppRoutes.loginScreen);
        });
      },
      title: "LogOut",
      middleText: "Are you sure you want to logout.?",
      backgroundColor: Colors.black,
      titleStyle: const TextStyle(color: Colors.white),
      middleTextStyle: const TextStyle(color: Colors.white),
    );
  }
}
