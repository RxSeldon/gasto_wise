import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/service_locator.dart';
import '../viewmodels/profile_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(
        authService: ServiceLocator().authService,
        budgetService: ServiceLocator().budgetService,
      )..loadUserData(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleLogout(BuildContext context) {
    final vm = context.read<ProfileViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await vm.logout();
              if (context.mounted) {
                if (success) {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (_) => false);
                } else {
                  _showMessage(context, vm.errorMessage ?? 'Logout failed');
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    final vm = context.read<ProfileViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: vm.user.name,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: vm.user.email,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone',
                hintText: vm.user.phone,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _showMessage(context, 'Profile updated successfully');
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBudget(BuildContext context) {
    final vm = context.read<ProfileViewModel>();
    final budgetController = TextEditingController(
      text: vm.monthlyBudget.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final success = vm.updateBudget(budgetController.text);
              if (context.mounted) {
                _showMessage(
                  context,
                  success
                      ? 'Monthly budget updated successfully'
                      : 'Please enter a valid amount',
                );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
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
    final vm = context.watch<ProfileViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context, vm),
            _buildSettingsSection(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileViewModel vm) {
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
            vm.user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            vm.user.email,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, ProfileViewModel vm) {
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
            onTap: () => _editProfile(context),
          ),
          _buildSettingTile(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: vm.user.phone,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Budget Settings'),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.attach_money,
            title: 'Monthly Budget',
            subtitle: '\$${vm.monthlyBudget.toStringAsFixed(2)}',
            onTap: () => _editBudget(context),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'Preferences'),
          const SizedBox(height: 12),
          _buildToggleTile(
            icon: Icons.notifications,
            title: 'Notifications',
            value: vm.notificationsEnabled,
            onChanged: vm.setNotificationsEnabled,
          ),
          _buildToggleTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            value: vm.darkModeEnabled,
            onChanged: vm.setDarkModeEnabled,
          ),
          const SizedBox(height: 24),
          _buildSectionTitle(context, 'About'),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.info,
            title: 'About GastoWise',
            subtitle: 'App version 1.0.0',
            onTap: () => _showAboutDialog(context),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleLogout(context),
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
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
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
