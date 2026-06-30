import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    if (!state.isLoggedIn) {
      return const _NotLoggedIn();
    }

    return _NotificationsView(
      userId: state.currentUserId,
      userRole: state.userRole,
    );
  }
}

class _NotLoggedIn extends StatelessWidget {
  const _NotLoggedIn();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Notifications',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppColors.lightGrey),
            const SizedBox(height: 16),
            const Text('Sign in to view notifications',
                style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  final String userId;
  final String userRole;

  const _NotificationsView({
    required this.userId,
    required this.userRole,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => NotificationService.instance.markAllAsRead(
              userId: userId,
              userRole: userRole,
            ),
            child: const Text(
              'Mark all read',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: NotificationService.instance.notificationsStream(
          userId: userId,
          userRole: userRole,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return _EmptyState();
          }

          final unread = notifications.where((n) => !n.isRead).toList();
          final read = notifications.where((n) => n.isRead).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              if (unread.isNotEmpty) ...[
                _SectionHeader(
                    label: 'New', count: unread.length, isUnread: true),
                ...unread.map((n) => _NotificationTile(notification: n)),
              ],
              if (read.isNotEmpty) ...[
                _SectionHeader(label: 'Earlier', count: read.length),
                ...read.map((n) => _NotificationTile(notification: n)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.lightGrey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 48,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No notifications yet',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark),
          ),
          const SizedBox(height: 8),
          const Text(
            'We\'ll notify you when something new happens',
            style: TextStyle(fontSize: 13, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final int count;
  final bool isUnread;

  const _SectionHeader({
    required this.label,
    required this.count,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
                letterSpacing: 0.5),
          ),
          const SizedBox(width: 8),
          if (isUnread)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationTile({required this.notification});

  IconData _iconForType(String type) {
    switch (type) {
      case 'new_car':
        return Icons.directions_car_rounded;
      case 'admin_broadcast':
      case 'admin_targeted':
        return Icons.campaign_rounded;
      case 'chat':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'new_car':
        return const Color(0xFF0D9488);
      case 'admin_broadcast':
      case 'admin_targeted':
        return AppColors.primary;
      case 'chat':
        return const Color(0xFF2563EB);
      default:
        return AppColors.grey;
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _colorForType(notification.type);

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.primary,
        child: const Icon(Icons.check_circle_outline,
            color: Colors.white, size: 28),
      ),
      onDismissed: (_) =>
          NotificationService.instance.markAsRead(notification.id),
      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            NotificationService.instance.markAsRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: notification.isRead
                ? AppColors.white
                : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.lightGrey
                  : AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconForType(notification.type),
                  color: iconColor, size: 22),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: notification.isRead
                    ? FontWeight.w500
                    : FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 3),
                Text(
                  notification.message,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMedium),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _timeAgo(notification.timestamp),
                  style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            trailing: !notification.isRead
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
