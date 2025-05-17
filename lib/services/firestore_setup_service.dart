import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';
import '../models/friendship.dart';

class FirestoreSetupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Funzione per inizializzare Firestore con la struttura richiesta per il sistema di amicizie
  Future<void> setupFirestoreCollections() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Crea il documento utente se non esiste
      final userDoc = _firestore.collection('users').doc(currentUser.uid);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        await userDoc.set({
          'email': currentUser.email ?? '',
          'username': currentUser.email?.split('@').first ?? 'User',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Crea le sottocollezioni iniziali
        await userDoc.collection('friends').doc('placeholder').set({
          'placeholder': true,
          'createdAt': FieldValue.serverTimestamp(),
        });

        print(
          'Created user document and initial collections for ${currentUser.email}',
        );
      }

      // Crea le collezioni globali se non esistono
      final friendRequestsCollection = _firestore.collection('friendRequests');
      final notificationsCollection = _firestore.collection('notifications');

      // Aggiungiamo un documento placeholder se necessario
      final requestsSnapshot = await friendRequestsCollection.limit(1).get();
      if (requestsSnapshot.docs.isEmpty) {
        await friendRequestsCollection.doc('placeholder').set({
          'placeholder': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Aggiungiamo un documento placeholder se necessario
      final notificationsSnapshot =
          await notificationsCollection.limit(1).get();
      if (notificationsSnapshot.docs.isEmpty) {
        await notificationsCollection.doc('placeholder').set({
          'placeholder': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      print('Firestore setup completed successfully');
    } catch (e) {
      print('Error during Firestore setup: $e');
    }
  }

  // Funzione per creare indici necessari (di solito questo viene fatto automaticamente)
  Future<void> createRequiredIndexes() async {
    try {
      // Gli indici vengono creati automaticamente quando eseguiamo query composte
      // ma possiamo suggerire all'utente di controllare la console Firebase se ci sono problemi
      print(
        'Se vedi errori di indici mancanti, segui il link fornito nell\'errore per crearli nella Firebase Console',
      );
    } catch (e) {
      print('Error during index setup: $e');
    }
  }

  // Funzione per creare alcuni utenti di esempio per i test
  Future<void> createSampleUsers() async {
    try {
      final usersCollection = _firestore.collection('users');

      // Aggiungi alcuni utenti di esempio (solo se non esistono già)
      final List<Map<String, dynamic>> sampleUsers = [
        {
          'id': 'sample1',
          'username': 'MarioRossi',
          'email': 'mario.rossi@example.com',
        },
        {
          'id': 'sample2',
          'username': 'LuigiBianchi',
          'email': 'luigi.bianchi@example.com',
        },
        {
          'id': 'sample3',
          'username': 'GiuliaVerdi',
          'email': 'giulia.verdi@example.com',
        },
        {
          'id': 'sample4',
          'username': 'SaraNeri',
          'email': 'sara.neri@example.com',
        },
      ];

      for (var user in sampleUsers) {
        final docRef = usersCollection.doc(user['id']);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'username': user['username'],
            'email': user['email'],
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Crea le sottocollezioni iniziali
          await docRef.collection('friends').doc('placeholder').set({
            'placeholder': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }

      print('Sample users created successfully');
    } catch (e) {
      print('Error creating sample users: $e');
    }
  }

  // Funzione per migrare da un modello di dati vecchio a quello nuovo
  Future<void> migrateOldFriendships() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Ottieni gli amici dal vecchio formato (in base al tuo vecchio schema)
      final oldFriendsQuery =
          _firestore
              .collection('users')
              .doc(currentUser.uid)
              .collection('friends')
              .get();

      final oldFriendsSnapshot = await oldFriendsQuery;

      // Migra ogni vecchia amicizia al nuovo formato
      for (var doc in oldFriendsSnapshot.docs) {
        // Salta il placeholder
        if (doc.id == 'placeholder') continue;

        final data = doc.data();
        final email = data['email']; // il campo che usavi prima

        if (email != null) {
          // Cerca l'utente con questa email
          final userQuery =
              await _firestore
                  .collection('users')
                  .where('email', isEqualTo: email)
                  .limit(1)
                  .get();

          if (userQuery.docs.isNotEmpty) {
            final friendUser = userQuery.docs.first;

            // Crea una nuova amicizia con il nuovo formato
            await _firestore
                .collection('users')
                .doc(currentUser.uid)
                .collection('friends')
                .add({
                  'userId': friendUser.id,
                  'username':
                      friendUser.data()['username'] ?? email.split('@').first,
                  'addedAt': FieldValue.serverTimestamp(),
                });

            // Elimina il vecchio documento
            await doc.reference.delete();
          }
        }
      }

      print('Migration of old friendships completed');
    } catch (e) {
      print('Error during migration: $e');
    }
  }

  // Inizializza tutto in un solo metodo
  Future<void> initializeSystem() async {
    await setupFirestoreCollections();
    await createRequiredIndexes();
    await createSampleUsers();
    await migrateOldFriendships();

    print('Friendship system initialization complete');
  }
}
