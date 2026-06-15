import 'package:get/get.dart';
import '../../moduls/unloading_page/unloading_screen_controller.dart';

class UnloadingScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnloadingScreenController>(() => UnloadingScreenController());
  }
}
