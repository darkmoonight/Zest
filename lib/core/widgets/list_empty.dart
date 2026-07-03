import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/settings/app_settings_notifier.dart';
import 'package:zest/core/utils/responsive_utils.dart';

/// Animated empty-state placeholder for lists with optional action button.
class ListEmpty extends ConsumerStatefulWidget {
  /// Creates an empty list view with image, text, and optional action.
  const ListEmpty({
    super.key,
    required this.img,
    required this.text,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.actionText,
    this.onAction,
  });

  /// Asset path for the empty-state illustration.
  final String img;

  /// Primary empty-state message.
  final String text;

  /// Optional secondary message below [text].
  final String? subtitle;

  /// Optional icon shown above the illustration.
  final IconData? icon;

  /// Optional color for [icon].
  final Color? iconColor;

  /// Label for the optional action button.
  final String? actionText;

  /// Callback invoked when the action button is pressed.
  final VoidCallback? onAction;

  @override
  /// Creates the state for this widget.
  ConsumerState<ListEmpty> createState() => _ListEmptyState();
}

/// State that drives fade and slide entrance animations for [ListEmpty].
class _ListEmptyState extends ConsumerState<ListEmpty>
    with SingleTickerProviderStateMixin {
  /// Controls the entrance animation timeline.
  late AnimationController _controller;

  /// Fade animation for the empty-state content.
  late Animation<double> _fadeAnimation;

  /// Slide animation for the empty-state content.
  late Animation<Offset> _slideAnimation;

  @override
  /// Initializes entrance animations and starts playback.
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
  /// Disposes the animation controller.
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  /// Builds the animated empty-state layout.
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isImage = ref.watch(appSettingsProvider).isImage;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding * 2),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.isMobile(context) ? 300 : 360,
              ),
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
                        color: widget.iconColor ?? colorScheme.onSurfaceVariant,
                      ),
                    ),
                  if (widget.icon != null) SizedBox(height: padding * 1.5),
                  _buildImage(context, widget.img, isImage),
                  SizedBox(height: padding * 1.5),
                  _buildText(context, widget.text, colorScheme),
                  if (widget.subtitle != null) ...[
                    SizedBox(height: padding * 0.75),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: padding),
                      child: _buildSubtitle(
                        context,
                        widget.subtitle!,
                        colorScheme,
                      ),
                    ),
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

  /// Builds the optional illustration image when images are enabled in settings.
  Widget _buildImage(BuildContext context, String img, bool isImage) {
    double scale;
    if (ResponsiveUtils.isMobile(context)) {
      scale = 5.0;
    } else if (ResponsiveUtils.isTablet(context)) {
      scale = 4.0;
    } else {
      scale = 3.5;
    }

    return isImage
        ? Opacity(
            opacity: 0.8,
            child: Image.asset(img, scale: scale, fit: BoxFit.contain),
          )
        : const SizedBox.shrink();
  }

  /// Builds the primary empty-state title text.
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

  /// Builds the optional subtitle text below the title.
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

  /// Builds the optional tonal action button with add icon.
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
