import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/main.dart';

class ListEmpty extends StatelessWidget {
  const ListEmpty({super.key, required this.img, required this.text});

  final String img;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: ListView(
      shrinkWrap: true,
      children: [_buildImage(img), _buildText(context, text)],
    ),
  );

  Widget _buildImage(String img) =>
      Obx(() => isImage.value ? Image.asset(img, scale: 5) : const Offstage());

  Widget _buildText(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}
