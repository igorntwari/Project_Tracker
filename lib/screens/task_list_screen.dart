import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../models/user.dart';
import '../widgets/main_app_bar.dart';
import '../widgets/task_widgets.dart';
import 'create_task_screen.dart';
import 'task_details_screen.dart';

class TaskListScreen extends StatefulWidget {
  final VoidCallback? onAvatarTap;

  const TaskListScreen({super.key, this.onAvatarTap});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = ['All', 'On Track', 'At Risk', 'Overdue'];

  bool _isLoading = true;
  List<TaskModel> _tasks = [];
  Map<int, User> _usersById = {};
  String _selectedFilter = 'All';
  String _searchQuery = '';
  bool _sortByPriority = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetches tasks and users from storage so each card can show its assignee
  Future<void> _loadTasks() async {
    try {
      final tasks = await _dbHelper.getTasks();
      final users = await _dbHelper.getUsers();

      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _usersById = {for (var user in users) user.id!: user};
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Applies the search text, the SLA filter chip and the chosen sort order
  List<TaskModel> get _visibleTasks {
    List<TaskModel> result = _tasks.where((task) {
      bool matchesSearch = task.title.toLowerCase().contains(_searchQuery.toLowerCase());
      bool matchesFilter = _selectedFilter == 'All' || task.slaStatus == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    const priorityRank = {'High': 0, 'Medium': 1, 'Low': 2};
    result.sort((a, b) {
      if (_sortByPriority) {
        int compare = (priorityRank[a.priority] ?? 3).compareTo(priorityRank[b.priority] ?? 3);
        if (compare != 0) return compare;
      }
      DateTime dateA = DateTime.tryParse(a.dueDate) ?? DateTime.now();
      DateTime dateB = DateTime.tryParse(b.dueDate) ?? DateTime.now();
      return dateA.compareTo(dateB);
    });
    return result;
  }

  // Opens the details screen and reloads when coming back in case the task changed
  Future<void> _openTaskDetails(TaskModel task) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetailsScreen(task: task)),
    );
    _loadTasks();
  }

  Future<void> _markAsCompleted(TaskModel task) async {
    await _dbHelper.updateTask(task.copyWith(status: 'Completed'));
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = _visibleTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: MainAppBar(title: 'Tasks', onAvatarTap: widget.onAvatarTap),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _loadTasks,
                    child: visibleTasks.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 80),
                              Center(child: Text("No tasks found.")),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                            itemCount: visibleTasks.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) => _buildTaskCard(visibleTasks[index]),
                          ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryBlue,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()),
          );
          if (result == true) {
            _loadTasks();
          }
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search tasks...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                filled: true,
                fillColor: Colors.white,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryBlue),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Sort menu (by due date or by priority)
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF3F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<bool>(
              icon: const Icon(Icons.filter_list, color: Color(0xFF334155)),
              tooltip: 'Sort tasks',
              onSelected: (byPriority) => setState(() => _sortByPriority = byPriority),
              itemBuilder: (context) => [
                CheckedPopupMenuItem(value: false, checked: !_sortByPriority, child: const Text('Sort by due date')),
                CheckedPopupMenuItem(value: true, checked: _sortByPriority, child: const Text('Sort by priority')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          String filter = _filters[index];
          bool isSelected = filter == _selectedFilter;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? kPrimaryBlue : const Color(0xFFEFF3F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    User? assignee = _usersById[task.assignedToId];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openTaskDetails(task),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE8EDF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        // The assignee's role acts as the task category (e.g. UI/UX Designer)
                        Text(
                          assignee?.role ?? 'Unassigned',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  _buildCardMenu(task),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    UserAvatar(user: assignee),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        formatTaskDate(task.dueDate),
                        style: const TextStyle(fontSize: 15, color: Color(0xFF334155)),
                      ),
                    ),
                    StatusBadge(status: displayStatusFor(task)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMenu(TaskModel task) {
    return SizedBox(
      width: 32,
      height: 32,
      child: PopupMenuButton<String>(
        padding: EdgeInsets.zero,
        icon: const Icon(Icons.more_vert, color: Color(0xFF334155), size: 20),
        onSelected: (value) {
          if (value == 'details') _openTaskDetails(task);
          if (value == 'complete') _markAsCompleted(task);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'details', child: Text('View details')),
          if (task.status != 'Completed')
            const PopupMenuItem(value: 'complete', child: Text('Mark as completed')),
        ],
      ),
    );
  }
}
