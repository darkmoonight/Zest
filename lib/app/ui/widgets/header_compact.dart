import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/utils/responsive_utils.dart';

Widget buildBottomSheetHeaderCompact(BuildContext context, String title) {
  final padding = ResponsiveUtils.getResponsivePadding(context);

  return Padding(
    padding: EdgeInsets.fromLTRB(
      padding,
      padding * 0.75,
      padding,
      padding * 0.5,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ResponsiveUtils.isDesktop(context) ? 60 : 40,
          height: 4,
          margin: EdgeInsets.only(bottom: padding * 0.75),
          decoration: BoxDecoration(
            color: context.theme.dividerColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Text(
          title.tr,
          textAlign: TextAlign.center,
          style: context.textTheme.titleLarge?.copyWith(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
