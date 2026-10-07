import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../widgets/main_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onAvatarTap;

  const HomeScreen({super.key, this.onAvatarTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<TaskModel>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = DatabaseHelper().getTasks();
  }

  Future<void> _refresh() async {
    setState(() {
      _tasksFuture = DatabaseHelper().getTasks();
    });
    try {
      await _tasksFuture;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: MainAppBar(title: 'Dashboard', onAvatarTap: widget.onAvatarTap),
      body: FutureBuilder<List<TaskModel>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load tasks.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refresh,
                    child: const Text('Try again'),
                  ),
                ],
              ),
            );
          }
          return _buildContent(snapshot.data ?? []);
        },
      ),
    );
  }

  Widget _buildContent(List<TaskModel> tasks) {
    int count(String sla) => tasks.where((t) => t.slaStatus == sla).length;

    final total = tasks.length;
    final completed = count('Completed');
    final progress = total == 0 ? 0.0 : completed / total;
    final attention = tasks
        .where((t) => t.slaStatus == 'Overdue' || t.slaStatus == 'At Risk')
        .toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Project Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(progress * 100).round()}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  const SizedBox(height: 8),
                  Text('$completed of $total tasks completed'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _StatCard(
                label: 'On Track',
                count: count('On Track'),
                color: slaColor('On Track'),
                icon: Icons.trending_up,
              ),
              _StatCard(
                label: 'At Risk',
                count: count('At Risk'),
                color: slaColor('At Risk'),
                icon: Icons.warning_amber_rounded,
              ),
              _StatCard(
                label: 'Overdue',
                count: count('Overdue'),
                color: slaColor('Overdue'),
                icon: Icons.error_outline,
              ),
              _StatCard(
                label: 'Completed',
                count: completed,
                color: slaColor('Completed'),
                icon: Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Needs Attention',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (attention.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No tasks need attention. Great work!'),
            )
          else
            ...attention.map((task) => _AttentionTile(task: task)),
        ],
      ),
    );
  }
}

Color slaColor(String sla) {
  switch (sla) {
    case 'Overdue':
      return Colors.red;
    case 'At Risk':
      return Colors.orange;
    case 'Completed':
      return Colors.green;
    default:
      return Colors.blue;
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

class _AttentionTile extends StatelessWidget {
  final TaskModel task;

  const _AttentionTile({required this.task});

  String _formatDate(String raw) {
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final sla = task.slaStatus;
    final color = slaColor(sla);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Due ${_formatDate(task.dueDate)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            sla,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}