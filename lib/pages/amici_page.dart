import 'package:flutter/material.dart';
import '../models/friendship.dart';
import '../services/friendship_service.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Amici'),
        backgroundColor: Colors.purple.shade800,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Amici"),
            Tab(text: "Richieste"),
            Tab(text: "Cerca"),
          ],
        ),
      ),
      backgroundColor: Colors.black87,
      body: TabBarView(
        controller: _tabController,
        children: [_buildFriendsTab(), _buildRequestsTab(), _buildSearchTab()],
      ),
    );
  }

  Widget _buildFriendsTab() {
    return StreamBuilder<List<Friend>>(
      stream: _friendshipService.getFriends(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final friends = snapshot.data ?? [];

        if (friends.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_off,
                  size: 80,
                  color: Colors.purple.shade200.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nessun amico',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Vai alla sezione "Cerca" per aggiungere amici',
                  style: TextStyle(fontSize: 14, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: friends.length,
          itemBuilder: (context, index) {
            final friend = friends[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.grey.shade900,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 2,
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.purple.shade400,
                      child: Text(
                        friend.username.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
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
                          color: friend.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade900,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Text(
                  friend.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle:
                    friend.isOnline
                        ? const Text(
                          'Online',
                          style: TextStyle(color: Colors.green),
                        )
                        : friend.lastOnline != null
                        ? Text(
                          'Ultimo accesso: ${_formatLastSeen(friend.lastOnline!)}',
                          style: const TextStyle(color: Colors.grey),
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
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white60,
            indicatorColor: Colors.purple.shade300,
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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail,
                  size: 80,
                  color: Colors.purple.shade200.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nessuna richiesta di amicizia',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.grey.shade900,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade400,
                  child: Text(
                    request.fromUserName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  request.fromUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Vuole aggiungerti come amico',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _actionButton(
                      icon: Icons.check,
                      color: Colors.green,
                      onPressed:
                          () => _respondToFriendRequest(
                            request.id,
                            FriendshipStatus.accepted,
                          ),
                      tooltip: 'Accetta',
                    ),
                    const SizedBox(width: 8),
                    _actionButton(
                      icon: Icons.close,
                      color: Colors.red,
                      onPressed:
                          () => _respondToFriendRequest(
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
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send,
                  size: 80,
                  color: Colors.purple.shade200.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nessuna richiesta inviata',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.grey.shade900,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 2,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.shade400,
                  child: Text(
                    request.toUserName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  request.toUserName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'Richiesta in attesa',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.pending, color: Colors.amber),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Cerca utenti',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.grey[800],
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (_) => _searchUsers(),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _searchUsers,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('Cerca'),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? const Center(
                    child: Text(
                      'Nessun utente trovato',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: Colors.grey.shade900,
                        margin: const EdgeInsets.symmetric(
                          vertical: 6,
                          horizontal: 4,
                        ),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.shade400,
                            child: Text(
                              (user['username'] as String)
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            user['username'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            user['email'],
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.person_add,
                              color: Colors.green,
                            ),
                            onPressed:
                                () => _sendFriendRequest(
                                  user['id'],
                                  user['username'],
                                ),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
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
  }

  // Mostra un dialog con le opzioni per l'amico
  void _showFriendOptionsDialog(Friend friend) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey.shade900,
            title: Text(
              friend.username,
              style: const TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: const Text(
                    'Visualizza profilo',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showFriendProfile(friend);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat, color: Colors.green),
                  title: const Text(
                    'Invia messaggio',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _navigateToChat(friend);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Rimuovi amico',
                    style: TextStyle(color: Colors.white),
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
                child: const Text('Chiudi'),
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
            backgroundColor: Colors.grey.shade900,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.purple.shade400,
                    child: Text(
                      friend.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    friend.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: friend.isOnline ? Colors.green : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      friend.isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Amici da: ${_formatDateTime(friend.addedAt)}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.chat),
                        label: const Text('Messaggio'),
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToChat(friend);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Rimuovi'),
                        onPressed: () {
                          Navigator.pop(context);
                          _showRemoveFriendDialog(friend);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
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
    final chatService = ChatService();

    // Mostra indicatore di caricamento
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
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
            backgroundColor: Colors.grey.shade900,
            title: const Text(
              'Rimuovere amico?',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Sei sicuro di voler rimuovere ${friend.username} dalla tua lista amici?',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annulla'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
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
                        ),
                      ),
                    );
                  }
                },
                child: const Text('Rimuovi'),
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
