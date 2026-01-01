import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/main.dart';

class ListEmpty extends StatefulWidget {
  const ListEmpty({
    super.key,
    required this.img,
    required this.text,
    this.subtitle,
    this.icon,
    this.actionText,
    this.onAction,
  });

  final String img;
  final String text;
  final String? subtitle;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  State<ListEmpty> createState() => _ListEmptyState();
}

class _ListEmptyState extends State<ListEmpty>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
          ),
        );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding * 2),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.icon != null)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.onSecondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        size: ResponsiveUtils.isMobile(context) ? 48 : 56,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (widget.icon != null) SizedBox(height: padding * 1.5),
                  _buildImage(context, widget.img),
                  SizedBox(height: padding * 1.5),
                  _buildText(context, widget.text, colorScheme),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: padding * 0.75),
                    _buildSubtitle(context, widget.subtitle!, colorScheme),
                  ],
                  if (widget.actionText != null && widget.onAction != null) ...[
                    SizedBox(height: padding * 2),
                    _buildActionButton(context, colorScheme),
                  ],
                ],
              ),
            ),
          ),
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
          ? Opacity(
              opacity: 0.8,
              child: Image.asset(img, scale: scale, fit: BoxFit.contain),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _buildText(
    BuildContext context,
    String text,
    ColorScheme colorScheme,
  ) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 18),
        color: colorScheme.onSurface,
        height: 1.3,
      ),
    );
  }

  Widget _buildSubtitle(
    BuildContext context,
    String subtitle,
    ColorScheme colorScheme,
  ) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
        color: colorScheme.onSurfaceVariant,
        height: 1.5,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, ColorScheme colorScheme) {
    return FilledButton.tonal(
      onPressed: widget.onAction,
      style: FilledButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveUtils.isMobile(context) ? 24 : 32,
          vertical: ResponsiveUtils.isMobile(context) ? 12 : 16,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.add,
            size: 20,
            color: colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Text(
            widget.actionText!,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
