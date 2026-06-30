import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final uid = state.currentUserId;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Messages',
            style: TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: !state.isLoggedIn
          ? const Center(
              child: Text('Sign in to view your messages',
                  style: TextStyle(color: AppColors.grey)),
            )
          : StreamBuilder<List<ChatModel>>(
              stream: ChatService.instance.chatsForUser(uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Could not load messages.\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.grey)),
                    ),
                  );
                }
                final chats = snapshot.data ?? [];
                if (chats.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 56, color: AppColors.lightGrey),
                        SizedBox(height: 14),
                        Text('No conversations yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.grey)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: chats.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, i) => _ChatTile(chat: chats[i], myUid: uid),
                );
              },
            ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final ChatModel chat;
  final String myUid;
  const _ChatTile({required this.chat, required this.myUid});

  @override
  Widget build(BuildContext context) {
    final other = chat.otherName(myUid);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: chat.id, otherUserName: other),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.lightGrey),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: chat.carImageUrl.isNotEmpty
                  ? Image.network(chat.carImageUrl,
                      width: 54,
                      height: 54,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _ph())
                  : _ph(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(other,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  const SizedBox(height: 2),
                  Text(chat.carName,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(
                    chat.lastMessage.isEmpty ? 'Say hello 👋' : chat.lastMessage,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textMedium),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _ph() => Container(
        width: 54,
        height: 54,
        color: AppColors.offWhite,
        child: const Icon(Icons.directions_car, color: AppColors.lightGrey),
      );
}
