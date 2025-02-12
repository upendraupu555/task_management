import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task_model.dart';

class TaskDatabase {
  static final TaskDatabase instance = TaskDatabase._init();
  static Database? _database;
  static const String tableName = "tasks";

  TaskDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2, // ✅ Increment DB version
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableName (
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            isCompleted INTEGER,
            dueDate TEXT,
            position INTEGER DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // ✅ Handles migration from version 1 to 2
          await db.execute(
              'ALTER TABLE $tableName ADD COLUMN position INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<List<Task>> fetchTasks() async {
    final db = await instance.database;
    final result = await db.query('tasks', orderBy: 'position ASC');
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return await db
        .update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<void> updateTaskPositions(List<Task> tasks) async {
    final db = await instance.database;
    final batch = db.batch();

    for (int i = 0; i < tasks.length; i++) {
      batch.update('tasks', {'position': i},
          where: 'id = ?', whereArgs: [tasks[i].id]);
    }

    await batch.commit();
  }



  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}
