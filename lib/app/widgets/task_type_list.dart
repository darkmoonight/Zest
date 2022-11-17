import 'package:dark_todo/app/data/schema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import '../modules/tasks/view.dart';

class TaskTypeList extends StatelessWidget {
  const TaskTypeList({
    super.key,
    required this.isLoaded,
    required this.tasks,
    required this.onDelete,
  });
  final bool isLoaded;
  final List<Tasks> tasks;
  final Function(Object) onDelete;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Visibility(
        visible: isLoaded,
        replacement: const Center(
          child: CircularProgressIndicator(),
        ),
        child: Visibility(
          visible: tasks.isNotEmpty,
          replacement: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/AddTasks.png',
                    scale: 5,
                  ),
                  Text(
                    'Добавьте категорию',
                    style: context.theme.textTheme.headline4?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              final task = tasks[index];
              return Dismissible(
                key: ObjectKey(task),
                direction: DismissDirection.endToStart,
                onDismissed: (DismissDirection direction) {
                  onDelete(task);
                },
                background: Container(
                  alignment: Alignment.centerRight,
                  child: const Padding(
                    padding: EdgeInsets.only(
                      right: 15,
                    ),
                    child: Icon(
                      Iconsax.trush_square,
                      color: Colors.red,
                    ),
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 20,
                    left: 25,
                    right: 25,
                  ),
                  child: CupertinoButton(
                    minSize: double.minPositive,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Get.to(
                        () => TaskPage(
                          id: task.id,
                          title: task.title,
                          desc: task.description,
                          task: task,
                        ),
                        transition: Transition.downToUp,
                      );
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: Row(
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: CircularStepProgressIndicator(
                                  totalSteps: 4,
                                  currentStep: 1,
                                  stepSize: 4,
                                  selectedColor: Color(task.taskColor),
                                  unselectedColor: Colors.grey[300],
                                  padding: 0,
                                  selectedStepSize: 6,
                                  roundedCap: (_, __) => true,
                                  child: Center(
                                    child: Text(
                                      '25%',
                                      style: context.theme.textTheme.headline6
                                          ?.copyWith(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task.title,
                                      style: context.theme.textTheme.headline4
                                          ?.copyWith(color: Colors.black),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      task.description,
                                      style: context.theme.textTheme.subtitle2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${task.taskCreate.day}.${task.taskCreate.month}.${task.taskCreate.year}',
                          style: context.theme.textTheme.subtitle2,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
