import 'package:flutter/material.dart';
import '../../data/models/task_model.dart';
import '../../data/services/database_service.dart';
import '../../data/services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String _searchQuery = '';
  TaskFilter _currentFilter = TaskFilter.all;

  // Getters
  List<Task> get tasks => _getFilteredTasks();
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TaskFilter get currentFilter => _currentFilter;

  // Statistics getters
  int get totalTasks => _tasks.length;
  int get completedTasks => _tasks.where((task) => task.isCompleted).length;
  int get pendingTasks => _tasks.where((task) => !task.isCompleted).length;
  int get overdueTasks => _tasks.where((task) => isTaskOverdue(task)).length;
  int get todayTasks => _tasks.where((task) => task.isDueToday).length;

  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return completedTasks / totalTasks;
  }

  int get currentStreak {
    final completedToday = _tasks
        .where((task) =>
            task.isCompleted &&
            task.completedAt != null &&
            _isSameDay(task.completedAt!, DateTime.now()))
        .length;
    return completedToday;
  }

  // Load all tasks from database
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = await DatabaseService.getAllTasks();
      resetRecurringTasks();
      _tasks.sort((a, b) => deadlineToShow(a).compareTo(deadlineToShow(b)));
      notifyListeners();
    } catch (e) {
      print('Error loading tasks: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Recurring logic: reset as pending if period changed
  void resetRecurringTasks() {
    final now = DateTime.now();
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.isCompleted && task.recurrence != TaskRecurrence.none) {
        bool shouldReset = false;
        DateTime lastComplete =
            task.completedAt ?? now.subtract(Duration(days: 1));

        switch (task.recurrence) {
          case TaskRecurrence.daily:
            shouldReset = !_isSameDay(now, lastComplete);
            break;
          case TaskRecurrence.weekly:
            shouldReset = !_isSameWeek(now, lastComplete);
            break;
          case TaskRecurrence.monthly:
            shouldReset = !_isSameMonth(now, lastComplete);
            break;
          default:
            break;
        }
        if (shouldReset) {
          final updatedTask =
              task.copyWith(isCompleted: false, completedAt: null);
          _tasks[i] = updatedTask;
          DatabaseService.updateTask(updatedTask);
        }
      }
    }
  }

  // Add new task
  Future<bool> addTask(Task task) async {
    _setLoading(true);
    try {
      final createdTask = await DatabaseService.createTask(task);
      if (createdTask != null) {
        _tasks.add(createdTask);
        _tasks.sort((a, b) => deadlineToShow(a).compareTo(deadlineToShow(b)));
        await _scheduleTaskNotifications(createdTask);
      }
      notifyListeners();
      return true;
    } catch (e) {
      print('Error adding task: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update existing task
  Future<bool> updateTask(Task updatedTask) async {
    try {
      final success = await DatabaseService.updateTask(updatedTask);
      if (success) {
        final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
          _tasks.sort((a, b) => deadlineToShow(a).compareTo(deadlineToShow(b)));
          await NotificationService.cancelNotification(updatedTask.id.hashCode);
          await _scheduleTaskNotifications(updatedTask);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error updating task: $e');
      return false;
    }
  }

  // Delete task
  Future<bool> deleteTask(Task task) async {
    try {
      final success = await DatabaseService.deleteTask(task.id!);
      if (success) {
        _tasks.removeWhere((t) => t.id == task.id);
        await NotificationService.cancelNotification(task.id.hashCode);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting task: $e');
      return false;
    }
  }

  // Toggle task completion
  Future<bool> toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        streakCount:
            !task.isCompleted ? task.streakCount + 1 : task.streakCount,
        completionHistory: !task.isCompleted
            ? [...task.completionHistory, DateTime.now()]
            : task.completionHistory,
      );
      return await updateTask(updatedTask);
    } catch (e) {
      print('Error toggling task completion: $e');
      return false;
    }
  }

  // Search tasks
  void searchTasks(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  // Filter tasks
  void setFilter(TaskFilter filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  // Helpers
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  List<Task> _getFilteredTasks() {
    List<Task> filtered = _tasks;
    switch (_currentFilter) {
      case TaskFilter.pending:
        filtered = filtered.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.completed:
        filtered = filtered.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.today:
        filtered = filtered.where((task) => task.isDueToday).toList();
        break;
      case TaskFilter.overdue:
        filtered = filtered.where((task) => isTaskOverdue(task)).toList();
        break;
      case TaskFilter.all:
        break;
    }
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery) ||
              task.description.toLowerCase().contains(_searchQuery))
          .toList();
    }
    return filtered;
  }

  Future<void> _scheduleTaskNotifications(Task task) async {
    if (task.reminderTime != null) {
      if (task.recurrence != TaskRecurrence.none) {
        await NotificationService.scheduleRecurringReminder(task);
      } else {
        await NotificationService.scheduleTaskReminder(task);
      }
    }
  }

  // --- DEADLINE LOGIC FOR RECURRING TASKS ---
  DateTime getAutoDeadline(Task task) {
    final now = DateTime.now();
    final created = task.createdAt ?? now;
    switch (task.recurrence) {
      case TaskRecurrence.daily:
        return DateTime(now.year, now.month, now.day, 23, 59);
      case TaskRecurrence.weekly:
        // Next weekday (same as createdAt) at 23:59
        final targetWeekday = created.weekday;
        final diff = (targetWeekday - now.weekday + 7) % 7;
        final deadlineDay = now.add(Duration(days: diff == 0 ? 7 : diff));
        return DateTime(
            deadlineDay.year, deadlineDay.month, deadlineDay.day, 23, 59);
      case TaskRecurrence.monthly:
        int targetDay = created.day;
        int nextMonth = now.month + 1;
        int year = now.year;
        if (nextMonth > 12) {
          nextMonth = 1;
          year++;
        }
        int daysInNextMonth = DateTime(year, nextMonth + 1, 0).day;
        targetDay = targetDay > daysInNextMonth ? daysInNextMonth : targetDay;
        return DateTime(year, nextMonth, targetDay, 23, 59);
      default:
        return task.deadline ?? now;
    }
  }

  DateTime deadlineToShow(Task task) => task.deadline ?? getAutoDeadline(task);

  bool isTaskOverdue(Task task) {
    final deadline = deadlineToShow(task);
    return !task.isCompleted && DateTime.now().isAfter(deadline);
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSameWeek(DateTime a, DateTime b) {
    final mondayA = a.subtract(Duration(days: a.weekday - 1));
    final mondayB = b.subtract(Duration(days: b.weekday - 1));
    return mondayA.year == mondayB.year &&
        mondayA.month == mondayB.month &&
        mondayA.day == mondayB.day;
  }

  bool _isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  String get motivationalMessage {
    if (completionRate >= 0.9) {
      return "🔥 You're absolutely CRUSHING it! Pure dominance!";
    } else if (completionRate >= 0.7) {
      return "⚡ Unstoppable force! Keep the momentum going!";
    } else if (completionRate >= 0.5) {
      return "💪 You're building something great! Push harder!";
    } else if (completionRate >= 0.3) {
      return "🎯 The champion in you is awakening! Time to dominate!";
    } else {
      return "👑 Every empire starts with a single step. You've got this!";
    }
  }

  Future<void> refresh() async {
    await loadTasks();
  }
}

enum TaskFilter {
  all,
  pending,
  completed,
  today,
  overdue,
}
