import 'package:flutter/material.dart';
import 'package:sync_todo/models/task.dart';
import 'package:sync_todo/repositories/task_repository.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TaskRepository _taskRepository = TaskRepository();
  bool _isButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _taskController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _taskController.text.trim().isNotEmpty;
    });
  }

  Future<void> _saveTask() async {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    // テキストを改行で分割し、空の行を除外
    final taskTitles =
        text
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

    // 各行を個別のタスクとして保存
    for (var i = 0; i < taskTitles.length; i++) {
      final now = DateTime.now();
      final task = Task(title: taskTitles[i], updated: now);
      await _taskRepository.addTask(task);
    }

    if (!mounted) return;
    Navigator.pop(context, true); // タスクが追加されたことを伝える
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('新しいタスクを追加')),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Theme.of(context).scaffoldBackgroundColor, // テーマの背景色を使用
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: LinedTextField(
                    controller: _taskController,
                    hintText: 'タスクを入力...',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isButtonEnabled ? _saveTask : null,
        backgroundColor:
            _isButtonEnabled
                ? Theme.of(context).appBarTheme.backgroundColor
                : Colors.grey,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        tooltip: '登録',
        child: const Icon(Icons.check),
      ),
    );
  }
}

// ノート風の罫線付きテキストフィールドウィジェット
class LinedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const LinedTextField({
    super.key,
    required this.controller,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: LinedTextFieldPainter(),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(
            left: 36.0, // 赤線の分だけ左に余白
            right: 16.0,
            top: 20.0,
            bottom: 12.0,
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
        style: const TextStyle(
          fontSize: 18.0,
          height: 1.5, // 行の高さを罫線に合わせる
          fontFamily: 'RobotoMono', // 等幅フォントでノート感
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }
}

// ノート風の罫線を描画するためのペインター
class LinedTextFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint =
        Paint()
          ..color = Colors.grey.shade300
          ..strokeWidth = 1.0;
    final redLinePaint =
        Paint()
          ..color = Colors.red.shade200
          ..strokeWidth = 2.0;

    const double lineHeight = 27.0; // テキスト行の高さに合わせる
    double y = 20.0; // 最初の線の位置（パディングと合わせる）

    // 横罫線
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += lineHeight;
    }
    // 左側の赤い縦線
    canvas.drawLine(const Offset(28, 0), Offset(28, size.height), redLinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
