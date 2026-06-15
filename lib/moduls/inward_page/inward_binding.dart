import 'package:get/get.dart';
import '../../moduls/inward_page/inward_controller.dart';

class InwardBinding extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut<InwardController>(() => InwardController());
  }
}