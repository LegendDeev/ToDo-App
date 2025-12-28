import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../../data/models/task_model.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task; // For editing existing task

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 1));
  TaskRecurrence _selectedRecurrence = TaskRecurrence.none;
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _reminderTime;
  String? _reminderPeriod;
  bool _hasReminder = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    // Initialize with existing task data if editing
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedDeadline = widget.task!.deadline;
      _selectedRecurrence = widget.task!.recurrence;
      _selectedPriority = widget.task!.priority;
      _reminderTime = widget.task!.reminderTime;
      _reminderPeriod = widget.task!.reminderPeriod;
      _hasReminder = widget.task!.reminderTime != null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Create New Goal' : 'Edit Goal'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Motivational quote
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFB347)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Every great achievement starts with a clear goal!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Title field
              _buildSectionTitle('Goal Title'),
              TextFormField(
                controller: _titleController,
                decoration: _buildInputDecoration(
                  'What will you conquer?',
                  Icons.flag_rounded,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a goal title';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Description field
              _buildSectionTitle('Description (Optional)'),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: _buildInputDecoration(
                  'Add details to your conquest...',
                  Icons.description,
                ),
              ),

              const SizedBox(height: 24),

              // Deadline selection
              _buildSectionTitle('Deadline'),
              InkWell(
                onTap: _selectDeadline,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Color(0xFF6C63FF)),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMM dd, yyyy • HH:mm')
                            .format(_selectedDeadline),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recurrence selection
              _buildSectionTitle('Recurrence'),
              _buildRecurrenceSelector(),

              const SizedBox(height: 24),

              // Priority selection
              _buildSectionTitle('Priority Level'),
              _buildPrioritySelector(),

              const SizedBox(height: 24),

              // Reminder section
              _buildSectionTitle('Reminder'),
              _buildReminderSection(),

              const SizedBox(height: 40),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.task == null ? '🚀 CREATE GOAL' : '✨ UPDATE GOAL',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF6C63FF),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
    );
  }

  Widget _buildRecurrenceSelector() {
    return Row(
      children: TaskRecurrence.values.map((recurrence) {
        final isSelected = _selectedRecurrence == recurrence;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRecurrence = recurrence),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF6C63FF) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Text(
                  recurrence.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrioritySelector() {
    return Row(
      children: TaskPriority.values.map((priority) {
        final isSelected = _selectedPriority == priority;
        Color color;
        switch (priority) {
          case TaskPriority.critical:
            color = Colors.red;
            break;
          case TaskPriority.high:
            color = Colors.orange;
            break;
          case TaskPriority.medium:
            color = Colors.blue;
            break;
          case TaskPriority.low:
            color = Colors.grey;
            break;
        }

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPriority = priority),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color),
                ),
                child: Text(
                  priority.name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderSection() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Enable Reminder'),
          subtitle: const Text('Get motivated at the right time'),
          value: _hasReminder,
          onChanged: (value) => setState(() => _hasReminder = value),
          activeColor: const Color(0xFF6C63FF),
        ),
        if (_hasReminder) ...[
          const SizedBox(height: 16),

          // Time selection
          InkWell(
            onTap: _selectReminderTime,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 12),
                  Text(
                    _reminderTime != null
                        ? DateFormat('HH:mm').format(_reminderTime!)
                        : 'Select reminder time',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Period selection
          Row(
            children: ['morning', 'afternoon', 'evening'].map((period) {
              final isSelected = _reminderPeriod == period;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _reminderPeriod = period),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF6C63FF)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Text(
                        period.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Future<void> _selectDeadline() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      if (mounted) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_selectedDeadline),
        );

        if (time != null) {
          setState(() {
            _selectedDeadline = DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            );
          });
        }
      }
    }
  }

  Future<void> _selectReminderTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        final now = DateTime.now();
        _reminderTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  void _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    final task = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      deadline: _selectedDeadline,
      recurrence: _selectedRecurrence,
      priority: _selectedPriority,
      reminderTime: _hasReminder ? _reminderTime : null,
      reminderPeriod: _hasReminder ? _reminderPeriod : null,
      isCompleted: widget.task?.isCompleted ?? false,
      createdAt: widget.task?.createdAt,
      completedAt: widget.task?.completedAt,
      streakCount: widget.task?.streakCount ?? 0,
      completionHistory: widget.task?.completionHistory ?? [],
    );

    bool success;
    if (widget.task == null) {
      success = await taskProvider.addTask(task);
    } else {
      success = await taskProvider.updateTask(task);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.task == null
                ? '🎯 Goal created! Time to dominate!'
                : '✨ Goal updated! Victory awaits!',
          ),
          backgroundColor: const Color(0xFF00C896),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save goal. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
