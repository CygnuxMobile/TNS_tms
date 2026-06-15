import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../../moduls/drs_page/drs_controller.dart';
import '../../../widgets/app_size.dart';
import '../../../widgets/tms_normaltext.dart';
import '../../../widgets/tms_richtext.dart';
import '../../../widgets/tost.dart';

import '../../../utils/tms_color.dart';
import '../../../widgets/custom_dropdown_search.dart';
import '../../../widgets/tms_button.dart';
import '../../home_page/dash_board_controller.dart';

enum FutherAction { Success, partial, failure }

class DrsUpdateScreen extends StatefulWidget {
  DrsUpdateScreen({super.key});

  @override
  State<DrsUpdateScreen> createState() => _DrsUpdateScreenState();
}

class _DrsUpdateScreenState extends State<DrsUpdateScreen> {
  DRSController drsController = Get.put(DRSController());

  DashBoardController ctrl = Get.find<DashBoardController>();

  SizedBox _sizeBox() => const SizedBox(
        height: 12,
      );

  SizedBox sizeBox() => const SizedBox(
        height: 08,
      );

  int index = Get.arguments;

  GlobalKey<FormState> deliveredPkgsFromKey = GlobalKey<FormState>();
  GlobalKey<FormState> addRemarksFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> closeKmFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> receiversNameFormKey = GlobalKey<FormState>();
  GlobalKey<FormState> failureReason = GlobalKey<FormState>();
  GlobalKey<FormState> partialReason = GlobalKey<FormState>();
  GlobalKey<FormState> relation = GlobalKey<FormState>();

  late String formattedDate;

