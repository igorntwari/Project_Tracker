import 'package:flutter/material.dart';
import '../widgets/main_app_bar.dart';

// Placeholder until the Team Members screen is implemented
class TeamScreen extends StatelessWidget {
  final VoidCallback? onAvatarTap;

  const TeamScreen({super.key, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: MainAppBar(title: 'Team Members', onAvatarTap: onAvatarTap),
      body: const Center(
        child: Text(
          'This is where the Team will be.',
          style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
        ),
      ),
    );
  }
}
