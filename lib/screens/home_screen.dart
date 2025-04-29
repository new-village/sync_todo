import 'package:flutter/material.dart';
import 'package:sync_todo/models/task.dart';
import 'package:sync_todo/repositories/task_repository.dart';
import 'package:sync_todo/screens/add_task_screen.dart';
import 'package:sync_todo/screens/edit_task_screen.dart';
import 'package:sync_todo/widgets/task_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _showAllTasks = false; // トグルスイッチ用（デフォルト:未完了のみ）

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    final tasks = await _taskRepository.getAllTasks();

    // 作成日時の新しい順にソート
    tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _navigateToAddTaskScreen() async {
    // タスク追加画面に遷移
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    // タスクが追加された場合はリストを更新
    if (result == true) {
      await _loadTasks();
    }
  }

  Future<void> _toggleTaskCompletion(String id) async {
    await _taskRepository.toggleTaskCompletion(id);
    await _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    // 表示用リストをフィルタリング
    final List<Task> displayTasks =
        _showAllTasks
            ? _tasks
            : _tasks.where((task) => !task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Sync Todo')),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
              : _tasks.isEmpty
              ? const Center(child: Text('タスクがありません。新しいタスクを追加しましょう！'))
              : ListView.builder(
                itemCount: displayTasks.length + 1, // +1 for toggle switch
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // トグルスイッチをリストの先頭に表示
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 0.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // 左寄せ
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Transform.scale(
                            scale: 0.6, // 60%の大きさに縮小
                            child: Switch(
                              value: _showAllTasks,
                              onChanged: (value) {
                                setState(() {
                                  _showAllTasks = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 6), // スイッチとテキストの間に適度な余白
                          const Text(
                            '完了済みタスクも表示',
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }
                  final task = displayTasks[index - 1];
                  return TaskItem(
                    task: task,
                    onToggle: _toggleTaskCompletion,
                    onDelete: _deleteTask,
                    onTap: (task) async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditTaskScreen(task: task),
                        ),
                      );
                      if (result == true) {
                        await _loadTasks();
                      }
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskScreen,
        tooltip: 'タスクを追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}
