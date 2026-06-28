import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notifications = true;
  String _displayName = 'Alex Johnson';
  String _displayEmail = 'alex@gmail.com';
  int _avatarIndex = 0;

  final List<List<Color>> _avatars = [
    [const Color(0xFF7C3AED), const Color(0xFF60A5FA)], // Purple-Blue
    [const Color(0xFFEC4899), const Color(0xFFF43F5E)], // Pink-Rose
    [const Color(0xFF10B981), const Color(0xFF3B82F6)], // Emerald-Blue
    [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Amber-Red
    [const Color(0xFF8B5CF6), const Color(0xFFD946EF)], // Violet-Fuchsia
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('user_profile_name') ?? 'Alex Johnson';
      _displayEmail = prefs.getString('user_profile_email') ?? 'alex@gmail.com';
      _avatarIndex = prefs.getInt('user_avatar_index') ?? 0;
    });
  }

  void _logout() async {
    await AuthService().logout();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Profile',
              style: TextStyle(
                  color: AppTheme.foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Profile Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: _avatars[_avatarIndex],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _avatars[_avatarIndex][0].withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(_displayName,
                    style: const TextStyle(
                        color: AppTheme.foreground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_displayEmail,
                    style: const TextStyle(
                        color: AppTheme.mutedForeground, fontSize: 14)),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 10),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                    ).then((_) => _loadProfileData());
                  },
                  child: const Text('Edit Profile',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Row
          Row(
            children: const [
              _StatBox(label: 'Total\nExpenses', value: '247'),
              SizedBox(width: 10),
              _StatBox(label: 'This Month', value: '\$1.8K', valueColor: AppTheme.primary),
              SizedBox(width: 10),
              _StatBox(label: 'Balance', value: '\$4.2K', valueColor: AppTheme.primary),
            ],
          ),
          const SizedBox(height: 24),

          // Section: Preferences
          _SectionLabel(label: 'Preferences'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                // Notifications Toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications_outlined,
                          color: AppTheme.mutedForeground, size: 20),
                      const SizedBox(width: 12),
                      const Expanded(
                          child: Text('Notifications',
                              style: TextStyle(
                                  color: AppTheme.foreground, fontSize: 15))),
                      Switch(
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                        activeThumbColor: AppTheme.primary,
                        activeTrackColor: AppTheme.primary.withValues(alpha: 0.3),
                        inactiveThumbColor: AppTheme.mutedForeground,
                        inactiveTrackColor: AppTheme.border,
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppTheme.border, height: 1),
                _MenuRow(
                  icon: Icons.lock_outline,
                  label: 'Privacy Settings',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section: Account
          _SectionLabel(label: 'Account'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _MenuRow(
                    icon: Icons.description_outlined,
                    label: 'Terms & Privacy',
                    onTap: () {}),
                const Divider(color: AppTheme.border, height: 1),
                _MenuRow(
                    icon: Icons.help_outline,
                    label: 'Help & Support',
                    onTap: () {}),
                const Divider(color: AppTheme.border, height: 1),
                _MenuRow(
                  icon: Icons.logout_rounded,
                  label: 'Logout',
                  labelColor: AppTheme.destructive,
                  iconColor: AppTheme.destructive,
                  onTap: _logout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text('Version 1.0.0',
                style:
                    TextStyle(color: AppTheme.mutedForeground, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
                color: AppTheme.foreground,
                fontSize: 16,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatBox({
    required this.label,
    required this.value,
    this.valueColor = AppTheme.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.mutedForeground,
                    fontSize: 11,
                    height: 1.4)),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    color: valueColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color labelColor;
  final Color iconColor;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.labelColor = AppTheme.foreground,
    this.iconColor = AppTheme.mutedForeground,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: TextStyle(color: labelColor, fontSize: 15))),
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.mutedForeground, size: 20),
          ],
        ),
      ),
    );
  }
}
