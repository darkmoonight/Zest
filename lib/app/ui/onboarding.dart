import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/main.dart';

class OnboardingData {
  final String image;
  final String title;
  final String description;

  const OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class OnboardingConstants {
  static const String imagesPath = 'assets/images/';

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

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  late final PageController _pageController;
  late final List<OnboardingData> _data;

  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _data = OnboardingConstants.getData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLastPage => _pageIndex == _data.length - 1;

  Future<void> _completeOnboarding() async {
    settings.onboard = true;
    await isar.writeTxn(() => isar.settings.put(settings));

    if (!mounted) return;
    MyApp.updateAppState(context, completeOnboarding: true);
  }

  void _goToNextPage() {
    _pageController.nextPage(
      duration: AppConstants.longAnimation,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(padding),
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

  PreferredSizeWidget _buildAppBar(double padding) {
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
              color: context.theme.colorScheme.primary,
            ),
            label: Text(
              'skip'.tr,
              style: TextStyle(
                color: context.theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              ),
            ),
          ),
        SizedBox(width: padding),
      ],
    );
  }

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

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.isCompleted = false,
  });

  final bool isActive;
  final bool isCompleted;

  @override
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

  Color _getDotColor(ColorScheme colorScheme) {
    if (isActive) return colorScheme.primary;
    if (isCompleted) return colorScheme.primaryContainer;
    return colorScheme.surfaceContainerHighest;
  }
}

class OnboardingContent extends StatelessWidget {
  const OnboardingContent({super.key, required this.data});

  final OnboardingData data;

  @override
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
