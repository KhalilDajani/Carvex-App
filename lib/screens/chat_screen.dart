import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../data/app_state.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String myUid) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    try {
      await ChatService.instance.sendMessage(
        chatId: widget.chatId,
        senderId: myUid,
        text: text,
      );
    } catch (e) {
      _controller.text = text; // restore so the user doesn't lose it
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send: $e')),
        );
      }
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = context.read<AppState>().currentUserId;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.otherUserName,
            style: const TextStyle(
                color: AppColors.textDark, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: ChatService.instance.messages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary));
                }
                final msgs = snapshot.data ?? [];
                if (msgs.isEmpty) {
                  return const Center(
                    child: Text('No messages yet. Start the conversation.',
                        style: TextStyle(color: AppColors.grey)),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) {
                    _scroll.jumpTo(_scroll.position.maxScrollExtent);
                  }
                });
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[i];
                    final mine = m.senderId == myUid;
                    return Align(
                      alignment:
                          mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 0.72),
                        decoration: BoxDecoration(
                          color: mine ? AppColors.primary : AppColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: mine
                                  ? AppColors.primary
                                  : AppColors.lightGrey),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                              color: mine ? Colors.white : AppColors.textDark,
                              fontSize: 14),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _Composer(controller: _controller, onSend: () => _send(myUid)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _Composer({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.lightGrey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                filled: true,
                fillColor: AppColors.offWhite,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
