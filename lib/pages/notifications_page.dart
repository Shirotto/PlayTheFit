import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/friendship_service.dart';
import '../models/friendship.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final FriendshipService _friendshipService = FriendshipService();

  @override
  void initState() {
    super.initState();
    // Segna tutte le notifiche come lette quando la pagina viene aperta
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _friendshipService.markAllNotificationsAsRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifiche'),
        backgroundColor: Colors.purple.shade800,
      ),
      backgroundColor: Colors.black87,
      body: StreamBuilder<List<UserNotification>>(
        stream: _friendshipService.getAllNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 80,
                    color: Colors.purple.shade200.withOpacity(0.7),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Nessuna notifica',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Le tue notifiche appariranno qui',
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationItem(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(UserNotification notification) {
    final formattedDate = _formatNotificationDate(notification.createdAt);

    IconData notificationIcon;
    Color iconColor;
    switch (notification.type) {
      case NotificationType.friendRequest:
        notificationIcon = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case NotificationType.friendAccepted:
        notificationIcon = Icons.people;
        iconColor = Colors.green;
        break;
      case NotificationType.system:
        notificationIcon = Icons.notifications;
        iconColor = Colors.amber;
        break;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.grey.shade900,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(notificationIcon, color: iconColor),
        ),
        title: Text(
          notification.message,
          style: TextStyle(
            color: Colors.white,
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            formattedDate,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
        trailing:
            notification.type == NotificationType.friendRequest
                ? _buildFriendRequestActions(notification)
                : null,
      ),
    );
  }

  Widget _buildFriendRequestActions(UserNotification notification) {
    return StreamBuilder<List<FriendRequest>>(
      stream: _friendshipService.getIncomingFriendRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        // Cerca la richiesta di amicizia corrispondente a questa notifica
        final request = snapshot.data?.firstWhere(
          (r) =>
              r.fromUserId == notification.fromUserId &&
              r.status == FriendshipStatus.pending,
          orElse:
              () => FriendRequest(
                id: '',
                fromUserId: '',
                fromUserName: '',
                toUserId: '',
                toUserName: '',
                status: FriendshipStatus.rejected,
                createdAt: DateTime.now(),
              ),
        );

        // Se la richiesta non è più valida o pendente, non mostra i pulsanti
        if (request!.id.isEmpty || request.status != FriendshipStatus.pending) {
          return const SizedBox.shrink();
        }

        return Row(
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
        );
      },
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

  String _formatNotificationDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      // Oggi
      return 'Oggi, ${DateFormat.Hm().format(date)}';
    } else if (difference.inDays == 1) {
      // Ieri
      return 'Ieri, ${DateFormat.Hm().format(date)}';
    } else if (difference.inDays < 7) {
      // Questa settimana
      return DateFormat('EEEE, HH:mm', 'it_IT').format(date);
    } else {
      // Altro
      return DateFormat('d MMM, HH:mm', 'it_IT').format(date);
    }
  }
}
