 import 'package:flutter/material.dart';
import '../../app_routes.dart';
import '../../widgets/tms_normaltext.dart';
import '../../utils/tms_color.dart';
import 'package:get/get.dart';
import '../docket_page/docket_controller.dart';
import 'inward_controller.dart';
import '../../moduls/inward_page/subScreen/thcpackage_screen.dart';

class InwardScreen extends StatefulWidget {
  InwardScreen({super.key});

  @override
  State<InwardScreen> createState() => _InwardScreenState();
}

class _InwardScreenState extends State<InwardScreen> {
  final InwardController inwardController = Get.find<InwardController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      inwardController.inWardListApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(AppRoutes.dashboardScreen);
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColor.white,
        appBar: AppBar(
          title: const TmsText(
            text: 'SCAN THC',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          centerTitle: true,
          backgroundColor: AppColor.black,
          // Use AppColor
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Get.toNamed(AppRoutes.dashboardScreen);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
        ),
        body: Obx(
          () {
            if (inwardController.inWardListApiDataStatus.value == DataStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (inwardController.inWardListApiDataStatus.value == DataStatus.error) {
              return const Center(
                child: TmsText(
                  text: 'Failed to load data. Please try again.',
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              );
            }

            final inwardList = inwardController.inWardList;
            if (inwardList.isEmpty) {
              return const Center(
                child: TmsText(
                  text: 'No data available.',
                  color: Colors.grey,
                  fontSize: 16,
                ),
              );
            }

            return ListView.builder(
              itemCount: inwardList.length,
              itemBuilder: (context, index) {
                final item = inwardList[index];
                return _buildInwardItem(
                  thcNo: item.thcno,
                  thcDate: item.thCDate,
                  onTap: () {
                    inwardController.destination = inwardList[index].desTCD;
                    inwardController.docket.value = inwardList[index].docket;
                    inwardController.lsNumber.value = inwardList[index].thcno;
                    inwardController.lsIndex = index;
                    Get.to(LSPackagesScreen());
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInwardItem({
    required String thcNo,
    required String thcDate,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: AppColor.black.withOpacity(0.5),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TmsText(
                    text: thcNo,
                    color: AppColor.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  const SizedBox(height: 8),
                  TmsText(
                    text: 'Date: $thcDate',
                    color: AppColor.black,
                    fontSize: 14,
                  ),
                ],
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColor.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
