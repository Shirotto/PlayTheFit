import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        backgroundColor: Colors.purple.shade800,
      ),
      backgroundColor: Colors.black87,
      body: StreamBuilder<List<Chat>>(
        stream: _chatService.getUserChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data ?? [];
          final currentUserId = _authService.currentUser?.uid;

          if (chats.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserName = chat.getOtherParticipantName(
                currentUserId!,
              );
              final otherUserId = chat.getOtherParticipantId(currentUserId);
              final isUnread =
                  chat.hasUnreadMessages &&
                  chat.lastMessageSenderId != currentUserId;

              return _buildChatItem(
                context,
                chat,
                otherUserName,
                otherUserId,
                isUnread,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.purple.shade200.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nessuna chat',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Inizia a chattare con i tuoi amici',
            style: TextStyle(fontSize: 14, color: Colors.white54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(
    BuildContext context,
    Chat chat,
    String otherUserName,
    String otherUserId,
    bool isUnread,
  ) {
    final currentUserId = _authService.currentUser?.uid;
    final isLastMessageFromMe = chat.lastMessageSenderId == currentUserId;
    final lastMessageTime = _formatChatTime(chat.lastMessageTime);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isUnread ? Colors.purple.shade900 : Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatDetailPage(
                    chatId: chat.id,
                    receiverId: otherUserId,
                    receiverName: otherUserName,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blue.shade400,
                child: Text(
                  otherUserName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          otherUserName,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          lastMessageTime,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (isLastMessageFromMe)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.done_all,
                              size: 14,
                              color:
                                  isUnread
                                      ? Colors.grey.shade400
                                      : Colors.blue.shade400,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            chat.lastMessageContent ?? 'Nuova chat',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color:
                                  isUnread
                                      ? Colors.white
                                      : Colors.grey.shade300,
                              fontWeight:
                                  isUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatChatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Ieri';
    } else if (now.difference(dateTime).inDays < 7) {
      return DateFormat('EEEE', 'it_IT').format(dateTime);
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }
}
