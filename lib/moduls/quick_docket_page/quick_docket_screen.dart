import 'dart:convert';
import 'dart:io';
import '../../moduls/quick_docket_page/widget/pincode_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import '../../model/quick_docket_model/quick_docket_submit_models/quick_docket_request.dart';
import '../../utils/tms_color.dart';
import '../../widgets/app_size.dart';
import '../../widgets/custom_dropdown_search.dart';
import '../../widgets/tms_button.dart';
import '../../widgets/tms_normaltext.dart';
import '../../widgets/tost.dart';
import '../docket_page/docket_controller.dart';
import 'quick_docket_controller.dart';

enum eWayBill { none, withEWayBill, withoutEWayBill }

class QuickDocketScreen extends StatefulWidget {
  const QuickDocketScreen({super.key});

  @override
  State<QuickDocketScreen> createState() => _QuickDocketScreenState();
}

class _QuickDocketScreenState extends State<QuickDocketScreen> {
  final SizedBox _sizedBox = const SizedBox(height: 8);

  final SizedBox _sizedBox12 = const SizedBox(height: 12);

  late QuickDocketController quickDocketController;

  @override
  void initState() {
    super.initState();
    quickDocketController = Get.put(QuickDocketController());
  }

  Future<void> imagesFromGallery() async {
    try {
      if (quickDocketController.selectedImages.length >= 3) {
        TmsToast.msg("You can only select up to 3 images.");
        return;
      }

      final List<XFile>? selectedFiles = await ImagePicker().pickMultiImage();
      if (selectedFiles != null) {
        final remainingSlots = 3 - quickDocketController.selectedImages.length;
        final filesToAdd = selectedFiles.take(remainingSlots).toList();

        setState(() {
          quickDocketController.selectedImages.addAll(filesToAdd);
        });
        await processAndConvertImages(filesToAdd);
      }
    } catch (e) {
      print("Error picking images from gallery: $e");
    }
  }

  Future<void> imageFromCamera() async {
    try {
      if (quickDocketController.selectedImages.length >= 3) {
        TmsToast.msg("You can only select up to 3 images.");
        return;
      }

      final XFile? capturedFile = await ImagePicker().pickImage(source: ImageSource.camera);
      if (capturedFile != null) {
        setState(() {
          quickDocketController.selectedImages.add(capturedFile);
        });
        await processAndConvertImages([capturedFile]);
      }
    } catch (e) {
      print("Error capturing image from camera: $e");
    }
  }

