import 'package:get/get.dart';

class FabController extends GetxController {
  final RxBool isVisible = true.obs;

  void show() {
    isVisible.value = true;
  }

  void hide() {
    isVisible.value = false;
  }
}
