/// ============================================
/// CATEGORY CARD WIDGET
/// ============================================
/// A reusable card widget for displaying a category
/// with its icon, name, and task count.
/// Used in category lists and selection dialogs.
/// ============================================

import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoryCard extends StatelessWidget {
  // ========================================
  // PROPERTIES
  // ========================================
  
  /// The category to display
  final Category category;
  
  /// Number of tasks in this category
  final int taskCount;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;

  // ========================================
  // CONSTRUCTOR
  // ========================================
  
  const CategoryCard({
    super.key,
    required this.category,
    this.taskCount = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      
      child: InkWell(
        // Make the card tappable
        onTap:  onTap,
        
        // Rounded corners for ink splash
        borderRadius: BorderRadius.circular(12),
        
        child: Container(
          padding: const EdgeInsets.all(16.0),
          
          // Gradient background using category color
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                category.getColor().withOpacity(0.7),
                category.getColor().withOpacity(0.4),
              ],
            ),
          ),
          
          // Column layout for content
          child: Column(
            mainAxisAlignment: MainAxisAlignment. center,
            children: [
              // ========================================
              // CATEGORY ICON
              // ========================================
              Icon(
                category. getIcon(),
                size: 40,
                color: Colors.white,
              ),
              
              const SizedBox(height: 8),
              
              // ========================================
              // CATEGORY NAME
              // ========================================
              Text(
                category.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight. bold,
                  color: Colors. white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 4),
              
              // ========================================
              // TASK COUNT
              // ========================================
              Text(
                '$taskCount tasks',
                style:  TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}