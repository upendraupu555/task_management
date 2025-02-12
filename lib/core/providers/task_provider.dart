import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/core/services/notification_service.dart';
import '../models/task_model.dart';
import '../database/task_database.dart';

final taskProvider = StateNotifierProvider<TaskViewModel, List<Task>>((ref) {
  return TaskViewModel();
});

final filteredTasksProvider = StateProvider<List<Task>>((ref) => []);

class TaskViewModel extends StateNotifier<List<Task>> {
  TaskViewModel() : super([]) {
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    state = await TaskDatabase.instance.fetchTasks();
  }

  Future<void> addTask(Task task) async {
    await TaskDatabase.instance.insertTask(task);
    NotificationService.showNotification(
        id: task.id!, title: task.title, body: task.description);
    fetchTasks();
  }

  Future<void> updateTask(Task task) async {
    await TaskDatabase.instance.updateTask(task);
    fetchTasks();
  }

  Future<void> deleteTask(int? id) async {
    await TaskDatabase.instance.deleteTask(id ?? 0);
    fetchTasks();
  }

  void searchTasks(String query, WidgetRef ref) {
    final filtered = state
        .where((task) =>
            task.title.toLowerCase().contains(query.toLowerCase()) ||
            task.description.toLowerCase().contains(query.toLowerCase()))
        .toList();

    ref.read(filteredTasksProvider.notifier).state = filtered;
  }

  void sortTasks(String sortBy, WidgetRef ref) async {
    List<Task> sortedTasks = [...state];

    if (sortBy == "name") {
      sortedTasks.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == "date") {
      sortedTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (sortBy == "priority") {
      sortedTasks.sort((a, b) => a.isCompleted ? 1 : -1);
    }
    await TaskDatabase.instance.updateTaskPositions(sortedTasks);
    ref.read(taskProvider.notifier).state = sortedTasks;
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final List<Task> updatedList = [...state];
    final task = updatedList.removeAt(oldIndex);
    updatedList.insert(newIndex, task);

    for (int i = 0; i < updatedList.length; i++) {
      updatedList[i] = updatedList[i].copyWith(position: i);
    }
    await TaskDatabase.instance.updateTaskPositions(updatedList);

    state = updatedList;
  }

  void toggleTaskCompletion(Task task) async {
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

    await updateTask(updatedTask);

    state = state.map((t) => t.id == task.id ? updatedTask : t).toList();
  }
}
