import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/car_model.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // One conversation per (car, buyer) pair. Deterministic id => no dupes.
  String _chatId(String carId, String buyerId) => '${carId}_$buyerId';

  /// Creates the chat doc if it doesn't exist and returns the chat id.
  Future<String> getOrCreateChat({
    required CarModel car,
    required String buyerId,
    required String buyerName,
  }) async {
    final sellerId = car.sellerId ?? '';
    final chatId = _chatId(car.id, buyerId);
    final ref = _db.collection('chats').doc(chatId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'carId': car.id,
        'carName': car.fullName,
        'carImageUrl': car.imageUrl,
        'buyerId': buyerId,
        'buyerName': buyerName,
        'sellerId': sellerId,
        'sellerName': car.sellerName ?? car.dealer,
        'participants': [buyerId, sellerId],
        'lastMessage': '',
        'lastSenderId': '',
        'lastTimestamp': FieldValue.serverTimestamp(),
      });
    }
    return chatId;
  }

  /// All conversations a user is part of, newest activity first.
  /// We deliberately do NOT add .orderBy() on the Firestore query — combining
  /// arrayContains with orderBy needs a composite index, and if it's missing
  /// the whole stream errors and the screen looks broken. Instead we sort the
  /// results in Dart, which needs no index.
  Stream<List<ChatModel>> chatsForUser(String uid) {
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((s) {
      final chats =
          s.docs.map((d) => ChatModel.fromFirestore(d.data(), d.id)).toList();
      chats.sort((a, b) => b.lastTimestamp.compareTo(a.lastTimestamp));
      return chats;
    });
  }

  /// Live messages of a conversation, oldest first.
  Stream<List<MessageModel>> messages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((s) =>
            s.docs.map((d) => MessageModel.fromFirestore(d.data(), d.id)).toList());
  }

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final chatRef = _db.collection('chats').doc(chatId);

    // Read the chat so we know who the recipient is and the sender's name.
    final chatSnap = await chatRef.get();
    final chat = chatSnap.data();

    await chatRef.collection('messages').add({
      'senderId': senderId,
      'text': trimmed,
      'timestamp': FieldValue.serverTimestamp(),
    });
    await chatRef.update({
      'lastMessage': trimmed,
      'lastSenderId': senderId,
      'lastTimestamp': FieldValue.serverTimestamp(),
    });

    // Connect chat -> notifications: drop an in-app notification for the
    // other participant so it shows up on their Notifications screen (and
    // gets pushed by the Cloud Function if it's deployed).
    if (chat != null) {
      final participants = List<String>.from(chat['participants'] ?? []);
      final recipientId =
          participants.firstWhere((p) => p != senderId, orElse: () => '');
      final senderName = senderId == chat['buyerId']
          ? (chat['buyerName'] as String? ?? 'A buyer')
          : (chat['sellerName'] as String? ?? 'A seller');

      if (recipientId.isNotEmpty) {
        await _db.collection('notifications').add({
          'title': 'Message from $senderName',
          'message': trimmed,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'targetUserId': recipientId,
          'targetRole': '',
          'type': 'chat',
        });
      }
    }
  }
}