  late String formattedTime;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    formattedDate = DateFormat('MMM, EEEE, yyyy').format(now);
    formattedTime = DateFormat('hh:mm a').format(now);
  }

  Future<List<String>?> imagesFromGallery() async {
    final List<XFile>? selectedFiles = await ImagePicker().pickMultiImage();
    if (selectedFiles != null && selectedFiles.isNotEmpty) {
      return Future.wait(selectedFiles.map((file) => _fileToBase64(file)));
    }
    return null;
  }

  Future<String?> imageFromCamera() async {
    final XFile? capturedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (capturedFile != null) {
      return _fileToBase64(capturedFile);
    }
    return null;
  }

  Future<String> _fileToBase64(XFile file) async {
    final bytes = await File(file.path).readAsBytes();
    return base64Encode(bytes);
  }

  Widget imageView(List<String> images) {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      crossAxisSpacing: 25,
      mainAxisSpacing: 25,
      children: List.generate(
        images.length,
        (index) {
          return Obx(() {
            if (images.isNotEmpty) {
              return Stack(
                children: [
                  Container(
                    height: AppSize.size(context).height * 0.15,
                    width: AppSize.size(context).width * 0.25,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        base64Decode(images[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: -12,
                    right: -12,
                    child: IconButton(
                      iconSize: 20,
                      onPressed: () {
                        images.removeAt(index);
                      },
                      icon: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return SizedBox();
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayColor: Colors.black.withOpacity(0.3),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          leading: InkWell(
            onTap: () {
              Get.back();
            },
            child: const Icon(
              Icons.arrow_back,
              size: 30,
              color: AppColor.white,
            ),
          ),
          title: TmsText(text: '${drsController.drsList[index].dockno}', color: Colors.white),
          backgroundColor: const Color(0xff232F34),
          elevation: 0,
          centerTitle: true,
        ),
        body: SafeArea(
          child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Center(
                            child: TmsText(
                              text: "Consignee Details",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff232F34),
                            ),
                          ),
                          Divider(),
                          sizeBox(),
                          TmsRichText(
                            text: "Consignee : ",
                            richText: drsController.drsList[index].csgenm,
                            color: Color(0xff232F34),
                            color1: AppColor.black45,
                            fontWeight: FontWeight.w500,
                            fontWeight1: FontWeight.bold,
                            fontSize: 17,
                            fontSize1: 17,
                          ),
                          sizeBox(),
                          TmsRichText(
                            text: "Address : ",
                            richText: drsController.drsList[index].csgecd,
                            color: Color(0xff232F34),
                            color1: AppColor.black45,
                            fontWeight: FontWeight.w500,
                            fontWeight1: FontWeight.bold,
                            fontSize: 17,
                            fontSize1: 17,
                          ),
                          sizeBox(),
                          TmsRichText(
                            text: "Content : ",
                            richText: drsController.drsList[index].content,
                            color: Color(0xff232F34),
                            color1: AppColor.black45,
                            fontWeight: FontWeight.w500,
                            fontWeight1: FontWeight.bold,
                            fontSize: 17,
                            fontSize1: 17,
                          ),
                          sizeBox(),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 05, bottom: 10, top: 10),
                                  child: Form(
                                    key: deliveredPkgsFromKey,
                                    child: TextFormField(
                                      controller: drsController.deliveredPkgsController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      style: GoogleFonts.urbanist(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        labelText: 'Enter delivered package ',
                                        labelStyle: GoogleFonts.urbanist(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        hintStyle: GoogleFonts.urbanist(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xff232F34)),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      onChanged: (newValue) {
                                        setState(() {
                                          if (newValue.isEmpty) {
                                            newValue = '0';
                                            drsController.images.clear();
                                          }

                                          num totalPackages =
                                              drsController.drsList[index].pkgsArrived;
                                          int userEnteredPackages = int.parse(newValue);

                                          if (userEnteredPackages > totalPackages) {
                                            userEnteredPackages = totalPackages.toInt();

                                            drsController.deliveredPkgsController.text =
                                                userEnteredPackages.toString();
                                            drsController.deliveredPkgsController.selection =
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: drsController
                                                      .deliveredPkgsController.text.length),
                                            );
                                          }

                                          if (userEnteredPackages == totalPackages) {
                                            drsController.futherActionStatus.value =
                                                FutherAction.Success;
                                          } else if (userEnteredPackages > 0 &&
                                              userEnteredPackages < totalPackages) {
                                            drsController.futherActionStatus.value =
                                                FutherAction.partial;
                                          } else if (userEnteredPackages == 0) {
                                            drsController.futherActionStatus.value =
                                                FutherAction.failure;
                                          }
                                        });
                                      },
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter delivered pkgs number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              TmsText(
                                  text: "/ ${drsController.drsList[index].pkgsArrived.toString()}"),
                              SizedBox(
                                width: AppSize.size(context).width / 5,
                              ),
                              TmsRichText(
                                text: "Amount : ",
                                richText: drsController.drsList[index].docketTotal.toString(),
                                color: Color(0xff232F34),
                                color1: AppColor.black45,
                                fontWeight: FontWeight.w500,
                                fontWeight1: FontWeight.bold,
                                fontSize: 17,
                                fontSize1: 17,
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    _sizeBox(),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: TmsText(
                                text: "Delivery Date Time",
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xff232F34),
                              ),
                            ),
                            Divider(),
                            TmsRichText(
                              text: "Date : ",
                              richText: formattedDate,
                              color: Color(0xff232F34),
                              color1: AppColor.black45,
                              fontWeight: FontWeight.w500,
                              fontWeight1: FontWeight.bold,
                              fontSize: 17,
                              fontSize1: 17,
                            ),
                            sizeBox(),
                            TmsRichText(
                              text: "Time : ",
                              richText: formattedTime,
                              color: Color(0xff232F34),
                              color1: AppColor.black45,
                              fontWeight: FontWeight.w500,
                              fontWeight1: FontWeight.bold,
                              fontSize: 17,
                              fontSize1: 17,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _sizeBox(),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TmsText(
                              text: "Futher Action",
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xff232F34),
                            ),
                            Divider(),
                            Obx(() {
                              return TmsText(
                                text: drsController.futherActionStatus.value == FutherAction.Success
                                    ? "Success"
                                    : drsController.futherActionStatus.value == FutherAction.partial
                                        ? "Partial"
                                        : "Failure",
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: drsController.futherActionStatus.value ==
                                        FutherAction.Success
                                    ? Colors.green
                                    : drsController.futherActionStatus.value == FutherAction.partial
                                        ? Colors.deepOrangeAccent
                                        : Colors.red,
                              );
                            }),
                            SizedBox(
                              height: 10,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() {
                                  if (drsController.futherActionStatus.value ==
                                      FutherAction.failure) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Form(
                                        key: failureReason,
                                        child: Dropdown(
                                          list: drsController.failureRemarkList
                                              .map((data) => data.codeDesc)
                                              .toList(),
                                          onChanged: (value) {
                                            for (var data in drsController.failureRemarkList) {
                                              if (value == data.codeDesc) {
                                                drsController.selectFailureReason = data.codeId;
                                                print(
                                                    ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${drsController.selectFailureReason}");
                                              }
                                            }
                                          },
                                          text: "Select Failure Reason ".obs,
                                          label: "Failure Reason",
                                          validator: (value) {
                                            if (value == null || value == '' || value.isEmpty) {
                                              return 'Please Select Failure Reason ';
                                            }
                                            return null;
                                          },
                                          isSize: true,
                                          enabled: true.obs,
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                }),
                                Obx(() {
                                  if (drsController.futherActionStatus.value ==
                                      FutherAction.partial) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Form(
                                        key: partialReason,
                                        child: Dropdown(
                                          list: drsController.partialRemarkList
                                              .map((data) => data.codeDesc)
                                              .toList(),
                                          onChanged: (value) {
                                            for (var data in drsController.partialRemarkList) {
                                              if (value == data.codeDesc) {
                                                drsController.selectPartialReason = data.codeId;
                                                print(
                                                    ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${drsController.selectPartialReason}");
                                              }
                                            }
                                          },
                                          text: "Select Partial Reason ".obs,
                                          label: "Partial Reason",
                                          validator: (value) {
                                            if (value == null || value == '' || value.isEmpty) {
                                              return 'Please Select Partial Reason ';
                                            }
                                            return null;
                                          },
                                          isSize: true,
                                          enabled: true.obs,
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                }),
                                Obx(() {
                                  if (drsController.futherActionStatus.value ==
                                          FutherAction.partial ||
                                      drsController.futherActionStatus.value ==
                                          FutherAction.Success) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Form(
                                        key: relation,
                                        child: Dropdown(
                                          list: drsController.relationList
                                              .map((data) => data.codeDesc)
                                              .toList(),
                                          onChanged: (value) {
                                            for (var data in drsController.relationList) {
                                              if (value == data.codeDesc) {
                                                drsController.selectRelation = data.codeId;
                                                print(
                                                    ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${drsController.selectRelation}");
                                              }
                                            }
                                          },
                                          text: "Select Relation ".obs,
                                          label: "Relation",
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please Select Relation ';
                                            }
                                            return null;
                                          },
                                          isSize: true,
                                          enabled: true.obs,
                                        ),
                                      ),
                                    );
                                  }
                                  return SizedBox();
                                }),
                                Obx(() {
                                  if (drsController.futherActionStatus.value ==
                                          FutherAction.Success ||
                                      drsController.futherActionStatus.value ==
                                          FutherAction.partial) {
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Form(
                                          key: receiversNameFormKey,
                                          child: TextFormField(
                                            controller: drsController.receiversNameController,
                                            style: GoogleFonts.urbanist(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            keyboardType: TextInputType.text,
                                            decoration: InputDecoration(
                                              labelText: 'Receivers Name',
                                              labelStyle: GoogleFonts.urbanist(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              hintStyle: GoogleFonts.urbanist(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(color: Color(0xff232F34)),
                                                borderRadius: BorderRadius.circular(15),
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter Receivers Name';
                                              }
                                              return null;
                                            },
                                          )),
                                    );
                                  }

                                  return SizedBox();
                                }),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Form(
                                      key: closeKmFormKey,
                                      child: TextFormField(
                                        controller: drsController.closeKmController,
                                        style: GoogleFonts.urbanist(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        keyboardType: TextInputType.number,
                                        decoration: InputDecoration(
                                          labelText: 'Close Km',
                                          labelStyle: GoogleFonts.urbanist(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          hintStyle: GoogleFonts.urbanist(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xff232F34)),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter Close Km';
                                          }
                                          return null;
                                        },
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Form(
                                      key: addRemarksFormKey,
                                      child: TextFormField(
                                        controller: drsController.drsRemarkController,
                                        style: GoogleFonts.urbanist(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        keyboardType: TextInputType.text,
                                        decoration: InputDecoration(
                                          labelText: 'Enter Remark',
                                          labelStyle: GoogleFonts.urbanist(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          hintStyle: GoogleFonts.urbanist(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xff232F34)),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter Enter Remark';
                                          }
                                          return null;
                                        },
                                      )),
                                ),
                                Obx(() {
                                  if (drsController.futherActionStatus.value ==
                                          FutherAction.Success ||
                                      drsController.futherActionStatus.value ==
                                          FutherAction.partial) {
                                    return Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            if (drsController.images.length < 2) {
                                              final base64Image = await imageFromCamera();
                                              if (base64Image != null) {
                                                drsController.images.add(base64Image);
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
                                            if (drsController.images.length < 2) {
                                              final base64Images = await imagesFromGallery();
                                              if (base64Images != null) {
                                                final availableSlots =
                                                    2 - drsController.images.length;
                                                drsController.images
                                                    .addAll(base64Images.take(availableSlots));
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
                                    );
                                  }
                                  return SizedBox();
                                }),
                                Obx(() {
                                  if (drsController.futherActionStatus.value ==
                                          FutherAction.Success ||
                                      drsController.futherActionStatus.value ==
                                          FutherAction.partial) {
                                    if (drsController.images.isNotEmpty) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 15.0),
                                        child: Container(
                                            height: AppSize.size(context).height * 0.10,
                                            child: imageView(drsController.images)),
                                      );
                                    }
                                  }

                                  return SizedBox();
                                }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TmsButton(
              text: 'Submit',
              size: Size(double.infinity, AppSize.size(context).height * 0.06),
              onPressed: () {
                if (drsController.futherActionStatus.value == FutherAction.Success) {
                  if (drsController.selectRelation.isEmpty) {
                    TmsToast.msg("Please enter relation");
                  } else if (drsController.receiversNameController.text.isEmpty) {
                    TmsToast.msg("Please enter receiversName");
                  } else if (drsController.drsRemarkController.text.isEmpty) {
                    TmsToast.msg("Please enter remark");
                  } else {
                    drsDialog(
                        context: context,
                        onConfirm: () {
                          drsController.drsSubmitApi(
                            context: context,
                            index: index,
                          );
                        });
                  }
                } else if (drsController.futherActionStatus.value == FutherAction.partial) {
                  if (drsController.selectPartialReason.isEmpty) {
                    TmsToast.msg("Please enter partialReason");
                  } else if (drsController.selectRelation.isEmpty) {
                    TmsToast.msg("Please enter relation");
                  } else if (drsController.receiversNameController.text.isEmpty) {
                    TmsToast.msg("Please enter receiversName");
                  } else if (drsController.drsRemarkController.text.isEmpty) {
                    TmsToast.msg("Please enter remark");
                  } else {
                    drsDialog(
                        context: context,
                        onConfirm: () {
                          drsController.drsSubmitApi(
                            context: context,
                            index: index,
                          );
                        });
                  }
                } else {
                  if (drsController.selectFailureReason.isEmpty) {
                    TmsToast.msg("Please enter failureReason");
                  } else if (drsController.drsRemarkController.text.isEmpty) {
                    TmsToast.msg("Please enter remark");
                  } else {
                    drsDialog(
                        context: context,
                        onConfirm: () {
                          drsController.drsSubmitApi(
                            context: context,
                            index: index,
                          );
                        });
                  }
                }
              }),
        ),
      ),
    );
  }

  void drsDialog({required BuildContext context, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: TmsText(
              text: drsController.futherActionStatus.value == FutherAction.Success
                  ? "Do you want to Deliver Docket?"
                  : drsController.futherActionStatus.value == FutherAction.partial
                      ? "Do you want to Partial Docket?"
                      : "Do you want to Failure Docket?"),
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
}
