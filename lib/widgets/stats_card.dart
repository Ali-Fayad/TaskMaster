/// ============================================
/// STATS CARD WIDGET
/// ============================================
/// A reusable card widget for displaying statistics
/// on the home screen.  Shows an icon, count value,
/// and label with customizable colors.
/// ============================================


import 'package:flutter/material.dart';

class StatsCard extends StatelessWidget {
  // ========================================
  // PROPERTIES
  // ========================================
  
  /// The icon to display in the card
  final IconData icon;
  
  /// The numeric value to display (e.g., task count)
  final String value;
  
  /// The label below the value (e.g., "Total Tasks")
  final String label;
  
  /// Background color of the card
  final Color color;

  // ========================================
  // CONSTRUCTOR
  // ========================================
  
  const StatsCard({
    super.key,
    required this. icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card elevation for shadow effect
      elevation: 2,
      
      // Card background color with some transparency
      color: color.withOpacity(0.1),
      
      child: Padding(
        padding:  const EdgeInsets.all(16.0),
        
        // Column layout:  Icon on top, then value, then label
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ========================================
            // ICON
            // ========================================
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            
            const SizedBox(height: 8),
            
            // ========================================
            // VALUE (Large number)
            // ========================================
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // ========================================
            // LABEL
            // ========================================
            Text(
              label,
              style:  TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}