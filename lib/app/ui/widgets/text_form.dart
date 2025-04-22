import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyTextForm extends StatelessWidget {
  const MyTextForm({
    super.key,
    required this.labelText,
    required this.type,
    required this.icon,
    required this.controller,
    required this.margin,
    this.onTap,
    this.onChanged,
    this.onFieldSubmitted,
    this.readOnly = false,
    this.validator,
    this.iconButton,
    this.elevation,
    this.focusNode,
    this.maxLine = 1,
  });

  final String labelText;
  final TextInputType type;
  final Icon icon;
  final IconButton? iconButton;
  final TextEditingController controller;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final EdgeInsets margin;
  final String? Function(String?)? validator;
  final bool readOnly;
  final double? elevation;
  final FocusNode? focusNode;
  final int? maxLine;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      margin: margin,
      child: _buildTextFormField(context),
    );
  }

  Widget _buildTextFormField(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: readOnly ? onTap : null,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      keyboardType: type,
      style: context.textTheme.labelLarge,
      decoration: _buildInputDecoration(),
      validator: validator,
      maxLines: maxLine,
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      prefixIcon: icon,
      suffixIcon: iconButton,
      labelText: labelText,
      border: InputBorder.none,
      focusedBorder: InputBorder.none,
      enabledBorder: InputBorder.none,
    );
  }
}
