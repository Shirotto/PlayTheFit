import 'package:cloud_firestore/cloud_firestore.dart';

enum FriendshipStatus { pending, accepted, rejected }

class FriendRequest {
  final String id;
  final String fromUserId;
  final String fromUserName;
  final String toUserId;
  final String toUserName;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime? respondedAt;

  FriendRequest({
    required this.id,
    required this.fromUserId,
    required this.fromUserName,
    required this.toUserId,
    required this.toUserName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory FriendRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FriendRequest(
      id: doc.id,
      fromUserId: data['fromUserId'] as String,
      fromUserName: data['fromUserName'] as String,
      toUserId: data['toUserId'] as String,
      toUserName: data['toUserName'] as String,
      status: FriendshipStatus.values.firstWhere(
        (e) => e.toString() == 'FriendshipStatus.${data['status']}',
        orElse: () => FriendshipStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt:
          data['respondedAt'] != null
              ? (data['respondedAt'] as Timestamp).toDate()
              : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'toUserId': toUserId,
      'toUserName': toUserName,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };

    if (respondedAt != null) {
      map['respondedAt'] = Timestamp.fromDate(respondedAt!);
    }

    return map;
  }

  FriendRequest copyWith({
    String? id,
    String? fromUserId,
    String? fromUserName,
    String? toUserId,
    String? toUserName,
    FriendshipStatus? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return FriendRequest(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      fromUserName: fromUserName ?? this.fromUserName,
      toUserId: toUserId ?? this.toUserId,
      toUserName: toUserName ?? this.toUserName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

class Friend {
  final String id;
  final String userId;
  final String username;
  final DateTime addedAt;
  bool isOnline;
  DateTime? lastOnline;

  Friend({
    required this.id,
    required this.userId,
    required this.username,
    required this.addedAt,
    this.isOnline = false,
    this.lastOnline,
  });
  factory Friend.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Friend(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      username: data['username'] as String? ?? 'Utente',
      addedAt:
          data['addedAt'] != null
              ? (data['addedAt'] as Timestamp).toDate()
              : DateTime.now(),
      isOnline: false, // Lo stato online verrà aggiornato separatamente
      lastOnline: null, // Lo stato online verrà aggiornato separatamente
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
