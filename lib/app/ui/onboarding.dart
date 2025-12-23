import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/home.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({super.key});

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onBoardHome() {
    settings.onboard = true;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.off(() => const HomePage(), transition: Transition.downToUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLargeScreen = constraints.maxWidth > 600;
            return Padding(
              padding: isLargeScreen
                  ? const EdgeInsets.symmetric(horizontal: 100, vertical: 20)
                  : const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Column(
                children: [
                  _buildPageView(),
                  const SizedBox(height: 20),
                  _buildDotIndicators(isLargeScreen),
                  const SizedBox(height: 20),
                  _buildActionButton(isLargeScreen),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageView() => Expanded(
    child: PageView.builder(
      controller: pageController,
      itemCount: data.length,
      onPageChanged: (index) => setState(() => pageIndex = index),
      itemBuilder: (context, index) => OnboardContent(
        image: data[index].image,
        title: data[index].title,
        description: data[index].description,
      ),
    ),
  );

  Widget _buildDotIndicators(bool isLargeScreen) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      data.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: DotIndicator(
          isActive: index == pageIndex,
          isLargeScreen: isLargeScreen,
        ),
      ),
    ),
  );

  Widget _buildActionButton(bool isLargeScreen) => SizedBox(
    width: isLargeScreen ? 300 : double.infinity,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: MyTextButton(
        text: pageIndex == data.length - 1 ? 'getStart'.tr : 'next'.tr,
        onPressed: () {
          if (pageIndex == data.length - 1) {
            onBoardHome();
          } else {
            pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          }
        },
      ),
    ),
  );
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    required this.isLargeScreen,
  });

  final bool isActive;
  final bool isLargeScreen;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: isLargeScreen ? 12 : 8,
    width: isLargeScreen ? 12 : 8,
    decoration: BoxDecoration(
      color: isActive
          ? context.theme.colorScheme.secondary
          : context.theme.colorScheme.secondaryContainer,
      shape: BoxShape.circle,
    ),
  );
}

class Onboard {
  final String image, title, description;

  Onboard({
    required this.image,
    required this.title,
    required this.description,
  });
}

final List<Onboard> data = [
  Onboard(
    image: 'assets/images/Task.png',
    title: 'title1'.tr,
    description: 'subtitle1'.tr,
  ),
  Onboard(
    image: 'assets/images/Design.png',
    title: 'title2'.tr,
    description: 'subtitle2'.tr,
  ),
  Onboard(
    image: 'assets/images/Feedback.png',
    title: 'title3'.tr,
    description: 'subtitle3'.tr,
  ),
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 600;
        final imageHeight = isLargeScreen
            ? constraints.maxHeight * 0.6
            : constraints.maxHeight * 0.5;

        final imageWidget = TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Image.asset(image, fit: BoxFit.contain, height: imageHeight),
        );

        final textColumn = TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return Opacity(opacity: value, child: child);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: isLargeScreen ? 28 : 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: isLargeScreen
                    ? constraints.maxWidth * 0.4
                    : constraints.maxWidth * 0.8,
                child: Text(
                  description,
                  style: context.textTheme.labelLarge?.copyWith(
                    fontSize: isLargeScreen ? 18 : 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );

        if (isLargeScreen) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: Center(child: imageWidget)),
              const SizedBox(width: 40),
              Expanded(child: Center(child: textColumn)),
            ],
          );
        } else {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [imageWidget, const SizedBox(height: 20), textColumn],
          );
        }
      },
    );
  }
}
