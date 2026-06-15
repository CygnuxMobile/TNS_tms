import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../main.dart';
import '../../../utils/pref.dart';
import '../../../utils/tms_color.dart';
import '../../../widgets/app_size.dart';
import '../../../widgets/tms_button.dart';
import '../pod_controller.dart';

/// Show dialog to open settings if permission is denied
Future<void> _showPermissionDialog(BuildContext context) async {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Permission Required"),
      content: Text("To pick images, please allow access to photos/camera."),
      actions: [
        TextButton(
          child: Text("Open Settings"),
          onPressed: () {
            openAppSettings();
            Navigator.of(context).pop();
          },
        ),
        TextButton(child: Text("Cancel"), onPressed: () => Navigator.of(context).pop()),
      ],
    ),
  );
}

/// Request and check both storage & manageExternalStorage permissions
Future<bool> checkStoragePermission(BuildContext context) async {
  if (await Permission.storage.isGranted) {
    return true;
  }

  Map<Permission, PermissionStatus> statuses = await [Permission.storage].request();

  _showPermissionDialog(context);

  return true;
}

/// Pick multiple images from gallery
Future<List<File>?> imagesFromGallery(BuildContext context) async {
  final List<XFile>? selectedFiles = await ImagePicker().pickMultiImage(imageQuality: 10);
  if (selectedFiles != null && selectedFiles.isNotEmpty) {
    return selectedFiles.map((file) => File(file.path)).toList();
  }
  return null;
}

/// Pick single image from camera
Future<File?> imageFromCamera(BuildContext context) async {
  PermissionStatus status = await Permission.camera.request();
  if (status.isGranted) {
    final XFile? capturedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 10,
    );
    if (capturedFile != null) {
      return File(capturedFile.path);
    }
  } else {
    _showPermissionDialog(context);
  }
  return null;
}

/// Grid view of selected images with delete option
Widget imageView({
  required RxList<String> pickImage,
  required String dockNo,
  required PodUploadController podUploadController,
}) {
  return Obx(() {
    print("🎯 Building imageView with ${pickImage.length} images");

    return GridView.builder(
      scrollDirection: Axis.horizontal,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: pickImage.length,
      itemBuilder: (context, index) {
        print("🖼️ Rendering image at index $index: ${pickImage[index]}");
        return Stack(
          children: [
            Container(
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(width: 2, color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(pickImage[index]),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    print("⚠️ Error loading image: $error");
                    return const Center(child: Text('Image error'));
                  },
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: GestureDetector(
                onTap: () {
                  final imagePath = pickImage[index];
                  final file = File(imagePath);

                  podDb.clearImageByPath(path: imagePath, dockNo: dockNo);

                  if (file.existsSync()) {
                    file.deleteSync();
                    print("🗑️ File deleted: $imagePath");
                  }

                  pickImage.removeAt(index);

                  if (pickImage.isEmpty) {
                    podDb.changeButtonName(buttonName: "Upload Pod", dockNo: dockNo);
                    podDb.changePodStatus(status: "No images uploaded", dockNo: dockNo);
                  }

                  podUploadController.podList.value = podDb.getAllDocket();
                },
                child: Container(
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(CupertinoIcons.xmark_circle_fill, color: Colors.red, size: 20),
                ),
              ),
            ),
          ],
        );
      },
    );
  });
}

