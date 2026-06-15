import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../environments%20.dart';
import '../../utils/tmsapi_method.dart';
import '../../utils/tmsapp_api.dart';
import '../../widgets/tms_button.dart';
import '../../widgets/tost.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app_routes.dart';
import '../../utils/pref.dart';

RxBool isNetOn = false.obs;

class SplashScreenController extends GetxController {
  final player = AudioPlayer();

  @override
  void onInit() {
    // versionCheckApi();
    checkLogin();
    player.play(AssetSource('audio/welcome_tms_app.mp3'));
    Connectivity().checkConnectivity().then((value) => noInterNetDialog(value));
    Connectivity().onConnectivityChanged.listen((event) {
      noInterNetDialog(event);
    });
    super.onInit();
  }

  // @override
  // void onReady() {
  //   checkLogin();
  //   super.onReady();
  // }

  void loginTimeCheck() async {
    String loginTimeStr = await Pref().getLoginTime();

    if (loginTimeStr.isEmpty) {
      print("No login time found");
      return;
    }
    DateTime loginTime = DateTime.parse(loginTimeStr);
    DateTime currentTime = DateTime.now();

    Duration difference = currentTime.difference(loginTime);

    if (difference.inMinutes >= 720) {
      await Pref().logout();
      Get.offAllNamed(AppRoutes.loginScreen);
    } else {
      print("User still within session. ${difference.inMinutes} minutes passed.");
    }
  }


  void noInterNetDialog(List<ConnectivityResult> result) {
    bool isConnected = (result != ConnectivityResult.none);
    if (!isConnected) {
      TmsToast.msg("please check your internet");
      Get.defaultDialog(
        title: 'No Internet Connection',
        backgroundColor: Colors.white,
        middleText: 'Please check your internet connection and try again.',
        barrierDismissible: false,
        confirm: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
          ),
          child: const Text('OK'),
          onPressed: () {
            Connectivity().checkConnectivity().then((value) {
              if (value == ConnectivityResult.none) {
                isNetOn = false.obs;
              } else {
                Get.back();
                isNetOn = true.obs;
              }
            });
          },
        ),
      );
    }
  }

  Future checkLogin() async {
    Future.delayed(
      const Duration(seconds: 1, milliseconds: 1),
      () {
        if (Pref().getIsLogin() == false) {
          Get.offAllNamed(AppRoutes.loginScreen);
        } else {
          Get.offAllNamed(AppRoutes.dashboardScreen);
        }
      },
    );
  }

  versionCheckApi() async {
    final response = await WebService.tmsGetRequest(ApiService.versionCheck);

    var data = jsonDecode(response.data);
    if (response.statusCode == 200) {
      if (data["data"] != null) {
        if (data['data'][0]['codeDesc'] != AppEnvironments.version) {
          showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: const EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Update Available",
                      style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w500),
                      textAlign: TextAlign.center,
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    Text(
                      "A new version (${data['data'][0]['codeDesc']}) is available. Please update the app.",
                      style: GoogleFonts.urbanist(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    TmsButton(
                      onPressed: () async {
                        Pref().logout();
                        var url = "https://play.google.com/store/apps/details?id=com.cygnux.tns";

                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      },
                      text: "Update Now",
                    ),
                  ],
                ),
              );
            },
          );
        } else {
          loginTimeCheck();
          checkLogin();
        }
      } else {
        TmsToast.msg("Failed to check version");
      }
    } else {
      TmsToast.msg("Failed to check version");
    }
  }
}
