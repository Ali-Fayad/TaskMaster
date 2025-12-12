/// ============================================
/// HOME SCREEN
/// ============================================
/// The main dashboard screen of the application.
/// Displays:
/// - Statistics cards (Total, Completed, Pending)
/// - Pie chart showing task distribution by category
/// - List of recent tasks
/// ============================================

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';  // Third party package for charts
import '../data/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../widgets/app_drawer.dart';
import '../widgets/stats_card.dart';
import '../widgets/task_card.dart';
import 'task_list_screen.dart';
import 'add_task_screen.dart';
import 'task_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ========================================
  // STATE VARIABLES
  // ========================================
  
  /// Database helper instance
  final DatabaseHelper _dbHelper = DatabaseHelper. instance;
  
  /// Statistics
  int _totalTasks = 0;
  int _completedTasks = 0;
  int _pendingTasks = 0;
  
  /// Data for pie chart
  Map<int, int> _tasksByCategory = {};
  
  /// List of all categories
  List<Category> _categories = [];
  
  /// List of recent tasks
  List<Task> _recentTasks = [];
  
  /// Loading state
  bool _isLoading = true;

  // ========================================
  // LIFECYCLE METHODS
  // ========================================
  
  @override
  void initState() {
    super.initState();
    _loadData();  // Load data when screen initializes
  }

  // ========================================
  // DATA LOADING METHOD
  // ========================================
  
  /// Loads all data from database and updates state
  /// This demonstrates state lifting - data is loaded here
  /// and passed down to child widgets
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Fetch all data concurrently for better performance
    final results = await Future.wait([
      _dbHelper.getTotalTasksCount(),
      _dbHelper.getCompletedTasksCount(),
      _dbHelper.getPendingTasksCount(),
      _dbHelper.getTasksCountByCategory(),
      _dbHelper.getAllCategories(),
      _dbHelper.getRecentTasks(limit: 5),
    ]);
    
    // Update state with fetched data
    setState(() {
      _totalTasks = results[0] as int;
      _completedTasks = results[1] as int;
      _pendingTasks = results[2] as int;
      _tasksByCategory = results[3] as Map<int, int>;
      _categories = results[4] as List<Category>;
      _recentTasks = results[5] as List<Task>;
      _isLoading = false;
    });
  }

  // ========================================
  // CALLBACK:  Toggle task completion
  // ========================================
  
  /// Called when a task's checkbox is toggled
  /// Updates database and refreshes data
  Future<void> _toggleTaskComplete(Task task) async {
    await _dbHelper.toggleTaskComplete(task.id!, !task.isCompleted);
    
    // Show SnackBar feedback (SnackBar requirement)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text(
            task.isCompleted 
                ? 'Task marked as pending' 
                : 'Task completed!  🎉',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    // Reload data to refresh UI
    _loadData();
  }

  // ========================================
  // HELPER:  Get category by ID
  // ========================================
  
  Category? _getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // ========================================
  // BUILD PIE CHART SECTIONS
  // ========================================
  
  List<PieChartSectionData> _buildPieChartSections() {
    if (_tasksByCategory.isEmpty) {
      // Return empty section if no tasks
      return [
        PieChartSectionData(
          color: Colors. grey[300],
          value: 1,
          title: 'No tasks',
          radius: 50,
          titleStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ];
    }
    
    List<PieChartSectionData> sections = [];
    
    _tasksByCategory.forEach((categoryId, count) {
      final category = _getCategoryById(categoryId);
      if (category != null) {
        sections.add(
          PieChartSectionData(
            color: category. getColor(),
            value: count. toDouble(),
            title: '$count',
            radius: 60,
            titleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
    });
    
    return sections. isEmpty 
        ? [PieChartSectionData(color: Colors.grey, value: 1, title: '')]
        : sections;
  }

  // ========================================
  // BUILD METHOD
  // ========================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ========================================
      // APP BAR
      // ========================================
      appBar: AppBar(
        title: const Text('TaskMaster'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      
      // ========================================
      // SIDE DRAWER (Drawer requirement)
      // ========================================
      drawer: const AppDrawer(),
      
      // ========================================
      // BODY CONTENT
      // ========================================
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:  const EdgeInsets.all(16.0),
                
                // ========================================
                // COLUMN LAYOUT for main content
                // ========================================
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ========================================
                    // STATISTICS ROW (Row layout requirement)
                    // ========================================
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            icon: Icons.assignment,
                            value: '$_totalTasks',
                            label: 'Total Tasks',
                            color: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: StatsCard(
                            icon:  Icons.check_circle,
                            value: '$_completedTasks',
                            label: 'Completed',
                            color: Colors.green,
                          ),
                        ),
                        Expanded(
                          child:  StatsCard(
                            icon: Icons.pending,
                            value: '$_pendingTasks',
                            label: 'Pending',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ========================================
                    // PIE CHART SECTION (fl_chart package)
                    // ========================================
                    const Text(
                      'Tasks by Category',
                      style:  TextStyle(
                        fontSize:  18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stack layout for chart and legend
                    SizedBox(
                      height:  200,
                      child: Row(
                        children: [
                          // Pie Chart
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sections: _buildPieChartSections(),
                                centerSpaceRadius: 40,
                                sectionsSpace:  2,
                              ),
                            ),
                          ),
                          
                          // Legend
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _categories.map((category) {
                                final count = _tasksByCategory[category. id] ?? 0;
                                return Padding(
                                  padding:  const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration:  BoxDecoration(
                                          color: category.getColor(),
                                          shape: BoxShape. circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child:  Text(
                                          '${category.name} ($count)',
                                          style:  const TextStyle(fontSize: 12),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // ========================================
                    // RECENT TASKS SECTION
                    // ========================================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight. bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to all tasks
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const TaskListScreen(),
                              ),
                            );
                          },
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Tasks list or empty state
                    _recentTasks.isEmpty
                        ?  Center(
                            child:  Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.task_alt,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No tasks yet!\nTap + to add your first task.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors. grey[600],
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            // Prevent ListView from scrolling independently
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _recentTasks.length,
                            itemBuilder: (context, index) {
                              final task = _recentTasks[index];
                              final category = _getCategoryById(task.categoryId);
                              
                              return TaskCard(
                                task: task,
                                category: category,
                                // Callback for completion toggle
                                onComplete: (value) => _toggleTaskComplete(task),
                                // Navigate to details on tap
                                onTap:  () async {
                                  await Navigator. push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TaskDetailsScreen(
                                        taskId: task.id!,
                                      ),
                                    ),
                                  );
                                  // Refresh data when returning
                                  _loadData();
                                },
                              );
                            },
                          ),
                  ],
                ),
              ),
            ),
      
      // ========================================
      // FLOATING ACTION BUTTON
      // ========================================
      floatingActionButton:  FloatingActionButton(
        onPressed: () async {
          // Navigate to Add Task screen
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          // Refresh data when returning
          _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}