import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/core/models/task_model.dart';
import 'package:task_management_app/core/providers/task_provider.dart';
import 'package:task_management_app/views/settings/settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  int currentIndex = -1;
  TextEditingController searchController = TextEditingController();
  bool isSearching = false;

  // Task? selectedTask;
  List<Task> taskList = [];

  @override
  Widget build(BuildContext context) {
    taskList = isSearching
        ? ref.watch(filteredTasksProvider)
        : ref.watch(taskProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearchDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 600) {
            // **Tablet Layout: Split View**
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: Task List
                Expanded(
                  flex: 2,
                  child: _buildTaskList(taskList),
                ),
                // Right: Task Details Panel
                Expanded(
                  flex: 2,
                  child: currentIndex == -1
                      ? const Center(
                          child: Text("Select a task to view details"))
                      : _buildTaskDetails(taskList[currentIndex]),
                ),
              ],
            );
          } else {
            // **Mobile Layout: Full-Screen List**
            return _buildTaskList(taskList);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          int id = taskList.isEmpty ? 0 : taskList.length;
          _showAddTaskDialog(context, ref, id++);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the Task List with Drag & Drop Reordering
  Widget _buildTaskList(List<Task> taskList) {
    return taskList.isEmpty
        ? const Center(child: Text("Add some tasks"))
        : ReorderableListView.builder(
            shrinkWrap: true,
            itemCount: taskList.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex--; // Adjust for reordering index shift
              }
              ref.read(taskProvider.notifier).reorderTasks(oldIndex, newIndex);
            },
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final task = taskList[index];
              return _buildReorderableTask(task, index);
            },
          );
  }

  /// Animated Task Tile with Drag Handle
  Widget _buildReorderableTask(Task task, int index) {
    return Card(
      key: ValueKey(task.id),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) {
                return ScaleTransition(scale: anim, child: child);
              },
              child: Checkbox(
                key: ValueKey(task.isCompleted),
                value: task.isCompleted,
                onChanged: (value) {
                  ref.read(taskProvider.notifier).toggleTaskCompletion(task);
                },
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.drag_handle, color: Colors.grey), // Drag handle
          ],
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                task.description,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  task.dueDate.toIso8601String().split("T")[0],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                onPressed: () => _showEditTaskDialog(context, task, ref),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeTask(index),
              ),
            ],
          ),
        ),
        onTap: () {
          if (MediaQuery.of(context).size.width > 600) {
            setState(() {
              currentIndex = taskList.indexOf(task);
            });
          }
        },
      ),
    );
  }

  ///  Builds Task Details Panel (for Tablet View)
  Widget _buildTaskDetails(Task task) {
    return StatefulBuilder(builder: (context, setState) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(task.description, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Text(task.dueDate.toIso8601String().split("T")[0],
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        "Status: ${task.isCompleted ? "Completed" : "Pending"}",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500)),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          ref
                              .read(taskProvider.notifier)
                              .toggleTaskCompletion(task);
                        });
                      },
                      child: Text(task.isCompleted
                          ? "Mark as Pending"
                          : "Mark as Completed"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  ///  Remove Task
  void _removeTask(int index) {
    final taskList = ref.watch(taskProvider);
    final removedTask = taskList[index];

    ref.read(taskProvider.notifier).deleteTask(removedTask.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${removedTask.title} deleted"),
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.orange,
          onPressed: () {
            ref.read(taskProvider.notifier).addTask(removedTask);
          },
        ),
      ),
    );
  }

  _showAddTaskDialog(BuildContext context, WidgetRef ref, id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final TextEditingController titleController = TextEditingController();
      final TextEditingController descriptionController =
          TextEditingController();
      DateTime? selectedDate;

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Add New Task"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Title"),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: "Description"),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          selectedDate == null
                              ? "Select Due Date"
                              : "Due: ${selectedDate!.toLocal().toIso8601String().split("T")[0]}",
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: () async {
                            DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                selectedDate = pickedDate;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.isNotEmpty) {
                        final newTask = Task(
                          id: id,
                          title: titleController.text,
                          description: descriptionController.text,
                          isCompleted: false,
                          dueDate: selectedDate ?? DateTime.now(),
                          // ✅ Store the selected date
                          position: 0,
                        );
                        ref.read(taskProvider.notifier).addTask(newTask);
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("title cannot be empty"),
                          ),
                        );
                      }
                    },
                    child: const Text("Add Task"),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

  void showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search Tasks"),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
              hintText: "Enter task title or description"),
          onChanged: (query) {
            ref.read(taskProvider.notifier).searchTasks(query, ref);
            setState(() {
              currentIndex = -1;
              isSearching = query.isNotEmpty;
            });
          },
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task, WidgetRef ref) {
    final titleController = TextEditingController(text: task.title);
    final descController = TextEditingController(text: task.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Title"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                final updatedTask = task.copyWith(
                  title: titleController.text,
                  description: descController.text,
                );

                ref.read(taskProvider.notifier).updateTask(updatedTask);

                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
