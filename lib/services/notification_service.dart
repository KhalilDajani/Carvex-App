import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification_model.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // The in-app notification document already exists in Firestore (it is
  // created either by sendNotification() on the app side or by the
  // Cloud Function for chat messages). We do NOT write another doc here,
  // otherwise the notifications list would show duplicates. We just log.
  debugPrint('[FCM][BG] Received background message: ${message.messageId}');
  debugPrint('[FCM][BG] title=${message.notification?.title} body=${message.notification?.body}');
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'carvex_channel';
  static const _channelName = 'Carvex Notifications';
  static const _channelDesc = 'Carvex car marketplace notifications';

  final StreamController<NotificationModel> _inAppController =
      StreamController.broadcast();
  Stream<NotificationModel> get inAppStream => _inAppController.stream;

  Future<void> initialize() async {
    debugPrint('[NotificationService] Initializing...');

    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('[NotificationService] Permission status: ${settings.authorizationStatus}');

    await _setupLocalNotifications();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[NotificationService] App launched from notification: ${initialMessage.messageId}');
      _handleMessageOpenedApp(initialMessage);
    }

    _fcm.onTokenRefresh.listen((token) {
      debugPrint('[NotificationService] FCM token refreshed');
      _saveToken(token);
    });

    debugPrint('[NotificationService] Initialization complete');
  }

  Future<void> _setupLocalNotifications() async {
    debugPrint('[NotificationService] Setting up local notifications...');

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[LocalNotif] Tapped notification id=${response.id} payload=${response.payload}');
      },
    );

    if (!kIsWeb) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
      debugPrint('[NotificationService] Android channel "$_channelId" created/verified');
    }
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    debugPrint('[LocalNotif] Showing: title="$title" body="$body" id=$id');
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // Foreground push: just show a banner. We do NOT write a Firestore doc
  // here — the doc already exists (created by the sender or Cloud Function).
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM][FG] Received foreground message: ${message.messageId}');
    final notification = message.notification;
    if (notification != null) {
      showLocalNotification(
        title: notification.title ?? 'Carvex',
        body: notification.body ?? '',
        id: message.hashCode,
        payload: message.data['type'],
      );
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] App opened from notification: ${message.messageId}');
    // No persistence here either — the in-app list reads from Firestore.
  }

  Future<void> _refreshAndSaveToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('[FCM] _refreshAndSaveToken: no logged-in user, skipping');
      return;
    }
    try {
      final token = await _fcm.getToken();
      debugPrint('[FCM] Retrieved FCM token: ${token?.substring(0, 20)}...');
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('[FCM] Error retrieving FCM token: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      debugPrint('[FCM] _saveToken: no logged-in user, skipping');
      return;
    }
    debugPrint('[FCM] Saving FCM token to Firestore for uid=$uid');
    await _db.collection('users').doc(uid).set(
      {'fcmToken': token, 'fcmUpdatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
    debugPrint('[FCM] FCM token saved successfully');
  }

  Future<void> onUserLogin() async {
    debugPrint('[NotificationService] onUserLogin — saving FCM token');
    await _refreshAndSaveToken();
  }

  Future<void> onUserLogout() async {
    final uid = _auth.currentUser?.uid;
    debugPrint('[NotificationService] onUserLogout — clearing FCM token for uid=$uid');
    if (uid == null) return;
    await _db.collection('users').doc(uid).update({'fcmToken': ''});
    await _fcm.deleteToken();
    debugPrint('[NotificationService] FCM token deleted');
  }

  // Writes a notification document. The Cloud Function picks this up and
  // pushes an FCM message to the matching users' devices.
  Future<void> sendNotification({
    required String title,
    required String message,
    required String targetRole,
    String targetUserId = '',
    String type = 'admin_broadcast',
  }) async {
    debugPrint('[NotificationService] sendNotification: title="$title" targetRole="$targetRole" targetUserId="$targetUserId"');
    await _db.collection('notifications').add({
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
      'targetUserId': targetUserId,
      'targetRole': targetRole,
      'type': type,
    });
    debugPrint('[NotificationService] Notification document written to Firestore');
  }

  // Called from AppState.approveCar() when an admin approves a listing.
  // 1) broadcasts "new car listed" to everyone,
  // 2) tells the seller their listing went live.
  Future<void> sendCarApprovedNotifications({
    required String carName,
    required String carId,
    required String sellerId,
  }) async {
    debugPrint('[NotificationService] sendCarApprovedNotifications: "$carName" carId=$carId');

    await sendNotification(
      title: 'New Car Listed 🚗',
      message: '$carName is now available on Carvex.',
      targetRole: 'all',
      type: 'new_car',
    );

    if (sellerId.isNotEmpty) {
      await sendNotification(
        title: 'Listing Approved ✅',
        message: 'Your listing "$carName" is now live on Carvex.',
        targetRole: '',
        targetUserId: sellerId,
        type: 'listing_approved',
      );
    }
  }

  Stream<List<NotificationModel>> notificationsStream({
    required String userId,
    required String userRole,
  }) {
    debugPrint('[NotificationService] notificationsStream: userId=$userId userRole=$userRole');
    return _db
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      final all = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .where((n) => _isNotificationForUser(n, userId, userRole))
          .toList();
      debugPrint('[NotificationService] notificationsStream: ${all.length} notifications for user');
      return all;
    });
  }

  bool _isNotificationForUser(
    NotificationModel n,
    String userId,
    String userRole,
  ) {
    if (n.targetUserId.isNotEmpty) {
      return n.targetUserId == userId;
    }
    if (n.targetRole == 'all') return true;
    if (n.targetRole == userRole) return true;
    return false;
  }

  Future<void> markAsRead(String notificationId) async {
    debugPrint('[NotificationService] markAsRead: $notificationId');
    await _db
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  Future<void> markAllAsRead({
    required String userId,
    required String userRole,
  }) async {
    debugPrint('[NotificationService] markAllAsRead: userId=$userId userRole=$userRole');
    final snapshot = await _db
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _db.batch();
    int count = 0;
    for (final doc in snapshot.docs) {
      final n = NotificationModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
      if (_isNotificationForUser(n, userId, userRole)) {
        batch.update(doc.reference, {'isRead': true});
        count++;
      }
    }
    await batch.commit();
    debugPrint('[NotificationService] markAllAsRead: marked $count notifications as read');
  }

  void dispose() {
    _inAppController.close();
  }
}