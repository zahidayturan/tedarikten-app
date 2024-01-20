import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Payload: ${message.data}");
  }

  Future<void> initNotifications() async {
    try {
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      print("FCM Token: $fcmToken");

      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    } catch (e) {
      print("Bildirimler başlatılırken hata oluştu: $e");
    }
  }

}
