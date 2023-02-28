import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:users_app/geo_fire/drivers_list.dart';

class SelectNearestActiveDriverScreen extends StatefulWidget {
  const SelectNearestActiveDriverScreen({super.key});

  @override
  State<SelectNearestActiveDriverScreen> createState() =>
      _SelectNearestActiveDriverScreenState();
}

class _SelectNearestActiveDriverScreenState
    extends State<SelectNearestActiveDriverScreen> {
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
            // TODO: remove the ride request from db

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
              child: ListTile(
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
                leading: Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Image.asset(
                    "asset/images/${dList[index]["car_details"]["type"].toString()}.png",
                    width: 70,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "3",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 2.0,
                    ),
                    Text(
                      "13 km",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
