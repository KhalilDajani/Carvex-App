import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class _AC {
  static const bg            = Color(0xFF0F1117);
  static const surface       = Color(0xFF1A1D27);
  static const card          = Color(0xFF20232F);
  static const border        = Color(0xFF2C2F3E);
  static const accent        = Color(0xFFD32F2F);
  static const accentSoft    = Color(0x22D32F2F);
  static const purple        = Color(0xFF7C3AED);
  static const purpleSoft    = Color(0x227C3AED);
  static const teal          = Color(0xFF0D9488);
  static const tealSoft      = Color(0x220D9488);
  static const amber         = Color(0xFFD97706);
  static const amberSoft     = Color(0x22D97706);
  static const textPrimary   = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted     = Color(0xFF64748B);
}

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AC.bg,
      appBar: AppBar(
        backgroundColor: _AC.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: _AC.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manage Users',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _AC.textPrimary,
            )),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _AC.border),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('name')
            .snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const _LoadingState();
          }

          
          if (snapshot.hasError) {
            return _ErrorState(message: 'Could not load users.\n${snapshot.error}');
          }

          final docs = snapshot.data?.docs ?? [];

          
          if (docs.isEmpty) {
            return const _EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'No users yet',
              subtitle: 'Registered users will appear here.',
            );
          }

          
          return Column(
            children: [
              _SummaryBar(count: docs.length, label: 'registered users'),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    return _UserCard(
                      name:     data['name']     as String? ?? 'Unknown',
                      email:    data['email']    as String? ?? '–',
                      role:     data['role']     as String? ?? 'buyer',
                      phone:    data['phone']    as String? ?? '',
                      imageUrl: data['imageUrl'] as String?,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final String name, email, role, phone;
  final String? imageUrl;

  const _UserCard({
    required this.name,  required this.email,
    required this.role,  required this.phone,
    this.imageUrl,
  });

  _RoleStyle get _roleStyle {
    switch (role) {
      case 'admin':
        return _RoleStyle(_AC.accent, _AC.accentSoft, Icons.shield_rounded);
      case 'seller':
        return _RoleStyle(_AC.amber, _AC.amberSoft, Icons.storefront_rounded);
      default:
        return _RoleStyle(_AC.teal, _AC.tealSoft, Icons.shopping_bag_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rs = _roleStyle;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _AC.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _AC.border),
      ),
      child: Row(
        children: [
          
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: rs.soft,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: rs.color,
                          fontSize: 20,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: rs.soft,
                    shape: BoxShape.circle,
                    border: Border.all(color: _AC.card, width: 2),
                  ),
                  child: Icon(rs.icon, color: rs.color, size: 9),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _AC.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(email,
                    style: const TextStyle(
                        fontSize: 12, color: _AC.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(phone,
                      style: const TextStyle(
                          fontSize: 11, color: _AC.textMuted)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: rs.soft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: rs.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              role[0].toUpperCase() + role.substring(1),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: rs.color,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleStyle {
  final Color color, soft;
  final IconData icon;
  const _RoleStyle(this.color, this.soft, this.icon);
}

class _SummaryBar extends StatelessWidget {
  final int count;
  final String label;
  const _SummaryBar({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: _AC.surface,
        border: Border(bottom: BorderSide(color: _AC.border)),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(
          fontSize: 12,
          color: _AC.textMuted,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, __) => Container(
        height: 72,
        decoration: BoxDecoration(
          color: _AC.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _AC.border),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: const BoxDecoration(
                color: _AC.border, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      height: 12, width: 140,
                      decoration: BoxDecoration(
                        color: _AC.border,
                        borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 6),
                  Container(
                      height: 10, width: 100,
                      decoration: BoxDecoration(
                        color: _AC.border,
                        borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  const _EmptyState({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: _AC.card,
                shape: BoxShape.circle,
                border: Border.all(color: _AC.border),
              ),
              child: Icon(icon, color: _AC.textMuted, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _AC.textSecondary,
                )),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _AC.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                color: _AC.accentSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: _AC.accent, size: 28),
            ),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _AC.textMuted)),
          ],
        ),
      ),
    );
  }
}
