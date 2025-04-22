import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zest/main.dart';

class Statistics extends StatelessWidget {
  const Statistics({
    super.key,
    required this.createdTodos,
    required this.completedTodos,
    required this.percent,
  });

  final int createdTodos;
  final int completedTodos;
  final String percent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [_buildTextColumn(context), _buildCircularSlider(context)],
        ),
      ),
    );
  }

  Widget _buildTextColumn(BuildContext context) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          _buildCompletionText(context),
          _buildDateText(context),
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'todoCompleted'.tr,
      style: context.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 20,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompletionText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        '$completedTodos/$createdTodos ${'completed'.tr}',
        style: context.textTheme.titleSmall?.copyWith(color: Colors.grey),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateText(BuildContext context) {
    return Text(
      DateFormat.MMMMEEEEd(locale.languageCode).format(DateTime.now()),
      style: context.textTheme.titleSmall,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCircularSlider(BuildContext context) {
    return SleekCircularSlider(
      appearance: CircularSliderAppearance(
        animationEnabled: false,
        angleRange: 360,
        startAngle: 270,
        size: 70,
        infoProperties: InfoProperties(
          modifier: (percentage) {
            return createdTodos != 0 ? '$percent%' : '0%';
          },
          mainLabelStyle: context.textTheme.labelLarge?.copyWith(fontSize: 18),
        ),
        customColors: CustomSliderColors(
          progressBarColors: [Colors.blueAccent, Colors.greenAccent],
          trackColor: Colors.grey.shade300,
        ),
        customWidths: CustomSliderWidths(
          progressBarWidth: 7,
          trackWidth: 3,
          handlerSize: 0,
          shadowWidth: 0,
        ),
      ),
      min: 0,
      max: createdTodos != 0 ? createdTodos.toDouble() : 1,
      initialValue: completedTodos.toDouble(),
    );
  }
}
