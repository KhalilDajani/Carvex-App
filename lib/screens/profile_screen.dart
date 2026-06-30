import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../widgets/common_widgets.dart';
import 'signin_screen.dart';
import 'sell_car_screen.dart';
import 'my_listings_screen.dart';
import 'favorites_screen.dart';
import 'financing_screen.dart';
import 'chat_list_screen.dart';
import 'admin/admin_panel_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('My Profile',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: state.isLoggedIn ? _LoggedInProfile(state: state) : _NotLoggedIn(),
    );
  }
}

class _LoggedInProfile extends StatelessWidget {
  final AppState state;
  const _LoggedInProfile({required this.state});

  Color _roleColor(String role) {
    switch (role) {
      case 'admin':
        return Colors.deepPurple;
      case 'seller':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'seller':
        return 'Seller';
      default:
        return 'Buyer';
    }
  }

  void _showEditProfile(BuildContext context) {
    final controller = TextEditingController(text: state.userName);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              await context.read<AppState>().updateProfile(name: name);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Save',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    state.userName.isNotEmpty
                        ? state.userName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(state.userName,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              Text(state.userEmail,
                  style:
                      const TextStyle(fontSize: 14, color: AppColors.grey)),
              if (state.userPhone.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(state.userPhone,
                    style:
                        const TextStyle(fontSize: 13, color: AppColors.grey)),
              ],
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _roleColor(state.userRole).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: _roleColor(state.userRole).withValues(alpha: 0.4)),
                ),
                child: Text(
                  _roleLabel(state.userRole),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _roleColor(state.userRole),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _showEditProfile(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 8),
                ),
                child: const Text('Edit Profile'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Container(
          color: AppColors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: state.isSeller
                ? [
                    _StatItem(
                        value: state.myListingsCount.toString(),
                        label: 'Listings'),
                  ]
                : [
                    _StatItem(
                        value: state.favorites.length.toString(),
                        label: 'Favorites'),
                    Container(
                        width: 1,
                        height: 40,
                        color: AppColors.lightGrey),
                    _StatItem(
                        value: state.compareList.length.toString(),
                        label: 'Comparing'),
                    Container(
                        width: 1,
                        height: 40,
                        color: AppColors.lightGrey),
                    _StatItem(
                        value: state.myListingsCount.toString(),
                        label: 'Listings'),
                  ],
          ),
        ),
        const SizedBox(height: 8),

        Container(
          color: AppColors.white,
          child: Column(
            children: [
              if (state.canManageCars)
                _ProfileMenuItem(
                  icon: Icons.directions_car_outlined,
                  label: 'My Listings',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const MyListingsScreen()),
                  ),
                ),

              if (state.canManageCars)
                _ProfileMenuItem(
                  icon: Icons.add_circle_outline,
                  label: 'Add New Car',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SellCarScreen()),
                  ),
                ),

              // Messages — available to everyone who is signed in
              _ProfileMenuItem(
                icon: Icons.chat_bubble_outline,
                label: 'Messages',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ChatListScreen()),
                ),
              ),

              if (!state.isSeller)
                _ProfileMenuItem(
                  icon: Icons.favorite_border,
                  label: 'Saved Cars',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FavoritesScreen()),
                  ),
                ),

              _ProfileMenuItem(
                icon: Icons.calculate_outlined,
                label: 'Finance Calculator',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FinancingScreen()),
                ),
              ),

              if (state.isAdmin) ...[
                const Divider(color: AppColors.lightGrey, height: 1),
                _ProfileMenuItem(
                  icon: Icons.admin_panel_settings_outlined,
                  label: 'Admin Panel',
                  color: Colors.deepPurple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AdminPanelScreen()),
                  ),
                ),
              ],

              _ProfileMenuItem(
                  icon: Icons.security_outlined,
                  label: 'Privacy & Security',
                  onTap: () {}),
              _ProfileMenuItem(
                  icon: Icons.help_outline,
                  label: 'Help & Support',
                  onTap: () {}),
            ],
          ),
        ),
        const SizedBox(height: 8),

        Container(
          color: AppColors.white,
          child: _ProfileMenuItem(
            icon: Icons.logout,
            label: 'Sign Out',
            color: AppColors.primary,
            onTap: () async {
              await context.read<AppState>().signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                  color: AppColors.lightGrey, shape: BoxShape.circle),
              child: const Icon(Icons.person_outline,
                  size: 40, color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            const Text('Not Signed In',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            const SizedBox(height: 8),
            const Text(
              'Sign in to access your profile, saved cars, and listings.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 24),
            RedButton(
              label: 'Sign In',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignInScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value, label;
  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        Text(label,
            style: const TextStyle(fontSize: 12, color: AppColors.grey)),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textDark, size: 22),
      title: Text(label,
          style: TextStyle(
              color: color ?? AppColors.textDark,
              fontWeight: FontWeight.w500,
              fontSize: 15)),
      trailing: color == null
          ? const Icon(Icons.chevron_right,
              color: AppColors.grey, size: 20)
          : null,
      onTap: onTap,
    );
  }
}