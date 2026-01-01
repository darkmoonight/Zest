import 'package:get/get.dart';

class FabController extends GetxController {
  final RxBool _isVisible = true.obs;

  RxBool get isVisible => _isVisible;

  void show() {
    if (!_isVisible.value) {
      _isVisible.value = true;
    }
  }

  void hide() {
    if (_isVisible.value) {
      _isVisible.value = false;
    }
  }
}
