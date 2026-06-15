import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../../../utils/tms_color.dart';
import '../../../widgets/tms_button.dart';
import '../../../widgets/tost.dart';
import '../../../widgets/app_size.dart';
import '../../../widgets/custom_dropdown_search.dart';
import '../../../widgets/dashboard_widgets/custom_drawer.dart';
import '../../../widgets/tms_normaltext.dart';
import '../inward_controller.dart';

class ScanScreen extends StatefulWidget {
  final int dockIndex;
  final InwardController inwardController;

  ScanScreen({required this.dockIndex, required this.inwardController});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late TextEditingController searchController;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    widget.inwardController.filterDocketList('');
  }

  Widget imageView(List<String> damageImages, bool isRemove) {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      crossAxisSpacing: 25,
      mainAxisSpacing: 25,
      children: List.generate(
        damageImages.length,
        (index) {
          return Stack(
            children: [
              Container(
                height: AppSize.size(context).height * 0.15,
                width: AppSize.size(context).width * 0.25,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    base64Decode(damageImages[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              isRemove == false
                  ? Positioned(
                      top: -12,
                      right: -12,
                      child: IconButton(
                        iconSize: 20,
                        onPressed: () {
                          setState(() {
                            damageImages.removeAt(index);
                          });
                        },
                        icon: const Icon(
                          CupertinoIcons.xmark_circle_fill,
                          color: Colors.red,
                        ),
                      ),
                    )
                  : SizedBox(),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff232F34),
        title: TmsText(
          text: 'Pending Barcode',
          color: AppColor.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (query) {
                widget.inwardController.filterDocketList(query);
              },
              style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
              cursorWidth: 1.5,
              cursorColor: const Color(0xff232F34),
              decoration: InputDecoration(
                labelText: 'Search...',
                labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xff232F34)),
                  borderRadius: BorderRadius.circular(15),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear),
                  color: Colors.black,
                  onPressed: () {
                    searchController.clear();
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            Obx(() {
              final filteredList = widget.inwardController.filteredDocketList;
              return filteredList.isEmpty
                  ? Center(
                      child: TmsText(
                        text: 'No results found.',
                        color: Colors.grey,
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          RxList<String> damageImages = <String>[].obs;
                          String damageCodeId = '';
                          String damageCodeType = '';

                          if (damageImages.isEmpty && item.damageImages.isNotEmpty) {
                            damageImages.value = item.damageImages;
                          }
                          if (damageCodeId.isEmpty && item.damageCodeId.isNotEmpty) {
                            damageCodeId = item.damageCodeId;
                          }
                          if (damageCodeType.isEmpty && item.damageCodeType.isNotEmpty) {
                            damageCodeType = item.damageCodeType.value;
                          }

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Obx(() => Checkbox(
                                            value: item.isScan.value,
                                            activeColor: const Color(0xff232F34),
                                            onChanged: (bool? newValue) {},
                                          )),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            TmsText(
                                              text: item.dockno,
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            TmsText(
                                              text: item.bcSerialNo,
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Obx(() {
                                        if (item.isScan.value) {
                                          return IconButton(
                                            icon: const Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              item.isScan.value = false;
                                              inwardController.docket[widget.dockIndex].isFullScan.value = false;
                                              item.damageCodeType.value = "";
                                              item.damageCodeId = "";
                                              item.isDamage.value = false;
                                              item.isAddDamage.value = false;
                                              item.isEdit.value = false;
                                            },
                                          );
                                        }
                                        return SizedBox();
                                      }),
                                    ],
                                  ),
                                  Obx(() {
                                    if (item.isScan.value) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border.symmetric(horizontal: BorderSide()),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                  onTap: () {
                                                    item.isExpand.value = !item.isExpand.value;
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      TmsText(
                                                        text: "Damage Information",
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Icon(
                                                        item.isExpand.isTrue ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            item.isExpand.value
                                                ? Column(
                                                    children: [
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () async {
                                                              if (damageImages.length < 2) {
                                                                final base64Image = await inwardController.imageFromCamera();
                                                                if (base64Image != null) {
                                                                  damageImages.add(base64Image);
                                                                  print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${damageImages.length}");
                                                                }
                                                              } else {
                                                                TmsToast.msg("You can only add up to 2 images.");
                                                              }
                                                            },
                                                            child: Icon(
                                                              Icons.camera_alt,
                                                              size: 40,
                                                              color: Color(0xff232F34),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              if (damageImages.length < 2) {
                                                                final base64Images = await inwardController.imagesFromGallery();
                                                                if (base64Images != null) {
                                                                  final availableSlots = 2 - damageImages.length;
                                                                  damageImages.addAll(base64Images.take(availableSlots));
                                                                }
                                                              } else {
                                                                TmsToast.msg("You can only add up to 2 images.");
                                                              }
                                                            },
                                                            child: Icon(
                                                              Icons.photo_library,
                                                              size: 40,
                                                              color: Color(0xff232F34),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      Obx(() {
                                                        if (damageImages.isNotEmpty) {
                                                          return Container(
                                                            height: AppSize.size(context).height * 0.10,
                                                            child: imageView(damageImages, item.isAddDamage.value),
                                                          );
                                                        }
                                                        return SizedBox();
                                                      }),
                                                      Obx(() {
                                                        if (damageImages.isNotEmpty) {
                                                          return Column(
                                                            children: [
                                                              SizedBox(height: 10),
                                                              _buildDropdown(
                                                                label: "Please select damage type",
                                                                hint: damageCodeId.isEmpty ? "Select damage type" : damageCodeId,
                                                                enabled: !(item.isAddDamage.value),
                                                                items: inwardController.damageTypeList.map((e) => e.codeDesc).toList(),
                                                                onChanged: (value) {
                                                                  for (var data in inwardController.damageTypeList) {
                                                                    if (data.codeDesc == value) {
                                                                      damageCodeId = data.codeId;
                                                                      damageCodeId = data.codeDesc;
                                                                      item.severity.value = data.codefor;
                                                                    }
                                                                  }
                                                                },
                                                              ),
                                                              SizedBox(height: 10),
                                                              Row(
                                                                children: [
                                                                  TmsText(
                                                                    text: "Severity : ",
                                                                    fontSize: 14,
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                  TmsText(
                                                                    text: item.severity.isEmpty ? "" : item.severity.value,
                                                                    fontSize: 14,
                                                                    color: Colors.black,
                                                                  ),
                                                                  Spacer(),
                                                                  Obx(() {
                                                                    return item.isAddDamage.isTrue
                                                                        ? GestureDetector(
                                                                            onTap: () {
                                                                              item.isAddDamage.value = false;
                                                                            },
                                                                            child: Icon(
                                                                              Icons.edit,
                                                                              color: AppColor.black45,
                                                                            ),
                                                                          )
                                                                        : SizedBox();
                                                                  }),
                                                                  SizedBox(width: 10),
                                                                ],
                                                              ),
                                                              SizedBox(height: 10),
                                                              Obx(() {
                                                                return item.isAddDamage.isFalse
                                                                    ? TmsButton(
                                                                        text: item.isEdit.isFalse ? "Add" : "Edit",
                                                                        onPressed: () {
                                                                          bool isAllDone = true;
                                                                          if (item.isAddDamage.isFalse) {
                                                                            if (damageImages.isEmpty) {
                                                                              isAllDone = false;
                                                                              TmsToast.msg("Please upload at least one image.");
                                                                            } else if (damageImages.length < 2) {
                                                                              isAllDone = false;
                                                                              TmsToast.msg("Please upload at least two images.");
                                                                            }
                                                                            if (damageCodeId.isEmpty) {
                                                                              isAllDone = false;
                                                                              TmsToast.msg("Please select a damage type.");
                                                                            }
                                                                            if (isAllDone) {
                                                                              item.damageImages.value = damageImages;
                                                                              item.damageCodeType.value = damageCodeType;
                                                                              item.damageCodeId = damageCodeId;
                                                                              item.isDamage.value = true;
                                                                              item.isAddDamage.value = true;
                                                                              item.isEdit.value = true;
                                                                            }
                                                                          } else {
                                                                            item.isDamage.value = false;
                                                                            item.isAddDamage.value = false;
                                                                          }
                                                                        },
                                                                      )
                                                                    : SizedBox();
                                                              }),
                                                              SizedBox(height: 10),
                                                            ],
                                                          );
                                                        }
                                                        return SizedBox();
                                                      }),
                                                    ],
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      );
                                    }
                                    return SizedBox();
                                  }),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required bool enabled,
    required List<String> items,
    required ValueChanged onChanged,
    // required GlobalKey<FormState> globalKey
  }) {
    return Dropdown(
      enabled: enabled.obs,
      height: 30.0.obs,
      isSize: false,
      text: hint.obs,
      label: label,
      list: items,
      onChanged: onChanged,
      // globalKey: globalKey,
      validator: (value) {
        if (value == null || value == '') {
          return 'Please Select $label';
        }
        return null;
      },
    );
  }
}

void inWardConfirmationDialog({required BuildContext context, required VoidCallback onConfirm}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: TmsText(text: "Do you want to Stock Update?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: TmsText(
              text: "NO",
              color: const Color(0xff232F34),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: TmsText(
              text: "YES",
              color: const Color(0xff232F34),
            ),
          ),
        ],
      );
    },
  );
}
