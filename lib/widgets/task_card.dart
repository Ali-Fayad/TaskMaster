/// ============================================
/// TASK CARD WIDGET
/// ============================================
/// A reusable card widget for displaying a task
/// in list views.  Shows checkbox, title, category,
/// priority indicator, and due date.
/// ============================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Third party package for date formatting
import '../models/task.dart';
import '../models/category.dart';

class TaskCard extends StatelessWidget {
  // ========================================
  // PROPERTIES
  // ========================================
  
  /// The task to display
  final Task task;
  
  /// The category of the task (for color and icon)
  final Category? category;
  
  /// Callback when card is tapped (navigate to details)
  final VoidCallback?  onTap;
  
  /// Callback when checkbox is toggled
  final Function(bool?)? onComplete;

  // ========================================
  // CONSTRUCTOR
  // ========================================
  
  const TaskCard({
    super.key,
    required this.task,
    this.category,
    this.onTap,
    this.onComplete,
  });

  // ========================================
  // HELPER METHOD:  Get priority color
  // ========================================
  Color _getPriorityColor() {
    switch (task.priority) {
      case 2:  // High priority
        return Colors. red;
      case 1:  // Medium priority
        return Colors.orange;
      case 0:  // Low priority
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      
      child: InkWell(
        // Make card tappable
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        
        child:  Padding(
          padding: const EdgeInsets.all(12.0),
          
          // ========================================
          // ROW LAYOUT: Checkbox | Content | Priority
          // ========================================
          child: Row(
            children: [
              // ========================================
              // CHECKBOX for completion status
              // ========================================
              Checkbox(
                value: task.isCompleted,
                onChanged: onComplete,
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              
              // ========================================
              // MAIN CONTENT (Expanded to fill space)
              // ========================================
              Expanded(
                child:  Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Task title with strikethrough if completed
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        // Strike through completed tasks
                        decoration: task.isCompleted 
                            ? TextDecoration. lineThrough 
                            :  null,
                        color: task.isCompleted 
                            ? Colors.grey 
                            : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // ========================================
                    // ROW:  Category | Due Date
                    // ========================================
                    Row(
                      children: [
                        // Category chip
                        if (category != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: category! .getColor().withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize:  MainAxisSize.min,
                              children: [
                                Icon(
                                  category!. getIcon(),
                                  size: 12,
                                  color: category!.getColor(),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category!.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: category!.getColor(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        // Due date with icon
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: task.isOverdue() ? Colors.red : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          // Using intl package for date formatting
                          DateFormat('MMM dd').format(task.dueDate),
                          style: TextStyle(
                            fontSize: 11,
                            color: task.isOverdue() ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // ========================================
              // PRIORITY INDICATOR (colored dot)
              // ========================================
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color:  _getPriorityColor(),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}