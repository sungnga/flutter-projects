import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:drivers_app/models/user_ride_request_info_model.dart';
import 'package:drivers_app/authentication/auth.dart';

class NotificationDialogBox extends StatefulWidget {
  NotificationDialogBox({required this.userRideRequestDetails});

  UserRideRequestInfoModel? userRideRequestDetails;

  @override
  State<NotificationDialogBox> createState() => _NotificationDialogBoxState();
}

class _NotificationDialogBoxState extends State<NotificationDialogBox> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      child: Container(
        margin: EdgeInsets.all(8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 14.0,
            ),
            Image.asset(
              "asset/images/car_logo.png",
              width: 160.0,
            ),
            const SizedBox(
              height: 10.0,
            ),

            // TITLE
            const Text(
              'New Ride Request',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22.0,
                color: Colors.black87,
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),

            const Divider(
              height: 2,
              thickness: 2,
            ),

            // ADDRESSES: ORIGIN/DESTINATION
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // origin location with icon
                  Row(
                    children: [
                      Image.asset(
                        "asset/images/origin.png",
                        width: 30.0,
                        height: 30.0,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails!.originAddress!,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),

                  // destination location with icon
                  Row(
                    children: [
                      Image.asset(
                        "asset/images/destination.png",
                        width: 30.0,
                        height: 30.0,
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Expanded(
                        child: Text(
                          widget.userRideRequestDetails!.destinationAddress!,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            Divider(
              height: 2,
              thickness: 2,
            ),

            // BUTTONS: DECLINE/ACCEPT
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // decline ride request
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      "Decline".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 25.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // accept ride request
                      acceptRideRequest(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      "Accept".toUpperCase(),
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  acceptRideRequest(BuildContext context) {
    String getRideRequestId = "";

    // the userRideRequestId is assigned to the the driver's newRideStatus attribute
    // when the user selects this driver for the ride request
    // assign the userRideRequestId to the variable getRideRequestId
    FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus")
        .once()
        .then((snap) {
      if (snap.snapshot.value != null) {
        getRideRequestId = snap.snapshot.value.toString();
      } else {
        Fluttertoast.showToast(msg: "This ride request is not available.");
      }

      // if the rideRequestId in the userRideRequestDetails matches
      // with the rideRequestId in the driver info
      if (getRideRequestId == widget.userRideRequestDetails!.rideRequestId) {
        // update newRideStatus attribute in db
        FirebaseDatabase.instance
            .ref()
            .child("drivers")
            .child(currentFirebaseUser!.uid)
            .child("newRideStatus")
            .set("accepted");

        // start trip - send driver to TripScreen

      } else {
        Fluttertoast.showToast(msg: "This ride request does not exist.");
      }
    });
  }
}
