import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/app_state.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../screens/notifications_screen.dart';
import '../theme/app_theme.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (!state.isLoggedIn) {
      return IconButton(
        icon: const Icon(Icons.notifications_none_rounded,
            color: AppColors.darkGrey),
        onPressed: () => _openNotifications(context),
      );
    }

    return StreamBuilder<List<NotificationModel>>(
      stream: NotificationService.instance.notificationsStream(
        userId: state.currentUserId,
        userRole: state.userRole,
      ),
      builder: (context, snapshot) {
        final unreadCount = (snapshot.data ?? [])
            .where((n) => !n.isRead)
            .length;

        return Stack(
          children: [
            IconButton(
              icon: Icon(
                unreadCount > 0
                    ? Icons.notifications_rounded
                    : Icons.notifications_none_rounded,
                color: unreadCount > 0
                    ? AppColors.primary
                    : AppColors.darkGrey,
              ),
              onPressed: () => _openNotifications(context),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _openNotifications(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }
}
