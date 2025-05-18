import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import '../models/friendship.dart';
import 'notification_service.dart';

class FriendshipService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  // Collezioni
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _friendRequestsCollection =>
      _firestore.collection('friendRequests');
  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');

  // Utente corrente
  User? get currentUser => _auth.currentUser;

  // Ricerca un utente per username
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final result =
          await _usersCollection
              .where('username', isGreaterThanOrEqualTo: query)
              .where('username', isLessThanOrEqualTo: query + '\uf8ff')
              .limit(10)
              .get();

      return result.docs
          .where(
            (doc) => doc.id != currentUser?.uid,
          ) // Esclude l'utente corrente
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return {
              'id': doc.id,
              'username': data['username'] ?? 'Utente',
              'email': data['email'] ?? '',
            };
          })
          .toList();
    } catch (e) {
      print('Errore nella ricerca degli utenti: $e');
      return [];
    }
  }

  // Invia richiesta di amicizia
  Future<bool> sendFriendRequest(
    String targetUserId,
    String targetUsername,
  ) async {
    try {
      if (currentUser == null) return false;

      // Verifica se esiste già una richiesta pendente
      final existingRequest =
          await _friendRequestsCollection
              .where('fromUserId', isEqualTo: currentUser!.uid)
              .where('toUserId', isEqualTo: targetUserId)
              .where('status', isEqualTo: 'pending')
              .get();

      if (existingRequest.docs.isNotEmpty) {
        return false; // Richiesta già inviata
      }

      // Verifica se sono già amici (controllo reciproco)
      final alreadyFriends =
          await _usersCollection
              .doc(currentUser!.uid)
              .collection('friends')
              .where('userId', isEqualTo: targetUserId)
              .get();

      if (alreadyFriends.docs.isNotEmpty) {
        return false; // Sono già amici
      }

      // Ottiene il nome dell'utente corrente
      final currentUserDoc = await _usersCollection.doc(currentUser!.uid).get();
      final currentUserData = currentUserDoc.data() as Map<String, dynamic>?;
      final currentUsername = currentUserData?['username'] ?? 'Utente';

      // Crea una nuova richiesta di amicizia
      final friendRequest = FriendRequest(
        id: '', // Verrà impostato da Firestore
        fromUserId: currentUser!.uid,
        fromUserName: currentUsername,
        toUserId: targetUserId,
        toUserName: targetUsername,
        status: FriendshipStatus.pending,
        createdAt: DateTime.now(),
      );

      // Salva la richiesta
      final docRef = await _friendRequestsCollection.add(friendRequest.toMap());

      // Crea una notifica per il destinatario
      final notification = UserNotification(
        id: '', // Verrà impostato da Firestore
        fromUserId: currentUser!.uid,
        fromUserName: currentUsername,
        toUserId: targetUserId,
        message: '$currentUsername ti ha inviato una richiesta di amicizia',
        type: NotificationType.friendRequest,
        createdAt: DateTime.now(),
      );
      await _notificationsCollection.add(notification.toMap());

      // Invia una notifica push all'utente destinatario
      await _notificationService.sendNotificationToUser(
        userId: targetUserId,
        title: 'Nuova richiesta di amicizia',
        body: '$currentUsername ti ha inviato una richiesta di amicizia',
        data: {
          'type': 'friendRequest',
          'fromUserId': currentUser!.uid,
          'fromUserName': currentUsername,
          'requestId': docRef.id,
        },
      );

      return true;
    } catch (e) {
      print('Errore nell\'invio della richiesta di amicizia: $e');
      return false;
    }
  }

  // Gestisce la risposta alla richiesta di amicizia
  Future<bool> respondToFriendRequest(
    String requestId,
    FriendshipStatus response,
  ) async {
    try {
      if (currentUser == null) return false;

      // Ottiene la richiesta
      final docRef = _friendRequestsCollection.doc(requestId);
      final docSnap = await docRef.get();

      if (!docSnap.exists) return false;

      final request = FriendRequest.fromFirestore(
        docSnap as DocumentSnapshot<Map<String, dynamic>>,
      );

      // Aggiorna lo stato della richiesta
      await docRef.update({
        'status': response.toString().split('.').last,
        'respondedAt': Timestamp.now(),
      });

      // Se la richiesta è accettata, aggiunge entrambi gli utenti come amici
      if (response == FriendshipStatus.accepted) {
        // Aggiunge l'utente mittente agli amici del destinatario
        await _usersCollection
            .doc(currentUser!.uid)
            .collection('friends')
            .add(
              Friend(
                id: '',
                userId: request.fromUserId,
                username: request.fromUserName,
                addedAt: DateTime.now(),
              ).toMap(),
            );

        // Aggiunge l'utente destinatario agli amici del mittente
        await _usersCollection
            .doc(request.fromUserId)
            .collection('friends')
            .add(
              Friend(
                id: '',
                userId: currentUser!.uid,
                username: request.toUserName,
                addedAt: DateTime.now(),
              ).toMap(),
            );

        // Invia una notifica al mittente della richiesta
        final notification = UserNotification(
          id: '',
          fromUserId: currentUser!.uid,
          fromUserName: request.toUserName,
          toUserId: request.fromUserId,
          message:
              '${request.toUserName} ha accettato la tua richiesta di amicizia',
          type: NotificationType.friendAccepted,
          createdAt: DateTime.now(),
        );
        await _notificationsCollection.add(notification.toMap());

        // Invia una notifica push all'utente mittente della richiesta
        await _notificationService.sendNotificationToUser(
          userId: request.fromUserId,
          title: 'Richiesta di amicizia accettata',
          body:
              '${request.toUserName} ha accettato la tua richiesta di amicizia',
          data: {
            'type': 'friendAccepted',
            'fromUserId': currentUser!.uid,
            'fromUserName': request.toUserName,
          },
        );
      }

      return true;
    } catch (e) {
      print('Errore nella gestione della richiesta di amicizia: $e');
      return false;
    }
  }

  // Ottiene la lista degli amici con lo stato online
  Stream<List<Friend>> getFriends() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _usersCollection
        .doc(currentUser!.uid)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
          final friends = <Friend>[];

          for (var doc in snapshot.docs) {
            Friend friend;
            try {
              friend = Friend.fromFirestore(
                doc as DocumentSnapshot<Map<String, dynamic>>,
              );
            } catch (e) {
              // Se c'è un errore nel formato, crea un Friend con i dati di base
              final data = doc.data() as Map<String, dynamic>;
              friend = Friend(
                id: doc.id,
                userId: data['userId'] as String? ?? '',
                username: data['username'] as String? ?? 'Utente',
                addedAt:
                    data['addedAt'] != null
                        ? (data['addedAt'] as Timestamp).toDate()
                        : DateTime.now(),
              );
              print(
                'Recuperato amico con formato alternativo: ${friend.username}',
              );
            }

            // Ottieni le informazioni sullo stato online dell'amico
            try {
              final userDoc = await _usersCollection.doc(friend.userId).get();
              if (userDoc.exists) {
                final userData = userDoc.data() as Map<String, dynamic>?;
                if (userData != null) {
                  friend.isOnline = userData['isOnline'] as bool? ?? false;
                  final lastOnlineTimestamp =
                      userData['lastOnline'] as Timestamp?;
                  if (lastOnlineTimestamp != null) {
                    friend.lastOnline = lastOnlineTimestamp.toDate();
                  }
                }
              }
            } catch (e) {
              // Ignora errori nella lettura dello stato online
              print('Errore nel recuperare lo stato online: $e');
            }

            friends.add(friend);
          }

          return friends;
        });
  }

  // Ottiene le richieste di amicizia in entrata pendenti
  Stream<List<FriendRequest>> getIncomingFriendRequests() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _friendRequestsCollection
        .where('toUserId', isEqualTo: currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FriendRequest.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();
        });
  }

  // Ottiene le richieste di amicizia in uscita pendenti
  Stream<List<FriendRequest>> getOutgoingFriendRequests() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _friendRequestsCollection
        .where('fromUserId', isEqualTo: currentUser!.uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => FriendRequest.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();
        });
  }

  // Ottiene le notifiche non lette
  Stream<List<UserNotification>> getUnreadNotifications() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _notificationsCollection
        .where('toUserId', isEqualTo: currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => UserNotification.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();
        });
  }

  // Ottiene tutte le notifiche
  Stream<List<UserNotification>> getAllNotifications() {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _notificationsCollection
        .where('toUserId', isEqualTo: currentUser!.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => UserNotification.fromFirestore(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();
        });
  }

  // Segna una notifica come letta
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Errore nel segnare la notifica come letta: $e');
    }
  }

  // Segna tutte le notifiche come lette
  Future<void> markAllNotificationsAsRead() async {
    try {
      if (currentUser == null) return;

      final batch = _firestore.batch();
      final notifications =
          await _notificationsCollection
              .where('toUserId', isEqualTo: currentUser!.uid)
              .where('isRead', isEqualTo: false)
              .get();

      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      print('Errore nel segnare tutte le notifiche come lette: $e');
    }
  }

  // Rimuove un amico
  Future<bool> removeFriend(String friendId, String friendUserId) async {
    try {
      if (currentUser == null) return false;

      // Elimina l'amico dall'utente corrente
      await _usersCollection
          .doc(currentUser!.uid)
          .collection('friends')
          .doc(friendId)
          .delete();

      // Cerca l'ID del documento dell'amicizia reciproca
      final reciprocalFriendQuery =
          await _usersCollection
              .doc(friendUserId)
              .collection('friends')
              .where('userId', isEqualTo: currentUser!.uid)
              .get();

      // Elimina l'utente corrente dagli amici dell'altro utente
      if (reciprocalFriendQuery.docs.isNotEmpty) {
        await _usersCollection
            .doc(friendUserId)
            .collection('friends')
            .doc(reciprocalFriendQuery.docs.first.id)
            .delete();
      }

      return true;
    } catch (e) {
      print('Errore nella rimozione dell\'amico: $e');
      return false;
    }
  }

  // Elimina una notifica
  Future<bool> deleteNotification(String notificationId) async {
    try {
      if (currentUser == null) return false;

      await _notificationsCollection.doc(notificationId).delete();
      return true;
    } catch (e) {
      print('Errore nell\'eliminare la notifica: $e');
      return false;
    }
  }
}
