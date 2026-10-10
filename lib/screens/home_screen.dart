import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/task_model.dart';
import '../widgets/main_app_bar.dart';
import 'task_statistics_screen.dart';

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

  Future<void> _openStatistics() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TaskStatisticsScreen()),
    );
    if (!mounted) return;
    _refresh();
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
    final onTrack = count('On Track');
    final atRisk = count('At Risk');
    final overdue = count('Overdue');
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
                count: onTrack,
                color: slaColor('On Track'),
                icon: Icons.trending_up,
              ),
              _StatCard(
                label: 'At Risk',
                count: atRisk,
                color: slaColor('At Risk'),
                icon: Icons.warning_amber_rounded,
              ),
              _StatCard(
                label: 'Overdue',
                count: overdue,
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
          const SizedBox(height: 16),
          _TaskOverviewCard(
            total: total,
            onTrack: onTrack,
            atRisk: atRisk,
            overdue: overdue,
            completed: completed,
            onTap: _openStatistics,
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

class _TaskOverviewCard extends StatelessWidget {
  final int total;
  final int onTrack;
  final int atRisk;
  final int overdue;
  final int completed;
  final VoidCallback onTap;

  const _TaskOverviewCard({
    required this.total,
    required this.onTrack,
    required this.atRisk,
    required this.overdue,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Task Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    children: [
                      Text(
                        'View statistics',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(120, 120),
                          painter: _DonutPainter(
                            values: [
                              onTrack.toDouble(),
                              atRisk.toDouble(),
                              overdue.toDouble(),
                              completed.toDouble(),
                            ],
                            colors: [
                              slaColor('On Track'),
                              slaColor('At Risk'),
                              slaColor('Overdue'),
                              slaColor('Completed'),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$total',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Tasks',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _LegendRow(
                          label: 'On Track',
                          count: onTrack,
                          color: slaColor('On Track'),
                        ),
                        _LegendRow(
                          label: 'At Risk',
                          count: atRisk,
                          color: slaColor('At Risk'),
                        ),
                        _LegendRow(
                          label: 'Overdue',
                          count: overdue,
                          color: slaColor('Overdue'),
                        ),
                        _LegendRow(
                          label: 'Completed',
                          count: completed,
                          color: slaColor('Completed'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _LegendRow({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _DonutPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 20.0;
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final total = values.fold<double>(0, (sum, v) => sum + v);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (total == 0) {
      paint.color = Colors.grey.shade300;
      canvas.drawArc(rect, 0, 2 * pi, false, paint);
      return;
    }

    double start = -pi / 2;
    for (int i = 0; i < values.length; i++) {
      final sweep = values[i] / total * 2 * pi;
      paint.color = colors[i];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.values != values;
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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