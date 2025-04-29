import 'package:hive/hive.dart';
import 'package:sync_todo/models/task.dart';

class TaskRepository {
  static const String _boxName = 'tasksBox';

  // Hiveボックスを取得するメソッド
  Future<Box<Task>> _getTasksBox() async {
    return await Hive.openBox<Task>(_boxName);
  }

  // 全てのタスクを取得
  Future<List<Task>> getAllTasks() async {
    final box = await _getTasksBox();
    return box.values.toList();
  }

  // タスクを追加
  Future<void> addTask(Task task) async {
    final box = await _getTasksBox();
    final now = DateTime.now();
    await box.put(task.id, task.copyWith(updated: now));
  }

  // タスクを更新
  Future<void> updateTask(Task task) async {
    final box = await _getTasksBox();
    final now = DateTime.now();
    await box.put(task.id, task.copyWith(updated: now));
  }

  // タスクを削除
  Future<void> deleteTask(String id) async {
    final box = await _getTasksBox();
    await box.delete(id);
  }

  // タスクの完了状態を切り替え
  Future<void> toggleTaskCompletion(String id) async {
    final box = await _getTasksBox();
    final task = box.get(id);
    if (task != null) {
      final now = DateTime.now();
      await box.put(
        id,
        task.copyWith(isCompleted: !task.isCompleted, updated: now),
      );
    }
  }
}
