/// ============================================
/// DATABASE HELPER
/// ============================================
/// This class manages all SQLite database operations. 
/// It implements the Singleton pattern to ensure only
/// one database connection exists throughout the app.
/// 
/// Operations include:
/// - Database initialization and table creation
/// - CRUD operations for Categories
/// - CRUD operations for Tasks
/// - Statistics queries
/// ============================================

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';
import '../models/category.dart';

class DatabaseHelper {
  // ========================================
  // SINGLETON PATTERN
  // ========================================
  
  /// Private constructor to prevent direct instantiation
  DatabaseHelper._privateConstructor();
  
  /// Single instance of DatabaseHelper (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  
  /// Database instance (cached after first access)
  static Database? _database;

  // ========================================
  // DATABASE CONFIGURATION
  // ========================================
  
  /// Database file name
  static const String _databaseName = 'taskmaster.db';
  
  /// Database version (increment when schema changes)
  static const int _databaseVersion = 1;
  
  /// Table names
  static const String tableCategories = 'categories';
  static const String tableTasks = 'tasks';

  // ========================================
  // DATABASE INITIALIZATION
  // ========================================
  
  /// Gets the database instance, creating it if necessary
  /// This is the main entry point for database access
  Future<Database> get database async {
    // Return existing database if already initialized
    if (_database != null) return _database!;
    
    // Create new database if not initialized
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database file and creates tables
  Future<Database> _initDatabase() async {
    // Get the default databases directory
    String databasesPath = await getDatabasesPath();
    
    // Create full path to database file
    String path = join(databasesPath, _databaseName);
    
    // Open (or create) the database
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate:  _onCreate,  // Called when database is first created
    );
  }

  /// Creates database tables when the database is first created
  /// This is called only once when the app is first installed
  Future<void> _onCreate(Database db, int version) async {
    // ========================================
    // CREATE CATEGORIES TABLE
    // ========================================
    await db.execute('''
      CREATE TABLE $tableCategories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        color INTEGER NOT NULL,
        icon INTEGER NOT NULL
      )
    ''');

    // ========================================
    // CREATE TASKS TABLE
    // ========================================
    await db.execute('''
      CREATE TABLE $tableTasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        categoryId INTEGER NOT NULL,
        dueDate TEXT NOT NULL,
        priority INTEGER NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        hasNotification INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES $tableCategories (id)
      )
    ''');

    // ========================================
    // INSERT DEFAULT CATEGORIES
    // ========================================
    // Populate with default categories on first run
    for (Category category in Category.defaultCategories) {
      await db.insert(tableCategories, category.toMap());
    }
  }

  // ========================================
  // CATEGORY CRUD OPERATIONS
  // ========================================

  /// INSERT:  Adds a new category to the database
  /// Returns the ID of the newly inserted category
  Future<int> insertCategory(Category category) async {
    Database db = await database;
    return await db.insert(tableCategories, category.toMap());
  }

  /// SELECT ALL: Gets all categories from the database
  /// Returns a list of Category objects
  Future<List<Category>> getAllCategories() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(tableCategories);
    
    // Convert each map to a Category object
    return List.generate(maps.length, (i) {
      return Category. fromMap(maps[i]);
    });
  }

  /// SELECT BY ID: Gets a specific category by its ID
  /// Returns the Category object or null if not found
  Future<Category?> getCategoryById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Category.fromMap(maps.first);
    }
    return null;
  }

  /// UPDATE: Updates an existing category
  /// Returns the number of rows affected
  Future<int> updateCategory(Category category) async {
    Database db = await database;
    return await db. update(
      tableCategories,
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  /// DELETE: Removes a category from the database
  /// Returns the number of rows affected
  Future<int> deleteCategory(int id) async {
    Database db = await database;
    return await db.delete(
      tableCategories,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================
  // TASK CRUD OPERATIONS
  // ========================================

  /// INSERT: Adds a new task to the database
  /// Returns the ID of the newly inserted task
  Future<int> insertTask(Task task) async {
    Database db = await database;
    return await db.insert(tableTasks, task.toMap());
  }

  /// SELECT ALL: Gets all tasks from the database
  /// Ordered by due date (nearest first)
  Future<List<Task>> getAllTasks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      orderBy: 'dueDate ASC',  // Sort by due date
    );
    
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  /// SELECT BY ID:  Gets a specific task by its ID
  /// Returns the Task object or null if not found
  Future<Task?> getTaskById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  /// SELECT BY CATEGORY:  Gets all tasks for a specific category
  /// Returns a list of Task objects filtered by categoryId
  Future<List<Task>> getTasksByCategory(int categoryId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'dueDate ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  /// SELECT COMPLETED: Gets all completed tasks
  Future<List<Task>> getCompletedTasks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'isCompleted = ? ',
      whereArgs: [1],  // 1 = true in SQLite
      orderBy: 'dueDate ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  /// SELECT PENDING:  Gets all incomplete/pending tasks
  Future<List<Task>> getPendingTasks() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      where: 'isCompleted = ?',
      whereArgs: [0],  // 0 = false in SQLite
      orderBy: 'dueDate ASC',
    );
    
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  /// SELECT RECENT: Gets the most recent tasks (for home screen)
  /// [limit] specifies how many tasks to return (default 5)
  Future<List<Task>> getRecentTasks({int limit = 5}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      tableTasks,
      orderBy: 'createdAt DESC',  // Most recently created first
      limit: limit,
    );
    
    return List.generate(maps.length, (i) {
      return Task.fromMap(maps[i]);
    });
  }

  /// UPDATE: Updates an existing task
  /// Returns the number of rows affected
  Future<int> updateTask(Task task) async {
    Database db = await database;
    return await db.update(
      tableTasks,
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task. id],
    );
  }

  /// DELETE: Removes a task from the database
  /// Returns the number of rows affected
  Future<int> deleteTask(int id) async {
    Database db = await database;
    return await db.delete(
      tableTasks,
      where: 'id = ?',
      whereArgs:  [id],
    );
  }

  /// TOGGLE COMPLETE: Toggles the completion status of a task
  /// This is a convenience method for quickly marking tasks done/undone
  Future<int> toggleTaskComplete(int id, bool isCompleted) async {
    Database db = await database;
    return await db.update(
      tableTasks,
      {'isCompleted': isCompleted ?  1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ========================================
  // STATISTICS QUERIES
  // ========================================

  /// Gets the total number of tasks
  Future<int> getTotalTasksCount() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableTasks'
    );
    return result. first['count'] as int;
  }

  /// Gets the number of completed tasks
  Future<int> getCompletedTasksCount() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db. rawQuery(
      'SELECT COUNT(*) as count FROM $tableTasks WHERE isCompleted = 1'
    );
    return result.first['count'] as int;
  }

  /// Gets the number of pending (incomplete) tasks
  Future<int> getPendingTasksCount() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM $tableTasks WHERE isCompleted = 0'
    );
    return result.first['count'] as int;
  }

  /// Gets task count grouped by category (for pie chart)
  /// Returns a map of categoryId to task count
  Future<Map<int, int>> getTasksCountByCategory() async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT categoryId, COUNT(*) as count 
      FROM $tableTasks 
      GROUP BY categoryId
    ''');
    
    Map<int, int> counts = {};
    for (var row in result) {
      counts[row['categoryId'] as int] = row['count'] as int;
    }
    return counts;
  }
}