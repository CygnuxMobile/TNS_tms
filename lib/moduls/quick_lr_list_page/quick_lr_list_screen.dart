import '../../moduls/quick_lr_list_page/quick_lr_list_controller.dart';
import '../../utils/pref.dart';
import '../../widgets/tms_normaltext.dart';
import '../../widgets/tost.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../app_routes.dart';
import '../../utils/tms_color.dart';

class QuickLrListScreen extends StatefulWidget {
  const QuickLrListScreen({super.key});

  @override
  State<QuickLrListScreen> createState() => _QuickLrListScreenState();
}

class _QuickLrListScreenState extends State<QuickLrListScreen> {
  final QuickLrListController controller = Get.put(QuickLrListController());

  @override
  void initState() {
    super.initState();
    controller.fetchQuickDocketBookedList(
      dockno: controller.docketController.text.trim(),
      companyCode: Pref().getCompanyCode(),
      location: Pref().getBaseLocation(),
      user: Pref().getUserId(),
      fromDate: controller.fromDataController.text,
      toDate: controller.toDateController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff232F34),
        centerTitle: true,
        title: TmsText(
          text: "Quick Docket List",
          color: AppColor.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leading: IconButton(
          onPressed: () {
            Get.offAndToNamed(AppRoutes.dashboardScreen);
          },
          icon: Icon(Icons.arrow_back, color: AppColor.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showFilterBottomSheet(context);
            },
            icon: Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.docketList.isEmpty) {
            return const Center(child: Text('No dockets found.'));
          } else {
            return ListView.builder(
              itemCount: controller.docketList.length,
              itemBuilder: (context, index) {
                final docket = controller.docketList[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                TmsText(
                                  text: '${docket['dockno'] ?? 'N/A'}',
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff232F34),
                                ),
                                SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                      ClipboardData(text: docket['dockno']),
                                    );
                                    TmsToast.msg(
                                      "${docket['dockno']} number copied to clipboard",
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${docket['dockDate'] ?? 'N/A'}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            TmsText(
                              text: '${docket['orgncd'] ?? 'N/A'}',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            SizedBox(width: 5),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 5),
                            TmsText(
                              text: '${docket['destination'] ?? 'N/A'}',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _buildInfoRow(
                          'Billing Party',
                          '${docket['partY_NAME'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          'Consignor',
                          '${docket['consinorName'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 4),
                        _buildInfoRow(
                          'Consignee',
                          '${docket['consineeName'] ?? 'N/A'}',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWeightInfo(
                              'Pkgs',
                              '${docket['pkgsno'] ?? 'N/A'}',
                            ),
                            _buildWeightInfo(
                              'Act Wt',
                              '${docket['actuwt'] ?? 'N/A'}',
                            ),
                            _buildWeightInfo(
                              'Chrg Wt',
                              '${docket['chrgwt'] ?? 'N/A'}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        }),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: GoogleFonts.urbanist(fontSize: 14, color: Colors.black87),
        children: [
          TextSpan(
            text: '$label: ',
            style: GoogleFonts.urbanist(color: Colors.grey[700]),
          ),
          TextSpan(
            text: value,
            style: GoogleFonts.urbanist(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInfo(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.urbanist(fontSize: 12, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: GoogleFonts.urbanist(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const TmsText(
                text: 'Filter Dockets',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _buildDatePickerField(
                context: context,
                controller: controller.fromDataController,
                labelText: 'From Date',
              ),
              const SizedBox(height: 16),
              _buildDatePickerField(
                context: context,
                controller: controller.toDateController,
                labelText: 'To Date',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.docketController,
                style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  labelText: 'Docket Number',
                  labelStyle: GoogleFonts.urbanist(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.receipt_long),
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  controller.fetchQuickDocketBookedList(
                    dockno: controller.docketController.text.trim(),
                    companyCode: Pref().getCompanyCode(),
                    location: Pref().getBaseLocation(),
                    user: Pref().getUserId(),
                    fromDate: controller.fromDataController.text,
                    toDate: controller.toDateController.text,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff232F34),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const TmsText(
                  text: 'Apply Filter',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required TextEditingController controller,
    required String labelText,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.urbanist(fontWeight: FontWeight.w600),
      readOnly: true,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: GoogleFonts.urbanist(color: Colors.grey[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xff232F34)),
      ),
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xff232F34),
                  onPrimary: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          String formattedDate = DateFormat('dd MMM yyyy').format(pickedDate);
          controller.text = formattedDate;
        }
      },
    );
  }
}
