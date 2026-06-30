import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory MessageModel.fromFirestore(Map<String, dynamic> d, String id) {
    return MessageModel(
      id: id,
      senderId: d['senderId'] as String? ?? '',
      text: d['text'] as String? ?? '',
      timestamp: d['timestamp'] is Timestamp
          ? (d['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }
}
