import 'package:get/get.dart';
import '../controllers/home_page_controller.dart';

class HomePageBindings implements Bindings {
  @override
  void dependencies() {
    Get.put(HomePageController(), permanent: true);
  }
}
