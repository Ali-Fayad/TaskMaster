/// ============================================
/// APP DRAWER WIDGET
/// ============================================
/// The side navigation drawer that appears when
/// the menu icon is tapped. Provides navigation
/// to all major screens of the application.
/// ============================================

import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/task_list_screen.dart';
import '../screens/add_task_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child:  ListView(
        // Remove padding from ListView
        padding: EdgeInsets. zero,
        
        children: [
          // ========================================
          // DRAWER HEADER
          // ========================================
          DrawerHeader(
            decoration: BoxDecoration(
              // Gradient background for header
              gradient: LinearGradient(
                begin: Alignment. topLeft,
                end:  Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // App icon
                Icon(
                  Icons.task_alt,
                  size: 48,
                  color: Colors.white,
                ),
                SizedBox(height: 8),
                // App name
                Text(
                  'TaskMaster',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Tagline
                Text(
                  'Organize your life',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // ========================================
          // NAVIGATION ITEMS
          // ========================================
          
          // Home navigation item
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Close drawer first
              Navigator.pop(context);
              // Navigate to Home Screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          
          // All Tasks navigation item
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('All Tasks'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TaskListScreen()),
              );
            },
          ),
          
          // Add Task navigation item
          ListTile(
            leading: const Icon(Icons.add_circle),
            title: const Text('Add Task'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddTaskScreen()),
              );
            },
          ),
          
          // Divider line
          const Divider(),
          
          // About navigation item (shows dialog)
          ListTile(
            leading: const Icon(Icons. info),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              // ========================================
              // ABOUT DIALOG (Dialog requirement)
              // ========================================
              showDialog(
                context:  context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.task_alt, color: Colors.indigo),
                      SizedBox(width: 8),
                      Text('TaskMaster'),
                    ],
                  ),
                  content:  const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Version 1.0.0'),
                      SizedBox(height: 8),
                      Text(
                        'A task management application built with Flutter '
                        'Made by Ali Fayad and Mhmd Rida!'
                        'For the CSC 415 Mobile Application Development course.',
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Features:',
                        style: TextStyle(fontWeight: FontWeight. bold),
                      ),
                      Text('• Create and manage tasks'),
                      Text('• Organize by categories'),
                      Text('• Set priorities and due dates'),
                      Text('• Track completion status'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}