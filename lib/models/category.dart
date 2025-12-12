/// ============================================
/// CATEGORY MODEL
/// ============================================
/// This model class represents a task category. 
/// Categories help organize tasks into groups like
/// Work, Personal, Shopping, etc.
/// ============================================

import 'package:flutter/material.dart';

class Category {
  // ========================================
  // PROPERTIES
  // ========================================
  
  /// Unique identifier for the category (auto-incremented in database)
  final int? id;
  
  /// Name of the category (e.g., "Work", "Personal")
  final String name;
  
  /// Color value stored as integer (use Color(value) to convert)
  final int color;
  
  /// Icon code point (use IconData(value, fontFamily: 'MaterialIcons') to convert)
  final int icon;

  // ========================================
  // CONSTRUCTOR
  // ========================================
  
  /// Creates a new Category instance
  /// [id] is optional for new categories (database assigns it)
  /// [name], [color], and [icon] are required
  Category({
    this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  // ========================================
  // DATABASE CONVERSION METHODS
  // ========================================
  
  /// Converts Category object to a Map for database storage
  /// Used when inserting or updating categories in SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'icon': icon,
    };
  }

  /// Creates a Category object from a database Map
  /// Used when reading categories from SQLite
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      color: map['color'] as int,
      icon: map['icon'] as int,
    );
  }

  // ========================================
  // HELPER METHODS
  // ========================================
  
  /// Returns the Color object from the stored integer value
  Color getColor() => Color(color);
  
  /// Returns the IconData object from the stored code point
  IconData getIcon() => IconData(icon, fontFamily: 'MaterialIcons');

  // ========================================
  // DEFAULT CATEGORIES
  // ========================================
  
  /// List of default categories to populate the database on first run
  /// These provide users with ready-to-use categories
  static List<Category> defaultCategories = [
    Category(
      name: 'Work',
      color: Colors.blue. value,           // Blue color for work tasks
      icon: Icons.work. codePoint,         // Briefcase icon
    ),
    Category(
      name: 'Personal',
      color: Colors.green.value,          // Green color for personal tasks
      icon: Icons. person.codePoint,       // Person icon
    ),
    Category(
      name: 'Shopping',
      color: Colors.orange.value,         // Orange color for shopping tasks
      icon: Icons. shopping_cart.codePoint, // Shopping cart icon
    ),
    Category(
      name: 'Health',
      color: Colors.red.value,            // Red color for health tasks
      icon: Icons. favorite.codePoint,     // Heart icon
    ),
    Category(
      name: 'Study',
      color: Colors.purple. value,         // Purple color for study tasks
      icon: Icons.book.codePoint,         // Book icon
    ),
  ];
}