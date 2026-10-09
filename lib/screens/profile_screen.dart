import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import 'signin.dart';

class ProfileScreen extends StatefulWidget {
  // This handles going back to the previous screen when we press the back button.
  final VoidCallback? onBack;

  const ProfileScreen({super.key, this.onBack});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variables to store the actual user details.
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // This function gets the user info from the database.
  Future<void> _loadUserData() async {
    final dbHelper = DatabaseHelper();
    
    // We fetch the profile of the user who is logged in.
    final user = await dbHelper.getUser(1);
    
    // After getting the data, we tell the screen to update and show it.
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Setting the background color.
      backgroundColor: const Color(0xFFF7F9FC), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // This makes the icons at the top of the phone screen dark.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // If we have a back function, we call it. Otherwise, we just close this screen.
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      // We make the screen scrollable so content doesn't get cut off on small screens.
      // First we show a loading circle. When it's done, we check if we found the user.
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _currentUser == null
              ? const Center(child: Text("User not found."))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 30),
                        // This draws the circle for the user's picture or initials.
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A89DF), // Setting the circle's color.
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _currentUser!.initials, // We put the user's initials here.
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // This shows the user's name.
                        Text(
                          _currentUser!.name, // We get the actual name from the user object.
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // This shows the user's job or role.
                        Text(
                          _currentUser!.role, // We get the actual role from the user object.
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // This is a box that holds the menu buttons. It has curved corners and a tiny shadow.
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                icon: Icons.edit_outlined,
                                title: 'Edit Profile',
                                onTap: () {},
                              ),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              _buildMenuItem(
                                icon: Icons.settings_outlined,
                                title: 'App Settings',
                                onTap: () {},
                              ),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              _buildMenuItem(
                                icon: Icons.info_outline,
                                title: 'About',
                                onTap: () {},
                              ),
                              const Divider(height: 1, color: Color(0xFFEEEEEE)),
                              _buildMenuItem(
                                icon: Icons.logout,
                                title: 'Sign Out',
                                textColor: const Color(0xFFD32F2F), // We make the sign out text red.
                                iconColor: const Color(0xFFD32F2F),
                                onTap: () {
                                  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                                    (route) => false,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
    );
  }

  // This is a small helper function so we don't have to copy-paste the same code for every menu item.
  // It builds a row with an icon and some text.
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color textColor = const Color(0xFF2C3E50),
    Color iconColor = const Color(0xFF2C3E50),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 16),
            // 'Expanded' makes sure the text fits on the screen without causing errors.
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
