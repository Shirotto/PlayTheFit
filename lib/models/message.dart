import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      senderName: data['senderName'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] as bool? ?? false,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'senderName': senderName,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'imageUrl': imageUrl,
    };
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class Chat {
  final String id;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final DateTime lastMessageTime;
  final String? lastMessageContent;
  final String? lastMessageSenderId;
  final bool hasUnreadMessages;

  Chat({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    required this.lastMessageTime,
    this.lastMessageContent,
    this.lastMessageSenderId,
    this.hasUnreadMessages = false,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Converti la mappa di partecipanti
    final Map<String, dynamic> rawParticipants =
        data['participants'] as Map<String, dynamic>;
    final Map<String, String> participants = {};

    rawParticipants.forEach((key, value) {
      participants[key] = value.toString();
    });

    return Chat(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds']),
      participantNames: participants,
      lastMessageTime: (data['lastMessageTime'] as Timestamp).toDate(),
      lastMessageContent: data['lastMessageContent'] as String?,
      lastMessageSenderId: data['lastMessageSenderId'] as String?,
      hasUnreadMessages: data['hasUnreadMessages'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'participants': participantNames,
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'lastMessageContent': lastMessageContent,
      'lastMessageSenderId': lastMessageSenderId,
      'hasUnreadMessages': hasUnreadMessages,
    };
  }

  String getOtherParticipantName(String currentUserId) {
    final otherParticipantId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    return participantNames[otherParticipantId] ?? 'Utente sconosciuto';
  }

  String getOtherParticipantId(String currentUserId) {
    return participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );
  }
}
