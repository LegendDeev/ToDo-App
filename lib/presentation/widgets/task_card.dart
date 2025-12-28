import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/task_model.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final TaskProvider taskProvider;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  const TaskCard({
    Key? key,
    required this.task,
    required this.taskProvider,
    this.onTap,
    this.onToggleComplete,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deadlineToShow = taskProvider.deadlineToShow(task);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            Card(
              elevation: task.isCompleted ? 2 : 8,
              shadowColor: _getPriorityColor().withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: task.isCompleted
                      ? LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                        )
                      : null,
                  border: Border.all(
                    color: task.isCompleted
                        ? Colors.green.withOpacity(0.3)
                        : task.isOverdue
                            ? Colors.red.withOpacity(0.3)
                            : _getPriorityColor().withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 12),
                      _buildTitle(context),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDescription(context),
                      ],
                      const SizedBox(height: 12),
                      _buildFooter(context, deadlineToShow),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 45,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.redAccent),
                tooltip: 'Delete Task',
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _getPriorityColor(),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          task.priorityEmoji,
          style: const TextStyle(fontSize: 16),
        ),
        if (task.recurrence != TaskRecurrence.none) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              task.recurrence.name.toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const Spacer(),
        GestureDetector(
          onTap: onToggleComplete,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: task.isCompleted ? Colors.green : Colors.transparent,
              border: Border.all(
                color: task.isCompleted ? Colors.green : Colors.grey[400]!,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: task.isCompleted
                ? const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      task.title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: task.isCompleted
            ? Colors.grey[600]
            : Theme.of(context).textTheme.titleLarge?.color,
        decoration:
            task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      task.description,
      style: TextStyle(
        fontSize: 14,
        color: task.isCompleted ? Colors.grey[500] : Colors.grey[700],
        decoration:
            task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildFooter(BuildContext context, DateTime deadlineToShow) {
    final isOverdue =
        !task.isCompleted && DateTime.now().isAfter(deadlineToShow);

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 18,
          color: isOverdue ? Colors.red : Colors.grey[600],
        ),
        const SizedBox(width: 3),
        Text(
          'Due by: ${DateFormat('MMM dd, yyyy • HH:mm').format(deadlineToShow)}',
          style: TextStyle(
            fontSize: 11,
            color: isOverdue ? Colors.red : Colors.grey[600],
            fontWeight: isOverdue ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    if (task.isCompleted) {
      return 'COMPLETED';
    } else if (task.isOverdue) {
      return 'OVERDUE';
    } else if (task.isDueToday) {
      return 'DUE TODAY';
    } else {
      return 'PENDING';
    }
  }

  Color _getStatusColor() {
    if (task.isCompleted) {
      return Colors.green;
    } else if (task.isOverdue) {
      return Colors.red;
    } else if (task.isDueToday) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case TaskPriority.critical:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.grey;
    }
  }
}
