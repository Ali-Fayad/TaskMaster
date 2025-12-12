/// ============================================
/// TASK DETAILS SCREEN
/// ============================================
/// Displays detailed information about a specific task. 
/// Includes: 
/// - Full task information display
/// - Edit navigation
/// - Delete with confirmation dialog
/// - Mark as complete functionality
/// ============================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Third party package for date formatting
import '../data/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';
import 'add_task_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  /// ID of the task to display
  final int taskId;
  
  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  // ========================================
  // STATE VARIABLES
  // ========================================
  
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  /// The task being displayed
  Task? _task;
  
  /// The task's category
  Category? _category;
  
  /// Loading state
  bool _isLoading = true;

  // ========================================
  // LIFECYCLE METHODS
  // ========================================
  
  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  // ========================================
  // DATA LOADING
  // ========================================
  
  Future<void> _loadTask() async {
    setState(() => _isLoading = true);
    
    final task = await _dbHelper.getTaskById(widget.taskId);
    
    if (task != null) {
      final category = await _dbHelper.getCategoryById(task.categoryId);
      setState(() {
        _task = task;
        _category = category;
      });
    }
    
    setState(() => _isLoading = false);
  }

  // ========================================
  // TOGGLE COMPLETION
  // ========================================
  
  Future<void> _toggleComplete() async {
    if (_task == null) return;
    
    await _dbHelper.toggleTaskComplete(_task!.id!, !_task!.isCompleted);
    
    // ========================================
    // SNACKBAR (SnackBar requirement)
    // ========================================
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text(
            _task!.isCompleted 
                ? 'Task marked as pending' 
                : 'Task completed!  🎉',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _task!.isCompleted ? Colors.orange : Colors.green,
        ),
      );
    }
    
    _loadTask();
  }

  // ========================================
  // DELETE TASK
  // ========================================
  
  Future<void> _deleteTask() async {
    // ========================================
    // ALERT DIALOG (Dialog requirement)
    // ========================================
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Task'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${_task?. title}"?\n\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirm == true && _task != null) {
      await _dbHelper.deleteTask(_task!.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task deleted'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back after delete
        Navigator.pop(context);
      }
    }
  }

  // ========================================
  // HELPER:  Get priority color
  // ========================================
  
  Color _getPriorityColor() {
    switch (_task?.priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 0:
      default:
        return Colors.green;
    }
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
        title: const Text('Task Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              if (_task != null) {
                await Navigator. push(
                  context,
                  MaterialPageRoute(
                    builder:  (context) => AddTaskScreen(taskId: _task!.id),
                  ),
                );
                _loadTask();  // Refresh after edit
              }
            },
            tooltip: 'Edit Task',
          ),
          // Delete button
          IconButton(
            icon: const Icon(Icons. delete),
            onPressed: _deleteTask,
            tooltip: 'Delete Task',
          ),
        ],
      ),
      
      // ========================================
      // BODY
      // ========================================
      body: _isLoading
          ? const Center(child:  CircularProgressIndicator())
          : _task == null
              ?  const Center(child: Text('Task not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ========================================
                      // MAIN TASK CARD
                      // ========================================
                      Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment:  CrossAxisAlignment.start,
                            children: [
                              // ========================================
                              // TITLE with completion status
                              // ========================================
                              Row(
                                children: [
                                  Expanded(
                                    child:  Text(
                                      _task! .title,
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight:  FontWeight.bold,
                                        decoration: _task!.isCompleted
                                            ? TextDecoration. lineThrough
                                            :  null,
                                        color: _task!.isCompleted
                                            ? Colors. grey
                                            : Colors.black87,
                                      ),
                                    ),
                                  ),
                                  // Completion icon
                                  Icon(
                                    _task!.isCompleted
                                        ? Icons. check_circle
                                        :  Icons.radio_button_unchecked,
                                    color: _task! .isCompleted
                                        ? Colors.green
                                        : Colors.grey,
                                    size: 32,
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 20),
                              const Divider(),
                              const SizedBox(height: 16),
                              
                              // ========================================
                              // CATEGORY (Row layout)
                              // ========================================
                              Row(
                                children: [
                                  const Icon(Icons.category, color: Colors.grey),
                                  const SizedBox(width:  12),
                                  const Text(
                                    'Category:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (_category != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _category!.getColor().withOpacity(0.2),
                                        borderRadius:  BorderRadius.circular(16),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _category!.getIcon(),
                                            size: 16,
                                            color: _category!.getColor(),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _category!.name,
                                            style: TextStyle(
                                              color: _category!.getColor(),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // ========================================
                              // PRIORITY
                              // ========================================
                              Row(
                                children: [
                                  const Icon(Icons. flag, color: Colors.grey),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Priority:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration:  BoxDecoration(
                                      color: _getPriorityColor().withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _task! .getPriorityText(),
                                      style: TextStyle(
                                        color:  _getPriorityColor(),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height:  16),
                              
                              // ========================================
                              // DUE DATE (using intl package)
                              // ========================================
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    color: _task!.isOverdue()
                                        ? Colors.red
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Due Date:',
                                    style:  TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('EEEE, MMMM dd, yyyy')
                                        .format(_task!.dueDate),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _task!.isOverdue()
                                          ? Colors.red
                                          : Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // ========================================
                              // STATUS
                              // ========================================
                              Row(
                                children: [
                                  Icon(
                                    _task!. isCompleted
                                        ? Icons.check_circle
                                        : Icons. pending,
                                    color: _task!.isCompleted
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Status:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _task!.isCompleted ? 'Completed' : 'Pending',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight. w600,
                                      color: _task!.isCompleted
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height:  16),
                              
                              // ========================================
                              // NOTIFICATIONS
                              // ========================================
                              Row(
                                children: [
                                  Icon(
                                    _task!. hasNotification
                                        ?  Icons.notifications_active
                                        : Icons.notifications_off,
                                    color: _task!.hasNotification
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Notifications: ',
                                    style: TextStyle(
                                      fontSize:  16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _task! .hasNotification ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: _task!.hasNotification
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              
                              // ========================================
                              // DESCRIPTION (if exists)
                              // ========================================
                              if (_task! .description.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                const Divider(),
                                const SizedBox(height: 16),
                                const Row(
                                  children: [
                                    Icon(Icons. description, color: Colors.grey),
                                    SizedBox(width: 12),
                                    Text(
                                      'Description:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height:  8),
                                Padding(
                                  padding: const EdgeInsets.only(left: 36),
                                  child: Text(
                                    _task!. description,
                                    style:  const TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 8),
                              
                              // ========================================
                              // CREATED DATE
                              // ========================================
                              Text(
                                'Created: ${DateFormat('MMM dd, yyyy - hh:mm a').format(_task!.createdAt)}',
                                style: TextStyle(
                                  fontSize:  12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // ========================================
                      // MARK AS COMPLETE BUTTON
                      // ========================================
                      ElevatedButton. icon(
                        onPressed:  _toggleComplete,
                        icon: Icon(
                          _task!.isCompleted
                              ? Icons. replay
                              : Icons.check_circle,
                        ),
                        label: Text(
                          _task!.isCompleted
                              ? 'MARK AS PENDING'
                              :  'MARK AS COMPLETE',
                          style: const TextStyle(
                            fontSize:  16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _task!.isCompleted
                              ? Colors.orange
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // ========================================
                      // DELETE BUTTON
                      // ========================================
                      OutlinedButton.icon(
                        onPressed: _deleteTask,
                        icon: const Icon(Icons.delete),
                        label: const Text(
                          'DELETE TASK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:  FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors. red),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }
}