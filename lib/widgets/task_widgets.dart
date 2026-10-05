import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../models/user.dart';

// Primary blue used across the task screens (app bar, buttons, chips)
const Color kPrimaryBlue = Color(0xFF2264D1);

// Formats an ISO date string as "10 Dec 2024"
String formatTaskDate(String isoDate) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  DateTime date = DateTime.tryParse(isoDate) ?? DateTime.now();
  return "${date.day} ${months[date.month - 1]} ${date.year}";
}

// 'To Do' tasks show their raw status, everything else shows the SLA status
String displayStatusFor(TaskModel task) {
  return task.status == 'To Do' ? 'To Do' : task.slaStatus;
}

// Pill shaped badge coloured by status (On Track, At Risk, Overdue, To Do...)
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color(0xFFF1F5F9); // Default To Do / Gray
    Color textColor = const Color(0xFF475569);

    if (status == 'At Risk') {
      bgColor = const Color(0xFFFFF4E5);
      textColor = const Color(0xFFD97706);
    } else if (status == 'Overdue') {
      bgColor = const Color(0xFFFFEBEE);
      textColor = const Color(0xFFD32F2F);
    } else if (status == 'On Track' || status == 'Completed') {
      bgColor = const Color(0xFFE8F5E9);
      textColor = const Color(0xFF2E7D32);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        status,
        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

// Circle avatar with the user's profile picture. The picture is downloaded once and
// cached on the device; the initials are shown while loading, offline or if missing.
class UserAvatar extends StatelessWidget {
  final User? user;
  final double radius;

  const UserAvatar({super.key, required this.user, this.radius = 16});

  // Same colours as the Team Members wireframe
  static const List<Color> _colors = [
    Color(0xFF2F6FD6),
    Color(0xFF7CC08F),
    Color(0xFFA78BFA),
    Color(0xFF2563EB),
    Color(0xFF22A060),
  ];

  @override
  Widget build(BuildContext context) {
    String? avatarUrl = user?.avatarUrl;
    if (avatarUrl == null || avatarUrl.isEmpty) return _buildInitials();

    return CachedNetworkImage(
      imageUrl: avatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => _buildInitials(),
      errorWidget: (context, url, error) => _buildInitials(),
    );
  }

  Widget _buildInitials() {
    Color color = _colors[((user?.id ?? 1) - 1) % _colors.length];
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        user?.initials ?? '?',
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
