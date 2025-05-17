import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ottieni l'utente attualmente autenticato
  User? get currentUser => _auth.currentUser;

  // Stream per monitorare i cambiamenti di autenticazione
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Registrazione con email e password
  Future<UserCredential> registerWithEmailAndPassword({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      // Controlla se l'username è già utilizzato
      final usernameCheck =
          await _firestore
              .collection('users')
              .where('username', isEqualTo: username)
              .get();

      if (usernameCheck.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'username-already-in-use',
          message: 'Questo username è già utilizzato. Scegline un altro.',
        );
      }

      // Crea l'utente con email e password
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Salva i dati dell'utente nel Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isOnline': true,
        'lastOnline': FieldValue.serverTimestamp(),
      });

      return userCredential;
    } catch (e) {
      rethrow;
    }
  } // Login solo con username

  Future<UserCredential> loginWithUsernameOrEmail({
    required String usernameOrEmail,
    required String password,
  }) async {
    // Cerca l'utente tramite username
    QuerySnapshot userQuery =
        await _firestore
            .collection('users')
            .where('username', isEqualTo: usernameOrEmail)
            .limit(1)
            .get();

    if (userQuery.docs.isEmpty) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Nessun utente trovato con questo username.',
      );
    }

    // Ottieni l'email dal documento trovato
    String email = userQuery.docs.first.get('email');

    // Effettua il login con email e password
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Logout
  Future<void> signOut() async {
    // Prima aggiorna lo stato online dell'utente
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'isOnline': false,
        'lastOnline': FieldValue.serverTimestamp(),
      });
    }

    await _auth.signOut();
  }

  // Aggiorna lo stato online dell'utente
  Future<void> updateOnlineStatus({required bool isOnline}) async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'isOnline': isOnline,
        'lastOnline':
            isOnline
                ? FieldValue.serverTimestamp()
                : FieldValue.serverTimestamp(),
      });
    }
  }

  // Ottieni i dati dell'utente corrente dal Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    if (currentUser == null) return null;

    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser!.uid).get();

    return userDoc.exists ? userDoc.data() as Map<String, dynamic> : null;
  }
}
