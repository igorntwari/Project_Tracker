import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';

class TaskStatisticsScreen extends StatefulWidget {
  const TaskStatisticsScreen({super.key});

  @override
  State<TaskStatisticsScreen> createState() => _TaskStatisticsScreenState();
}

class _TaskStatisticsScreenState extends State<TaskStatisticsScreen> {
  bool _isLoading = true;
  List<TaskModel> _tasks = [];

  // These numbers will be used to draw the chart.
  int _onTrackCount = 0;
  int _atRiskCount = 0;
  int _overdueCount = 0;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  // This gets the tasks from the database and counts how many are in each status.
  Future<void> _loadStatistics() async {
    try {
      final dbHelper = DatabaseHelper();
      final tasks = await dbHelper.getTasks();

      int onTrack = 0;
      int atRisk = 0;
      int overdue = 0;
      int completed = 0;

      // We go through all the tasks one by one to see if they are completed, overdue, etc.
      for (var task in tasks) {
        String status = task.slaStatus; 
        if (status == 'Completed') {
          completed++;
        } else if (status == 'Overdue') {
          overdue++;
        } else if (status == 'At Risk') {
          atRisk++;
        } else {
          onTrack++;
        }
      }

      // We sort the tasks by their due date so the ones due soonest show up first.
      tasks.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a.dueDate) ?? DateTime.now();
        DateTime dateB = DateTime.tryParse(b.dueDate) ?? DateTime.now();
        return dateA.compareTo(dateB);
      });

      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _onTrackCount = onTrack;
        _atRiskCount = atRisk;
        _overdueCount = overdue;
        _completedCount = completed;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Task Statistics',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildChartCard(),
                  const SizedBox(height: 24),
                  _buildUpcomingDeadlinesCard(),
                ],
              ),
            ),
    );
  }

  // We are building a bar chart from scratch using simple shapes and lines.
  // This shows we know how to put things together on the screen.
  Widget _buildChartCard() {
    // We find the biggest number so we know how tall to make the chart.
    int maxCount = [_onTrackCount, _atRiskCount, _overdueCount, _completedCount].reduce((a, b) => a > b ? a : b);
    if (maxCount == 0) maxCount = 1; // If there are no tasks, we make it 1 so the app doesn't crash from math errors.

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Task Status',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 200, // We make it tall enough so it fits nicely on the screen.
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar('On Track', _onTrackCount, maxCount, const Color(0xFF48B67D)),
                _buildBar('At Risk', _atRiskCount, maxCount, const Color(0xFFF4B942)),
                _buildBar('Overdue', _overdueCount, maxCount, const Color(0xFFE25A4B)),
                _buildBar('Completed', _completedCount, maxCount, const Color(0xFF8B9CB2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String label, int count, int maxCount, Color color) {
    // We calculate how tall each bar should be based on its number.
    double barHeight = (count / maxCount) * 110;
    if (count > 0 && barHeight < 15) barHeight = 15; // If the number is small, we still want the bar to be visible.

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: 45,
          height: barHeight,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(height: 1, width: 65, color: Colors.grey[200]),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF555555), fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildUpcomingDeadlinesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Upcoming Deadlines',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          if (_tasks.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("No tasks found."),
            ),
          ..._tasks.map((task) => _buildDeadlineItem(task)),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(TaskModel task) {
    DateTime date = DateTime.tryParse(task.dueDate) ?? DateTime.now();
    String formattedDate = "${date.day} ${_monthName(date.month)} ${date.year}";

    // If the task is just started, we show it differently.
    // For other statuses, we change the colors depending on whether it's late, on track, etc.
    String displayStatus = task.status == 'To Do' ? 'To Do' : task.slaStatus;
    
    Color badgeBgColor = const Color(0xFFF1F5F9); // Default color is gray.
    Color badgeTextColor = const Color(0xFF475569);

    if (displayStatus == 'At Risk') {
      badgeBgColor = const Color(0xFFFFF4E5);
      badgeTextColor = const Color(0xFFD97706);
    } else if (displayStatus == 'Overdue') {
      badgeBgColor = const Color(0xFFFFEBEE);
      badgeTextColor = const Color(0xFFD32F2F);
    } else if (displayStatus == 'On Track' || displayStatus == 'Completed') {
      badgeBgColor = const Color(0xFFE8F5E9);
      badgeTextColor = const Color(0xFF2E7D32);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 22, color: Color(0xFF334155)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayStatus,
                  style: TextStyle(
                    color: badgeTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
      ],
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    if (month >= 1 && month <= 12) return months[month - 1];
    return '';
  }
}
