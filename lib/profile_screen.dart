import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database/database_helper.dart';
import 'models/user.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Real data variables instead of mock data
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Fetch the user data from SQLite
  Future<void> _loadUserData() async {
    final dbHelper = DatabaseHelper();
    
    // Fetch logged-in user profile
    final user = await dbHelper.getUser(1);
    
    // Update the UI
    setState(() {
      _currentUser = user;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Matching the light grayish-blue background from the screenshot
      backgroundColor: const Color(0xFFF7F9FC), 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark, // Makes battery/time icons dark
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Handle back action (e.g., Navigator.pop(context))
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
      // Using SingleChildScrollView to strictly avoid pixel overflow errors.
      // We first check if it's loading, then if user exists.
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
                        // User Avatar Container
                        Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4A89DF), // Blue color from screenshot
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _currentUser!.initials, // Real data
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // User Name
                        Text(
                          _currentUser!.name, // Real data
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // User Role
                        Text(
                          _currentUser!.role, // Real data
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Menu Options Card wrapped in a Container with rounded corners and slight shadow
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
                                textColor: const Color(0xFFD32F2F), // Red color for Sign Out
                                iconColor: const Color(0xFFD32F2F),
                                onTap: () {},
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

  // Local helper method to keep code DRY (Don't Repeat Yourself)
  // Extracts repeating list tile UI into a single reusable widget structure.
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
            // Expanded prevents the text from overflowing the row if it's too long
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
