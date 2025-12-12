/// ============================================
/// ADD/EDIT TASK SCREEN (updated input styles)
/// ============================================
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Third party package for date formatting
import '../data/database_helper.dart';
import '../models/task.dart';
import '../models/category.dart';

class AddTaskScreen extends StatefulWidget {
  final int? taskId;
  const AddTaskScreen({super.key, this.taskId});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int _selectedPriority = 1;
  bool _hasNotification = false;
  List<Category> _categories = [];
  bool _isLoading = true;
  bool get _isEditMode => widget.taskId != null;
  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final categories = await _dbHelper.getAllCategories();
    setState(() {
      _categories = categories;
      if (categories.isNotEmpty && _selectedCategoryId == null) {
        _selectedCategoryId = categories.first.id;
      }
    });

    if (_isEditMode) {
      final task = await _dbHelper.getTaskById(widget.taskId!);
      if (task != null) {
        setState(() {
          _existingTask = task;
          _titleController.text = task.title;
          _descriptionController.text = task.description;
          _selectedCategoryId = task.categoryId;
          _selectedDate = task.dueDate;
          _selectedPriority = task.priority;
          _hasNotification = task.hasNotification;
        });
      }
    }

    setState(() => _isLoading = false);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'Select due date',
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final task = Task(
      id: _isEditMode ? widget.taskId : null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      dueDate: _selectedDate,
      priority: _selectedPriority,
      hasNotification: _hasNotification,
      isCompleted: _existingTask?.isCompleted ?? false,
      createdAt: _existingTask?.createdAt ?? DateTime.now(),
    );

    if (_isEditMode) {
      await _dbHelper.updateTask(task);
    } else {
      await _dbHelper.insertTask(task);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditMode ? 'Task updated successfully!' : 'Task created successfully! 🎉'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  // Helper: standard text style for inputs (use black)
  TextStyle get _inputTextStyle => const TextStyle(color: Colors.black87);
  TextStyle get _labelStyle => const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600);
  TextStyle get _hintStyle => TextStyle(color: Colors.grey[600]);

  @override
  Widget build(BuildContext context) {
    // If you want to respect dark mode, you can conditionally choose colors:
    // final isDark = Theme.of(context).brightness == Brightness.dark;
    // final inputColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Task' : 'Add Task'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveTask,
            tooltip: 'Save Task',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title field
              TextFormField(
                controller: _titleController,
                style: _inputTextStyle,
                cursorColor: Colors.black87,
                decoration: InputDecoration(
                  labelText: 'Task Title *',
                  labelStyle: _labelStyle,
                  hintText: 'Enter task title',
                  hintStyle: _hintStyle,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title, color: Colors.black54),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  if (value.trim().length < 3) {
                    return 'Title must be at least 3 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description field
              TextFormField(
                controller: _descriptionController,
                style: _inputTextStyle,
                cursorColor: Colors.black87,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: _labelStyle,
                  hintText: 'Enter task description (optional)',
                  hintStyle: _hintStyle,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description, color: Colors.black54),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Category dropdown
              DropdownButtonFormField<int>(
                value: _selectedCategoryId,
                style: _inputTextStyle, // text color for selected item
                decoration: InputDecoration(
                  labelText: 'Category *',
                  labelStyle: _labelStyle,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category, color: Colors.black54),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.id,
                    child: Row(
                      children: [
                        Icon(category.getIcon(), size: 20, color: category.getColor()),
                        const SizedBox(width: 12),
                        Text(category.name, style: _inputTextStyle),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedCategoryId = value);
                },
                validator: (value) {
                  if (value == null) return 'Please select a category';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Due date picker
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Due Date *',
                    labelStyle: _labelStyle,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today, color: Colors.black54),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                        style: _inputTextStyle,
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.black54),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Priority selection with explicit text colors
              const Text(
                'Priority',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    RadioListTile<int>(
                      title: Text('High', style: _inputTextStyle),
                      subtitle: Text('Urgent and important', style: _hintStyle),
                      secondary: const Icon(Icons.flag, color: Colors.red),
                      value: 2,
                      groupValue: _selectedPriority,
                      activeColor: Colors.red,
                      onChanged: (value) {
                        setState(() => _selectedPriority = value ?? 1);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<int>(
                      title: Text('Medium', style: _inputTextStyle),
                      subtitle: Text('Important but not urgent', style: _hintStyle),
                      secondary: const Icon(Icons.flag, color: Colors.orange),
                      value: 1,
                      groupValue: _selectedPriority,
                      activeColor: Colors.orange,
                      onChanged: (value) {
                        setState(() => _selectedPriority = value ?? 1);
                      },
                    ),
                    const Divider(height: 1),
                    RadioListTile<int>(
                      title: Text('Low', style: _inputTextStyle),
                      subtitle: Text('Can be done later', style: _hintStyle),
                      secondary: const Icon(Icons.flag, color: Colors.green),
                      value: 0,
                      groupValue: _selectedPriority,
                      activeColor: Colors.green,
                      onChanged: (value) {
                        setState(() => _selectedPriority = value ?? 1);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Notification toggle with explicit title style
              Card(
                child: SwitchListTile(
                  title: Text('Enable Notifications', style: _inputTextStyle),
                  subtitle: Text('Get reminded about this task', style: _hintStyle),
                  secondary: Icon(
                    _hasNotification ? Icons.notifications_active : Icons.notifications_off,
                    color: _hasNotification ? Colors.blue : Colors.grey,
                  ),
                  value: _hasNotification,
                  onChanged: (value) {
                    setState(() => _hasNotification = value);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              ElevatedButton(
                onPressed: _saveTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  _isEditMode ? 'UPDATE TASK' : 'SAVE TASK',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}