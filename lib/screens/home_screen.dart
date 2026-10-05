import 'package:flutter/material.dart';
import '../widgets/main_app_bar.dart';

// Placeholder until the Dashboard screen is implemented
class HomeScreen extends StatelessWidget {
  final VoidCallback? onAvatarTap;

  const HomeScreen({super.key, this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: MainAppBar(title: 'Dashboard', onAvatarTap: onAvatarTap),
      body: const Center(
        child: Text(
          'This is where the Home dashboard will be.',
          style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
        ),
      ),
    );
  }
}
