import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/home.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding>
    with SingleTickerProviderStateMixin {
  late PageController pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void onBoardHome() {
    settings.onboard = true;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.off(() => const HomePage(), transition: Transition.fadeIn);
  }

  void skipOnboarding() {
    pageController.animateToPage(
      data.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildTopBar(context, colorScheme, padding),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isLargeScreen ? padding * 8 : padding * 2,
                  ),
                  child: Column(
                    children: [
                      Expanded(child: _buildPageView()),
                      SizedBox(height: padding * 2),
                      _buildDotIndicators(context, colorScheme, padding),
                      SizedBox(height: padding * 2),
                      _buildNavigationButtons(
                        context,
                        colorScheme,
                        padding,
                        isLargeScreen,
                      ),
                      SizedBox(height: padding * 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    ColorScheme colorScheme,
    double padding,
  ) {
    final isLastPage = pageIndex == data.length - 1;

    return Padding(
      padding: EdgeInsets.all(padding * 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              IconsaxPlusBold.task_square,
              color: colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isLastPage ? 0.0 : 1.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isLastPage ? 0.8 : 1.0,
              child: IgnorePointer(
                ignoring: isLastPage,
                child: TextButton.icon(
                  onPressed: skipOnboarding,
                  icon: Icon(
                    IconsaxPlusLinear.arrow_right_3,
                    size: 18,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  label: Text(
                    'skip'.tr,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView() => PageView.builder(
    controller: pageController,
    itemCount: data.length,
    onPageChanged: (index) => setState(() => pageIndex = index),
    itemBuilder: (context, index) => OnboardContent(
      key: ValueKey(index),
      image: data[index].image,
      title: data[index].title,
      description: data[index].description,
      icon: data[index].icon,
    ),
  );

  Widget _buildDotIndicators(
    BuildContext context,
    ColorScheme colorScheme,
    double padding,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        data.length,
        (index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
          child: DotIndicator(
            isActive: index == pageIndex,
            colorScheme: colorScheme,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    ColorScheme colorScheme,
    double padding,
    bool isLargeScreen,
  ) {
    final isLastPage = pageIndex == data.length - 1;
    final buttonWidth = isLargeScreen ? 400.0 : double.infinity;
    final showBackButton = pageIndex > 0;

    return SizedBox(
      width: buttonWidth,
      child: Row(
        children: [
          if (showBackButton) ...[
            Expanded(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: showBackButton ? 1.0 : 0.0,
                child: OutlinedButton.icon(
                  onPressed: () {
                    pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  icon: Icon(IconsaxPlusLinear.arrow_left_1, size: 18),
                  label: Text(
                    'back'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        14,
                      ),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: padding * 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: padding),
          ],
          Expanded(
            child: MyTextButton(
              text: isLastPage ? 'getStart'.tr : 'next'.tr,
              onPressed: () {
                if (isLastPage) {
                  onBoardHome();
                } else {
                  pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    required this.colorScheme,
  });

  final bool isActive;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class Onboard {
  final String image, title, description;
  final IconData icon;

  Onboard({
    required this.image,
    required this.title,
    required this.description,
    required this.icon,
  });
}

final List<Onboard> data = [
  Onboard(
    image: 'assets/images/Task.png',
    title: 'title1'.tr,
    description: 'subtitle1'.tr,
    icon: IconsaxPlusBold.folder_2,
  ),
  Onboard(
    image: 'assets/images/Design.png',
    title: 'title2'.tr,
    description: 'subtitle2'.tr,
    icon: IconsaxPlusBold.task_square,
  ),
  Onboard(
    image: 'assets/images/Feedback.png',
    title: 'title3'.tr,
    description: 'subtitle3'.tr,
    icon: IconsaxPlusBold.tick_circle,
  ),
];

class OnboardContent extends StatefulWidget {
  const OnboardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String image, title, description;
  final IconData icon;

  @override
  State<OnboardContent> createState() => _OnboardContentState();
}

class _OnboardContentState extends State<OnboardContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isLargeScreen = !ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final contentCard = Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          color: colorScheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(padding * 3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(padding * 2),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.tertiaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.icon,
                    size: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      isLargeScreen ? 48 : 40,
                    ),
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: padding * 2),
                Image.asset(
                  widget.image,
                  fit: BoxFit.contain,
                  height: isLargeScreen
                      ? constraints.maxHeight * 0.35
                      : constraints.maxHeight * 0.3,
                ),
                SizedBox(height: padding * 2),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: ResponsiveUtils.getResponsiveFontSize(
                      context,
                      24,
                    ),
                    color: colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: padding),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isLargeScreen ? 500 : double.infinity,
                  ),
                  child: Text(
                    widget.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        15,
                      ),
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );

        if (isLargeScreen) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: contentCard,
            ),
          );
        } else {
          return Center(child: contentCard);
        }
      },
    );
  }
}
