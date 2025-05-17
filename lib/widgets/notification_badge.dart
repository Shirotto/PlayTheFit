import 'package:flutter/material.dart';
import '../services/friendship_service.dart';

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
  Widget build(BuildContext context) {
    return StreamBuilder<List<dynamic>>(
      stream: _friendshipService.getUnreadNotifications(),
      builder: (context, snapshot) {
        final hasUnread =
            snapshot.hasData && (snapshot.data?.isNotEmpty ?? false);
        final count = snapshot.data?.length ?? 0;

        return Stack(
          alignment: Alignment.topRight,
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: hasUnread && widget.onTap != null ? widget.onTap : null,
              child: widget.child,
            ),
            if (hasUnread)
              Positioned(
                right: widget.offset,
                top: widget.offset,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: widget.badgeColor,
                    shape: count > 9 ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: count > 9 ? BorderRadius.circular(7) : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.shade800.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
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
}
