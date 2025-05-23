import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/notification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Canali di notifica
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'Notifiche Importanti',
    description: 'Questo canale è utilizzato per notifiche importanti',
    importance: Importance.high,
  );

  // Funzione per inizializzare il servizio di notifiche
  Future<void> init() async {
    // Richiedi il permesso per le notifiche
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('Stato autorizzazione FCM: ${settings.authorizationStatus}');

    // Configurazione Android
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    // Configurazione iOS
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Inizializza le notifiche locali
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Gestione dei messaggi in background
    FirebaseMessaging.onBackgroundMessage(
      _firebaseMessagingBackgroundHandler,
    ); // Gestione delle notifiche quando l'app è in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Salva il token FCM nel database
    await _saveTokenToDatabase();

    // Ascolta gli aggiornamenti del token
    _messaging.onTokenRefresh.listen((String token) {
      _saveTokenToDatabase();
    });
  }

  // Gestisce il tap sulla notifica
  void _handleNotificationTap(NotificationResponse response) {
    // Qui possiamo implementare la navigazione verso la pagina appropriata
    // in base ai dati della notifica
    debugPrint('Notifica tappata: ${response.payload}');
  }

  // Gestisce i messaggi quando l'app è in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint(
      'Ricevuta notifica in foreground: ${message.notification?.title}',
    );

    // Mostra la notifica locale
    if (message.notification != null) {
      await _flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification?.title ?? 'Nuova notifica',
        message.notification?.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }

    // Se la notifica è una richiesta di amicizia, salvala nel database
    if (message.data['type'] == 'friendRequest' ||
        message.data['type'] == 'friendAccepted') {
      _saveNotificationToDatabase(message);
    }
  }

  // Salva la notifica nel database
  Future<void> _saveNotificationToDatabase(RemoteMessage message) async {
    try {
      if (_auth.currentUser == null) return;

      NotificationType type;
      if (message.data['type'] == 'friendRequest') {
        type = NotificationType.friendRequest;
      } else if (message.data['type'] == 'friendAccepted') {
        type = NotificationType.friendAccepted;
      } else {
        type = NotificationType.system;
      }

      final notification = UserNotification(
        id: '',
        fromUserId: message.data['fromUserId'] ?? '',
        fromUserName: message.data['fromUserName'] ?? '',
        toUserId: _auth.currentUser!.uid,
        message: message.notification?.body ?? '',
        type: type,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      debugPrint('Errore nel salvare la notifica: $e');
    }
  }

  // Salva il token FCM nel database
  Future<void> _saveTokenToDatabase() async {
    if (_auth.currentUser == null) return;

    try {
      // Ottieni il token FCM
      String? token = await _messaging.getToken();

      if (token != null) {
        // Salva il token nel documento dell'utente
        await _firestore.collection('users').doc(_auth.currentUser!.uid).update(
          {'fcmToken': token, 'tokenUpdatedAt': FieldValue.serverTimestamp()},
        );

        debugPrint('Token FCM salvato: $token');
      }
    } catch (e) {
      debugPrint('Errore nel salvare il token FCM: $e');
    }
  }

  // Invia una notifica ad un utente specifico
  Future<void> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    try {
      // Ottieni il token FCM dell'utente
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData != null && userData.containsKey('fcmToken')) {
        final token = userData['fcmToken'] as String?;

        if (token != null) {
          // Invia la notifica tramite Cloud Functions (da implementare)
          // In un'implementazione reale, dovresti usare Firebase Cloud Functions
          // o il tuo server per inviare la notifica
          debugPrint('Notifica da inviare a $userId con token: $token');
          debugPrint('Titolo: $title, Corpo: $body, Dati: $data');

          // Qui in realtà dovresti chiamare un'API del server
          // che utilizza FCM per inviare la notifica
        }
      }
    } catch (e) {
      debugPrint('Errore nell\'invio della notifica: $e');
    }
  }

  // Mostra una notifica di level up all'utente
  Future<void> showLevelUpNotification({
    required int newLevel,
    required List<String> rewards,
  }) async {
    // Titolo della notifica
    final title = '🎉 Livello $newLevel Sbloccato!';

    // Corpo della notifica con le ricompense
    String body = 'Hai raggiunto il livello $newLevel! ';
    if (rewards.isNotEmpty) {
      body += 'Ricompense sbloccate:\n${rewards.join('\n')}';
    } else {
      body += 'Continua così!';
    }

    // Mostra una notifica locale
    await _flutterLocalNotificationsPlugin.show(
      newLevel.hashCode, // ID unico basato sul livello
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
          color: const Color.fromARGB(255, 33, 150, 243), // Blu tema app
          styleInformation: BigTextStyleInformation(body),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: 'levelUp_$newLevel',
    );

    // Salva la notifica nel database per visualizzarla nella pagina notifiche
    _saveSystemNotificationToDatabase(title, body);
  }

  // Salva una notifica di sistema nel database
  Future<void> _saveSystemNotificationToDatabase(
    String title,
    String body,
  ) async {
    if (_auth.currentUser == null) return;

    try {
      final notification = UserNotification(
        id: '',
        fromUserId: 'system',
        fromUserName: 'PlayTheFit',
        toUserId: _auth.currentUser!.uid,
        message: '$title\n$body', // Include title in the message
        type: NotificationType.system,
        createdAt: DateTime.now(),
        isRead: false,
      );

      await _firestore.collection('notifications').add(notification.toMap());
    } catch (e) {
      debugPrint('Errore nel salvare la notifica di sistema: $e');
    }
  }
}

// Gestisce i messaggi quando l'app è in background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // È necessario inizializzare Firebase prima di utilizzarlo
  // await Firebase.initializeApp();

  debugPrint('Ricevuta notifica in background: ${message.notification?.title}');

  // Qui non puoi mostrare notifiche locali o accedere al database
  // perché questo handler viene eseguito in un isolate separato
}
