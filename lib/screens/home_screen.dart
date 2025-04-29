import 'package:flutter/material.dart';
import 'package:sync_todo/models/task.dart';
import 'package:sync_todo/repositories/task_repository.dart';
import 'package:sync_todo/screens/add_task_screen.dart';
import 'package:sync_todo/screens/edit_task_screen.dart';
import 'package:sync_todo/widgets/task_item.dart';
import 'package:dots_indicator/dots_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TaskRepository _taskRepository = TaskRepository();
  List<Task> _tasks = [];
  bool _isLoading = true;
  int _pageIndex = 0; // 0:今日, 1:一覧
  final PageController _pageController = PageController();
  bool _showAllTasks = true; // 追加: すべてのタスク表示トグル

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day); // 日付のみ
    final List<Task> todayTasks =
        _tasks
            .where(
              (task) =>
                  task.deadline != null &&
                  DateUtils.isSameDay(task.deadline, today),
            )
            .toList();
    // トグルに応じてallTasksを切り替え
    final List<Task> allTasks =
        _showAllTasks
            ? _tasks
            : _tasks.where((task) => !task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageIndex == 0 ? '今日のタスク' : 'タスク一覧'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0), // 余白をなくす
          child: DotsIndicator(
            dotsCount: 2,
            position: _pageIndex.toDouble(),
            decorator: DotsDecorator(
              activeColor: Colors.white,
              color: Colors.white.withAlpha(102), // 0.4相当
              size: const Size.square(8.0),
              activeSize: const Size(18.0, 8.0),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
              : PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _pageIndex = index;
                  });
                },
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.6,
                              alignment: Alignment.centerLeft,
                              child: Switch(
                                value: _showAllTasks,
                                onChanged: (value) {
                                  setState(() {
                                    _showAllTasks = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '完了タスクも表示',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildTaskList(
                          _showAllTasks
                              ? todayTasks
                              : todayTasks
                                  .where((task) => !task.isCompleted)
                                  .toList(),
                          emptyText: '今日のタスクはありません',
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.scale(
                              scale: 0.6,
                              alignment: Alignment.centerLeft,
                              child: Switch(
                                value: _showAllTasks,
                                onChanged: (value) {
                                  setState(() {
                                    _showAllTasks = value;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '完了タスクも表示',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: _buildTaskList(
                          allTasks,
                          emptyText: 'タスクがありません。\n新しいタスクを追加しましょう！',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTaskScreen,
        tooltip: 'タスクを追加',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTaskList(List<Task> tasks, {required String emptyText}) {
    if (tasks.isEmpty) {
      return Center(child: Text(emptyText));
    }
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
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
          onToday: (task) async {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day); // 日付のみ
            final isToday =
                task.deadline != null &&
                DateUtils.isSameDay(task.deadline, today);
            debugPrint(
              '[onToday] task.title: \'${task.title}\', deadline: \'${task.deadline}\', isToday: $isToday',
            );
            final updated =
                isToday
                    ? task.copyWith(deadline: null, deadlineSet: true)
                    : task.copyWith(deadline: today, deadlineSet: true);
            await _taskRepository.updateTask(updated);
            await _loadTasks();
          },
        );
      },
    );
  }
}
