import 'package:flutter/material.dart';
import 'package:zest/app/utils/responsive_utils.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Color textColor;
  final bool compact;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.textColor,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    final double iconFontSize = ResponsiveUtils.getResponsiveFontSize(
      context,
      isDesktop ? 14 : 15,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : (isDesktop ? 12 : 14),
        vertical: compact ? 6 : (isDesktop ? 7 : 8),
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicWidth(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconFontSize, color: textColor),
            const SizedBox(width: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                fontSize: iconFontSize,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor.withValues(alpha: 0.8),
                fontSize: ResponsiveUtils.getResponsiveFontSize(
                  context,
                  isDesktop ? 11 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
