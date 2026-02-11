import 'package:get/get.dart';

class FabController extends GetxController {
  final RxBool _isVisible = true.obs;

  RxBool get isVisible => _isVisible;

  void setVisibility(bool visible) {
    if (_isVisible.value != visible) {
      _isVisible.value = visible;
    }
  }
}
