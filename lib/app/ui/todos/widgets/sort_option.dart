import 'package:get/get.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';

extension SortOptionLabel on SortOption {
  String label() {
    switch (this) {
      case SortOption.alphaAsc:
        return 'sortByNameAsc'.tr;
      case SortOption.alphaDesc:
        return 'sortByNameDesc'.tr;
      case SortOption.dateAsc:
        return 'sortByDateAsc'.tr;
      case SortOption.dateDesc:
        return 'sortByDateDesc'.tr;
      case SortOption.priorityAsc:
        return 'sortByPriorityAsc'.tr;
      case SortOption.priorityDesc:
        return 'sortByPriorityDesc'.tr;
      case SortOption.none:
        return 'sortByIndex'.tr;
    }
  }
}