/// Main Image Picker Widget
Widget podImagePicker({
  required PodUploadController podUploadController,
  required BuildContext context,
  required RxList<String> pickImage,
  required String docket,
  required int index,
}) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: SizedBox(
      width: double.infinity,
      child: Obx(() {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 5,
              width: 65,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Pick Image", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                /// CAMERA BUTTON
                Expanded(
                  child: GestureDetector(
                    onTap: pickImage.length >= 2
                        ? () {
                            Get.snackbar(
                              'Limit reached',
                              'You can only select up to 2 images.',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          }
                        : () async {
                            print("📸 Camera button tapped");
                            File? image = await imageFromCamera(context);
                            print("📸 Raw Image Picked: ${image?.path}");

                            if (image == null) return;

                            int imageNumber = pickImage.length + 1;

                            if (imageNumber > 2) {
                              Get.snackbar(
                                'Limit reached',
                                'You can only select Front and Back images.',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            String imageType = imageNumber == 1 ? "F" : "B";

                            String imageName = "P@${docket}_${imageType}@${Pref().getUserId()}@${Pref().getBranchCode()}.jpg";

                            final Directory cacheDir = await getTemporaryDirectory();
                            final Directory targetDir = Directory('${cacheDir.path}/image');

                            if (!(await targetDir.exists())) {
                              await targetDir.create(recursive: true);
                              print("📁 Directory created: ${targetDir.path}");
                            }

                            String newPath = '${targetDir.path}/$imageName';

                            File newImage = await image.copy(newPath);
                            print("✅ Copied image to: $newPath");

                            if (await newImage.exists()) {
                              pickImage.add(newImage.path);
                              print("📝 Added to pickImage list: ${newImage.path}");
                              print("🔄 pickImage list refreshed");
                            }
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: const Color(0xffe5eeff),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              color: AppColor.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Camera',
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12),

                /// GALLERY BUTTON
                Expanded(
                  child: GestureDetector(
                    onTap: pickImage.length >= 2
                        ? () {
                            Get.snackbar(
                              'Limit reached',
                              'You can only select up to 2 images.',
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            );
                          }
                        : () async {
                            print("🖼️ Gallery button tapped");

                            List<File> images = await imagesFromGallery(context) ?? [];
                            print("🖼️ Gallery selected: ${images.length} files");

                            int remainingSlots = 2 - pickImage.length;
                            if (remainingSlots <= 0) {
                              Get.snackbar(
                                'Limit reached',
                                'You can only select Front and Back images.',
                                backgroundColor: Colors.redAccent,
                                colorText: Colors.white,
                              );
                              return;
                            }

                            List<File> selectedImages = images.take(remainingSlots).toList();

                            final Directory cacheDir = await getTemporaryDirectory();
                            final Directory targetDir = Directory('${cacheDir.path}/image');

                            if (!(await targetDir.exists())) {
                              await targetDir.create(recursive: true);
                              print("📁 Directory created: ${targetDir.path}");
                            }

                            for (int i = 0; i < selectedImages.length; i++) {
                              File original = selectedImages[i];

                              int imageNumber = pickImage.length + 1;
                              if (imageNumber > 2) break;

                              String imageType = imageNumber == 1 ? "F" : "B";

                              String imageName = "P@${docket}_${imageType}@${Pref().getUserId()}@${Pref().getBranchCode()}.jpg";

                              String newPath = '${targetDir.path}/$imageName';

                              File savedFile = await original.copy(newPath);
                              pickImage.add(savedFile.path);

                              print("🖼️ Saved gallery file: ${savedFile.path}");
                            }
                          },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        color: const Color(0xffe5eeff),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.image,
                              color: AppColor.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Gallery',
                              style: TextStyle(
                                color: AppColor.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 25),

            /// Image View
            Obx(() {
              return pickImage.isNotEmpty
                  ? SizedBox(
                      height: AppSize.size(context).height * 0.12,
                      child: imageView(
                        pickImage: pickImage,
                        dockNo: docket,
                        podUploadController: podUploadController,
                      ),
                    )
                  : const SizedBox();
            }),

            /// Submit Button
            Obx(() {
              return pickImage.isNotEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 25),
                        SizedBox(
                          width: double.infinity,
                          child: TmsButton(
                            text: "+ Add",
                            color: AppColor.primaryColor,
                            onPressed: () {
                              if (pickImage.length < 2) {
                                Get.snackbar(
                                  'Add Both Images',
                                  'Please add both Front and Back images before submitting.',
                                  backgroundColor: Colors.redAccent,
                                  colorText: Colors.white,
                                );
                                return;
                              }

                              podDb.changePodStatus(
                                status: "Images uploaded - Pending submission",
                                dockNo: docket,
                              );
                              podDb.changeButtonName(buttonName: "Edit Pod", dockNo: docket);
                              podDb.imageInsert(dockNo: docket, podImage: pickImage);
                              podUploadController.podList.value = podDb.getAllDocket();
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    )
                  : const SizedBox();
            }),
          ],
        );
      }),
    ),
  );
}
