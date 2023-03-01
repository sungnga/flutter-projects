import 'package:drivers_app/authentication/auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationSystem {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future initializeCloudMessaging() async {
    // Re-enable FCM auto-init at runtime
    // to enable auto-init for a specific app instance
    messaging.setAutoInitEnabled(true);

    // Request permission to receive messages for iOS platform
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // 1. Terminated state:
    // when the app is completely closed or not running,
    // the app opens directly from the push notification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? remoteMessage) {
      // the remoteMessage we get back is the ride request info
      if (remoteMessage != null) {
        // display ride request info - user info who requested the ride

      }
    });

    // 2. Foreground state:
    // when the app is open, in view and in use, it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      // display ride request info - user info who requested the ride
    });

    // 3. Background state:
    // when the app is minimized
    // the app opens directly from the push notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
      // display ride request info - user info who requested the ride
    });
  }

  Future<void> generateAndGetToken() async {
    // the FCM SDK generates a registration token for the driver
    String? registrationToken = await messaging.getToken();
    print("DRIVER PUSH NOTIFICATION TOKEN: ${registrationToken}");

    // save the driver token to db
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("token")
        .set(registrationToken);

    messaging.subscribeToTopic("allDrivers");
    messaging.subscribeToTopic("allUsers");
  }
}
