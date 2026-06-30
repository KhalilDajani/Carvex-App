import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String targetUserId; 
  final String targetRole;   
  final String type;         

  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.targetUserId,
    required this.targetRole,
    required this.type,
  });

  factory NotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String docId,
  ) {
    return NotificationModel(
      id: docId,
      title: data['title'] as String? ?? '',
      message: data['message'] as String? ?? '',
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isRead: data['isRead'] as bool? ?? false,
      targetUserId: data['targetUserId'] as String? ?? '',
      targetRole: data['targetRole'] as String? ?? 'all',
      type: data['type'] as String? ?? 'admin_broadcast',
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': isRead,
        'targetUserId': targetUserId,
        'targetRole': targetRole,
        'type': type,
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        title: title,
        message: message,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        targetUserId: targetUserId,
        targetRole: targetRole,
        type: type,
      );
}
