import '../../utils/tmsapi_method.dart';
import '../../utils/tmsapp_api.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class QuickLrListController extends GetxController {
  var docketList = [].obs;

  var isLoading = false.obs;

  TextEditingController docketController = TextEditingController();
  TextEditingController fromDataController = TextEditingController(
    text: DateFormat(
      'dd MMM yyyy',
    ).format(DateTime.now().subtract(const Duration(days: 30))),
  );
  TextEditingController toDateController = TextEditingController(
    text: DateFormat('dd MMM yyyy').format(DateTime.now()).toString(),
  );

  Future<void> fetchQuickDocketBookedList({
    String dockno = "",
    String location = "",
    String companyCode = "",
    String user = "",
    String fromDate = "",
    String toDate = "",
  }) async {
    docketList.clear();
    try {
      isLoading(true);
      final requestBody = json.encode({
        "dockno": dockno,
        "location": location,
        "companyCode": companyCode,
        "user": user,
        "fromDate": fromDate,
        "toDate": toDate,
      });

      final response = await WebService.tmsPostRequest(
        url: ApiService.QuickDocketBookedList,
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.data);
        if (data != null && data['data'] is List) {
          docketList.value = data['data'];
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }
}
