import 'package:zest/app/utils/snackbar_overlay.dart';

void showSnackBar(String message, {bool isError = false, bool isInfo = false}) {
  SnackBarOverlay.instance.show(message, isError: isError, isInfo: isInfo);
}
