import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/data/db.dart';

class TaskCard extends StatefulWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.createdTodos,
    required this.completedTodos,
    required this.percent,
    required this.onDoubleTap,
    required this.onTap,
  });

  final Tasks task;
  final int createdTodos;
  final int completedTodos;
  final String percent;
  final VoidCallback onDoubleTap;
  final VoidCallback onTap;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTap: widget.onDoubleTap,
      child: _buildCard(context),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      shape: _getCardShape(),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        horizontalTitleGap: 10,
        minVerticalPadding: 25,
        leading: _buildLeadingWidget(context),
        title: _buildTitle(context),
        subtitle: _buildSubtitle(),
        trailing: _buildTrailingText(),
      ),
    );
  }

  RoundedRectangleBorder? _getCardShape() {
    return todoController.isMultiSelectionTask.isTrue &&
            todoController.selectedTask.contains(widget.task)
        ? RoundedRectangleBorder(
            side: BorderSide(
              color: context.theme.colorScheme.onPrimaryContainer,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          )
        : null;
  }

  Widget _buildLeadingWidget(BuildContext context) {
    return SizedBox(
      height: 60,
      width: 60,
      child: SleekCircularSlider(
        appearance: CircularSliderAppearance(
          animationEnabled: false,
          angleRange: 360,
          startAngle: 270,
          size: 110,
          infoProperties: InfoProperties(
            modifier: (percentage) {
              return widget.createdTodos != 0 ? '${widget.percent}%' : '0%';
            },
            mainLabelStyle: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          customColors: CustomSliderColors(
            progressBarColor: Color(widget.task.taskColor),
            trackColor: Colors.grey.shade300,
          ),
          customWidths: CustomSliderWidths(
            progressBarWidth: 5,
            trackWidth: 3,
            handlerSize: 0,
            shadowWidth: 0,
          ),
        ),
        min: 0,
        max: widget.createdTodos != 0 ? widget.createdTodos.toDouble() : 1,
        initialValue: widget.completedTodos.toDouble(),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.task.title,
      style: context.textTheme.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget? _buildSubtitle() {
    return widget.task.description.isNotEmpty
        ? Text(
            widget.task.description,
            style: context.textTheme.labelLarge?.copyWith(
              color: Colors.grey,
              fontSize: 14,
            ),
          )
        : null;
  }

  Widget _buildTrailingText() {
    return Text(
      '${widget.completedTodos}/${widget.createdTodos}',
      style: context.textTheme.labelMedium?.copyWith(color: Colors.grey),
    );
  }
}
