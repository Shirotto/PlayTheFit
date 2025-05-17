import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import 'notification_service.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Collezioni
  CollectionReference get _chatsCollection => _firestore.collection('chats');
  CollectionReference get _usersCollection => _firestore.collection('users');

  // Utente corrente
  User? get currentUser => _auth.currentUser;

  // Crea o ottieni una chat esistente tra due utenti
  Future<String> getChatId(String otherUserId) async {
    if (currentUser == null) throw Exception('Utente non autenticato');

    // Ordina gli ID per garantire che la chat abbia lo stesso ID indipendentemente da chi la inizia
    final List<String> participantIds = [currentUser!.uid, otherUserId];
    participantIds.sort(); // Per consistenza

    // Cerca chat esistente
    final querySnapshot =
        await _chatsCollection
            .where('participantIds', isEqualTo: participantIds)
            .limit(1)
            .get();

    // Se esiste già una chat, ritorna il suo ID
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.id;
    }

    // Altrimenti, crea una nuova chat
    final currentUserData = await _usersCollection.doc(currentUser!.uid).get();
    final otherUserData = await _usersCollection.doc(otherUserId).get();

    final currentUserName =
        (currentUserData.data() as Map<String, dynamic>)['username'] ??
        'Utente';
    final otherUserName =
        (otherUserData.data() as Map<String, dynamic>)['username'] ?? 'Utente';

    final chatRef = await _chatsCollection.add({
      'participantIds': participantIds,
      'participants': {
        currentUser!.uid: currentUserName,
        otherUserId: otherUserName,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessageTime': FieldValue.serverTimestamp(),
      'hasUnreadMessages': false,
    });

    return chatRef.id;
  }

  // Invia un messaggio
  Future<void> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    String? imageUrl,
  }) async {
    if (currentUser == null) throw Exception('Utente non autenticato');

    // Ottieni il nome del mittente
    final currentUserDoc = await _usersCollection.doc(currentUser!.uid).get();
    final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;
    final senderName = currentUserData?['username'] ?? 'Utente';

    // Crea il messaggio
    final message = Message(
      id: '',
      senderId: currentUser!.uid,
      receiverId: receiverId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
      isRead: false,
      imageUrl: imageUrl,
    );

    // Salva il messaggio nella collezione annidiata all'interno della chat
    await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .add(message.toMap());

    // Aggiorna i metadati della chat
    await _chatsCollection.doc(chatId).update({
      'lastMessageContent': content,
      'lastMessageSenderId': currentUser!.uid,
      'lastMessageTime': Timestamp.fromDate(DateTime.now()),
      'hasUnreadMessages': true,
    });

    // Invia una notifica push al destinatario
    await _notificationService.sendNotificationToUser(
      userId: receiverId,
      title: senderName,
      body: content,
      data: {
        'type': 'chatMessage',
        'chatId': chatId,
        'senderId': currentUser!.uid,
        'senderName': senderName,
      },
    );
  }

  // Segna tutti i messaggi di una chat come letti
  Future<void> markChatAsRead(String chatId) async {
    if (currentUser == null) throw Exception('Utente non autenticato');

    // Ottieni tutti i messaggi non letti inviati all'utente corrente
    final unreadMessages =
        await _chatsCollection
            .doc(chatId)
            .collection('messages')
            .where('receiverId', isEqualTo: currentUser!.uid)
            .where('isRead', isEqualTo: false)
            .get();

    // Aggiorna ogni messaggio come letto
    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Aggiorna lo stato della chat
    batch.update(_chatsCollection.doc(chatId), {'hasUnreadMessages': false});

    // Esegui le operazioni in batch
    await batch.commit();
  }

  // Ottieni la lista delle chat dell'utente
  Stream<List<Chat>> getUserChats() {
    if (currentUser == null) return Stream.value([]);

    return _chatsCollection
        .where('participantIds', arrayContains: currentUser!.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();
        });
  }

  // Ottieni i messaggi di una chat
  Stream<List<Message>> getChatMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Message.fromFirestore(doc))
              .toList();
        });
  }

  // Elimina un messaggio
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}
