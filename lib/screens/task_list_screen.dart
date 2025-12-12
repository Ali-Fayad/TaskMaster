/// ============================================
/// TASK LIST SCREEN
/// ============================================
/// Displays a filterable list of all tasks. 
/// Features:
/// - Filter by category (DropdownButton)
/// - Filter by status (All/Completed/Pending)
/// - Swipe to delete tasks
/// - ListView with TaskCard widgets
/// ============================================

import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../widgets/task_card.dart';
import '../widgets/app_drawer.dart';
import 'add_task_screen.dart';
import 'task_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // ========================================
  // STATE VARIABLES
  // ========================================
  
  final DatabaseHelper _dbHelper = DatabaseHelper. instance;
  
  /// All tasks from database
  List<Task> _allTasks = [];
  
  /// Filtered tasks to display
  List<Task> _filteredTasks = [];
  
  /// All categories for dropdown
  List<Category> _categories = [];
  
  /// Currently selected category filter (null = All)
  int? _selectedCategoryId;
  
  /// Currently selected status filter
  String _selectedStatus = 'All';  // All, Completed, Pending
  
  /// Loading state
  bool _isLoading = true;

  // ========================================
  // LIFECYCLE METHODS
  // ========================================
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ========================================
  // DATA LOADING
  // ========================================
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final tasks = await _dbHelper.getAllTasks();
    final categories = await _dbHelper.getAllCategories();
    
    setState(() {
      _allTasks = tasks;
      _categories = categories;
      _isLoading = false;
    });
    
    _applyFilters();
  }

  // ========================================
  // FILTER LOGIC
  // ========================================
  
  /// Applies both category and status filters
  void _applyFilters() {
    List<Task> filtered = List.from(_allTasks);
    
    // Apply category filter
    if (_selectedCategoryId != null) {
      filtered = filtered.where((t) => t.categoryId == _selectedCategoryId).toList();
    }
    
    // Apply status filter
    if (_selectedStatus == 'Completed') {
      filtered = filtered.where((t) => t.isCompleted).toList();
    } else if (_selectedStatus == 'Pending') {
      filtered = filtered. where((t) => !t.isCompleted).toList();
    }
    
    setState(() {
      _filteredTasks = filtered;
    });
  }

  // ========================================
  // CALLBACKS
  // ========================================
  
  /// Toggle task completion
  Future<void> _toggleTaskComplete(Task task) async {
    await _dbHelper.toggleTaskComplete(task.id!, !task.isCompleted);
    
    // ========================================
    // SNACKBAR (SnackBar requirement)
    // ========================================
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            task.isCompleted ?  'Task marked as pending' :  'Task completed! 🎉',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    _loadData();
  }

  /// Delete task with confirmation
  Future<void> _deleteTask(Task task) async {
    // ========================================
    // ALERT DIALOG (Dialog requirement)
    // ========================================
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      await _dbHelper.deleteTask(task.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      _loadData();
    }
  }

  // ========================================
  // HELPER:  Get category by ID
  // ========================================
  
  Category?  _getCategoryById(int categoryId) {
    try {
      return _categories.firstWhere((c) => c.id == categoryId);
    } catch (e) {
      return null;
    }
  }

  // ========================================
  // BUILD METHOD
  // ========================================
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  const Text('All Tasks'),
        backgroundColor: Theme. of(context).colorScheme.inversePrimary,
      ),
      
      drawer: const AppDrawer(),
      
      body: _isLoading
          ?  const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ========================================
                // FILTER ROW (DropdownButton requirement)
                // ========================================
                Container(
                  padding:  const EdgeInsets.all(16),
                  color: Colors. grey[100],
                  child: Row(
                    children:  [
                      // Category filter dropdown
                      Expanded(
                        child: DropdownButtonFormField<int? >(
                          initialValue: _selectedCategoryId,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets. symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          items: [
                            // "All" option
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All Categories'),
                            ),
                            // Category options
                            ..._categories.map((category) {
                              return DropdownMenuItem<int?>(
                                value: category.id,
                                child: Row(
                                  children: [
                                    Icon(
                                      category.getIcon(),
                                      size: 16,
                                      color: category.getColor(),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(category.name),
                                  ],
                                ),
                              );
                            }),
                          ],

                          onChanged: (value) {
                            setState(() => _selectedCategoryId = value);
                            _applyFilters();
                          },
                        ),
                      ),
                      
                      const SizedBox(width: 16),
                      
                      // Status filter dropdown
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedStatus,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical:  8,
                            ),
                          ),
                          items:  const [
                            DropdownMenuItem(value: 'All', child: Text('All')),
                            DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                            DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedStatus = value ??  'All');
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ========================================
                // TASK COUNT INDICATOR
                // ========================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_filteredTasks.length} task(s) found',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // ========================================
                // TASK LIST (ListView requirement)
                // ========================================
                Expanded(
                  child: _filteredTasks.isEmpty
                      // Empty state
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 64,
                                color: Colors. grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No tasks found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Try changing filters or add a new task',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        )
                      // Task list with swipe to delete
                      : RefreshIndicator(
                          onRefresh: _loadData,
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 80),
                            itemCount: _filteredTasks. length,
                            itemBuilder:  (context, index) {
                              final task = _filteredTasks[index];
                              final category = _getCategoryById(task.categoryId);
                              
                              // ========================================
                              // DISMISSIBLE for swipe to delete
                              // ========================================
                              return Dismissible(
                                key:  Key(task.id. toString()),
                                direction: DismissDirection.endToStart,
                                
                                // Confirmation before delete
                                confirmDismiss: (direction) async {
                                  return await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Task'),
                                      content:  Text(
                                        'Are you sure you want to delete "${task.title}"?',
                                      ),
                                      actions:  [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                
                                // Delete on dismiss
                                onDismissed: (direction) async {
                                  await _dbHelper.deleteTask(task.id!);
                                  _loadData();
                                  
                                  if (mounted) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Task deleted'),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                                
                                // Red background when swiping
                                background: Container(
                                  alignment: Alignment. centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons. delete,
                                    color:  Colors.white,
                                  ),
                                ),
                                
                                // Task card
                                child: TaskCard(
                                  task: task,
                                  category: category,
                                  onComplete: (value) => _toggleTaskComplete(task),
                                  onTap: () async {
                                    // Navigate to task details
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:  (context) => TaskDetailsScreen(
                                          taskId: task.id!,
                                        ),
                                      ),
                                    );
                                    // Refresh on return
                                    _loadData();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      
      // ========================================
      // FLOATING ACTION BUTTON
      // ========================================
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          _loadData();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}