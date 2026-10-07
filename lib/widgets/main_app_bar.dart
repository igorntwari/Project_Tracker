import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'task_widgets.dart';

// Blue app bar shared by the main tabs: menu, centred title and the user's initials
class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onAvatarTap;

  const MainAppBar({super.key, required this.title, this.onAvatarTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryBlue,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light, // White status bar icons on blue
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.white),
        onPressed: () {
          // Open navigation drawer when it is connected
        },
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: onAvatarTap,
            child: const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Text(
                'JD',
                style: TextStyle(color: kPrimaryBlue, fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
