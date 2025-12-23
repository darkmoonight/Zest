import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/ui/responsive_utils.dart';
import 'package:zest/main.dart';

class ListEmpty extends StatelessWidget {
  const ListEmpty({super.key, required this.img, required this.text});

  final String img;
  final String text;

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildImage(context, img),
            SizedBox(height: padding),
            _buildText(context, text),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, String img) {
    double scale;
    if (ResponsiveUtils.isMobile(context)) {
      scale = 5.0;
    } else if (ResponsiveUtils.isTablet(context)) {
      scale = 4.0;
    } else {
      scale = 3.5;
    }

    return Obx(
      () => isImage.value
          ? Image.asset(img, scale: scale, fit: BoxFit.contain)
          : const SizedBox.shrink(),
    );
  }

  Widget _buildText(BuildContext context, String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.bodyLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
      ),
    );
  }
}
