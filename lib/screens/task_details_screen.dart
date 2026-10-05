import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../models/user.dart';
import '../widgets/task_widgets.dart';

class TaskDetailsScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();

  static const List<String> _statusOptions = ['To Do', 'In Progress', 'Completed'];

  late TaskModel _task;
  User? _assignee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _notesController.text = _task.notes ?? '';
    // Save the notes as soon as the user leaves the notes field
    _notesFocusNode.addListener(() {
      if (!_notesFocusNode.hasFocus) _saveNotes();
    });
    _loadAssignee();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadAssignee() async {
    final user = await _dbHelper.getUser(_task.assignedToId);
    if (!mounted) return;
    setState(() {
      _assignee = user;
      _isLoading = false;
    });
  }

  // Persists a changed task to SQLite and refreshes the screen (SLA may change)
  Future<void> _updateTask(TaskModel updated) async {
    await _dbHelper.updateTask(updated);
    if (!mounted) return;
    setState(() => _task = updated);
  }

  Future<void> _saveNotes() async {
    String notes = _notesController.text.trim();
    if (notes == (_task.notes ?? '')) return; // Nothing changed
    await _updateTask(_task.copyWith(notes: notes));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Make sure unsaved notes are stored when leaving with the system back gesture
      onPopInvokedWithResult: (didPop, result) => _saveNotes(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Task Details',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.black),
              onSelected: (value) {
                if (value == 'complete') _updateTask(_task.copyWith(status: 'Completed'));
              },
              itemBuilder: (context) => [
                if (_task.status != 'Completed')
                  const PopupMenuItem(value: 'complete', child: Text('Mark as completed')),
              ],
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GestureDetector(
                // Tapping outside the notes field closes the keyboard (and saves)
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildInfoRow(
                        Icons.person_add_alt_outlined,
                        'Assigned to',
                        Row(
                          children: [
                            UserAvatar(user: _assignee, radius: 15),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _assignee?.name ?? 'Unassigned',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildInfoRow(
                        Icons.calendar_today_outlined,
                        'Due Date',
                        Text(
                          formatTaskDate(_task.dueDate),
                          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                        ),
                      ),
                      _buildInfoRow(
                        Icons.flag,
                        'Priority',
                        Text(
                          _task.priority,
                          style: TextStyle(fontSize: 15, color: _priorityColor(_task.priority), fontWeight: FontWeight.w500),
                        ),
                      ),
                      _buildInfoRow(Icons.format_list_bulleted, 'Status', _buildStatusDropdown()),
                      const SizedBox(height: 12),
                      _buildSlaCard(),
                      const SizedBox(height: 28),
                      const Text(
                        'Notes',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 12),
                      _buildNotesField(),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () {
                            // Navigator.push(context, MaterialPageRoute(builder: (_) => EditTaskScreen(task: _task)));
                            // Un-comment when the Create / Edit Task screen is merged
                          },
                          child: const Text('Edit Task', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                _task.title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(status: displayStatusFor(_task)),
          ],
        ),
        const SizedBox(height: 6),
        // The assignee's role acts as the task category, same as on the list
        Text(
          _assignee?.role ?? 'Unassigned',
          style: const TextStyle(fontSize: 15, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 10),
        Text(
          _task.description,
          style: const TextStyle(fontSize: 15, color: Color(0xFF475569), height: 1.4),
        ),
      ],
    );
  }

  // One row of the details list: icon, grey label and a value widget
  Widget _buildInfoRow(IconData icon, String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1E3A5F)),
          const SizedBox(width: 16),
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontSize: 15, color: Color(0xFF475569))),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    // Keep any unexpected status from the database selectable instead of crashing
    List<String> options = _statusOptions.contains(_task.status)
        ? _statusOptions
        : [..._statusOptions, _task.status];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _task.status,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF334155)),
          style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
          borderRadius: BorderRadius.circular(10),
          items: options
              .map((status) => DropdownMenuItem(value: status, child: Text(status)))
              .toList(),
          onChanged: (newStatus) {
            if (newStatus != null && newStatus != _task.status) {
              _updateTask(_task.copyWith(status: newStatus));
            }
          },
        ),
      ),
    );
  }

  // Coloured SLA card; colour and message follow the SLA rules in TaskModel
  Widget _buildSlaCard() {
    String sla = _task.slaStatus;

    Color bgColor = const Color(0xFFE8F5E9);
    Color accentColor = const Color(0xFF2E9D57);
    IconData icon = Icons.check_circle;
    String message = 'The task is progressing as expected.';

    if (sla == 'At Risk') {
      bgColor = const Color(0xFFFFF4E5);
      accentColor = const Color(0xFFD97706);
      icon = Icons.warning_amber_rounded;
      message = 'The deadline is close. This task needs attention.';
    } else if (sla == 'Overdue') {
      bgColor = const Color(0xFFFFEBEE);
      accentColor = const Color(0xFFD32F2F);
      icon = Icons.error_outline;
      message = 'The deadline has passed and the task is not completed.';
    } else if (sla == 'Completed') {
      bgColor = const Color(0xFFF1F5F9);
      accentColor = const Color(0xFF64748B);
      icon = Icons.task_alt;
      message = 'This task has been completed.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SLA Status',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(icon, color: accentColor, size: 22),
              const SizedBox(width: 10),
              Text(
                sla,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
        ],
      ),
    );
  }

  Widget _buildNotesField() {
    return TextField(
      controller: _notesController,
      focusNode: _notesFocusNode,
      minLines: 3,
      maxLines: 5,
      decoration: InputDecoration(
        hintText: 'Add any additional notes...',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryBlue),
        ),
      ),
    );
  }

  Color _priorityColor(String priority) {
    if (priority == 'High') return const Color(0xFFE53935);
    if (priority == 'Medium') return const Color(0xFFD97706);
    return const Color(0xFF2E9D57);
  }
}
