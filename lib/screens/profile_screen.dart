import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app/router.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const _accentBlue = Color(0xFF5B8DEE);
  static const _kNotifications = 'profile_notifications';
  static const _kDarkMode = 'profile_dark_mode';
  static const _kLanguage = 'profile_language';

  final _authService = AuthService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _notifications = true;
  bool _darkMode = true;
  String _language = 'English';

  Future<_ProfileSummary> _loadSummary() async {
    final user = await _authService.getCurrentUser();
    final photoUrl = await _authService.getPhotoUrl();
    return _ProfileSummary(
      name: user?.displayName ?? 'Reframed User',
      email: user?.email ?? 'local@reframed',
      photoUrl: photoUrl,
    );
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notifications = prefs.getBool(_kNotifications) ?? true;
      _darkMode = prefs.getBool(_kDarkMode) ?? true;
      _language = prefs.getString(_kLanguage) ?? 'English';
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, _notifications);
    await prefs.setBool(_kDarkMode, _darkMode);
    await prefs.setString(_kLanguage, _language);
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<String?> _askInput({
    required String title,
    required String initialValue,
    required String hint,
  }) async {
    final controller = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(_ProfileSummary summary) async {
    final value = await _askInput(
      title: 'Edit name',
      initialValue: summary.name,
      hint: 'Your name',
    );
    if (value == null || value.isEmpty) return;
    await _authService.updateDisplayName(value);
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _editEmail(_ProfileSummary summary) async {
    final value = await _askInput(
      title: 'Edit email',
      initialValue: summary.email,
      hint: 'name@example.com',
    );
    if (value == null || value.isEmpty) return;
    try {
      await _authService.updateEmail(value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email update submitted successfully.')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update email: $e')),
      );
    }
  }

  Future<void> _editPhoto(_ProfileSummary summary) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null) return;
    await _authService.updatePhotoUrl(picked.path);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile image updated')),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileSummary>(
      future: _loadSummary(),
      builder: (context, snapshot) {
        final summary = snapshot.data ??
            const _ProfileSummary(name: 'Reframed User', email: 'local@reframed');
        final profileImage = _resolveProfileImage(summary.photoUrl);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: const Color(0xFF1A1A1A),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _editPhoto(summary),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: _accentBlue.withValues(alpha: 0.24),
                          backgroundImage: profileImage,
                          child: profileImage == null
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 44,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        summary.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        summary.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.blueGrey.shade400,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: () => _editName(summary),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit name'),
                          ),
                          FilledButton.tonalIcon(
                            onPressed: () => _editPhoto(summary),
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Choose image'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Settings',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(color: Colors.blueGrey.shade400),
              ),
              const SizedBox(height: 8),
              Card(
                color: const Color(0xFF1A1A1A),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Notifications'),
                      subtitle: const Text('Receive reflection reminders'),
                      value: _notifications,
                      onChanged: (v) async {
                        setState(() => _notifications = v);
                        await _saveSettings();
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Dark mode'),
                      subtitle: const Text('Use dark appearance'),
                      value: _darkMode,
                      onChanged: (v) async {
                        setState(() => _darkMode = v);
                        await _saveSettings();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.language_rounded),
                      title: const Text('Language'),
                      subtitle: Text(_language),
                      onTap: () async {
                        final value = await showDialog<String>(
                          context: context,
                          builder: (context) => SimpleDialog(
                            title: const Text('Choose language'),
                            children: [
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'English'),
                                child: const Text('English'),
                              ),
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, 'Urdu'),
                                child: const Text('Urdu'),
                              ),
                            ],
                          ),
                        );
                        if (value == null) return;
                        setState(() => _language = value);
                        await _saveSettings();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(summary.email),
                      onTap: () => _editEmail(summary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await _authService.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.welcome,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign out'),
              ),
            ],
          ),
        );
      },
    );
  }
}

ImageProvider? _resolveProfileImage(String? photoUrl) {
  if (photoUrl == null || photoUrl.isEmpty) return null;
  if (photoUrl.startsWith('http')) return NetworkImage(photoUrl);
  final file = File(photoUrl);
  if (!file.existsSync()) return null;
  return FileImage(file);
}

class _ProfileSummary {
  final String name;
  final String email;
  final String? photoUrl;

  const _ProfileSummary({
    required this.name,
    required this.email,
    this.photoUrl,
  });
}
