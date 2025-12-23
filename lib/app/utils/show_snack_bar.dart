import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

void showSnackBar(String message, {bool isError = false, bool isInfo = false}) {
  final context = Get.context;
  if (context == null) return;

  final colorScheme = Theme.of(context).colorScheme;

  Color backgroundColor;
  Color textColor;
  IconData icon;

  if (isError) {
    backgroundColor = colorScheme.errorContainer;
    textColor = colorScheme.onErrorContainer;
    icon = IconsaxPlusBold.close_circle;
  } else if (isInfo) {
    backgroundColor = colorScheme.secondaryContainer;
    textColor = colorScheme.onSecondaryContainer;
    icon = IconsaxPlusBold.info_circle;
  } else {
    backgroundColor = colorScheme.primaryContainer;
    textColor = colorScheme.onPrimaryContainer;
    icon = IconsaxPlusBold.tick_circle;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    builder: (context) => _ToastDialog(
      message: message,
      icon: icon,
      backgroundColor: backgroundColor,
      textColor: textColor,
    ),
  );
}

class _ToastDialog extends StatefulWidget {
  const _ToastDialog({
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });

  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;

  @override
  State<_ToastDialog> createState() => _ToastDialogState();
}

class _ToastDialogState extends State<_ToastDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1000), () async {
      if (mounted) {
        await _controller.reverse();
        if (mounted && context.mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: widget.textColor, size: 28),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    widget.message,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: widget.textColor,
                      letterSpacing: -0.3,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
