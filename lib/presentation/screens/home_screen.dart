import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/task_provider.dart';
import '../../data/models/task_model.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_card.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Set filter on tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final provider = Provider.of<TaskProvider>(context, listen: false);
      switch (_tabController.index) {
        case 0:
          provider.setFilter(TaskFilter.all);
          break;
        case 1:
          provider.setFilter(TaskFilter.today);
          break;
        case 2:
          provider.setFilter(TaskFilter.pending);
          break;
        case 3:
          provider.setFilter(TaskFilter.completed);
          break;
      }
    });

    // Initialize filter to All on first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<TaskProvider>(context, listen: false);
      provider.setFilter(TaskFilter.all);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        print(
            'Building HomeScreen with ${taskProvider.tasks.length} tasks, filter: ${taskProvider.currentFilter}');
        return DefaultTabController(
          length: 4,
          child: Scaffold(
            body: RefreshIndicator(
              onRefresh: taskProvider.refresh,
              child: CustomScrollView(
                slivers: [
                  _buildAppBar(context, taskProvider),
                  _buildStatsSection(taskProvider),
                  _buildTabBar(),
                  _buildTabContent(taskProvider),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _navigateToAddTask(context),
              backgroundColor: const Color(0xFFFFD700),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                'ADD GOAL',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(BuildContext context, TaskProvider taskProvider) {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6C63FF),
                Color(0xFF4C43D4),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Ready to dominate?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: taskProvider.searchTasks,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search your goals...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(TaskProvider taskProvider) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              taskProvider.motivationalMessage,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Total Tasks',
                    value: taskProvider.totalTasks.toString(),
                    icon: Icons.task_alt,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4C43D4)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Completed',
                    value: taskProvider.completedTasks.toString(),
                    icon: Icons.check_circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C896), Color(0xFF00A67C)],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatsCard(
                    title: 'Success Rate',
                    value: '${(taskProvider.completionRate * 100).toInt()}%',
                    icon: Icons.trending_up,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFB347)],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatsCard(
                    title: 'Streak',
                    value: taskProvider.currentStreak.toString(),
                    icon: Icons.local_fire_department,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.deepPurpleAccent,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Today'),
          Tab(text: 'Pending'),
          Tab(text: 'Completed'),
        ],
      ),
    );
  }

  Widget _buildTabContent(TaskProvider taskProvider) {
    return SliverFillRemaining(
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(taskProvider),
          _buildTaskList(taskProvider),
          _buildTaskList(taskProvider),
          _buildTaskList(taskProvider),
        ],
      ),
    );
  }

  Widget _buildTaskList(TaskProvider taskProvider) {
    final tasks = taskProvider.tasks;
    if (taskProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (tasks.isEmpty) {
      return _buildEmptyState(taskProvider.currentFilter);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          taskProvider: Provider.of<TaskProvider>(context, listen: false),
          onTap: () => _showTaskDetails(context, task),
          onToggleComplete: () => taskProvider.toggleTaskCompletion(task),
          onDelete: () => _deleteTask(context, taskProvider, task),
        );
      },
    );
  }

  Widget _buildEmptyState(TaskFilter filter) {
    String title;
    String subtitle;
    IconData icon;

    switch (filter) {
      case TaskFilter.all:
        title = 'Ready to conquer?';
        subtitle = 'Add your first goal and start dominating!';
        icon = Icons.rocket_launch;
        break;
      case TaskFilter.today:
        title = 'Today is yours!';
        subtitle = 'No tasks for today. Time to plan your victory!';
        icon = Icons.today;
        break;
      case TaskFilter.pending:
        title = 'All caught up!';
        subtitle = 'No pending tasks. You\'re absolutely crushing it!';
        icon = Icons.check_circle_outline;
        break;
      case TaskFilter.completed:
        title = 'Your victories await!';
        subtitle = 'Complete some tasks to see your achievements here!';
        icon = Icons.emoji_events;
        break;
      default:
        title = 'No tasks';
        subtitle = 'No tasks available.';
        icon = Icons.info_outline;
    }

    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[500],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning, Champion!';
    } else if (hour < 17) {
      return 'Good afternoon, Warrior!';
    } else {
      return 'Good evening, Master!';
    }
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            const SizedBox(height: 10),
            Text(
                'Deadline: ${DateFormat('MMM dd, yyyy • HH:mm').format(task.deadline)}'),
            Text(
                'Priority: ${task.priority.name.toUpperCase()} ${task.priorityEmoji}'),
            if (task.recurrence != TaskRecurrence.none)
              Text('Recurrence: ${task.recurrence.name.toUpperCase()}'),
            const SizedBox(height: 10),
            Text(
              task.motivationalMessage,
              style: TextStyle(
                color: task.isCompleted ? Colors.green : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!task.isCompleted)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Provider.of<TaskProvider>(context, listen: false)
                    .toggleTaskCompletion(task);
              },
              child: const Text('Mark Complete'),
            ),
        ],
      ),
    );
  }

  void _deleteTask(BuildContext context, TaskProvider taskProvider, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              taskProvider.deleteTask(task);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${task.title} deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
