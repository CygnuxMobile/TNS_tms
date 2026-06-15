import 'package:flutter/material.dart';
import '../../../moduls/inward_page/inward_controller.dart';
import '../../../widgets/tms_normaltext.dart';
import 'package:get/get.dart';
import '../../../widgets/custom_dropdown_search.dart';
import '../widget/scan_dialog.dart';

class ThcSummary extends StatelessWidget {
  InwardController inwardController = Get.find<InwardController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const TmsText(text: 'THC Summary', color: Colors.white, fontWeight: FontWeight.bold),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xff232F34),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8.0),
                          topRight: Radius.circular(8.0),
                        ),
                      ),
                      child: const Center(
                        child: TmsText(
                          text: 'DEPS Details',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Table(
                      border: TableBorder.all(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                      children: [
                        _buildTableRow(
                          title: 'Scan Docket',
                          value:
                              "${inwardController.docketScanCount()} / ${inwardController.docketCount()}",
                          onTap: () {},
                        ),
                        _buildTableRow(
                          title: 'Scan Packages',
                          value:
                              "${inwardController.completedBoxScanCount()} / ${inwardController.scanDocketBoxCount()}",
                          onTap: () {},
                        ),
                        _buildTableRow(
                          title: 'Short Packages',
                          value:
                              "${inwardController.pendingBoxScanCount()} / ${inwardController.scanDocketBoxCount()}",
                          onTap: () {},
                        ),
                        _buildTableRow(
                          title: 'Damage Packages',
                          value: "${inwardController.damageScanCount()}",
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Color(0xff232F34),
          ),
          onPressed: () {
            inWardConfirmationDialog(
              context: context,
              onConfirm: () {
                inwardController.inWardSubmit();
              },
            );
          },
          child: const Text(
            'STOCK UPDATE',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TmsText(
            text: title,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TmsText(
              text: value,
              textAlign: TextAlign.right,
              color: Color(0xff232F34),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required List<String> items,
    required ValueChanged onChanged,
    required GlobalKey<FormState> globalKey,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Dropdown(
        enabled: true.obs,
        height: 30.0.obs,
        isSize: false,
        text: hint.obs,
        label: label,
        list: items,
        onChanged: onChanged,
        globalKey: globalKey,
        validator: (value) {
          if (value == null || value == '') {
            return 'Please Select $label';
          }
          return null;
        },
      ),
    );
  }
}
