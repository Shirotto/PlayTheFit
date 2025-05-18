import 'package:flutter/material.dart';
import '../services/friendship_service.dart';
import '../models/notification.dart';

class NotificationBadge extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double offset;
  final Color badgeColor;

  const NotificationBadge({
    super.key,
    required this.child,
    this.onTap,
    this.offset = 5.0,
    this.badgeColor = Colors.red,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  final FriendshipService _friendshipService = FriendshipService();
  @override
  void initState() {
    super.initState();
    // Verificare se ci sono notifiche non lette all'avvio
    _checkUnreadNotifications();
  }

  // Metodo per controllare se ci sono notifiche non lette
  void _checkUnreadNotifications() async {
    final notifications =
        await _friendshipService.getUnreadNotifications().first;
    if (notifications.isNotEmpty && mounted) {
      print('Ci sono ${notifications.length} notifiche non lette');
    }
  }

  // Restituisce il numero di notifiche non lette
  Future<int> getUnreadCount() async {
    final notifications =
        await _friendshipService.getUnreadNotifications().first;
    return notifications.length;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UserNotification>>(
      stream: _friendshipService.getUnreadNotifications(),
      builder: (context, snapshot) {
        final hasUnread =
            snapshot.hasData && (snapshot.data?.isNotEmpty ?? false);
        final count = snapshot.data?.length ?? 0;

        // Debug print per verificare la ricezione delle notifiche
        if (hasUnread) {
          print('Notifiche non lette: $count');
        }
        return Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(onTap: widget.onTap, child: widget.child),
            if (hasUnread)
              Positioned(
                right: widget.offset,
                top: widget.offset,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: widget.badgeColor,
                    shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: count > 9 ? BorderRadius.circular(7) : null,
                    boxShadow: [
                      BoxShadow(
                        color: widget.badgeColor.withOpacity(0.7),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  // Verifica se il badge è visibile o meno
  Future<bool> isBadgeVisible() async {
    final notifications =
        await _friendshipService.getUnreadNotifications().first;
    return notifications.isNotEmpty;
  }
}
