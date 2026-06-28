import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../services/expense_provider.dart';
import '../widgets/glass_card.dart';
import 'account_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Notification toggles
  bool _notifExpenseAdded = true;
  bool _notifWeeklyReport = true;
  bool _notifBudgetAlert = true;
  bool _notifReceiptScan = false;
  bool _notifDailyReminder = false;

  // App preference toggles
  bool _hapticFeedback = true;
  bool _compactView = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifExpenseAdded = prefs.getBool('notif_expense_added') ?? true;
      _notifWeeklyReport = prefs.getBool('notif_weekly_report') ?? true;
      _notifBudgetAlert = prefs.getBool('notif_budget_alert') ?? true;
      _notifReceiptScan = prefs.getBool('notif_receipt_scan') ?? false;
      _notifDailyReminder = prefs.getBool('notif_daily_reminder') ?? false;
      _hapticFeedback = prefs.getBool('haptic_feedback') ?? true;
      _compactView = prefs.getBool('compact_view') ?? false;
      _loading = false;
    });
  }

  Future<void> _setPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _confirmWipeData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Data Wipe', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.surface,
        content: const Text(
          'Are you sure you want to permanently delete all expenses and scanned receipts from this device? This action cannot be undone.',
          style: TextStyle(color: AppTheme.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.destructive),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Everything', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // Clear data locally
      await Provider.of<ExpenseProvider>(context, listen: false).clearAllExpenses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ All local expenses and receipts have been cleared successfully.'),
            backgroundColor: AppTheme.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                  ),
                ),
                child: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Settings',
                      style: TextStyle(
                          color: AppTheme.foreground,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  Text('Manage your preferences',
                      style: TextStyle(color: AppTheme.mutedForeground, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Account Configuration Section
          _SectionHeader(title: 'Account Settings', icon: Icons.person_outline_rounded),
          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              _ClickableTile(
                icon: Icons.manage_accounts_rounded,
                iconColor: AppTheme.primary,
                title: 'User Profile & Account',
                subtitle: 'Configure accents, display name, switch account',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AccountSettingsScreen()),
                  );
                },
              ),
              _Divider(),
              _ClickableTile(
                icon: Icons.delete_forever_rounded,
                iconColor: AppTheme.destructive,
                title: 'Delete All Data',
                subtitle: 'Wipe all expenses & receipts from database',
                onTap: _confirmWipeData,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Notifications Section
          _SectionHeader(title: 'Notifications', icon: Icons.notifications_outlined),
          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              _ToggleTile(
                icon: Icons.add_circle_outline_rounded,
                iconColor: AppTheme.primary,
                title: 'Expense Added',
                subtitle: 'Alert when a new expense is recorded',
                value: _notifExpenseAdded,
                onChanged: (v) {
                  setState(() => _notifExpenseAdded = v);
                  _setPref('notif_expense_added', v);
                },
              ),
              _Divider(),
              _ToggleTile(
                icon: Icons.bar_chart_rounded,
                iconColor: const Color(0xFF7C4DFF),
                title: 'Weekly Report',
                subtitle: 'Summary of your weekly spending',
                value: _notifWeeklyReport,
                onChanged: (v) {
                  setState(() => _notifWeeklyReport = v);
                  _setPref('notif_weekly_report', v);
                },
              ),
              _Divider(),
              _ToggleTile(
                icon: Icons.warning_amber_rounded,
                iconColor: AppTheme.destructive,
                title: 'Budget Alert',
                subtitle: 'Notify when approaching budget limit',
                value: _notifBudgetAlert,
                onChanged: (v) {
                  setState(() => _notifBudgetAlert = v);
                  _setPref('notif_budget_alert', v);
                },
              ),
              _Divider(),
              _ToggleTile(
                icon: Icons.document_scanner_rounded,
                iconColor: AppTheme.green,
                title: 'Receipt Scan Complete',
                subtitle: 'Alert when OCR scan finishes',
                value: _notifReceiptScan,
                onChanged: (v) {
                  setState(() => _notifReceiptScan = v);
                  _setPref('notif_receipt_scan', v);
                },
              ),
              _Divider(),
              _ToggleTile(
                icon: Icons.alarm_rounded,
                iconColor: const Color(0xFFFF9800),
                title: 'Daily Reminder',
                subtitle: 'Remind you to log expenses daily',
                value: _notifDailyReminder,
                onChanged: (v) {
                  setState(() => _notifDailyReminder = v);
                  _setPref('notif_daily_reminder', v);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // App Preferences Section
          _SectionHeader(title: 'App Preferences', icon: Icons.tune_rounded),
          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              _ToggleTile(
                icon: Icons.vibration_rounded,
                iconColor: const Color(0xFF00BCD4),
                title: 'Haptic Feedback',
                subtitle: 'Vibrate on interactions',
                value: _hapticFeedback,
                onChanged: (v) {
                  setState(() => _hapticFeedback = v);
                  _setPref('haptic_feedback', v);
                },
              ),
              _Divider(),
              _ToggleTile(
                icon: Icons.view_compact_rounded,
                iconColor: const Color(0xFF9C27B0),
                title: 'Compact View',
                subtitle: 'Show more items with smaller cards',
                value: _compactView,
                onChanged: (v) {
                  setState(() => _compactView = v);
                  _setPref('compact_view', v);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // About Section
          _SectionHeader(title: 'About', icon: Icons.info_outline_rounded),
          const SizedBox(height: 12),

          _SettingsCard(
            children: [
              _InfoTile(
                icon: Icons.app_settings_alt_rounded,
                iconColor: AppTheme.primary,
                title: 'App Version',
                value: '1.0.0',
              ),
              _Divider(),
              _InfoTile(
                icon: Icons.receipt_long_rounded,
                iconColor: AppTheme.green,
                title: 'OCR Engine',
                value: 'Tesseract',
              ),
              _Divider(),
              _InfoTile(
                icon: Icons.storage_rounded,
                iconColor: const Color(0xFFFF9800),
                title: 'Backend',
                value: 'ASP.NET Core',
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, color: AppTheme.primary, size: 16),
        const SizedBox(width: 6),
        Text(title,
            style: const TextStyle(
                color: AppTheme.foreground,
                fontSize: 15,
                fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppTheme.foreground,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            activeTrackColor: AppTheme.primary.withAlpha((0.25 * 255).round()),
            inactiveThumbColor: AppTheme.mutedForeground,
            inactiveTrackColor: AppTheme.surfaceLight,
          ),
        ],
      ),
    );
  }
}

class _ClickableTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ClickableTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withAlpha((0.15 * 255).round()),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppTheme.foreground,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.mutedForeground, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.mutedForeground, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withAlpha((0.15 * 255).round()),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: const TextStyle(
                    color: AppTheme.foreground,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.mutedForeground, fontSize: 13)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.5,
      color: AppTheme.border,
      indent: 68,
    );
  }
}
