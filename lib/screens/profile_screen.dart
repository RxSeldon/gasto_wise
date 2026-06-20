import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';

// REFACTORED: Single Responsibility - only handles UI
// Auth and user operations delegated to services (Dependency Inversion)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final IAuthService _authService;

  // Mock user data
  late User _user;
  double _monthlyBudget = 5000.0;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _authService = ServiceLocator().authService;
    _user = User(
      id: '1',
      name: 'Juan Dela Cruz',
      email: 'juan@example.com',
      phone: '+63 912 345 6789',
    );
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        setState(() => _user = user);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading user: $e')));
      }
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _authService.logout();
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (_) => false);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Logout error: $e')));
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProfile() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: _user.name,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: _user.email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: _user.phone,
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBudget() {
    final budgetController = TextEditingController(
      text: _monthlyBudget.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
              final newBudget = double.tryParse(budgetController.text);
              if (newBudget != null && newBudget > 0) {
                setState(() => _monthlyBudget = newBudget);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Monthly budget updated successfully'),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount')),
                );
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'GastoWise',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 GastoWise. All rights reserved.',
      children: const [
        SizedBox(height: 24),
        Text('Smart Expense and Budget Tracker'),
        SizedBox(height: 12),
        Text(
          'GastoWise helps you track your expenses and manage your budget effectively.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
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
            child: const Center(
              child: Text('👤', style: TextStyle(fontSize: 50)),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _user.email,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
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
            subtitle: _user.phone,
            onTap: () {}, // Can implement later
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
            subtitle: 'App version 1.0.0',
            onTap: _showAboutDialog,
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
    required Function(bool) onChanged,
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
