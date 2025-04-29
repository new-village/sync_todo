import 'package:flutter/material.dart';
import 'package:sync_todo/models/task.dart';

// チェックボックスやタイトルのTextStyleを共通定数化
const kTaskTitleStyle = TextStyle(fontWeight: FontWeight.w600);

class TaskItem extends StatelessWidget {
  final Task task;
  final Function(String) onToggle;
  // 削除用コールバックは不要になったが、他の箇所のため残す
  final Function(String) onDelete;
  final void Function(Task) onTap; // 追加
  final void Function(Task) onToday; // 追加

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    required this.onTap, // 追加
    required this.onToday, // 追加
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = task.isCompleted;
    return Card(
      color: theme.cardColor, // テーマのカード色を使用
      elevation: 1,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 2,
      ), // さらに高さを低く
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ), // 角を角ばった形に
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 0,
        ), // 高さをさらに低く
        child: ListTile(
          leading: Transform.scale(
            scale: 1.5, // チェックボックスをさらに大きく
            child: Checkbox.adaptive(
              value: isCompleted,
              onChanged: (_) => onToggle(task.id),
              activeColor: theme.colorScheme.primary,
              shape: const CircleBorder(), // 丸型に
              side: BorderSide(
                color: theme.dividerColor, // テーマのdividerColorを利用
                width: 1.5,
              ),
              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap, // チェックボックスのタップ領域を小さく
              visualDensity: const VisualDensity(
                horizontal: -4,
                vertical: -4,
              ), // さらに高さを詰める
              fillColor: WidgetStateProperty.resolveWith<Color>((states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.primary;
                }
                return theme.dividerColor; // 非選択時の色をテーマのdividerColorに
              }),
            ),
          ),
          title: Text(
            task.title,
            style: theme.textTheme.titleMedium
                ?.merge(kTaskTitleStyle)
                .copyWith(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  color:
                      isCompleted
                          ? theme.colorScheme.onSurfaceVariant.withAlpha(128)
                          : theme.colorScheme.onSurfaceVariant,
                ),
          ),
          // subtitle: 作成日表示を削除
          minLeadingWidth: 0,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 0, // さらに高さを低く
          ),
          onTap: () => onTap(task), // 追加
          trailing: IconButton(
            icon: Icon(
              Icons.today,
              color:
                  task.deadline != null &&
                          DateUtils.isSameDay(
                            task.deadline,
                            DateTime(
                              DateTime.now().year,
                              DateTime.now().month,
                              DateTime.now().day,
                            ),
                          )
                      ? Colors.teal
                      : Colors.grey,
            ),
            tooltip: '今日やる',
            onPressed: () => onToday(task),
          ),
        ),
      ),
    );
  }
}
