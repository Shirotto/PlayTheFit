import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  // Lista per memorizzare le chat in cache locale
  List<Chat> _cachedChats = [];

  @override
  void initState() {
    super.initState();
    // Carica le chat una volta quando la pagina viene aperta
    _loadChats();
  }

  // Metodo per caricare le chat e memorizzarle in cache
  void _loadChats() async {
    try {
      _chatService.getUserChats().listen((chats) {
        if (chats.isNotEmpty) {
          setState(() {
            _cachedChats = chats;
          });
        }
      });
    } catch (e) {
      print('Errore nel caricare le chat: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Chat',
          style: AppDesignSystem.headingMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        backgroundColor: AppDesignSystem.darkPrimary,
        actions: [
          // Aggiungi un pulsante di refresh per ricaricare le chat
          AppComponents.iconButton(
            icon: Icons.refresh,
            onPressed: () {
              setState(() {}); // Forza il ricaricamento del widget
            },
            tooltip: 'Aggiorna',
            iconColor: AppDesignSystem.textPrimary,
          ),
        ],
      ),
      body: StreamBuilder<List<Chat>>(
        stream: _chatService.getUserChats(),
        builder: (context, snapshot) {          if (snapshot.connectionState == ConnectionState.waiting &&
              _cachedChats.isEmpty) {
            return AppComponents.loadingIndicator();
          }

          // Se abbiamo un errore ma abbiamo dati in cache, mostriamo quelli
          if (snapshot.hasError) {
            if (_cachedChats.isNotEmpty) {
              // Usa la cache e mostra un messaggio
              final chats = _cachedChats;
              final currentUserId = _authService.currentUser?.uid;

              return Column(
                children: [                  Container(
                    padding: const EdgeInsets.all(AppDesignSystem.paddingS),
                    color: AppDesignSystem.warning.withOpacity(0.3),
                    child: Row(
                      children: [
                        Icon(Icons.warning, color: AppDesignSystem.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Visualizzando chat in modalità offline. Alcune conversazioni potrebbero non essere aggiornate.',
                            style: AppDesignSystem.bodyMedium.copyWith(
                              color: AppDesignSystem.textPrimary,
                            ),
                          ),
                        ),
                        AppComponents.iconButton(
                          icon: Icons.refresh,
                          onPressed: () => setState(() {}),
                          iconColor: AppDesignSystem.textPrimary,
                        ),
                      ],
                    ),
                  ),
                  Expanded(child: _buildChatList(chats, currentUserId!)),
                ],
              );
            } else {              // Se non abbiamo cache, mostra l'errore
              return AppComponents.emptyState(
                icon: Icons.error_outline,
                title: 'Errore nel caricamento delle chat',
                subtitle: 'Verifica la connessione e riprova',
                iconColor: AppDesignSystem.error,
                action: AppComponents.primaryButton(
                  text: 'Riprova',
                  onPressed: () => setState(() {
                    _loadChats();
                  }),
                ),
              );
            }
          }

          // Aggiorna la cache quando abbiamo nuovi dati
          final chats = snapshot.data ?? [];
          if (chats.isNotEmpty) {
            _cachedChats = List.from(chats);
          }

          final currentUserId = _authService.currentUser?.uid;
          if (chats.isEmpty) {
            return _buildEmptyState();
          }

          return _buildChatList(chats, currentUserId!);
        },
      ),
    );
  }
  // Metodo per costruire la lista delle chat
  Widget _buildChatList(List<Chat> chats, String currentUserId) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppDesignSystem.paddingS),
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        final otherUserName = chat.getOtherParticipantName(currentUserId);
        final otherUserId = chat.getOtherParticipantId(currentUserId);
        final isUnread =
            chat.hasUnreadMessages && chat.lastMessageSenderId != currentUserId;

        return _buildChatItem(
          context,
          chat,
          otherUserName,
          otherUserId,
          isUnread,
        );
      },
    );
  }
  Widget _buildEmptyState() {
    return AppComponents.emptyState(
      icon: Icons.chat_bubble_outline,
      title: 'Nessuna chat',
      subtitle: 'Inizia a chattare con i tuoi amici',
      iconColor: AppDesignSystem.secondary,
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
    final lastMessageTime = _formatChatTime(chat.lastMessageTime);    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppDesignSystem.paddingXS, 
        horizontal: AppDesignSystem.paddingXS
      ),
      child: AppComponents.standardCard(
        hasPrimaryAccent: isUnread,
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
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppDesignSystem.paddingM),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: AppDesignSystem.primary,
                  child: Text(
                    otherUserName.substring(0, 1).toUpperCase(),
                    style: AppDesignSystem.headingSmall.copyWith(
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: AppDesignSystem.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            otherUserName,
                            style: AppDesignSystem.bodyLarge.copyWith(
                              fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            lastMessageTime,
                            style: AppDesignSystem.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDesignSystem.paddingXS),
                      Row(
                        children: [
                          if (isLastMessageFromMe)
                            Padding(
                              padding: const EdgeInsets.only(right: AppDesignSystem.paddingXS),
                              child: Icon(
                                Icons.done_all,
                                size: 14,
                                color: isUnread 
                                    ? AppDesignSystem.textTertiary
                                    : AppDesignSystem.primary,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              chat.lastMessageContent ?? 'Nuova chat',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppDesignSystem.bodyMedium.copyWith(
                                color: isUnread 
                                    ? AppDesignSystem.textPrimary
                                    : AppDesignSystem.textSecondary,
                                fontWeight: isUnread 
                                    ? FontWeight.bold 
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          if (isUnread)
                            Container(
                              margin: const EdgeInsets.only(left: AppDesignSystem.paddingS),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: AppDesignSystem.primary,
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
