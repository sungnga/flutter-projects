import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:users_app/geo_fire/drivers_list.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/models/direction_details_info.dart';

class SelectNearestActiveDriverScreen extends StatefulWidget {
  SelectNearestActiveDriverScreen({this.referenceRideRequest});

  // the data is being passed from the searchNearestOnlineDrivers() method in main_screen.dart
  DatabaseReference? referenceRideRequest;

  @override
  State<SelectNearestActiveDriverScreen> createState() =>
      _SelectNearestActiveDriverScreenState();
}

class _SelectNearestActiveDriverScreenState
    extends State<SelectNearestActiveDriverScreen> {
  String fareAmt = "";

  String getFareAmtBasedOnCarType(int index) {
    if (tripDirectionDetailsInfo != null) {
      if (dList[index]["car_details"]["type"].toString() == "bike") {
        fareAmt =
            (AssistantMethods().calculateFareAmount(tripDirectionDetailsInfo!) /
                    2)
                .toStringAsFixed(2);
      }

      if (dList[index]["car_details"]["type"].toString() == "uber-x") {
        fareAmt =
            (AssistantMethods().calculateFareAmount(tripDirectionDetailsInfo!) *
                    2)
                .toStringAsFixed(2);
      }

      if (dList[index]["car_details"]["type"].toString() == "uber-go") {
        fareAmt =
            (AssistantMethods().calculateFareAmount(tripDirectionDetailsInfo!))
                .toString();
      }
    }

    return fareAmt;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.white54,
        title: Text(
          "Nearest Online Drivers",
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            // if the user clicks on the close[X] button ->
            // remove the ride request info from the allRideRequests node in db
            // display a message to user the ride request has been cancelled
            // refresh/restart the app
            widget.referenceRideRequest!.remove();
            Fluttertoast.showToast(msg: "You cancelled the ride request.");
            SystemNavigator.pop();
          },
          icon: Icon(
            Icons.close,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView.builder(
          itemCount: dList.length,
          itemBuilder: (BuildContext context, int index) {
            return Card(
              color: Colors.grey,
              elevation: 3,
              shadowColor: Color(0xff00aa80),
              margin: EdgeInsets.all(8.0),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Image.asset(
                      "asset/images/${dList[index]["car_details"]["type"].toString()}.png",
                      width: 70,
                    ),
                  ),
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        dList[index]["name"],
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        dList[index]["car_details"]["car_model"],
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      SmoothStarRating(
                        rating: 3.5,
                        color: Colors.black,
                        borderColor: Colors.black,
                        allowHalfRating: true,
                        starCount: 5,
                        size: 15.0,
                      )
                    ],
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "\$${getFareAmtBasedOnCarType(index)}",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 4.0,
                      ),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.durationText!
                            : "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12.0),
                      ),
                      SizedBox(
                        height: 2.0,
                      ),
                      Text(
                        tripDirectionDetailsInfo != null
                            ? tripDirectionDetailsInfo!.distanceText!
                            : "",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            fontSize: 12.0),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
