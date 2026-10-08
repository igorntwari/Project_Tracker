import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../models/task_model.dart';

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
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<User> _assignableUsers = [];
  User? _selectedAssignee;
  DateTime? _selectedDueDate;

  String _selectedPriority = 'Medium';
  String _selectedStatus = 'To Do';

  bool _isFetchingUsers = true;
  bool _isSaving = false;
  String? _globalErrorNotice;

  final List<String> _priorityOptions = ['Low', 'Medium', 'High'];
  final List<String> _statusOptions = ['To Do', 'In Progress', 'Completed'];

  static const int _kMinTitleLength = 3;
  static const int _kMaxTitleLength = 80;
  static const int _kMaxDescLength = 300;

  @override
  void initState() {
    super.initState();
    _fetchTeamMembers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchTeamMembers() async {
    try {
      final users = await DatabaseHelper().getUsers();
      if (mounted) {
        setState(() {
          _assignableUsers = users;
          _isFetchingUsers = false;
        });
      }
    } catch (err) {
      if (mounted) {
        setState(() {
          _globalErrorNotice = 'Database error: Unable to load team roster.';
          _isFetchingUsers = false;
        });
      }
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    _resetErrorNotice();
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1D61E7),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _saveTaskToDatabase() async {
    _resetErrorNotice();
    if (!_taskFormKey.currentState!.validate()) return;

    if (_selectedAssignee == null) {
      setState(() => _globalErrorNotice = 'Please select a team member.');
      return;
    }

    if (_selectedDueDate == null) {
      setState(() => _globalErrorNotice = 'Please select a due date.');
      return;
    }

    setState(() => _isSaving = true);

    try {
  final newTask = TaskModel(
    title: _titleController.text.trim(),
    description: _descriptionController.text.trim(),
    assignedToId: _selectedAssignee!.id!,
    dueDate: _selectedDueDate!.toIso8601String(),
    priority: _selectedPriority,
    status: _selectedStatus,
  );

      await DatabaseHelper().insertTask(newTask);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _globalErrorNotice = 'Failed to save task: ${e.toString()}';
          _isSaving = false;
        });
      }
    }
  }

  String? _validateTaskTitle(String? input) {
    final sanitized = input?.trim() ?? '';
    if (sanitized.isEmpty) return 'Task title cannot be left blank';
    if (sanitized.length < _kMinTitleLength) return 'Title must be at least $_kMinTitleLength characters';
    if (sanitized.length > _kMaxTitleLength) return 'Title exceeds max allowed limit ($_kMaxTitleLength chars)';
    return null;
  }

  String? _validateDescription(String? input) {
    final sanitized = input?.trim() ?? '';
    if (sanitized.length > _kMaxDescLength) return 'Description capped at $_kMaxDescLength chars';
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Form(
          key: _taskFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_globalErrorNotice != null)
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
                        child: Text(_globalErrorNotice!, style: TextStyle(color: Colors.red.shade900, fontSize: 13)),
                      ),
                      InkWell(
                        onTap: _resetErrorNotice,
                        child: Icon(Icons.close, color: Colors.red.shade700, size: 18),
                      ),
                    ],
                  ),
                ),

              const Text('Task Title', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A202C))),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
               onChanged: (_) {
                  if (_globalErrorNotice != null) {
                    setState(() {
                      _globalErrorNotice = null;
                    });
                  }
                },

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
                ),
                validator: _validateTaskTitle,
              ),

              const SizedBox(height: 18),

              const Text('Description', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A202C))),
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
                ),
                validator: _validateDescription,
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 28.0, right: 12.0),
                    child: Icon(Icons.person_outline, color: Color(0xFF1D61E7), size: 24),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Assign To', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A202C))),
                        const SizedBox(height: 8),
                        _isFetchingUsers
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              )
                            : DropdownButtonFormField<User>(
                                value: _selectedAssignee,
                                hint: Text('Select team member', style: TextStyle(color: Colors.grey.shade400, fontSize: 14)),
                                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF1D61E7), width: 1.5),
                                  ),
                                ),
                                items: _assignableUsers.map((User user) {
                                  return DropdownMenuItem<User>(
                                    value: user,
                                    child: Text(user.name, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                                  );
                                }).toList(),
                                onChanged: (User? selected) {
                                  _resetErrorNotice();
                                  setState(() => _selectedAssignee = selected);
                                },
                                validator: (value) => value == null ? 'Please select a team member' : null,
                              ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 28.0, right: 12.0),
                    child: Icon(Icons.calendar_today_outlined, color: Color(0xFF1D61E7), size: 22),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A202C))),
                        const SizedBox(height: 8),
                        FormField<DateTime>(
                          initialValue: _selectedDueDate,
                          validator: (_) => _selectedDueDate == null ? 'Please set a task due date' : null,
                          builder: (FormFieldState<DateTime> state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () async {
                                    await _selectDueDate(context);
                                    state.didChange(_selectedDueDate);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: state.hasError ? Colors.redAccent : Colors.grey.shade300),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _selectedDueDate == null
                                              ? 'Select date'
                                              : '${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _selectedDueDate == null ? Colors.grey.shade400 : Colors.black87,
                                          ),
                                        ),
                                        const Icon(Icons.calendar_month, color: Colors.black54, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                                if (state.hasError)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6, left: 12),
                                    child: Text(state.errorText!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                                  ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 28.0, right: 12.0),
                    child: Icon(Icons.flag_outlined, color: Colors.redAccent, size: 24),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A202C))),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedPriority,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF1D61E7), width: 1.5),
                            ),
                          ),
                          items: _priorityOptions.map((String p) {
                            return DropdownMenuItem<String>(
                              value: p,
                              child: Text(p, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPriority = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 28.0, right: 12.0),
                    child: Icon(Icons.format_list_bulleted, color: Color(0xFF1D61E7), size: 24),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Status', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A202C))),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedStatus,
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF1D61E7), width: 1.5),
                            ),
                          ),
                          items: _statusOptions.map((String s) {
                            return DropdownMenuItem<String>(
                              value: s,
                              child: Text(s, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedStatus = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTaskToDatabase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D61E7),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Create Task',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}