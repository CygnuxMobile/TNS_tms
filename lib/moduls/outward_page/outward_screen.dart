import 'package:flutter/material.dart';
import '../../moduls/outward_page/outward_controller.dart';
import '../../moduls/outward_page/subScreen/LsPackages/lspackages_screen.dart';
import '../../widgets/tms_normaltext.dart';
import 'package:get/get.dart';
import '../../app_routes.dart';
import '../../utils/tms_color.dart';
import '../docket_page/docket_controller.dart';

class OutWardScreen extends StatelessWidget {
  const OutWardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OutWardController outWardController = Get.put(OutWardController());


    WidgetsBinding.instance.addPostFrameCallback((_) {
      outWardController.outWardListApi();
    });

    return Scaffold(
      backgroundColor: AppColor.white,
      appBar: AppBar(
        title: const TmsText(
          text: 'Scan Loading Sheet',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff232F34),
        elevation: 0,
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
      body: Obx(() {
        if (outWardController.outWardDataStatus.value == DataStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        } else if (outWardController.outWardDataStatus.value == DataStatus.error) {
          return const Center(
            child: TmsText(
              text: 'Failed to load data. Please try again.',
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          );
        } else if (outWardController.outWardList.isEmpty) {
          return const Center(
            child: TmsText(
              text: 'No records found.',
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          );
        } else {
          return ListView.builder(
            itemCount: outWardController.outWardList.length,
            itemBuilder: (context, index) {
              final item = outWardController.outWardList[index];
              return thcNumberView(
                thcNo: item.tcno ,
                thcDate: item.tcdt ,
                location: item.tobhCode,
                outWardController: outWardController,
              );
            },
          );
        }
      }),
    );
  }

  Widget thcNumberView({
    required String thcNo,
    required String thcDate,
    required String location,
    required OutWardController outWardController,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: () {
          outWardController.bcNumberListApi(lsNo: thcNo);
          Get.to(LSPackagesScreen());
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TmsText(
                    text: thcNo,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  TmsText(
                    text: thcDate,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 4),
                  TmsText(
                    text: location,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColor.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
