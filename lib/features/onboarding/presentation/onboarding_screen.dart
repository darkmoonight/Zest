import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/navigation/app_routes.dart';
import 'package:zest/core/navigation/app_router.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/i18n/tr.dart';

/// Single onboarding slide with image, title, and description.
class OnboardingData {
  /// Asset path for the slide illustration.
  final String image;

  /// Headline shown on the slide.
  final String title;

  /// Supporting copy beneath the title.
  final String description;

  /// Creates a [OnboardingData].
  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

/// Class representing onboarding constants.
class OnboardingConstants {
  static const String imagesPath = 'assets/images/';

  /// Onboarding data.
  static List<OnboardingData> getData() => [
    OnboardingData(
      image: '${imagesPath}Task.png',
      title: 'title1'.tr,
      description: 'subtitle1'.tr,
    ),
    OnboardingData(
      image: '${imagesPath}Design.png',
      title: 'title2'.tr,
      description: 'subtitle2'.tr,
    ),
    OnboardingData(
      image: '${imagesPath}Feedback.png',
      title: 'title3'.tr,
      description: 'subtitle3'.tr,
    ),
  ];
}

/// Multi-page onboarding flow with skip and get-started actions.
class OnBoarding extends ConsumerStatefulWidget {
  /// Creates a [OnBoarding].
  const OnBoarding({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<OnBoarding> createState() => _OnBoardingState();
}

/// Widget that on boarding state.
class _OnBoardingState extends ConsumerState<OnBoarding> {
  /// The page controller.
  late final PageController _pageController;

  /// The data.
  late final List<OnboardingData> _data;

  /// Page index.
  int _pageIndex = 0;

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _data = OnboardingConstants.getData();
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _pageIndex == _data.length - 1;

  /// Void.
  Future<void> _completeOnboarding() async {
    final settings = ref.read(liveSettingsProvider);
    settings.onboard = true;
    await ref.read(settingsRepositoryProvider).save(settings);
    refreshAppRouter(ref);

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  /// Go to next page.
  void _goToNextPage() {
    _pageController.nextPage(
      duration: AppConstants.longAnimation,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(padding, colorScheme),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            children: [
              _buildPageView(),
              SizedBox(height: padding * 2),
              _buildDotIndicators(),
              SizedBox(height: padding * 3),
              _buildActionButton(padding),
              SizedBox(height: padding),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the app bar widget.
  PreferredSizeWidget _buildAppBar(double padding, ColorScheme colorScheme) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      actions: [
        if (!_isLastPage)
          TextButton.icon(
            onPressed: _completeOnboarding,
            icon: Icon(
              Icons.arrow_forward_ios_rounded,
              size: AppConstants.iconSizeSmall,
              color: colorScheme.primary,
            ),
            label: Text(
              'skip'.tr,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        SizedBox(width: padding),
      ],
    );
  }

  /// Builds the page view widget.
  Widget _buildPageView() {
    return Expanded(
      child: PageView.builder(
        controller: _pageController,
        itemCount: _data.length,
        onPageChanged: (index) => setState(() => _pageIndex = index),
        itemBuilder: (context, index) => OnboardingContent(data: _data[index]),
      ),
    );
  }

  /// Builds the dot indicators widget.
  Widget _buildDotIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _data.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingXS,
          ),
          child: DotIndicator(
            isActive: index == _pageIndex,
            isCompleted: index < _pageIndex,
          ),
        ),
      ),
    );
  }

  /// Builds the action button widget.
  Widget _buildActionButton(double padding) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding),
        child: FilledButton(
          onPressed: _isLastPage ? _completeOnboarding : _goToNextPage,
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusLarge,
              ),
            ),
          ),
          child: Text(
            _isLastPage ? 'getStart'.tr : 'next'.tr,
            style: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated page indicator dot for onboarding carousels.
class DotIndicator extends StatelessWidget {
  /// Creates a [DotIndicator].
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.isCompleted = false,
  });

  /// Whether this dot represents the current page.
  final bool isActive;

  /// Whether the corresponding page has been passed.
  final bool isCompleted;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: AppConstants.longAnimation,
      curve: Curves.easeInOutCubic,
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: _getDotColor(colorScheme),
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }

  /// Get dot color.
  Color _getDotColor(ColorScheme colorScheme) {
    if (isActive) return colorScheme.primary;
    if (isCompleted) return colorScheme.primaryContainer;
    return colorScheme.surfaceContainerHighest;
  }
}

/// Layout for one onboarding slide's image and text.
class OnboardingContent extends StatelessWidget {
  /// Creates a [OnboardingContent].
  const OnboardingContent({super.key, required this.data});

  /// Slide content (image, title, and description).
  final OnboardingData data;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Image.asset(
            data.image,
            height: isMobile ? 240.0 : 320.0,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: padding * 3),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Column(
            children: [
              Text(
                data.title,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padding * 1.6),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isMobile ? 320.0 : 400.0),
                child: Text(
                  data.description,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
