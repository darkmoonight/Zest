import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/utils/notification.dart';
import 'package:zest/main.dart';

class TodoCard extends StatefulWidget {
  const TodoCard({
    super.key,
    required this.todo,
    required this.allTodos,
    required this.calendar,
    required this.onLongPress,
    required this.onTap,
  });

  final Todos todo;
  final bool allTodos;
  final bool calendar;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  final todoController = Get.put(TodoController());

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, innerState) {
        return GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: _buildCard(context, innerState),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, StateSetter innerState) {
    return Card(
      shape: _getCardShape(),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
        child: Row(
          children: [
            Flexible(
              child: Row(
                children: [
                  _buildCheckbox(innerState),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTodoName(),
                        _buildTodoDescription(),
                        _buildCategoryInfo(),
                        _buildCompletionTime(),
                        _buildTagsAndPriority(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  RoundedRectangleBorder? _getCardShape() {
    return todoController.isMultiSelectionTodo.isTrue &&
            todoController.selectedTodo.contains(widget.todo)
        ? RoundedRectangleBorder(
            side: BorderSide(
              color: context.theme.colorScheme.onPrimaryContainer,
            ),
            borderRadius: const BorderRadius.all(Radius.circular(20)),
          )
        : null;
  }

  Widget _buildCheckbox(StateSetter innerState) {
    return Checkbox(
      value: widget.todo.done,
      shape: const CircleBorder(),
      onChanged: (val) {
        innerState(() {
          widget.todo.done = val!;
          widget.todo.todoCompletionTime = val ? DateTime.now() : null;
        });
        _handleCheckboxChange(val!);
      },
    );
  }

  void _handleCheckboxChange(bool val) {
    DateTime? date = widget.todo.todoCompletedTime;
    if (val) {
      flutterLocalNotificationsPlugin.cancel(widget.todo.id);
    } else if (date != null && DateTime.now().isBefore(date)) {
      NotificationShow().showNotification(
        widget.todo.id,
        widget.todo.name,
        widget.todo.description,
        widget.todo.todoCompletedTime,
      );
    }
    Future.delayed(
      const Duration(milliseconds: 300),
      () => todoController.updateTodoCheck(widget.todo),
    );
  }

  Widget _buildTodoName() {
    return Text(
      widget.todo.name,
      style: context.textTheme.titleLarge?.copyWith(fontSize: 16),
      overflow: TextOverflow.visible,
    );
  }

  Widget _buildTodoDescription() {
    return widget.todo.description.isNotEmpty
        ? Text(
            widget.todo.description,
            style: context.textTheme.labelLarge?.copyWith(color: Colors.grey),
            overflow: TextOverflow.visible,
          )
        : const Offstage();
  }

  Widget _buildCategoryInfo() {
    return (widget.allTodos || widget.calendar)
        ? Row(
            children: [
              ColorIndicator(
                height: 8,
                width: 8,
                borderRadius: 20,
                color: Color(widget.todo.task.value!.taskColor),
                onSelectFocus: false,
              ),
              const Gap(5),
              Text(
                widget.todo.task.value!.title,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          )
        : const Offstage();
  }

  Widget _buildCompletionTime() {
    return widget.todo.todoCompletedTime != null && !widget.calendar
        ? Text(
            _formatCompletionTime(widget.todo.todoCompletedTime!),
            style: context.textTheme.labelLarge?.copyWith(
              color: context.theme.colorScheme.secondary,
              fontSize: 12,
            ),
          )
        : const Offstage();
  }

  String _formatCompletionTime(DateTime time) {
    return timeformat == '12'
        ? DateFormat.yMMMEd(locale.languageCode).add_jm().format(time)
        : DateFormat.yMMMEd(locale.languageCode).add_Hm().format(time);
  }

  Widget _buildTagsAndPriority() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [_buildPriorityChip(), _buildTagsChips()]),
    );
  }

  Widget _buildPriorityChip() {
    return widget.todo.priority != Priority.none
        ? _StatusChip(
            icon: IconsaxPlusLinear.flag,
            color: widget.todo.priority.color,
            label: widget.todo.priority.name.tr,
          )
        : const Offstage();
  }

  Widget _buildTagsChips() {
    return widget.todo.tags.isNotEmpty
        ? Row(
            children: widget.todo.tags.map((e) => _TagsChip(label: e)).toList(),
          )
        : const Offstage();
  }

  Widget _buildAdditionalInfo() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Column(
        children: [_buildCalendarTime(), const Gap(5), _buildFixedIcon()],
      ),
    );
  }

  Widget _buildCalendarTime() {
    return widget.calendar
        ? Text(
            _formatCalendarTime(widget.todo.todoCompletedTime!),
            style: context.textTheme.labelLarge?.copyWith(
              color: context.theme.colorScheme.secondary,
              fontSize: 12,
            ),
          )
        : const Offstage();
  }

  String _formatCalendarTime(DateTime time) {
    return timeformat == '12'
        ? DateFormat.jm(locale.languageCode).format(time)
        : DateFormat.Hm(locale.languageCode).format(time);
  }

  Widget _buildFixedIcon() {
    return widget.todo.fix
        ? const Icon(
            IconsaxPlusLinear.attach_square,
            size: 20,
            color: Colors.grey,
          )
        : const Offstage();
  }
}

class _TagsChip extends StatelessWidget {
  const _TagsChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, top: 2),
      child: Chip(
        elevation: 4,
        avatar: const Icon(IconsaxPlusLinear.tag),
        label: Text(label),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.only(right: 10),
        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color? color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 5, top: 2),
      child: Chip(
        elevation: 4,
        avatar: Icon(icon, color: color),
        label: Text(label),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.only(right: 10),
        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
      ),
    );
  }
}
