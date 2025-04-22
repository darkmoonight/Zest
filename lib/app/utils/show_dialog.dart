import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<bool> showAdaptiveDialogTextIsNotEmpty({
  required BuildContext context,
  required VoidCallback onPressed,
}) async {
  return await showAdaptiveDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog.adaptive(
        title: _buildTitle(context),
        content: _buildContent(context),
        actions: _buildActions(context, onPressed),
      );
    },
  ).then((value) => value ?? false);
}

Widget _buildTitle(BuildContext context) {
  return Text('clearText'.tr, style: context.textTheme.titleLarge);
}

Widget _buildContent(BuildContext context) {
  return Text('clearTextWarning'.tr, style: context.textTheme.titleMedium);
}

List<Widget> _buildActions(BuildContext context, VoidCallback onPressed) {
  return [
    TextButton(
      onPressed: () => Get.back(result: false),
      child: Text(
        'cancel'.tr,
        style: context.theme.textTheme.titleMedium?.copyWith(
          color: Colors.blueAccent,
        ),
      ),
    ),
    TextButton(
      onPressed: onPressed,
      child: Text(
        'delete'.tr,
        style: context.theme.textTheme.titleMedium?.copyWith(color: Colors.red),
      ),
    ),
  ];
}
