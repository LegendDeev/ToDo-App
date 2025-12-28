import 'package:mongo_dart/mongo_dart.dart';

enum TaskRecurrence { none, daily, weekly, monthly }

enum TaskPriority { low, medium, high, critical }

class Task {
  final ObjectId? id;
  final String title;
  final String description;
  final DateTime deadline;
  final TaskRecurrence recurrence;
  final TaskPriority priority;
  final DateTime? reminderTime;
  final String? reminderPeriod; // 'morning', 'evening', 'afternoon'
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int streakCount;
  final List<DateTime> completionHistory;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.deadline,
    this.recurrence = TaskRecurrence.none,
    this.priority = TaskPriority.medium,
    this.reminderTime,
    this.reminderPeriod,
    this.isCompleted = false,
    DateTime? createdAt,
    this.completedAt,
    this.streakCount = 0,
    this.completionHistory = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to MongoDB document
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'deadline': deadline.toIso8601String(),
      'recurrence': recurrence.name,
      'priority': priority.name,
      'reminderTime': reminderTime?.toIso8601String(),
      'reminderPeriod': reminderPeriod,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'streakCount': streakCount,
      'completionHistory':
          completionHistory.map((d) => d.toIso8601String()).toList(),
    };
  }

  // Create from MongoDB document
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['_id'] as ObjectId?,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      deadline: DateTime.parse(map['deadline']),
      recurrence: TaskRecurrence.values.firstWhere(
        (e) => e.name == map['recurrence'],
        orElse: () => TaskRecurrence.none,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => TaskPriority.medium,
      ),
      reminderTime: map['reminderTime'] != null
          ? DateTime.parse(map['reminderTime'])
          : null,
      reminderPeriod: map['reminderPeriod'],
      isCompleted: map['isCompleted'] ?? false,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      streakCount: map['streakCount'] ?? 0,
      completionHistory: (map['completionHistory'] as List<dynamic>?)
              ?.map((d) => DateTime.parse(d.toString()))
              .toList() ??
          [],
    );
  }

  // Copy with method for updates
  Task copyWith({
    ObjectId? id,
    String? title,
    String? description,
    DateTime? deadline,
    TaskRecurrence? recurrence,
    TaskPriority? priority,
    DateTime? reminderTime,
    String? reminderPeriod,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
    int? streakCount,
    List<DateTime>? completionHistory,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      recurrence: recurrence ?? this.recurrence,
      priority: priority ?? this.priority,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderPeriod: reminderPeriod ?? this.reminderPeriod,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      streakCount: streakCount ?? this.streakCount,
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }

  // Check if task is overdue
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(deadline);

  // Check if task is due today
  bool get isDueToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDay = DateTime(deadline.year, deadline.month, deadline.day);
    return today == taskDay;
  }

  // Get motivational message based on task status
  String get motivationalMessage {
    if (isCompleted) {
      return "🔥 DOMINATED! You're unstoppable!";
    } else if (isOverdue) {
      return "⚡ Time to conquer this challenge!";
    } else if (isDueToday) {
      return "🎯 Today's your day to shine!";
    } else {
      return "💪 You've got this, champion!";
    }
  }

  // Get priority color
  String get priorityEmoji {
    switch (priority) {
      case TaskPriority.critical:
        return "🔴";
      case TaskPriority.high:
        return "🟡";
      case TaskPriority.medium:
        return "🟢";
      case TaskPriority.low:
        return "🔵";
    }
  }
}
