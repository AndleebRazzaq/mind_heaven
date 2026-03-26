import 'package:flutter/material.dart';
import 'auth_screen.dart';

/// Profile: avatar, name, email, Premium, Settings (ref style).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _accentBlue = Color(0xFF5B8DEE);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: const Color(0xFF1A1A1A),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Alex',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'alex@mindheaven.com',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.blueGrey.shade400,
                        ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      backgroundColor: _accentBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('Premium Member'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.blueGrey.shade400,
                ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.psychology_outlined,
            label: 'Therapy Tone',
            value: 'Empathetic',
          ),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            value: 'Enabled',
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'Appearance',
            value: 'Dark Mode',
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            label: 'Language',
            value: 'English',
          ),
          const SizedBox(height: 20),
          Text(
            'Account',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.blueGrey.shade400,
                ),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.logout_rounded,
            label: 'Sign out',
            value: '',
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const AuthScreen(initialLogin: true),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap ?? () {},
        leading: CircleAvatar(
          backgroundColor: ProfileScreen._accentBlue.withOpacity(0.3),
          child: Icon(icon, color: ProfileScreen._accentBlue, size: 22),
        ),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: value.isEmpty
            ? const Icon(Icons.chevron_right_rounded, color: Colors.blueGrey)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: TextStyle(color: Colors.blueGrey.shade300, fontSize: 13),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded, color: Colors.blueGrey, size: 20),
                ],
              ),
      ),
    );
  }
}
