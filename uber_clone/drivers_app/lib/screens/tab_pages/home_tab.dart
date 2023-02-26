import 'dart:async';
import 'package:drivers_app/authentication/auth.dart';
import 'package:drivers_app/screens/main_screen.dart';
import 'package:drivers_app/streams/stream.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drivers_app/constants/map_style.dart';
import 'package:drivers_app/assistants/assistant_methods.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Position? driverCurrentPosition;
  var geoLocator = Geolocator();
  LocationPermission? permission;

  String statusText = "Offline";
  Color buttonColor = Colors.grey;
  bool isDriverActive = false;

  @override
  void initState() {
    super.initState();

    // when main_screen loads, get user info from db
    // the user data is stored in userModelCurrentInfo object
    AssistantMethods.readCurrentOnlineUserInfo();
    checkLocationPermission();
  }

  Future<void> checkLocationPermission() async {
    bool serviceEnabled;
    // LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }
      print(permission);
    }

    if (permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          return Future.error('Location permissions are denied');
        }
      }
    }
  }

  void getDriverCurrentPosition() async {
    // Position userCurrentPosition;

    // get current position from device
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(currentPosition);

    // set user current position to current position
    driverCurrentPosition = currentPosition;

    LatLng latLngPosition = LatLng(
        driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    // this is the blue dot on google map showing user current position
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    // String humanReadableAddress =
    //     await AssistantMethods.searchAddressForGeoCoord(
    //         driverCurrentPosition!, context);
    // print("Your address is: ${humanReadableAddress}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              newGoogleMapController!.setMapStyle(blackThemeMapStyle);
              getDriverCurrentPosition();
            },
          ),

          // online offline driver
          statusText != "Online"
              ? Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Colors.black87,
                )
              : Container(),

          // button for online offline driver
          Positioned(
            top: statusText != "Online"
                ? MediaQuery.of(context).size.height * 0.46
                : 25.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // offline
                    if (isDriverActive != true) {
                      driverIsOnlineNow();
                      updateDriversLocationAtRealTime();

                      setState(() {
                        statusText = "Online";
                        isDriverActive = true;
                        // buttonColor = Colors.transparent;
                      });

                      // display Toast
                      Fluttertoast.showToast(msg: "You are now online");
                    } else {
                      driverIsOfflineNow();

                      setState(() {
                        statusText = "Offline";
                        isDriverActive = false;
                        // buttonColor = Colors.grey;
                      });

                      // display Toast
                      Fluttertoast.showToast(msg: "You are now offline");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26.0)),
                  ),
                  child: statusText != "Online"
                      ? Text(
                          statusText,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Icon(
                          Icons.phonelink_ring,
                          color: Colors.white,
                          size: 26.0,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // this method is called when the driver clicks the button to go online
  void driverIsOnlineNow() async {
    // get driver's current location
    Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // set driver's current position
    driverCurrentPosition = pos;

    // NOTE: the activeDrivers node must match in fb realtime database Rules
    Geofire.initialize("activeDrivers");

    // set the online driver's id and location to activeDrivers node in realtime database
    Geofire.setLocation(
      currentFirebaseUser!.uid,
      driverCurrentPosition!.latitude,
      driverCurrentPosition!.longitude,
    );

    // in the 'drivers' node under driver's uid, create the newRideStatus property to this driver's doc
    DatabaseReference ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");

    // set the value 'idle' to the newRideStatus property
    ref.set("idle"); // searching for ride request
    ref.onValue.listen((event) {}); // driver listens for requests
  }

  void updateDriversLocationAtRealTime() {
    // use stream subscription to listen to driver position changing
    // and set the position to driverCurrentPosition
    streamSubscriptionPosition =
        Geolocator.getPositionStream().listen((Position position) {
      driverCurrentPosition = position;

      // updating driver's latLng in activeDrivers node in realtime database
      if (isDriverActive == true) {
        Geofire.setLocation(
          currentFirebaseUser!.uid,
          driverCurrentPosition!.latitude,
          driverCurrentPosition!.longitude,
        );
      }

      // convert driver location to LatLng in order to update on google map
      LatLng latLng = LatLng(
          driverCurrentPosition!.latitude, driverCurrentPosition!.longitude);
      // update driver location on map in realtime
      newGoogleMapController!.animateCamera(CameraUpdate.newLatLng(latLng));
    });
  }

  // this method is called when the driver clicks the button to go offline
  void driverIsOfflineNow() async {
    Geofire.removeLocation(currentFirebaseUser!.uid);

    DatabaseReference? ref = FirebaseDatabase.instance
        .ref()
        .child("drivers")
        .child(currentFirebaseUser!.uid)
        .child("newRideStatus");
    ref.onDisconnect();
    ref.remove();
    ref = null;

    // Future.delayed(const Duration(milliseconds: 2), () {
    //   SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    //   SystemNavigator.pop();
    //   Navigator.push(context, MaterialPageRoute(builder: (c) => MainScreen()));
    // });
  }
}
