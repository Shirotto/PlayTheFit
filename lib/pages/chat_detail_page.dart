import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

class ChatDetailPage extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;

  const ChatDetailPage({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Segna tutti i messaggi come letti quando si apre la chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatService.markChatAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _chatService.sendMessage(
        chatId: widget.chatId,
        receiverId: widget.receiverId,
        content: message,
      );
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Errore nell\'invio del messaggio: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final currentUserId = _authService.currentUser?.uid;

    return AppScaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: AppDesignSystem.headingMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        backgroundColor: AppDesignSystem.darkPrimary,
        actions: [
          AppComponents.iconButton(
            icon: Icons.info_outline,
            onPressed: () {
              // Apri info chat
            },
            iconColor: AppDesignSystem.textPrimary,
            tooltip: 'Info chat',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _chatService.getChatMessages(widget.chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return AppComponents.loadingIndicator();
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return AppComponents.emptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'Nessun messaggio',
                    subtitle: 'Inizia a chattare!',
                    iconColor: AppDesignSystem.primary,
                  );
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(AppDesignSystem.paddingM),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUserId;

                    return _buildMessageItem(message, isMe);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }
  Widget _buildMessageItem(Message message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesignSystem.paddingM),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 16,
              backgroundColor: AppDesignSystem.primary,
              child: Text(
                message.senderName.substring(0, 1).toUpperCase(),
                style: AppDesignSystem.bodySmall.copyWith(
                  color: AppDesignSystem.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(width: AppDesignSystem.paddingS),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppDesignSystem.paddingM),
              decoration: BoxDecoration(
                color: isMe ? AppDesignSystem.primary : AppDesignSystem.cardBackground,
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusL),
                boxShadow: AppDesignSystem.shadowS,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
                      child: Image.network(
                        message.imageUrl!,
                        width: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 200,
                            height: 150,
                            color: AppDesignSystem.cardBackgroundSecondary,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 200,
                            height: 100,
                            color: AppDesignSystem.cardBackgroundSecondary,
                            child: Icon(
                              Icons.error_outline,
                              color: AppDesignSystem.textTertiary,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppDesignSystem.paddingS),
                  ],
                  Text(
                    message.content,
                    style: AppDesignSystem.bodyLarge.copyWith(
                      color: isMe ? AppDesignSystem.textPrimary : AppDesignSystem.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDesignSystem.paddingXS),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formatMessageTime(message.timestamp),
                        style: AppDesignSystem.caption.copyWith(
                          color: isMe 
                              ? AppDesignSystem.textPrimary.withOpacity(0.7)
                              : AppDesignSystem.textTertiary,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: AppDesignSystem.paddingXS),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? AppDesignSystem.success
                              : AppDesignSystem.textTertiary,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppDesignSystem.paddingS),
          if (isMe) const SizedBox(width: 32), // Spazio equivalente all'avatar
        ],
      ),
    );
  }
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppDesignSystem.paddingM),
      decoration: BoxDecoration(
        color: AppDesignSystem.darkSecondary,
        boxShadow: AppDesignSystem.shadowM,
      ),
      child: Row(
        children: [
          AppComponents.iconButton(
            icon: Icons.attach_file,
            onPressed: () {
              // Implementare l'invio di file
            },
            iconColor: AppDesignSystem.textTertiary,
            tooltip: 'Allega file',
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDesignSystem.paddingM),
              decoration: BoxDecoration(
                color: AppDesignSystem.cardBackground,
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
              ),
              child: TextField(
                controller: _messageController,
                style: AppDesignSystem.bodyLarge,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Scrivi un messaggio',
                  hintStyle: AppDesignSystem.bodyLarge.copyWith(
                    color: AppDesignSystem.textTertiary,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppDesignSystem.paddingM,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDesignSystem.paddingS),
          _isLoading
              ? Padding(
                padding: const EdgeInsets.all(AppDesignSystem.paddingS),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppDesignSystem.primary,
                  ),
                ),
              )
              : AppComponents.iconButton(
                icon: Icons.send,
                onPressed: _sendMessage,
                iconColor: AppDesignSystem.primary,
                tooltip: 'Invia messaggio',
              ),
        ],
      ),
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }
}
