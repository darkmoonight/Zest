import 'package:gap/gap.dart';
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(),
    body: SafeArea(
      child: Column(
        children: [
          _buildPageView(),
          _buildDotIndicators(),
          _buildActionButton(),
        ],
      ),
    ),
  );

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

  Widget _buildDotIndicators() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      data.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: DotIndicator(isActive: index == pageIndex),
      ),
    ),
  );

  Widget _buildActionButton() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
  );
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    height: 8,
    width: 8,
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
  Widget build(BuildContext context) => Column(
    children: [
      Flexible(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(image, scale: 5),
            Text(
              title,
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(10),
            SizedBox(
              width: 300,
              child: Text(
                description,
                style: context.textTheme.labelLarge?.copyWith(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
