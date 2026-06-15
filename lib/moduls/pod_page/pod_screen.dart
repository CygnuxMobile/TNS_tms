import '../../moduls/pod_page/pod_controller.dart';
import '../../moduls/pod_page/widget/image_bottom_sheet.dart';
import '../../moduls/pod_page/widget/pod_upload_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../main.dart';
import '../../utils/connection_handler.dart';
import '../../utils/tms_color.dart';

class PodUploadScreen extends StatefulWidget {
  const PodUploadScreen({Key? key}) : super(key: key);

  @override
  State<PodUploadScreen> createState() => _PodUploadScreenState();
}

class _PodUploadScreenState extends State<PodUploadScreen> {
  final PodUploadController podUploadController = Get.put(PodUploadController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final allDockets = podDb.getAllDocket();

      if (allDockets.isNotEmpty) {
        print("================ All Docket Records ================");
        for (int i = 0; i < allDockets.length; i++) {
          print("-----------------------------------------------------------------------------");
          print("\n${allDockets[i].dockNo}");
          print("\n${allDockets[i].dockDt}");
          print("\n${allDockets[i].buttonName}");
          print("\n${allDockets[i].status}");
          if (allDockets[i].podImagePaths.isNotEmpty) {
            for (var data in allDockets[i].podImagePaths) {
              print("\n$data");
            }
          }
        }
      }

      bool isOnline = ConnectionService().hasConnection;
      if (isOnline) {
        podUploadController.isOnline.value = true;
        podUploadController.podListApi();
        print("🟢 11111111 Online - Ready to sync");
        podUploadController.uploadPendingPODs();
      } else {
        podUploadController.isOnline.value = false;
        podUploadController.podListApiStatus.value = ApiStatus.success;
        podUploadController.podList.value = podDb.getAllDocket();

        ///-------------------------------------------------------

        print("🔴 1111111 Offline - Will store data locally");
      }

      ConnectionService().connectionChange.listen((isOnline) {
        if (isOnline) {
          podUploadController.isOnline.value = true;
          print(" 2222222🟢 Online - Try to sync now");
          podUploadController.uploadPendingPODs();
        } else {
          podUploadController.isOnline.value = false;
          podUploadController.podListApiStatus.value = ApiStatus.success;
          podUploadController.podList.value = podDb.getAllDocket();

          ///-------------------------------------------------------
          print(" 2222222 🔴 Offline - Save data locally");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      appBar: AppBar(
        title: const Text(
          "Pod Upload",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff232F34),
        surfaceTintColor: const Color(0xff232F34),
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          Obx(() {
            if (podUploadController.isOnline.isTrue) {
              return InkWell(
                onTap: () => podUploadBottomSheet(context, podUploadController),
                child: const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(
                    Icons.filter_alt_rounded,
                    color: Colors.white,
                  ),
                ),
              );
            } else {
              return const SizedBox();
            }
          })
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final status = podUploadController.podListApiStatus.value;

          if (status == ApiStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xff232F34)));
          } else if (status == ApiStatus.error) {
            return const Center(child: Text("No data found"));
          }

          return Column(
            children: [
              const SizedBox(height: 12),
              _buildTabSwitcher(),
              const SizedBox(height: 10),
              Expanded(child: _buildPodList()),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xff232F34), width: 1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [_buildTab("POD", 0), _buildTab("Offline POD", 1)]),
    );
  }

  Widget _buildTab(String label, int index) {
    return Obx(() {
      final isSelected = podUploadController.selectedTab.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => podUploadController.selectedTab.value = index,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xff232F34) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xff232F34),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPodList() {
    return Obx(() {
      final selectedTab = podUploadController.selectedTab.value;
      final isOnlineTab = selectedTab == 0;

      final filteredList = podUploadController.podList
          .where((item) => isOnlineTab ? item.apiStatusIndex != 1 : item.apiStatusIndex == 1)
          .toList();

      if (filteredList.isEmpty) {
        return const Center(child: Text("No PODs available"));
      }

      return ListView.builder(
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final pod = filteredList[index];

          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE2E4E9), width: 1),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    if (pod.apiStatusIndex == 1)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: const Color(0xffFFFFFF),
                          border: Border.all(color: const Color(0xffE2E4E9), width: 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.cloud_off_rounded, color: Colors.orange),
                              const SizedBox(width: 10),
                              const Text(
                                "Offline pod upload.",
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              pod.loading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(Colors.orange),
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          "Docket No : ",
                          style: TextStyle(color: Color(0xff667085)),
                        ),
                        Text(pod.dockNo, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Status : ", style: TextStyle(color: Color(0xff667085))),
                        Expanded(
                          child: Text(
                            pod.status,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: pod.apiStatusIndex == 0 ? 10 : 0),
                    pod.apiStatusIndex == 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                      ),
                                      builder: (context) => podImagePicker(
                                        index: index,
                                        context: context,
                                        podUploadController: podUploadController,
                                        docket: pod.dockNo,
                                        pickImage: pod.podImagePaths.obs,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: AppColor.primaryColor, width: 1.2),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.0),
                                    ),
                                  ),
                                  child: Text(
                                    pod.buttonName,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.primaryColor,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                                  child: ElevatedButton(
                                    onPressed: pod.loading
                                        ? null
                                        : () async {
                                            await Permission.storage.request();
                                            await Permission.manageExternalStorage.request();
                                            final isOnline = ConnectionService().hasConnection;

                                            if (pod.buttonName == "Edit Pod") {
                                              if (pod.podImagePaths.length < 2) {
                                                Get.snackbar(
                                                  'Incomplete Images',
                                                  'Please make sure both Front and Back images are added before submitting.',
                                                  backgroundColor: Colors.redAccent,
                                                  colorText: Colors.white,
                                                );
                                                return;
                                              }

                                              podUploadController.submitHandel(
                                                index: index,
                                                isOnline: isOnline,
                                                docketNo: pod.dockNo,
                                                podImage: pod.podImagePaths[0],
                                                podImageBack: pod.podImagePaths[1],
                                              );
                                            } else {
                                              Get.snackbar(
                                                'Limit reached',
                                                'You will have to pick 2 images from here.',
                                                backgroundColor: Colors.redAccent,
                                                colorText: Colors.white,
                                              );
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColor.primaryColor,
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16.0),
                                      ),
                                    ),
                                    child: pod.loading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation(Colors.white),
                                              strokeWidth: 2.0,
                                            ),
                                          )
                                        : const Text(
                                            "Submit",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
