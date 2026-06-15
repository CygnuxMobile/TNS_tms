import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_routes.dart';
import '../../widgets/tms_normaltext.dart';

import 'drs_controller.dart';
import 'drs_update/drs_update_screen.dart';

class DRSListScreen extends StatelessWidget {
  DRSListScreen({Key? key}) : super(key: key);

  DRSController dRSController = Get.put(DRSController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TmsText(
          text: 'Docket Delivery',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
        backgroundColor: Color(0xff232F34),
        leading: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.dashboardScreen);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Get.toNamed(AppRoutes.dashboardScreen);
          return false;
        },
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Obx(() {
            if (dRSController.drsListDataStatus.value == DataStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (dRSController.drsListDataStatus.value == DataStatus.error) {
              return const Center(
                child: TmsText(
                  text: 'No data available.',
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              );
            } else {
              return Column(
                children: [
                  Column(
                    children: [
                      // Stack(
                      //   alignment: Alignment.center,
                      //   children: [
                      //     SizedBox(
                      //       height: 150,
                      //       width: 150,
                      //       child: CircularProgressIndicator(
                      //         value: 0.5, // Half-filled arc
                      //         strokeWidth: 12,
                      //         color: Colors.red,
                      //         backgroundColor: Colors.grey.shade300,
                      //       ),
                      //     ),
                      //     const Text(
                      //       '2\nTotal Dockets',
                      //       textAlign: TextAlign.center,
                      //       style:
                      //       TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                  // Obx(() {
                  //   return Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       Expanded(
                  //         child: GestureDetector(
                  //           onTap: () {
                  //             dRSController.pendingAttemptedStatus.value =
                  //                 PendingAttempted.pending;
                  //           },
                  //           child: Container(
                  //             height: 40,
                  //             decoration: BoxDecoration(
                  //               color:
                  //                   dRSController.pendingAttemptedStatus.value ==
                  //                           PendingAttempted.pending
                  //                       ? Color(0xff232F34)
                  //                       : Colors.white,
                  //               border:
                  //                   Border.all(color: const Color(0xff232F34)),
                  //               borderRadius: BorderRadius.only(
                  //                 topLeft: Radius.circular(8),
                  //                 bottomLeft: Radius.circular(8),
                  //               ),
                  //             ),
                  //             child: Center(
                  //               child: TmsText(
                  //                 text: 'Pending',
                  //                 color: dRSController
                  //                             .pendingAttemptedStatus.value ==
                  //                         PendingAttempted.pending
                  //                     ? Colors.white
                  //                     : Color(0xff232F34),
                  //                 fontSize: 14,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //       Expanded(
                  //         child: GestureDetector(
                  //           onTap: () {
                  //             dRSController.pendingAttemptedStatus.value =
                  //                 PendingAttempted.attempted;
                  //           },
                  //           child: Container(
                  //             height: 40,
                  //             decoration: BoxDecoration(
                  //               color:
                  //                   dRSController.pendingAttemptedStatus.value ==
                  //                           PendingAttempted.attempted
                  //                       ? Color(0xff232F34)
                  //                       : Colors.white,
                  //               border:
                  //                   Border.all(color: const Color(0xff232F34)),
                  //               borderRadius: BorderRadius.only(
                  //                 topRight: Radius.circular(8),
                  //                 bottomRight: Radius.circular(8),
                  //               ),
                  //             ),
                  //             child: Center(
                  //               child: TmsText(
                  //                 text: 'Attempted',
                  //                 color: dRSController
                  //                             .pendingAttemptedStatus.value ==
                  //                         PendingAttempted.attempted
                  //                     ? Colors.white
                  //                     : Color(0xff232F34),
                  //                 fontSize: 14,
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   );
                  // }),
                  // SizedBox(height: 12),
                  // Docket Cards List
                  Expanded(
                    child: ListView.builder(
                      itemCount: dRSController.drsList.length,
                      itemBuilder: (context, index) {
                        var item = dRSController.drsList[index];
                        return GestureDetector(
                            onTap: () {
                              dRSController.futherActionStatus = FutherAction.Success.obs;
                              dRSController.deliveredPkgsController.text =
                                  dRSController.drsList[index].pkgsPending.toString();
                              dRSController.receiversNameController.text =
                                  dRSController.drsList[index].csgenm;
                              Get.toNamed(AppRoutes.drsUpdateScreen, arguments: index);
                            },
                            child: DocketCard(
                              docketId: item.dlypdcno,
                              reference: item.dockno,
                              name: item.csgenm,
                              address: item.csgecd,
                            ));
                      },
                    ),
                  ),
                ],
              );
            }
          }),
        ),
      ),
    );
  }
}

class DocketCard extends StatelessWidget {
  final String docketId;
  final String reference;
  final String name;
  final String address;

  const DocketCard({
    Key? key,
    required this.docketId,
    required this.reference,
    required this.name,
    required this.address,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TmsText(
              text: docketId,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TmsText(text: reference),
                // TmsText(text: 'Prepaid', fontWeight: FontWeight.bold),
              ],
            ),
            const SizedBox(height: 5),
            TmsText(
              text: name,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 5),
            TmsText(
              text: address,
              fontSize: 13,
              color: Colors.black54,
              textAlign: TextAlign.start,
            ),
            // const SizedBox(height: 10),
            // Row(
            //   children: [
            //     const Icon(Icons.location_on, color: Color(0xff232F34)),
            //     const SizedBox(width: 15),
            //     const Icon(Icons.phone, color: Color(0xff232F34)),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}
