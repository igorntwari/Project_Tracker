import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../widgets/task_widgets.dart';

class TeamScreen extends StatefulWidget {
  final VoidCallback? onAvatarTap;

  const TeamScreen({super.key, this.onAvatarTap});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final users = await _dbHelper.getUsers();
      if (!mounted) return;
      setState(() {
        _members = users;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  // Shows a bottom-sheet modal to add a new team member
  void _showAddMemberModal() {
    final nameController = TextEditingController();
    final roleController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          // Push the sheet above the keyboard
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Add Team Member',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Full name field
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Jane Smith',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kPrimaryBlue, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Role field
                  const Text(
                    'Role',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1A202C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: roleController,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'e.g. Backend Developer',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: kPrimaryBlue, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a role';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Add button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        final name = nameController.text.trim();
                        final role = roleController.text.trim();

                        // Build initials from the first letter of first and last name
                        final parts = name.split(' ');
                        String initials = parts[0][0].toUpperCase();
                        if (parts.length > 1) {
                          initials += parts.last[0].toUpperCase();
                        }

                        final newUser = User(
                          name: name,
                          role: role,
                          initials: initials,
                        );

                        await _dbHelper.insertUser(newUser);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                        _loadMembers();

                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text('$name added to the team!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text(
                        'Add Member',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: const Text(
          'Team Members',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: _showAddMemberModal,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: kPrimaryBlue, size: 22),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(
                  child: Text(
                    'No team members yet.',
                    style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadMembers,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    itemCount: _members.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _buildMemberCard(_members[index]),
                  ),
                ),
    );
  }

  Widget _buildMemberCard(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8EDF4)),
      ),
      child: Row(
        children: [
          UserAvatar(user: user, radius: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.role,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 32,
            height: 32,
            child: PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.more_vert, color: Color(0xFF334155), size: 20),
              onSelected: (value) {
                if (value == 'view') {
                  // Placeholder for viewing member details
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'view', child: Text('View details')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
