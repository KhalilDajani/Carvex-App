import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../data/app_state.dart';
import '../../models/notification_model.dart';
import '../../services/notification_service.dart';
import '../notifications_screen.dart';
import 'admin_users_screen.dart';
import 'admin_cars_screen.dart';
import 'admin_send_notification_screen.dart';

class _AdminColors {
  static const bg        = Color(0xFF0F1117);
  static const surface   = Color(0xFF1A1D27);
  static const card      = Color(0xFF20232F);
  static const border    = Color(0xFF2C2F3E);
  static const accent    = Color(0xFFD32F2F);   
  static const accentSoft= Color(0x22D32F2F);
  static const purple    = Color(0xFF7C3AED);
  static const purpleSoft= Color(0x227C3AED);
  static const teal      = Color(0xFF0D9488);
  static const tealSoft  = Color(0x220D9488);
  static const amber     = Color(0xFFD97706);
  static const amberSoft = Color(0x22D97706);
  static const textPrimary   = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted     = Color(0xFF64748B);
}

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AdminColors.bg,
      body: CustomScrollView(
        slivers: [
          
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: _AdminColors.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: _AdminColors.textPrimary, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              _AdminNotificationBellDark(),
              SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _AdminHeaderBanner(),
            ),
          ),

          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
              child: _SectionLabel('Overview'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: const _StatsGrid(),
            ),
          ),

          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 28, 16, 0),
              child: _SectionLabel('Management'),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ManagementCard(
                icon: Icons.people_alt_rounded,
                label: 'Manage Users',
                subtitle: 'View all registered users and roles',
                color: _AdminColors.purple,
                colorSoft: _AdminColors.purpleSoft,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminUsersScreen())),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _ManagementCard(
                icon: Icons.directions_car_filled_rounded,
                label: 'Manage Cars',
                subtitle: 'Approve, reject or delete listings',
                color: _AdminColors.accent,
                colorSoft: _AdminColors.accentSoft,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const AdminCarsScreen())),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _ManagementCard(
                icon: Icons.campaign_rounded,
                label: 'Send Notification',
                subtitle: 'Broadcast messages to Buyers, Sellers, or all',
                color: _AdminColors.teal,
                colorSoft: _AdminColors.tealSoft,
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const AdminSendNotificationScreen())),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _AdminHeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1D27), Color(0xFF12151E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          
          Positioned(
            right: -20, top: -20,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _AdminColors.accent.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            right: 60, top: 30,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _AdminColors.purple.withValues(alpha: 0.1),
              ),
            ),
          ),
          
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _AdminColors.accentSoft,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: _AdminColors.accent.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.shield_rounded,
                        color: _AdminColors.accent, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Admin Panel',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: _AdminColors.textPrimary,
                            letterSpacing: -0.5,
                          )),
                      SizedBox(height: 2),
                      Text('Carvex Control Center',
                          style: TextStyle(
                            fontSize: 12,
                            color: _AdminColors.textMuted,
                            fontWeight: FontWeight.w500,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  Future<Map<String, int>> _fetchStats() async {
    final db = FirebaseFirestore.instance;
    final usersSnap = await db.collection('users').get();
    final carsSnap  = await db.collection('cars').get();
    int buyers = 0, sellers = 0;
    for (final doc in usersSnap.docs) {
      final role = doc.data()['role'] as String? ?? '';
      if (role == 'buyer')  buyers++;
      if (role == 'seller') sellers++;
    }
    return {
      'users':   usersSnap.docs.length,
      'cars':    carsSnap.docs.length,
      'buyers':  buyers,
      'sellers': sellers,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: _fetchStats(),
      builder: (context, snapshot) {
        final loading = !snapshot.hasData;
        final stats   = snapshot.data ?? {};

        if (loading) {
          return const _StatsLoadingGrid();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 500;
            final count  = isWide ? 4 : 2;
            return GridView.count(
              crossAxisCount: count,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: isWide ? 1.4 : 1.5,
              children: [
                _StatCard(
                  label: 'Total Users',
                  value: '${stats['users']}',
                  icon: Icons.people_alt_rounded,
                  color: _AdminColors.purple,
                  colorSoft: _AdminColors.purpleSoft,
                ),
                _StatCard(
                  label: 'Total Cars',
                  value: '${stats['cars']}',
                  icon: Icons.directions_car_filled_rounded,
                  color: _AdminColors.accent,
                  colorSoft: _AdminColors.accentSoft,
                ),
                _StatCard(
                  label: 'Buyers',
                  value: '${stats['buyers']}',
                  icon: Icons.shopping_bag_rounded,
                  color: _AdminColors.teal,
                  colorSoft: _AdminColors.tealSoft,
                ),
                _StatCard(
                  label: 'Sellers',
                  value: '${stats['sellers']}',
                  icon: Icons.storefront_rounded,
                  color: _AdminColors.amber,
                  colorSoft: _AdminColors.amberSoft,
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, colorSoft;

  const _StatCard({
    required this.label, required this.value,
    required this.icon,  required this.color, required this.colorSoft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _AdminColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: colorSoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                    height: 1,
                  )),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _AdminColors.textMuted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsLoadingGrid extends StatelessWidget {
  const _StatsLoadingGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: List.generate(4, (_) => _SkeletonBox(radius: 16)),
    );
  }
}

class _ManagementCard extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final Color color, colorSoft;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,     required this.label,
    required this.subtitle, required this.color,
    required this.colorSoft, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _AdminColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: colorSoft,
        highlightColor: colorSoft.withValues(alpha: 0.5),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _AdminColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: colorSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _AdminColors.textPrimary,
                        )),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _AdminColors.textMuted,
                        )),
                  ],
                ),
              ),
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: colorSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.arrow_forward_ios_rounded,
                    color: color, size: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: _AdminColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _AdminColors.textSecondary,
              letterSpacing: 0.8,
            )),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double? width, height;
  final double radius;
  const _SkeletonBox({this.width, this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _AdminColors.border,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _AdminNotificationBellDark extends StatelessWidget {
  const _AdminNotificationBellDark();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isLoggedIn) return const SizedBox.shrink();

    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService.instance.notificationsStream(
        userId: state.currentUserId,
        userRole: state.userRole,
      ),
      builder: (context, snapshot) {
        final unread = (snapshot.data ?? []).where((n) => !n.isRead).length;
        return Stack(
          children: [
            IconButton(
              icon: Icon(
                unread > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                color: unread > 0
                    ? _AdminColors.accent
                    : _AdminColors.textSecondary,
              ),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsScreen()),
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: _AdminColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unread > 9 ? '9+' : unread.toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
