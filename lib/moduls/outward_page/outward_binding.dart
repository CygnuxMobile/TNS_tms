import 'package:get/get.dart';
import '../../moduls/outward_page/outward_controller.dart';

class OutWardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OutWardController>(() => OutWardController());
  }

}