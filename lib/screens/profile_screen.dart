import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final IAuthService _authService;

  User? _user;
  double _monthlyBudget = AppConstants.defaultBudget;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = ServiceLocator().authService;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = user ?? const User(
          id: '1',
          name: 'Juan Dela Cruz',
          email: 'juan@example.com',
          phone: '+63 912 345 6789',
        );
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading user: $e')));
    }
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
    }
  }

  Future<void> _editProfile() async {
    final user = _user;
    if (user == null) return;

    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final phoneController = TextEditingController(text: user.phone);

    final updatedUser = await showDialog<User>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(
                context,
                User(
                  id: user.id,
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();

    if (updatedUser == null || !mounted) return;
    setState(() => _user = updatedUser);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  Future<void> _editBudget() async {
    final budgetController = TextEditingController(
      text: _monthlyBudget.toStringAsFixed(2),
    );

    final newBudget = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Monthly Budget'),
        content: TextField(
          controller: budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Monthly Budget',
            prefixText: '\$ ',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final parsedBudget = double.tryParse(budgetController.text);
              if (parsedBudget == null || parsedBudget <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
                return;
              }
              Navigator.pop(context, parsedBudget);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    budgetController.dispose();

    if (newBudget == null || !mounted) return;
    setState(() => _monthlyBudget = newBudget);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Monthly budget updated successfully')),
    );
  }

  void _showAppAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: AppConstants.appVersion,
      applicationLegalese: 'Copyright 2026 GastoWise. All rights reserved.',
      children: const [
        SizedBox(height: 24),
        Text(AppConstants.appDescription),
        SizedBox(height: 12),
        Text(
          'GastoWise helps you track your expenses and manage your budget effectively.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    if (_isLoading || user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, user),
            _buildSettingsSection(context, user),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, User user) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(Icons.person, color: Colors.blue.shade800, size: 56),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, User user) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Account Settings'),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: _editProfile,
          ),
          _buildSettingTile(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: user.phone,
            onTap: _editProfile,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Budget Settings'),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.attach_money,
            title: 'Monthly Budget',
            subtitle: '\$${_monthlyBudget.toStringAsFixed(2)}',
            onTap: _editBudget,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Preferences'),
          const SizedBox(height: 12),
          _buildToggleTile(
            icon: Icons.notifications,
            title: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() => _notificationsEnabled = value);
            },
          ),
          _buildToggleTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() => _darkModeEnabled = value);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'About'),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.info,
            title: 'About GastoWise',
            subtitle: 'App version ${AppConstants.appVersion}',
            onTap: _showAppAboutDialog,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleLogout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade800),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.blue.shade800,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
