import 'package:flutter/material.dart';
import '../models/friendship.dart';
import '../services/friendship_service.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

class AmiciPage extends StatefulWidget {
  final int initialTabIndex;

  const AmiciPage({super.key, this.initialTabIndex = 0});

  @override
  State<AmiciPage> createState() => _AmiciPageState();
}

class _AmiciPageState extends State<AmiciPage>
    with SingleTickerProviderStateMixin {
  final FriendshipService _friendshipService = FriendshipService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers() async {
    if (_searchController.text.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _friendshipService.searchUsers(
        _searchController.text.trim(),
      );
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Errore nella ricerca: $e')));
      setState(() {
        _isSearching = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Amici',
          style: AppDesignSystem.headingMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        backgroundColor: AppDesignSystem.darkPrimary,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppDesignSystem.primary,
          labelColor: AppDesignSystem.textPrimary,
          unselectedLabelColor: AppDesignSystem.textSecondary,
          tabs: const [
            Tab(text: "Amici"),
            Tab(text: "Richieste"),
            Tab(text: "Cerca"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFriendsTab(), _buildRequestsTab(), _buildSearchTab()],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return StreamBuilder<List<Friend>>(
      stream: _friendshipService.getFriends(),
      builder: (context, snapshot) {        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppComponents.loadingIndicator();
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return AppComponents.emptyState(
            icon: Icons.person_off,
            title: 'Nessun amico',
            subtitle: 'Vai alla sezione "Cerca" per aggiungere amici',
            iconColor: AppDesignSystem.accent,
          );
        }        return ListView.builder(
          padding: const EdgeInsets.all(AppDesignSystem.paddingM),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return AppComponents.standardCard(
              margin: const EdgeInsets.only(bottom: AppDesignSystem.paddingS),
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppDesignSystem.primary,
                      child: Text(
                        friend.username.substring(0, 1).toUpperCase(),
                        style: AppDesignSystem.bodyMedium.copyWith(
                          color: AppDesignSystem.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          color: friend.isOnline ? AppDesignSystem.success : AppDesignSystem.textTertiary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppDesignSystem.cardBackground,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  friend.username,
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: friend.isOnline
                    ? Text(
                        'Online',
                        style: AppDesignSystem.bodySmall.copyWith(
                          color: AppDesignSystem.success,
                        ),
                      )
                    : friend.lastOnline != null
                        ? Text(
                            'Ultimo accesso: ${_formatLastSeen(friend.lastOnline!)}',
                            style: AppDesignSystem.bodySmall.copyWith(
                              color: AppDesignSystem.textSecondary,
                            ),
                          )
                        : null,
                trailing: null,
                onTap: () => _showFriendProfile(friend),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRequestsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(        children: [
          TabBar(
            labelColor: AppDesignSystem.textPrimary,
            unselectedLabelColor: AppDesignSystem.textSecondary,
            indicatorColor: AppDesignSystem.primary,
            tabs: const [Tab(text: "Ricevute"), Tab(text: "Inviate")],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildIncomingRequestsList(),
                _buildOutgoingRequestsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingRequestsList() {
    return StreamBuilder<List<FriendRequest>>(
      stream: _friendshipService.getIncomingFriendRequests(),
      builder: (context, snapshot) {        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppComponents.loadingIndicator();
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return AppComponents.emptyState(
            icon: Icons.mail,
            title: 'Nessuna richiesta di amicizia',
            subtitle: '',
            iconColor: AppDesignSystem.accent,
          );
        }        return ListView.builder(
          padding: const EdgeInsets.all(AppDesignSystem.paddingM),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return AppComponents.standardCard(
              margin: const EdgeInsets.only(bottom: AppDesignSystem.paddingS),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppDesignSystem.secondary,
                  child: Text(
                    request.fromUserName.substring(0, 1).toUpperCase(),
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  request.fromUserName,
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Vuole aggiungerti come amico',
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton(
                      icon: Icons.check,
                      color: AppDesignSystem.success,
                      onPressed: () => _respondToFriendRequest(
                        request.id,
                        FriendshipStatus.accepted,
                      ),
                      tooltip: 'Accetta',
                    ),
                    const SizedBox(width: AppDesignSystem.paddingXS),
                    _actionButton(
                      icon: Icons.close,
                      color: AppDesignSystem.error,
                      onPressed: () => _respondToFriendRequest(
                        request.id,
                        FriendshipStatus.rejected,
                      ),
                      tooltip: 'Rifiuta',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOutgoingRequestsList() {
    return StreamBuilder<List<FriendRequest>>(
      stream: _friendshipService.getOutgoingFriendRequests(),
      builder: (context, snapshot) {        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppComponents.loadingIndicator();
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return AppComponents.emptyState(
            icon: Icons.send,
            title: 'Nessuna richiesta inviata',
            subtitle: '',
            iconColor: AppDesignSystem.accent,
          );
        }        return ListView.builder(
          padding: const EdgeInsets.all(AppDesignSystem.paddingM),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return AppComponents.standardCard(
              margin: const EdgeInsets.only(bottom: AppDesignSystem.paddingS),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppDesignSystem.warning,
                  child: Text(
                    request.toUserName.substring(0, 1).toUpperCase(),
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  request.toUserName,
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'Richiesta in attesa',
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                trailing: Icon(
                  Icons.pending,
                  color: AppDesignSystem.warning,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(      children: [
        Padding(
          padding: const EdgeInsets.all(AppDesignSystem.paddingM),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textPrimary,
                  ),
                  decoration: AppDesignSystem.inputDecoration(
                    hintText: 'Cerca utenti',
                    prefixIcon: Icons.search,
                  ),
                  onSubmitted: (_) => _searchUsers(),
                ),
              ),
              const SizedBox(width: AppDesignSystem.paddingS),
              AppComponents.primaryButton(
                text: 'Cerca',
                onPressed: _searchUsers,
              ),
            ],
          ),
        ),        Expanded(
          child: _isSearching
              ? AppComponents.loadingIndicator()
              : _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? AppComponents.emptyState(
                      icon: Icons.search_off,
                      title: 'Nessun utente trovato',
                      subtitle: '',
                      iconColor: AppDesignSystem.textSecondary,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppDesignSystem.paddingM),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        return AppComponents.standardCard(
                          margin: const EdgeInsets.only(bottom: AppDesignSystem.paddingS),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppDesignSystem.accent,
                              child: Text(
                                (user['username'] as String)
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: AppDesignSystem.bodyMedium.copyWith(
                                  color: AppDesignSystem.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              user['username'],
                              style: AppDesignSystem.bodyMedium.copyWith(
                                color: AppDesignSystem.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              user['email'],
                              style: AppDesignSystem.bodySmall.copyWith(
                                color: AppDesignSystem.textSecondary,
                              ),
                            ),
                            trailing: AppComponents.iconButton(
                              icon: Icons.person_add,
                              onPressed: () => _sendFriendRequest(
                                user['id'],
                                user['username'],
                              ),
                              iconColor: AppDesignSystem.success,
                              tooltip: 'Aggiungi amico',
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
        tooltip: tooltip,
        constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
        padding: EdgeInsets.zero,
        iconSize: 20,
      ),
    );
  }

  Future<void> _respondToFriendRequest(
    String requestId,
    FriendshipStatus response,
  ) async {
    final success = await _friendshipService.respondToFriendRequest(
      requestId,
      response,
    );
    if (success) {
      final message =
          response == FriendshipStatus.accepted
              ? 'Richiesta di amicizia accettata'
              : 'Richiesta di amicizia rifiutata';

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  Future<void> _sendFriendRequest(String userId, String username) async {
    final success = await _friendshipService.sendFriendRequest(
      userId,
      username,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Richiesta di amicizia inviata')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossibile inviare la richiesta. Potrebbe essere già stata inviata.',
            ),
          ),
        );
      }
    }
  }  // Mostra un dialog con le opzioni per l'amico
  void _showFriendOptionsDialog(Friend friend) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppDesignSystem.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusL),
            ),
            title: Text(
              friend.username,
              style: AppDesignSystem.headingSmall.copyWith(
                color: AppDesignSystem.textPrimary,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: AppDesignSystem.primary),
                  title: Text(
                    'Visualizza profilo',
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showFriendProfile(friend);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.chat, color: AppDesignSystem.success),
                  title: Text(
                    'Invia messaggio',
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToChat(friend);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: AppDesignSystem.error),
                  title: Text(
                    'Rimuovi amico',
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showRemoveFriendDialog(friend);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppDesignSystem.primary,
                ),
                child: Text(
                  'Chiudi',
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.primary,
                  ),
                ),
              ),
            ],
          ),
    );
  }
  // Mostra il profilo dell'amico
  void _showFriendProfile(Friend friend) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: AppDesignSystem.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDesignSystem.paddingL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppDesignSystem.secondary,
                    child: Text(
                      friend.username.substring(0, 1).toUpperCase(),
                      style: AppDesignSystem.headingLarge.copyWith(
                        color: AppDesignSystem.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDesignSystem.paddingM),
                  Text(
                    friend.username,
                    style: AppDesignSystem.headingMedium.copyWith(
                      color: AppDesignSystem.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppDesignSystem.paddingS),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDesignSystem.paddingM,
                      vertical: AppDesignSystem.paddingS,
                    ),
                    decoration: BoxDecoration(
                      color: friend.isOnline ? AppDesignSystem.success : AppDesignSystem.textTertiary,
                      borderRadius: BorderRadius.circular(AppDesignSystem.radiusXL),
                    ),
                    child: Text(
                      friend.isOnline ? 'Online' : 'Offline',
                      style: AppDesignSystem.bodySmall.copyWith(
                        color: AppDesignSystem.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDesignSystem.paddingL),
                  Text(
                    'Amici da: ${_formatDateTime(friend.addedAt)}',
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppDesignSystem.paddingL),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppComponents.successButton(
                        text: 'Messaggio',
                        icon: Icons.chat,
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToChat(friend);
                        },
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Rimuovi'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showRemoveFriendDialog(friend);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppDesignSystem.error,
                          foregroundColor: AppDesignSystem.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDesignSystem.paddingM,
                            vertical: AppDesignSystem.paddingS,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // Naviga alla chat con l'amico
  void _navigateToChat(Friend friend) async {
    // Ottieni il servizio chat
    final chatService = ChatService();    // Mostra indicatore di caricamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: AppComponents.loadingIndicator());
      },
    );

    try {
      // Ottieni o crea l'ID della chat
      final chatId = await chatService.getChatId(friend.userId);

      // Chiudi l'indicatore di caricamento
      Navigator.pop(context);

      // Naviga alla pagina della chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ChatDetailPage(
                chatId: chatId,
                receiverId: friend.userId,
                receiverName: friend.username,
              ),
        ),
      );
    } catch (e) {
      // Chiudi l'indicatore di caricamento in caso di errore
      Navigator.pop(context);
      // Mostra un messaggio di errore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errore nell\'aprire la chat: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  // Mostra dialog di conferma per rimuovere un amico
  void _showRemoveFriendDialog(Friend friend) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppDesignSystem.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusL),
            ),
            title: Text(
              'Rimuovere amico?',
              style: AppDesignSystem.headingSmall.copyWith(
                color: AppDesignSystem.textPrimary,
              ),
            ),
            content: Text(
              'Sei sicuro di voler rimuovere ${friend.username} dalla tua lista amici?',
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: AppDesignSystem.textSecondary,
                ),
                child: Text(
                  'Annulla',
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppDesignSystem.error,
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  final success = await _friendshipService.removeFriend(
                    friend.id,
                    friend.userId,
                  );
                  if (success && mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${friend.username} rimosso dalla lista amici',
                          style: AppDesignSystem.bodyMedium.copyWith(
                            color: AppDesignSystem.textPrimary,
                          ),
                        ),
                        backgroundColor: AppDesignSystem.success,
                      ),
                    );
                  }
                },
                child: Text(
                  'Rimuovi',
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  // Formatta la data e ora per l'ultimo accesso
  String _formatLastSeen(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'adesso';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min fa';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ore fa';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} giorni fa';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  // Formatta una data per la visualizzazione
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