  Future<void> processAndConvertImages(List<XFile> files) async {
    for (XFile file in files) {
      try {
        final File imageFile = File(file.path);

        final compressedImageFile = await compressImage(imageFile, maxSizeInBytes: 1024 * 1024);

        final bytes = await compressedImageFile.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          quickDocketController.base64Images.add(base64String);
        });
      } catch (e) {
        print("Error processing image: $e");
      }
    }
  }

  Future<File> compressImage(File file, {required int maxSizeInBytes}) async {
    final imageBytes = await file.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes)!;

    int quality = 90;
    int resizeFactor = 100;

    File compressedFile = file;

    while (true) {
      final resizedImage = img.copyResize(decodedImage, width: (decodedImage.width * resizeFactor ~/ 100));
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      if (compressedBytes.length <= maxSizeInBytes || quality <= 50) {
        compressedFile = File('${file.path}_compressed.jpg')..writeAsBytesSync(compressedBytes);
        break;
      }

      quality -= 10;
      resizeFactor -= 10;
    }

    return compressedFile;
  }

  Future<void> showPickerDialog() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose an option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.camera_alt), title: Text('Camera'), onTap: () => imageFromCamera()),
            ListTile(leading: Icon(Icons.photo_album), title: Text('Gallery'), onTap: () => imagesFromGallery()),
          ],
        ),
      ),
    );
  }

  Widget imageView() {
    return GridView.count(
      scrollDirection: Axis.horizontal,
      crossAxisCount: 1,
      crossAxisSpacing: 25,
      mainAxisSpacing: 25,
      children: List.generate(quickDocketController.selectedImages.length, (index) {
        return Obx(() {
          if (quickDocketController.selectedImages.isNotEmpty) {
            return Stack(
              children: [
                Container(
                  height: AppSize.size(context).height * 0.15,
                  width: AppSize.size(context).width * 0.25,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(width: 2)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    // Ensures the image respects the container's borderRadius
                    child: Image.file(File(quickDocketController.selectedImages[index].path), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: -12,
                  right: -12,
                  child: IconButton(
                    iconSize: 20,
                    onPressed: () {
                      setState(() {
                        quickDocketController.selectedImages.removeAt(index);
                      });
                    },
                    icon: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.red),
                  ),
                ),
              ],
            );
          } else {
            return SizedBox();
          }
        });
      }),
    );
  }

  final GlobalKey<FormState> productFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> packageTypeFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> numberPkgFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> declaredValueFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> actualWeightFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> valueMetricFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> eWayBillWeightFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> transportModelFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> consigneeFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> consignorFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> vehicleNumberFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> fromPinCodeFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> toPinCodeFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> toCityFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> billingPartyFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> billingTypeFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> destinationFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> invoiceNoFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> docketNoFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> lengthNoFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> breadthNoFromKey = GlobalKey<FormState>();
  final GlobalKey<FormState> heightNoFromKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayColor: Colors.black.withOpacity(0.3),
      child: WillPopScope(
        onWillPop: () async {
          quickDocketController.ctrlClear();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const TmsText(text: 'Quick Docket', color: Colors.white, fontWeight: FontWeight.bold),
            centerTitle: true,
            backgroundColor: const Color(0xff232F34),
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Get.back();
                quickDocketController.ctrlClear();
              },
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 4),
                      Form(
                        key: docketNoFromKey,
                        child: TextFormField(
                          focusNode: quickDocketController.docketFocus,
                          controller: quickDocketController.docketNoController,
                          style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                          decoration: InputDecoration(
                            labelText: 'Docket No',
                            labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xff232F34)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                          ),
                          onChanged: (value) {
                            quickDocketController.docketCheckDataStatus.value = docketCheck.none;
                          },
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter Docket No';
                            }
                            return null;
                          },
                        ),
                      ),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.payBaseDataStatus.value) {
                          case DataStatus.completed:
                            return InkWell(
                              onTap: () {
                                quickDocketController.textFocus();
                              },
                              child: Dropdown(
                                height: 30.0.obs,
                                enabled: true.obs,
                                isSize: false,
                                text: 'Select Paybase Type '.obs,
                                label: "Paybase Type",
                                list: quickDocketController.payBasList.map((e) => e.codeDesc).toList(),
                                onChanged: (value) {
                                  if (quickDocketController.docketCheckDataStatus.value == docketCheck.wrong) {
                                    if (quickDocketController.docketNoController.text.isNotEmpty) {
                                      quickDocketController.docketCheckApi(
                                        context: context,
                                        isPayBaseType: true,
                                        billingTypeFromKey: billingTypeFromKey,
                                        billingPartyFromKey: billingPartyFromKey,
                                        transportModelFromKey: transportModelFromKey,
                                        invoiceNoFromKey: invoiceNoFromKey,
                                        productFromKey: productFromKey,
                                        packageTypeFromKey: packageTypeFromKey,
                                        lengthNoFromKey: lengthNoFromKey,
                                        breadthNoFromKey: breadthNoFromKey,
                                        heightNoFromKey: heightNoFromKey,
                                        numberPkgFromKey: numberPkgFromKey,
                                        declaredValueFromKey: declaredValueFromKey,
                                        toPinCodeFromKey: toPinCodeFromKey,
                                        actualWeightFromKey: actualWeightFromKey,
                                        consignorFromKey: consignorFromKey,
                                        consigneeFromKey: consigneeFromKey,
                                        fromPinCodeFromKey: fromPinCodeFromKey,
                                      );
                                    }
                                  }
                                  quickDocketController.textFocus();
                                  quickDocketController.billingSelectType(value!);
                                  for (var data in quickDocketController.payBasList) {
                                    if (data.codeDesc == value) {
                                      quickDocketController.consignorId = data.codeAccess;
                                    }
                                  }
                                  quickDocketController.custListApi(context: context);
                                  if (value == "Paid") {
                                    quickDocketController.isConsignee.value = true;
                                    quickDocketController.isConsignor.value = false;
                                  } else if (value == "To Pay") {
                                    quickDocketController.isConsignee.value = false;
                                    quickDocketController.isConsignor.value = true;
                                  } else {
                                    quickDocketController.isConsignee.value = true;
                                    quickDocketController.isConsignor.value = false;
                                  }

                                  quickDocketController.selectConsignor.value = 'Select Consignor';
                                  quickDocketController.selectConsignee.value = 'Select Consignee';
                                  quickDocketController.consignorName.value = 'Select Billing Party';
                                },
                                globalKey: billingTypeFromKey,
                                validator: (value) {
                                  if (value == null || value == '') {
                                    return 'Please Select Paybase Type';
                                  }
                                  return null;
                                },
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.billingTypeApi();
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());
                        }
                      }),
                      _sizedBox12,
                      Obx(
                        () => InkWell(
                          onTap: () {
                            quickDocketController.textFocus();
                            if (quickDocketController.billingType.isEmpty && quickDocketController.originLocation.isEmpty) {
                              TmsToast.msg('Please select Origin Location && Billing Type ');
                            } else if (quickDocketController.billingType.isEmpty) {
                              TmsToast.msg('Please select Billing Type ');
                            } else if (quickDocketController.originLocation.isEmpty) {
                              TmsToast.msg('Please select Origin Location Type ');
                            }
                          },
                          child: Dropdown(
                            height: 30.0.obs,
                            enabled: (quickDocketController.customerList.isNotEmpty ? true : false).obs,
                            isSize: false,
                            text: quickDocketController.consignorName.isEmpty ? 'Select Billing Party'.obs : quickDocketController.consignorName,
                            label: "Billing Party",
                            selectedItem: quickDocketController.consignorName,
                            list: quickDocketController.customerList.map((element) => "${element.custcd} - ${element.custnm}").toList(),
                            onChanged: (value) {
                              quickDocketController.consignorId = value!.split(" - ").first;
                              quickDocketController.billingPartyCheckApi(billingPartyId: quickDocketController.consignorId);
                              quickDocketController.consignorName.value = quickDocketController.customerList
                                  .where((innerValue) => innerValue.custcd.contains(quickDocketController.consignorId))
                                  .first
                                  .custnm;
                              for (var data in quickDocketController.customerList) {
                                if (data.custcd == value.split(" - ").first) {
                                  quickDocketController.isValueMetrics.value = data.volYn == "Y" ? true : false;
                                }
                              }

                              if (quickDocketController.billingType.value == "P01") {
                                quickDocketController.selectConsignor.value = quickDocketController.consignorName.value;
                                quickDocketController.selectConsignorId.value = quickDocketController.consignorId;
                              } else if (quickDocketController.billingType.value == "P03") {
                                quickDocketController.selectConsignee.value = quickDocketController.consignorName.value;
                                quickDocketController.selectConsigneeId.value = quickDocketController.consignorId;
                              } else {
                                if (quickDocketController.selectedTBBValue.value == "Consignor") {
                                  quickDocketController.selectConsignor.value = quickDocketController.consignorName.value;
                                  quickDocketController.selectConsignorId.value = quickDocketController.consignorId;
                                } else {
                                  quickDocketController.selectConsignee.value = quickDocketController.consignorName.value;
                                  quickDocketController.selectConsigneeId.value = quickDocketController.consignorId;
                                }
                              }
                              quickDocketController.textFocus();
                              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${quickDocketController.consignorId}");
                              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${quickDocketController.consignorName.value}");
                            },
                            globalKey: billingPartyFromKey,
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Please Select Billing Party ';
                              }
                              if (value == "Select Billing Party") {
                                return 'Please Select Billing Party ';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      _sizedBox12,
                      Obx(() {
                        if (quickDocketController.billingType.value == "P02") {
                          return Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Radio<String>(
                                  value: "Consignor",
                                  groupValue: quickDocketController.selectedTBBValue.value,
                                  activeColor: Color(0xff232F34),
                                  onChanged: (value) {
                                    setState(() {
                                      quickDocketController.selectedTBBValue.value = value!;
                                      quickDocketController.selectConsignor.value = quickDocketController.consignorName.value;
                                      quickDocketController.selectConsignorId.value = quickDocketController.consignorId;
                                      quickDocketController.selectConsignee.value = 'Select Consignee';
                                      quickDocketController.selectConsigneeId.value = '';
                                      quickDocketController.isConsignee.value = true;
                                      quickDocketController.isConsignor.value = false;
                                    });
                                  },
                                ),
                                const Text("Consignor"),
                                const SizedBox(width: 20),
                                Radio<String>(
                                  value: "Consignee",
                                  groupValue: quickDocketController.selectedTBBValue.value,
                                  activeColor: Color(0xff232F34),
                                  onChanged: (value) {
                                    setState(() {
                                      quickDocketController.selectedTBBValue.value = value!;
                                      quickDocketController.selectConsignee.value = quickDocketController.consignorName.value;
                                      quickDocketController.selectConsigneeId.value = quickDocketController.consignorId;
                                      quickDocketController.selectConsignor.value = 'Select Consignor';
                                      quickDocketController.selectConsignorId.value = '';
                                      quickDocketController.isConsignee.value = false;
                                      quickDocketController.isConsignor.value = true;
                                    });
                                  },
                                ),
                                const Text("Consignee"),
                              ],
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }),
                      _sizedBox12,
                      Obx(() {
                        return InkWell(
                          onTap: () {
                            quickDocketController.textFocus();
                          },
                          child: Dropdown(
                            enabled: quickDocketController.isConsignor,
                            height: 30.0.obs,
                            isSize: false,
                            text: quickDocketController.selectConsignor.isEmpty ? 'Select Consignor'.obs : quickDocketController.selectConsignor,
                            label: "Consignor",
                            list: quickDocketController.consignorList.map((element) => '${element.custnm}').toList(),
                            selectedItem: quickDocketController.selectConsignor,
                            onChanged: (value) {
                              quickDocketController.textFocus();
                              for (var data in quickDocketController.consignorList) {
                                if (data.custnm == value) {
                                  quickDocketController.selectConsignorId.value = data.custcd;
                                  quickDocketController.selectConsignor.value = data.custnm;
                                }
                              }
                            },
                            globalKey: consignorFromKey,
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Please Select Consignor ';
                              }

                              if (value == "Select Consignor") {
                                return 'Please Select Consignor ';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      _sizedBox12,
                      Obx(() {
                        return InkWell(
                          onTap: () {
                            quickDocketController.textFocus();
                          },
                          child: Dropdown(
                            enabled: quickDocketController.isConsignee,
                            height: 30.0.obs,
                            isSize: false,
                            text: quickDocketController.selectConsignee.isEmpty ? 'Select Consignee'.obs : quickDocketController.selectConsignee,
                            label: "Consignee",
                            selectedItem: quickDocketController.selectConsignee,
                            list: quickDocketController.consignorList.map((element) => '${element.custnm}').toList(),
                            onChanged: (value) {
                              quickDocketController.textFocus();
                              for (var data in quickDocketController.consignorList) {
                                if (data.custnm == value) {
                                  quickDocketController.selectConsigneeId.value = data.custcd;
                                  quickDocketController.selectConsignee.value = data.custnm;
                                }
                              }
                            },
                            globalKey: consigneeFromKey,
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Please Select Consignee ';
                              }

                              if (value == "Select Consignee") {
                                return 'Please Select Consignee ';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.transportModelDataStatus.value) {
                          case DataStatus.completed:
                            return Obx(
                              () => InkWell(
                                onTap: () {
                                  quickDocketController.textFocus();
                                },
                                child: Dropdown(
                                  enabled: quickDocketController.eWayBillStatus.value == eWayBill.withoutEWayBill ? true.obs : false.obs,
                                  height: 30.0.obs,
                                  isSize: false,
                                  text: quickDocketController.eWayBillStatus.value == eWayBill.withoutEWayBill
                                      ? 'Select Transport Model'.obs
                                      : quickDocketController.selectTransportModel,
                                  label: "Transport Model",
                                  list: quickDocketController.eWayBillStatus.value == eWayBill.withoutEWayBill
                                      ? quickDocketController.transportModelList.map((element) => '${element.codeDesc}').toList()
                                      : [quickDocketController.selectTransportModel.value],
                                  onChanged: (value) async {
                                    quickDocketController.selectTransportModel.value = value!;
                                    quickDocketController.textFocus();
                                    for (var data in quickDocketController.transportModelList) {
                                      if (data.codeDesc == value) {
                                        quickDocketController.selectTransportId.value = data.codeId;
                                      }
                                    }
                                  },
                                  globalKey: transportModelFromKey,
                                  validator: (value) {
                                    if (value == null || value == '') {
                                      return 'Please Select Transport Model ';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.transportModelApi();
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());

                          default:
                            return SizedBox();
                        }
                      }),
                      _sizedBox12,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio<String>(
                            value: "OWN",
                            groupValue: quickDocketController.selectedValue.value,
                            activeColor: Color(0xff232F34),
                            onChanged: (value) {
                              setState(() {
                                quickDocketController.selectedValue.value = value!;
                                quickDocketController.vehicleNoController.value.clear();
                              });
                            },
                          ),
                          const Text("Own"),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: "Market",
                            groupValue: quickDocketController.selectedValue.value,
                            activeColor: Color(0xff232F34),
                            onChanged: (value) {
                              setState(() {
                                quickDocketController.selectedValue.value = value!;
                                quickDocketController.selectVehicleNumber.value = '';
                              });
                            },
                          ),
                          const Text("Market"),
                        ],
                      ),
                      if (quickDocketController.selectedValue.value == "OWN") ...{
                        Obx(() {
                          return InkWell(
                            onTap: () {
                              quickDocketController.textFocus();
                            },
                            child: Dropdown(
                              enabled: true.obs,
                              height: 30.0.obs,
                              isSize: false,
                              text: 'Select Vehicle Number'.obs,
                              label: "Vehicle Number",
                              list: quickDocketController.vehicleList.map((element) => '${element.vehno}').toList(),
                              onChanged: (value) async {
                                quickDocketController.selectVehicleNumber.value = value!;
                                quickDocketController.textFocus();
                              },
                              globalKey: vehicleNumberFromKey,
                            ),
                          );
                        }),
                      } else ...{
                        Form(
                          key: vehicleNumberFromKey,
                          child: TextFormField(
                            controller: quickDocketController.vehicleNoController.value,
                            style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                return newValue.copyWith(text: newValue.text.toUpperCase(), selection: newValue.selection);
                              }),
                              LengthLimitingTextInputFormatter(10),
                            ],
                            decoration: InputDecoration(
                              labelText: 'Vehicle No',
                              labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                              hintStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff232F34)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return null;
                              }

                              final RegExp indianVehicleRegex = RegExp(r'^[A-Z]{2}\d{1,2}[A-Z]{1,2}\d{4}$');

                              if (!indianVehicleRegex.hasMatch(value.trim().toUpperCase())) {
                                return 'Enter a valid Indian vehicle number (e.g. MH12AB1234)';
                              }

                              return null;
                            },
                          ),
                        ),
                      },
                      _sizedBox12,
                      originLocationDropdown(context),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.fromPinCodeDataStatus.value) {
                          case DataStatus.completed:
                            return Obx(
                              () => InkWell(
                                onTap: () {
                                  quickDocketController.textFocus();
                                },
                                child: Dropdown(
                                  enabled: quickDocketController.eWayBillStatus.value == eWayBill.withoutEWayBill ? true.obs : false.obs,
                                  height: 30.0.obs,
                                  isSize: false,
                                  text: quickDocketController.eWayBillStatus.value == eWayBill.withoutEWayBill
                                      ? 'Select From Pincode'.obs
                                      : quickDocketController.selectFromPinCode,
                                  label: "From Pincode",
                                  list: quickDocketController.eWayBillStatus.value == eWayBill.withoutEWayBill
                                      ? quickDocketController.fromPinCodeList.map((element) => '${element.value}').toList()
                                      : [quickDocketController.selectFromPinCode.value],
                                  onChanged: (value) async {
                                    quickDocketController.selectFromPinCode.value = value!;
                                    quickDocketController.textFocus();
                                  },
                                  globalKey: fromPinCodeFromKey,
                                  validator: (value) {
                                    if (value == null || value == '') {
                                      return 'Please Select From Pincode';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.fromPinCodeApi(quickDocketController.fromCityId);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());

                          default:
                            return SizedBox();
                        }
                      }),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.locationDataStatus.value) {
                          case DataStatus.completed:
                            return InkWell(
                              onTap: () {
                                quickDocketController.textFocus();
                              },
                              child: Dropdown(
                                height: 30.0.obs,
                                enabled: true.obs,
                                isSize: false,
                                text: 'Select Destination '.obs,
                                label: "Destination",
                                list: quickDocketController.location.map((e) => e.locCode).toList(),
                                onChanged: (value) {
                                  quickDocketController.destinationId = value ?? '';
                                  quickDocketController.toCityApi(quickDocketController.destinationId);
                                },
                                globalKey: destinationFromKey,
                                validator: (value) {
                                  if (value == null || value == '') {
                                    return 'Please Select Destination';
                                  }
                                  return null;
                                },
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.toCityApi(quickDocketController.destinationId);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());
                        }
                      }),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.toCityDataStatus.value) {
                          case DataStatus.completed:
                            return InkWell(
                              onTap: () {
                                quickDocketController.textFocus();
                              },
                              child: Dropdown(
                                height: 30.0.obs,
                                enabled: true.obs,
                                isSize: false,
                                text: 'Select To City '.obs,
                                label: "To City",
                                list: quickDocketController.toCityList.map((e) => e.location).toList(),
                                onChanged: (value) {
                                  for (var data in quickDocketController.toCityList) {
                                    if (data.location == value) {
                                      quickDocketController.toCityId = data.cityCode;
                                    }
                                  }
                                  quickDocketController.toPinCodeApi(quickDocketController.toCityId);
                                },
                                globalKey: toCityFromKey,
                                validator: (value) {
                                  if (value == null || value == '') {
                                    return 'Please Select To City';
                                  }
                                  return null;
                                },
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.toCityApi(quickDocketController.destinationId);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());
                        }
                      }),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.toPinCodeDataStatus.value) {
                          case DataStatus.completed:
                            return InkWell(
                              onTap: () {
                                quickDocketController.textFocus();
                              },
                              child: Dropdown(
                                height: 30.0.obs,
                                enabled: true.obs,
                                isSize: false,
                                text: 'Select To PinCode '.obs,
                                label: "To PinCode",
                                list: quickDocketController.toPinCodeList.map((e) => e.value).toList(),
                                onChanged: (value) {
                                  quickDocketController.toPinCode = value ?? '';
                                },
                                globalKey: toPinCodeFromKey,
                                validator: (value) {
                                  if (value == null || value == '') {
                                    return 'Please Select To PinCode';
                                  }
                                  return null;
                                },
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.toPinCodeApi(quickDocketController.toCityId);
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());
                        }
                      }),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TmsText(text: "Fulfillment Details", color: AppColor.blue, fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      Obx(
                        () => ListView.builder(
                          itemCount: quickDocketController.docketInvoiceList.length,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final invoice = quickDocketController.docketInvoiceList[index];
                            return Container(
                              width: double.infinity,
                              decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(width: 10),
                                    TmsText(text: invoice.invno, fontWeight: FontWeight.bold, maxLines: 1),
                                    Expanded(child: TmsText(text: "${invoice.decval}", maxLines: 1)),
                                    IconButton(
                                      icon: Icon(CupertinoIcons.delete),
                                      color: Colors.red,
                                      onPressed: () {
                                        quickDocketController.docketInvoiceList.removeAt(index);
                                      },
                                      splashRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Obx(() {
                        if (quickDocketController.eWayBillStatus.value == eWayBill.withEWayBill) {
                          return Form(
                            child: TextFormField(
                              enabled: false,
                              controller: TextEditingController(text: quickDocketController.selectEWayBillState.value),
                              style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'EWB State',
                                labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                hintStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w500),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff232F34)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }),
                      _sizedBox,
                      Obx(() {
                        if (quickDocketController.eWayBillStatus.value == eWayBill.withEWayBill) {
                          return Form(
                            key: eWayBillWeightFromKey,
                            child: TextFormField(
                              focusNode: quickDocketController.eWayBillNo,
                              controller: quickDocketController.eWayBillNoController,
                              enabled: quickDocketController.isEWayNumber.value,
                              style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                labelText: 'EWB Number',
                                labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                hintStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w500),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xff232F34)),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the EWB number';
                                }
                                return null;
                              },
                              onChanged: (value) {
                                quickDocketController.isEWBEmpty.value = value.trim().isEmpty;
                                bool isEmpty = value.trim().isEmpty;

                                quickDocketController.isDeclared.value = isEmpty;
                                quickDocketController.isInvoice.value = isEmpty;
                                quickDocketController.isNumberOfPkg.value = isEmpty;
                                quickDocketController.isActualWeight.value = isEmpty;
                                quickDocketController.isPackage.value = isEmpty;
                                quickDocketController.isProduct.value = isEmpty;
                                quickDocketController.isHeight.value = isEmpty;
                                quickDocketController.isBreadth.value = isEmpty;
                                quickDocketController.isLength.value = isEmpty;
                              },
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      }),
                      _sizedBox,
                      Obx(() {
                        if (quickDocketController.isEWBEmpty.isFalse) {
                          return ElevatedButton(
                            onPressed: () {
                              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${quickDocketController.consignorId}");
                              print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${quickDocketController.consignorName.value}");
                              bool isAdded = quickDocketController.docketInvoiceList.any(
                                (data) => data.ewbno == quickDocketController.eWayBillNoController.text,
                              );

                              if (isAdded) {
                                TmsToast.msg("${quickDocketController.eWayBillNoController.text} number was already added");
                              } else {
                                quickDocketController.eWayBillApi(
                                  eWayNumber: quickDocketController.eWayBillNoController.text,
                                  stateGst: quickDocketController.selectGetNO.value,
                                  isQrScan: false,
                                  isMenuScreen: false,
                                  context: context,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff232F34),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                            ),
                            child: TmsText(text: 'EWB Check', color: Colors.white),
                          );
                        }
                        return SizedBox();
                      }),
                      _sizedBox12,
                      Obx(() {
                        return Form(
                          key: invoiceNoFromKey,
                          child: TextFormField(
                            focusNode: quickDocketController.invoiceNumber,
                            enabled: quickDocketController.isInvoice.value,
                            controller: quickDocketController.invoiceNoController,
                            style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'invoice No',
                              labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                              hintStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff232F34)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value == '') {
                                return 'Please Enter Invoice No';
                              }
                              return null;
                            },
                          ),
                        );
                      }),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.productDataStatus.value) {
                          case DataStatus.completed:
                            return InkWell(
                              onTap: () {
                                quickDocketController.textFocus();
                              },
                              child: Dropdown(
                                enabled: quickDocketController.isProduct,
                                height: 30.0.obs,
                                isSize: false,
                                text: 'Select Product'.obs,
                                label: "Product",
                                list: quickDocketController.productList.map((element) => '${element.codeDesc}').toList(),
                                onChanged: (value) async {
                                  quickDocketController.textFocus();
                                  for (var data in quickDocketController.productList) {
                                    if (data.codeDesc == value) {
                                      quickDocketController.selectProduct = data.codeId;
                                    }
                                  }
                                },
                                globalKey: productFromKey,
                                validator: (value) {
                                  if (value == null || value == '') {
                                    return 'Please Select Product';
                                  }
                                  return null;
                                },
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.productApi();
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());

                          default:
                            return SizedBox();
                        }
                      }),
                      _sizedBox12,
                      Obx(() {
                        switch (quickDocketController.packageTypeDataStatus.value) {
                          case DataStatus.completed:
                            return InkWell(
                              onTap: () {
                                quickDocketController.textFocus();
                              },
                              child: Dropdown(
                                enabled: quickDocketController.isPackage,
                                height: 30.0.obs,
                                isSize: false,
                                text: 'Select Package Type'.obs,
                                label: "Package Type",
                                list: quickDocketController.packageTypeList.map((element) => '${element.codeDesc}').toList(),
                                onChanged: (value) async {
                                  quickDocketController.textFocus();
                                  for (var data in quickDocketController.packageTypeList) {
                                    if (data.codeDesc == value) {
                                      quickDocketController.selectPackage = data.codeId;
                                    }
                                  }
                                },
                                globalKey: packageTypeFromKey,
                                validator: (value) {
                                  if (value == null || value == '') {
                                    return 'Please Select Package Type';
                                  }
                                  return null;
                                },
                              ),
                            );

                          case DataStatus.error:
                            return Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Icon(Icons.error, color: Colors.white),
                                ),
                                SizedBox(height: 10),
                                Text('Failed to load data. Please try again.'),
                                ElevatedButton(
                                  onPressed: () {
                                    quickDocketController.packageTypeApi();
                                  },
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff232F34)),
                                  child: Text('Retry', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );

                          case DataStatus.loading:
                            return Center(child: CircularProgressIndicator());

                          default:
                            return SizedBox();
                        }
                      }),
                      Obx(() => quickDocketController.isValueMetrics.isTrue ? _sizedBox12 : SizedBox()),
                      Obx(() {
                        if (quickDocketController.isValueMetrics.isTrue) {
                          return Row(
                            children: [
                              Form(
                                key: lengthNoFromKey,
                                child: Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: TextFormField(
                                      focusNode: quickDocketController.length,
                                      enabled: quickDocketController.isLength.value,
                                      controller: quickDocketController.lengthController,
                                      decoration: InputDecoration(
                                        labelText: 'Length',
                                        labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: Color(0xff232F34)),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                                      inputFormatters: [DecimalTextInputFormatter()],
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter length';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Obx(() {
                                return Form(
                                  key: breadthNoFromKey,
                                  child: Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 0),
                                      child: TextFormField(
                                        controller: quickDocketController.breadthController,
                                        focusNode: quickDocketController.breadth,
                                        enabled: quickDocketController.isBreadth.value,
                                        decoration: InputDecoration(
                                          labelText: 'Breadth',
                                          labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xff232F34)),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [DecimalTextInputFormatter()],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter breadth';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 10),
                              Form(
                                key: heightNoFromKey,
                                child: Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 0),
                                    child: Obx(() {
                                      return TextFormField(
                                        controller: quickDocketController.heightController,
                                        focusNode: quickDocketController.height,
                                        enabled: quickDocketController.isHeight.value,
                                        decoration: InputDecoration(
                                          labelText: 'Height',
                                          labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xff232F34)),
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                        ),
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        inputFormatters: [DecimalTextInputFormatter()],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter height';
                                          }
                                          return null;
                                        },
                                      );
                                    }),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return SizedBox();
                      }),
                      _sizedBox12,
                      Row(
                        children: [
                          Expanded(
                            child: Form(
                              key: numberPkgFromKey,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Obx(() {
                                  return TextFormField(
                                    controller: quickDocketController.noOfPackageController,
                                    focusNode: quickDocketController.noOfPackage,
                                    enabled: quickDocketController.isNumberOfPkg.value,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      labelText: 'Number of PKG',
                                      labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xff232F34)),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the number of packages';
                                      }
                                      return null;
                                    },
                                  );
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Obx(() {
                            return Expanded(
                              child: Form(
                                key: declaredValueFromKey,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: TextFormField(
                                    focusNode: quickDocketController.declaredValue,
                                    enabled: quickDocketController.isDeclared.value,
                                    controller: quickDocketController.declaredValueController,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {}
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Declared Value',
                                      labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                      hintStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w500),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Color(0xff232F34)),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter the declared value';
                                      }

                                      final declaredValue = double.tryParse(value) ?? 0;

                                      if (declaredValue > 50000 && (quickDocketController.eWayBillNoController.text.isEmpty)) {
                                        return 'Ewaybill required if declared value is more than 50,000';
                                      }

                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      _sizedBox12,
                      Form(
                        key: actualWeightFromKey,
                        child: Obx(() {
                          return TextFormField(
                            focusNode: quickDocketController.actualWeight,
                            controller: quickDocketController.actualWeightController,
                            enabled: quickDocketController.isActualWeight.value,
                            style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              labelText: 'Actual Weight',
                              labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
                              hintStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.w500),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Color(0xff232F34)),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the actual weight';
                              }
                              return null;
                            },
                          );
                        }),
                      ),
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: TmsButton(
                              text: 'ADD INVOICE',
                              size: Size(double.infinity, AppSize.size(context).height * 0.06),
                              onPressed: () {
                                if (invoiceNoFromKey.currentState!.validate() &&
                                    productFromKey.currentState!.validate() &&
                                    packageTypeFromKey.currentState!.validate() &&
                                    (quickDocketController.isValueMetrics.isTrue
                                        ? (lengthNoFromKey.currentState!.validate() &&
                                              breadthNoFromKey.currentState!.validate() &&
                                              heightNoFromKey.currentState!.validate())
                                        : true) &&
                                    numberPkgFromKey.currentState!.validate() &&
                                    declaredValueFromKey.currentState!.validate() &&
                                    actualWeightFromKey.currentState!.validate()) {
                                  quickDocketController.docketInvoiceList.add(
                                    DocketInvoiceList(
                                      invno: quickDocketController.invoiceNoController.text,
                                      prodcd: quickDocketController.selectProduct,
                                      pkgsty: quickDocketController.selectPackage,
                                      pkgs: parseInputToInt(quickDocketController.noOfPackageController.text),
                                      decval: parseInputToDouble(quickDocketController.declaredValueController.text),
                                      actuwt: parseInputToDouble(quickDocketController.actualWeightController.text),
                                      ewbno: quickDocketController.eWayBillNoController.text,
                                      voLL: parseInputToDouble(quickDocketController.lengthController.text),
                                      voLB: parseInputToDouble(quickDocketController.breadthController.text),
                                      voLH: parseInputToDouble(quickDocketController.heightController.text),
                                      eWayBillExpiredDate: quickDocketController.eWayBillExpiredDate,
                                      eWayBillInvoiceDate: quickDocketController.eWayBillInvoiceDate,
                                    ),
                                  );
                                  quickDocketController.isEWayNumber.value = true;
                                  quickDocketController.isDeclared.value = true;
                                  quickDocketController.isInvoice.value = true;

                                  quickDocketController.isDeclared.value = true;
                                  quickDocketController.isInvoice.value = true;
                                  quickDocketController.isNumberOfPkg.value = true;
                                  quickDocketController.isActualWeight.value = true;
                                  quickDocketController.isPackage.value = true;
                                  quickDocketController.isProduct.value = true;
                                  quickDocketController.isHeight.value = true;
                                  quickDocketController.isBreadth.value = true;
                                  quickDocketController.isLength.value = true;
                                  quickDocketController.invoiceNoController.clear();
                                  quickDocketController.noOfPackageController.clear();
                                  quickDocketController.declaredValueController.clear();
                                  quickDocketController.actualWeightController.clear();
                                  quickDocketController.actualWeightController.clear();
                                  quickDocketController.eWayBillNoController.clear();
                                  quickDocketController.breadthController.clear();
                                  quickDocketController.lengthController.clear();
                                  quickDocketController.heightController.clear();
                                }
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff232F34),
                              minimumSize: Size(double.infinity, AppSize.size(context).height * 0.06),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              showPickerDialog();
                            },
                            child: Icon(Icons.camera_alt, color: Colors.white),
                          ),
                          SizedBox(height: 10),
                          Obx(() {
                            if (quickDocketController.selectedImages.isNotEmpty) {
                              return Container(height: AppSize.size(context).height * 0.10, child: imageView());
                            } else {
                              return SizedBox();
                            }
                          }),
                          SizedBox(height: 10),
                          TmsButton(
                            text: 'Submit',
                            size: Size(double.infinity, AppSize.size(context).height * 0.06),
                            onPressed: () {
                              if (quickDocketController.docketNoController.text.isEmpty) {
                                quickDocketController.submitValidator(
                                  billingTypeFromKey: billingTypeFromKey,
                                  billingPartyFromKey: billingPartyFromKey,
                                  transportModelFromKey: transportModelFromKey,
                                  toPinCodeFromKey: toPinCodeFromKey,
                                  invoiceNoFromKey: invoiceNoFromKey,
                                  productFromKey: productFromKey,
                                  packageTypeFromKey: packageTypeFromKey,
                                  lengthNoFromKey: lengthNoFromKey,
                                  breadthNoFromKey: breadthNoFromKey,
                                  heightNoFromKey: heightNoFromKey,
                                  numberPkgFromKey: numberPkgFromKey,
                                  declaredValueFromKey: declaredValueFromKey,
                                  fromPinCodeFromKey: fromPinCodeFromKey,
                                  consignorFromKey: consignorFromKey,
                                  consigneeFromKey: consigneeFromKey,
                                  actualWeightFromKey: actualWeightFromKey,
                                );
                              } else {
                                if (docketNoFromKey.currentState!.validate()) {
                                  quickDocketController.docketCheckApi(
                                    context: context,
                                    isPayBaseType: false,
                                    billingTypeFromKey: billingTypeFromKey,
                                    billingPartyFromKey: billingPartyFromKey,
                                    transportModelFromKey: transportModelFromKey,
                                    toPinCodeFromKey: toPinCodeFromKey,
                                    invoiceNoFromKey: invoiceNoFromKey,
                                    productFromKey: productFromKey,
                                    packageTypeFromKey: packageTypeFromKey,
                                    lengthNoFromKey: lengthNoFromKey,
                                    breadthNoFromKey: breadthNoFromKey,
                                    heightNoFromKey: heightNoFromKey,
                                    numberPkgFromKey: numberPkgFromKey,
                                    consignorFromKey: consignorFromKey,
                                    consigneeFromKey: consigneeFromKey,
                                    declaredValueFromKey: declaredValueFromKey,
                                    actualWeightFromKey: actualWeightFromKey,
                                    fromPinCodeFromKey: fromPinCodeFromKey,
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  parseInputToDouble(String input) {
    if (input.isEmpty) {
      return 0.0;
    }
    return double.tryParse(input) ?? 0.0;
  }

  parseInputToInt(String input) {
    if (input.isEmpty) {
      return 0;
    }
    return int.tryParse(input) ?? 0;
  }

  originLocationDropdown(context) {
    return Dropdown(
      height: 30.0.obs,
      enabled: quickDocketController.eWayBillStatus.value == eWayBill.withEWayBill ? false.obs : true.obs,
      isSize: false,
      boxDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey, width: 1),
      ),
      text: quickDocketController.fromCity.obs,
      label: "From City",
      list: quickDocketController.cityList.map((element) => '${element.location}').toList(),
      onChanged: (value) {
        quickDocketController.fromCity = value!;
        if (quickDocketController.eWayBillStatus.value == eWayBill.withoutEWayBill) {
          for (var data in quickDocketController.cityList) {
            if (value == data.location) {
              quickDocketController.fromCityId = data.cityCode;
            }
          }
          quickDocketController.fromPinCodeApi(quickDocketController.fromCityId);
        }
      },
    );
  }

  docketNoTextField() {
    return SizedBox(
      height: 58,
      child: TextFormField(
        focusNode: quickDocketController.docketFocus,
        controller: quickDocketController.docketNoController,
        style: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: 'Docket No',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xff232F34)),
            borderRadius: BorderRadius.circular(15),
          ),
          labelStyle: GoogleFonts.urbanist(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  InfoText() {
    return Row(
      children: [
        Image(image: AssetImage('assets/images/dashboardimages/Info.png'), height: 20),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: TmsText(
            textAlign: TextAlign.start,
            text: 'Please enter correct docket no. \nIf you don’t have docket no. system will auto generate it.',
            fontSize: 10,
            color: Color(0xff232F34),
          ),
        ),
      ],
    );
  }

  customInfo({required String text}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Image(image: AssetImage('assets/images/dashboardimages/Info.png'), height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: TmsText(textAlign: TextAlign.start, text: text, fontSize: 10, color: Color(0xff232F34)),
          ),
        ],
      ),
    );
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final RegExp _regExp = RegExp(r'^\d{0,2}(\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }
    if (_regExp.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}
