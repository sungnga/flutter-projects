import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:drivers_app/authentication/auth.dart';
import 'package:drivers_app/models/user_ride_request_info_model.dart';

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
        print("REMOTE MESSAGE: ${remoteMessage.data}");
        print("REMOTE REQUEST ID: ${remoteMessage.data["rideRequestId"]}");
        // display ride request info - user info who requested the ride
        readUserRideRequestInfo(remoteMessage.data["rideRequestId"]);
      }
    });

    // 2. Foreground state:
    // when the app is open, in view and in use, it receives a push notification
    FirebaseMessaging.onMessage.listen((RemoteMessage? remoteMessage) {
      print("REMOTE MESSAGE: ${remoteMessage!.data}");
      print("REMOTE REQUEST ID: ${remoteMessage.data["rideRequestId"]}");
      // display ride request info - user info who requested the ride
      readUserRideRequestInfo(remoteMessage.data["rideRequestId"]);
    });

    // 3. Background state:
    // when the app is minimized
    // the app opens directly from the push notification
    // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? remoteMessage) {
    //   print("REMOTE MESSAGE: ${remoteMessage!.data}");
    //   print("REMOTE REQUEST ID: ${remoteMessage.data["rideRequestId"]}");
    //   // display ride request info - user info who requested the ride
    //   readUserRideRequestInfo(remoteMessage.data["rideRequestId"]);
    // });
    FirebaseMessaging.onBackgroundMessage((RemoteMessage? remoteMessage) {
      print("REMOTE MESSAGE: ${remoteMessage!.data}");
      print("REMOTE REQUEST ID: ${remoteMessage.data["rideRequestId"]}");
      // display ride request info - user info who requested the ride
      readUserRideRequestInfo(remoteMessage.data["rideRequestId"]);
      throw "";
    });
  }

  readUserRideRequestInfo(String userRideRequestId) {
    // get the user ride request info from db
    FirebaseDatabase.instance
        .ref()
        .child("allRideRequests")
        .child(userRideRequestId)
        .once()
        .then((snapshotData) {
      if (snapshotData.snapshot.value != null) {
        print(snapshotData.snapshot.value);

        double originLat = double.parse(
            (snapshotData.snapshot.value! as Map)["origin"]["latitude"]);
        double originLng = double.parse(
            (snapshotData.snapshot.value! as Map)["origin"]["longitude"]);
        String originAddress =
            (snapshotData.snapshot.value! as Map)["originAddress"];

        double destinationLat = double.parse(
            (snapshotData.snapshot.value! as Map)["destination"]["latitude"]);
        double destinationLng = double.parse(
            (snapshotData.snapshot.value! as Map)["destination"]["longitude"]);
        String destinationAddress =
            (snapshotData.snapshot.value! as Map)["destinationAddress"];

        String userName = (snapshotData.snapshot.value! as Map)["userName"];
        String userPhone = (snapshotData.snapshot.value! as Map)["userPhone"];

        // assigning user ride request info data to UserRideRequestInfoModel attributes
        UserRideRequestInfoModel userRideRequestDetails =
            UserRideRequestInfoModel();

        userRideRequestDetails.originLatLng = LatLng(originLat, originLng);
        userRideRequestDetails.originAddress = originAddress;

        userRideRequestDetails.destinationLatLng =
            LatLng(destinationLat, destinationLng);
        userRideRequestDetails.destinationAddress = destinationAddress;

        userRideRequestDetails.userName = userName;
        userRideRequestDetails.userPhone = userPhone;

        print("USER RIDE REQUEST DETAILS: ${userRideRequestDetails.userName}");
      } else {
        Fluttertoast.showToast(msg: "This ride request id doesn't exist.");
      }
    });
  }

  Future<void> generateAndGetToken() async {
    // the FCM SDK generates a registration token for the driver
    String? registrationToken = await messaging.getToken();
    print("DRIVER FCM TOKEN: ${registrationToken}");

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
