import 'package:flutter/material.dart';

import 'widgets/task_widgets.dart';
import 'screens/signin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Project & SLA Task Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimaryBlue),
      ),
      // MainScreen holds the bottom navigation bar (Home, Tasks, Team, Profile)
      home: const SignInScreen(),
    );
  }
}