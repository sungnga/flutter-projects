import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/authentication/auth.dart';
import 'package:users_app/components/sidebar.dart';
import 'package:users_app/constants/map_style.dart';
import 'package:users_app/screens/login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  // GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 240;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? permission;
  double bottomPaddingOfMap = 0;

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

  void getUserCurrentPosition() async {
    // Position userCurrentPosition;

    // get current position from device
    Position currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(currentPosition);

    // set user current position to current position
    userCurrentPosition = currentPosition;

    LatLng latLngPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition =
        CameraPosition(target: latLngPosition, zoom: 14);

    // this is the blue dot on google map of user position
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // key: scaffoldKey,
      // drawer: Theme(
      //   data: Theme.of(context).copyWith(
      //     canvasColor: Colors.black,
      //   ),
      //   child: Sidebar(
      //     name: userModelCurrentInfo!.name,
      //     email: userModelCurrentInfo!.email,
      //   ),
      // ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              newGoogleMapController!.setMapStyle(blackThemeMapStyle);
              setState(() {
                bottomPaddingOfMap = 230.0;
              });
              getUserCurrentPosition();
            },
          ),
          // custom sidebar button
          Positioned(
            top: 54.0,
            left: 20.0,
            child: GestureDetector(
              onTap: () {
                // scaffoldKey.currentState!.openDrawer();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          // search location
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedSize(
              curve: Curves.easeIn,
              duration: Duration(milliseconds: 120),
              child: Container(
                height: searchLocationContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20.0),
                    topLeft: Radius.circular(20.0),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'From',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Your current location',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Divider(
                        height: 1.0,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 16.0,
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.add_location_alt_outlined,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            width: 12.0,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'To',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Where to go?',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Divider(
                        height: 1.0,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          fAuth.signOut();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff00aa80),
                          textStyle: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        child: Text('Request a ride'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// ------- v2 of location permission and get userCurrentPosition
  // void checkLocationPermission() async {
  //   LocationPermission permission;

  //   try {
  //     permission = await Geolocator.checkPermission();
  //     // print(permission);

  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.denied) {
  //         permission = await Geolocator.requestPermission();
  //       }
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       permission = await Geolocator.requestPermission();
  //       if (permission == LocationPermission.deniedForever) {
  //         permission = await Geolocator.requestPermission();
  //       }
  //     }
  //     // print(permission);
  //   } catch (err) {
  //     print(err);
  //   }
  // }

  // void locateUserPosition() async {
  //   Position cPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high);

  //   userCurrentPosition = cPosition;

  //   LatLng latLngPosition =
  //       LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

  //   CameraPosition cameraPosition =
  //       CameraPosition(target: latLngPosition, zoom: 14);

  //   newGoogleMapController!
  //       .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  // }