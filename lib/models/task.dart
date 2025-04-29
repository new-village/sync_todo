import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  DateTime? deadline;

  @HiveField(5)
  DateTime updated;

  Task({
    String? id,
    required this.title,
    this.isCompleted = false,
    DateTime? createdAt,
    this.deadline,
    DateTime? updated,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       updated = updated ?? DateTime.now();

  Task copyWith({
    String? title,
    bool? isCompleted,
    DateTime? deadline,
    bool deadlineSet = false, // 追加
    DateTime? updated,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt,
      deadline: deadlineSet ? deadline : this.deadline, // 修正
      updated: updated ?? DateTime.now(),
    );
  }
}
