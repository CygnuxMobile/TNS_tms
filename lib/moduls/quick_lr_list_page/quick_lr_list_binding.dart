import 'package:get/get.dart';
import '../../moduls/quick_lr_list_page/quick_lr_list_controller.dart';

class QuickLrListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => QuickLrListController());
  }
}
