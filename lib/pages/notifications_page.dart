import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/friendship_service.dart';
import '../models/friendship.dart';
import 'package:intl/intl.dart';
import 'amici_page.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

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
    // ma non le elimina
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Le notifiche verranno semplicemente segnate come lette
      _friendshipService.markAllNotificationsAsRead();
    });
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Notifiche',
          style: AppDesignSystem.headingMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        backgroundColor: AppDesignSystem.darkPrimary,
      ),      body: StreamBuilder<List<UserNotification>>(
        stream: _friendshipService.getAllNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return AppComponents.loadingIndicator();
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return AppComponents.emptyState(
              icon: Icons.notifications_off,
              title: 'Nessuna notifica',
              subtitle: 'Le tue notifiche appariranno qui',
              iconColor: AppDesignSystem.accent,
            );
          }          return ListView.builder(
            padding: const EdgeInsets.all(AppDesignSystem.paddingM),
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
    final formattedDate = _formatNotificationDate(notification.createdAt);    IconData notificationIcon;
    Color iconColor;
    switch (notification.type) {
      case NotificationType.friendRequest:
        notificationIcon = Icons.person_add;
        iconColor = AppDesignSystem.secondary;
        break;
      case NotificationType.friendAccepted:
        notificationIcon = Icons.people;
        iconColor = AppDesignSystem.success;
        break;
      case NotificationType.system:
        notificationIcon = Icons.notifications;
        iconColor = AppDesignSystem.warning;
        break;
    }

    return Dismissible(
      key: Key(notification.id),      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: AppDesignSystem.error,
        child: const Icon(Icons.delete, color: AppDesignSystem.textPrimary),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppDesignSystem.darkSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
            ),
            title: Text(
              'Eliminare notifica?',
              style: AppDesignSystem.headingSmall.copyWith(
                color: AppDesignSystem.textPrimary,
              ),
            ),
            content: Text(
              'Sei sicuro di voler eliminare questa notifica?',
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.textSecondary,
              ),
            ),            actions: [
              AppComponents.secondaryButton(
                text: 'Annulla',
                onPressed: () => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: AppDesignSystem.paddingS),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: AppDesignSystem.errorButtonStyle,
                child: Text(
                  'Elimina',
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _friendshipService.deleteNotification(notification.id);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Notifica eliminata')));      },
      child: AppComponents.standardCard(
        margin: const EdgeInsets.symmetric(
          vertical: AppDesignSystem.paddingXS,
          horizontal: 0,
        ),
        child: ListTile(
          onTap: notification.type == NotificationType.friendRequest
              ? () {
                  // Naviga alla pagina degli amici sulla tab delle richieste
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AmiciPage(initialTabIndex: 1),
                    ),
                  );
                }
              : null,
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDesignSystem.paddingS,
            horizontal: AppDesignSystem.paddingM,
          ),
          leading: CircleAvatar(
            backgroundColor: iconColor.withOpacity(0.2),
            child: Icon(notificationIcon, color: iconColor),
          ),
          title: Text(
            notification.message,
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.textPrimary,
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppDesignSystem.paddingXS),
            child: Text(
              formattedDate,
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.textTertiary,
              ),
            ),
          ),
          trailing: notification.type == NotificationType.friendRequest
              ? _buildFriendRequestActions(notification)
              : null,
        ),
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
          children: [            _actionButton(
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
        );
      },
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
