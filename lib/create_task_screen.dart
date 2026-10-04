import 'package:flutter/material.dart';

/// Domain exception for task validation failures
class TaskValidationException implements Exception {
  final String message;
  final String? code;
  TaskValidationException(this.message, {this.code});

  @override
  String toString() => 'TaskValidationException [$code]: $message';
}

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _taskFormKey = GlobalKey<FormState>();

  // Text controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Async state & error feedback tracking
  String? _globalErrorNotice;
  bool _isProcessing = false;

  // Project business constants
  static const int _kMinTitleLength = 3;
  static const int _kMaxTitleLength = 80;
  static const int _kMaxDescLength = 300;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Sanitizes input and checks title length rules
  String? _validateTaskTitle(String? input) {
    final sanitized = input?.trim() ?? '';
    if (sanitized.isEmpty) {
      return 'Task title cannot be left blank';
    }
    if (sanitized.length < _kMinTitleLength) {
      return 'Title must be at least $_kMinTitleLength characters';
    }
    if (sanitized.length > _kMaxTitleLength) {
      return 'Title exceeds max allowed limit ($_kMaxTitleLength chars)';
    }
    return null;
  }

  // Validates optional description bounds
  String? _validateDescription(String? input) {
    final sanitized = input?.trim() ?? '';
    if (sanitized.length > _kMaxDescLength) {
      return 'Description capped at $_kMaxDescLength chars';
    }
    return null;
  }

  void _resetErrorNotice() {
    if (_globalErrorNotice != null) {
      setState(() => _globalErrorNotice = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Create Task',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Form(
          key: _taskFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Error Alert Banner for unhandled exceptions or DB errors
              if (_globalErrorNotice != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _globalErrorNotice!,
                          style: TextStyle(color: Colors.red.shade900, fontSize: 13),
                        ),
                      ),
                      InkWell(
                        onTap: _resetErrorNotice,
                        child: Icon(Icons.close, color: Colors.red.shade700, size: 18),
                      ),
                    ],
                  ),
                ),
              ],

              // --- TASK TITLE ---
              const Text(
                'Task Title',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _titleController,
                onChanged: (_) => _resetErrorNotice(),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter task title',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1D61E7), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
                validator: _validateTaskTitle,
              ),

              const SizedBox(height: 18),

              // --- DESCRIPTION ---
              const Text(
                'Description',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1A202C),
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                onChanged: (_) => _resetErrorNotice(),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Enter task description',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF1D61E7), width: 1.5),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
                validator: _validateDescription,
              ),
            ],
          ),
        ),
      ),
    );
  }
}