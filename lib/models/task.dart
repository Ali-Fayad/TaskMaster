/// ============================================
/// TASK MODEL
/// ============================================
/// This model class represents a task in the application.
/// It contains all the information about a task including
/// title, description, category, due date, priority, etc.
/// ============================================

class Task {
  // ========================================
  // PROPERTIES
  // ========================================
  
  /// Unique identifier for the task (auto-incremented in database)
  final int? id;
  
  /// Title of the task (required, shown in lists)
  final String title;
  
  /// Detailed description of the task (optional)
  final String description;
  
  /// Foreign key linking to category table
  final int categoryId;
  
  /// When the task is due (stored as ISO string in database)
  final DateTime dueDate;
  
  /// Priority level:  0 = Low, 1 = Medium, 2 = High
  final int priority;
  
  /// Whether the task has been completed
  final bool isCompleted;
  
  /// Whether notifications are enabled for this task
  final bool hasNotification;
  
  /// When the task was created
  final DateTime createdAt;

  // ========================================
  // CONSTRUCTOR
  // ========================================
  
  /// Creates a new Task instance
  /// [id] is optional for new tasks (database assigns it)
  /// [title], [categoryId], [dueDate], [priority] are required
  /// [description] defaults to empty string
  /// [isCompleted] and [hasNotification] default to false
  /// [createdAt] defaults to current time
  Task({
    this. id,
    required this.title,
    this.description = '',
    required this.categoryId,
    required this. dueDate,
    required this. priority,
    this.isCompleted = false,
    this. hasNotification = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ========================================
  // DATABASE CONVERSION METHODS
  // ========================================
  
  /// Converts Task object to a Map for database storage
  /// Used when inserting or updating tasks in SQLite
  /// Note: DateTime is converted to ISO string format
  /// Note: bool is converted to int (0 or 1) for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'dueDate': dueDate. toIso8601String(),      // Convert DateTime to String
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,         // Convert bool to int
      'hasNotification': hasNotification ?  1 : 0, // Convert bool to int
      'createdAt': createdAt. toIso8601String(),  // Convert DateTime to String
    };
  }

  /// Creates a Task object from a database Map
  /// Used when reading tasks from SQLite
  /// Note:  Converts ISO strings back to DateTime
  /// Note:  Converts int (0 or 1) back to bool
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?  ?? '',
      categoryId: map['categoryId'] as int,
      dueDate: DateTime.parse(map['dueDate'] as String),
      priority: map['priority'] as int,
      isCompleted: (map['isCompleted'] as int) == 1,      // Convert int to bool
      hasNotification: (map['hasNotification'] as int) == 1, // Convert int to bool
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // ========================================
  // COPY WITH METHOD
  // ========================================
  
  /// Creates a copy of this Task with some properties changed
  /// Useful for updating tasks without modifying the original
  /// Example: task.copyWith(isCompleted: true)
  Task copyWith({
    int? id,
    String? title,
    String?  description,
    int? categoryId,
    DateTime? dueDate,
    int? priority,
    bool? isCompleted,
    bool? hasNotification,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this. id,
      title: title ??  this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this. categoryId,
      dueDate: dueDate ?? this. dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      hasNotification: hasNotification ?? this.hasNotification,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Returns a human-readable priority string
  String getPriorityText() {
    switch (priority) {
      case 2:
        return 'High';
      case 1:
        return 'Medium';
      case 0:
      default:
        return 'Low';
    }
  }
  
  /// Returns whether the task is overdue
  bool isOverdue() {
    return ! isCompleted && dueDate.isBefore(DateTime.now());
  }
}