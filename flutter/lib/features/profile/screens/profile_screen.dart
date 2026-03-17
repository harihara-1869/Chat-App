import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Profile picture
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: user?.profilePicture != null
                            ? NetworkImage(user!.profilePicture!)
                            : null,
                        child: user?.profilePicture == null
                            ? Text(
                                user?.username[0].toUpperCase() ?? 'U',
                                style: const TextStyle(fontSize: 40),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF6366F1),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              // TODO: Implement image picker
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Username
                  Text(
                    user?.username ?? 'Username',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Email
                  Text(
                    user?.email ?? 'email@example.com',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Verification badge
                  if (user?.isVerified == true)
                    Chip(
                      avatar: const Icon(
                        Icons.verified,
                        color: Colors.blue,
                        size: 18,
                      ),
                      label: const Text('Verified'),
                      backgroundColor: Colors.blue.withOpacity(0.1),
                    ),
                  const SizedBox(height: 32),

                  // Profile info
                  _buildInfoTile(
                    icon: Icons.person_outline,
                    title: 'Username',
                    value: user?.username ?? 'N/A',
                    onTap: () => _showEditUsernameDialog(context),
                  ),
                  _buildInfoTile(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user?.email ?? 'N/A',
                  ),
                  _buildInfoTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Joined',
                    value: _formatDate(user?.createdAt),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6366F1)),
      title: Text(title),
      subtitle: Text(value),
      trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
      onTap: onTap,
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showEditUsernameDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Username',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newUsername = controller.text.trim();
              if (newUsername.isNotEmpty) {
                await ref
                    .read(profileProvider.notifier)
                    .updateUsername(newUsername);
                if (context.mounted) {
                  Navigator.pop(context);
                  // Refresh auth state
                  await ref.read(authProvider.notifier).refreshUser();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}