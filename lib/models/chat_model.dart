import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final String carId;
  final String carName;
  final String carImageUrl;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final String sellerName;
  final List<String> participants;
  final String lastMessage;
  final String lastSenderId;
  final DateTime lastTimestamp;

  ChatModel({
    required this.id,
    required this.carId,
    required this.carName,
    required this.carImageUrl,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.sellerName,
    required this.participants,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastTimestamp,
  });

  factory ChatModel.fromFirestore(Map<String, dynamic> d, String id) {
    return ChatModel(
      id: id,
      carId: d['carId'] ?? '',
      carName: d['carName'] ?? '',
      carImageUrl: d['carImageUrl'] ?? '',
      buyerId: d['buyerId'] ?? '',
      buyerName: d['buyerName'] ?? '',
      sellerId: d['sellerId'] ?? '',
      sellerName: d['sellerName'] ?? '',
      participants: List<String>.from(d['participants'] ?? []),
      lastMessage: d['lastMessage'] ?? '',
      lastSenderId: d['lastSenderId'] ?? '',
      lastTimestamp: d['lastTimestamp'] is Timestamp
          ? (d['lastTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Returns the display name of the *other* participant relative to [myUid].
  String otherName(String myUid) => myUid == buyerId ? sellerName : buyerName;
}
