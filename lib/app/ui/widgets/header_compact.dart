import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget buildBottomSheetHeaderCompact(BuildContext context, String title) =>
    Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: context.theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title.tr,
            textAlign: TextAlign.center,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
