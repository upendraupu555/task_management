import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_management_app/core/providers/theme_provider.dart';
import '../../core/providers/task_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String value = ref.watch(sortProvider);
    final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Column(
        children: [
          ListTile(
            title: const Text("Sort Tasks"),
            trailing: DropdownButton<String>(
              value: value,
              items: const [
                DropdownMenuItem(value: "name", child: Text("By Name")),
                DropdownMenuItem(value: "date", child: Text("By Date")),
                DropdownMenuItem(value: "priority", child: Text("By Priority")),

              ],
              onChanged: (value) {
                ref.read(taskProvider.notifier).sortTasks(value!, ref);
                ref.read(sortProvider.notifier).changeSortValue(value);
              },
            ),
          ),
          ListTile(
            title: const Text("Dark Mode"),
            trailing: Switch(
              value: isDarkMode,
              onChanged: (value) =>
                  ref.read(themeProvider.notifier).toggleTheme(),
            ),
          ),
        ],
      ),
    );
  }
}
