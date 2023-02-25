import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/assistants/assistant_methods.dart';
import 'package:users_app/authentication/auth.dart';
import 'package:users_app/components/progress_dialog.dart';
import 'package:users_app/components/sidebar.dart';
import 'package:users_app/constants/map_style.dart';
import 'package:users_app/screens/login_screen.dart';
import 'package:users_app/screens/search_places_screen.dart';
import 'package:users_app/utils/app_info_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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
  double searchLocationContainerHeight = 300;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? permission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

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

    // this is the blue dot on google map showing user current position
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress =
        await AssistantMethods.searchAddressForGeoCoord(
            userCurrentPosition!, context);
    print("Your address is: ${humanReadableAddress}");
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
            polylines: polyLineSet,
            markers: markerSet,
            circles: circleSet,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              newGoogleMapController!.setMapStyle(blackThemeMapStyle);
              setState(() {
                bottomPaddingOfMap = 310.0;
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
                            children: [
                              Text(
                                'From',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                Provider.of<AppInfo>(context)
                                            .userPickUpLocation !=
                                        null
                                    ? "${(Provider.of<AppInfo>(context).userPickUpLocation!.locationName!).substring(0, 30)} ..."
                                    : "Not getting address",
                                style:
                                    TextStyle(color: Colors.grey, fontSize: 14),
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
                      GestureDetector(
                        onTap: () async {
                          var responseFromSearchScreen = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPlacesScreen()));

                          if (responseFromSearchScreen == "obtainedDropOff") {
                            // draw direction route
                            await drawPolyLineFromOriginToDestination();
                          }
                        },
                        child: Row(
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
                              children: [
                                Text(
                                  'To',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                              .userDropOffLocation !=
                                          null
                                      ? Provider.of<AppInfo>(context)
                                          .userDropOffLocation!
                                          .locationName!
                                      : 'Where to go?',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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

  Future<void> drawPolyLineFromOriginToDestination() async {
    // Get userPickUpLocation and userDropOffLocation states from AppInfo provider
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).userPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).userDropOffLocation;

    // convert the user's pickup and drop-off locations into LatLng (from google_map_flutter package)
    var originLatLng = LatLng(
        originPosition!.locationLatitude!, originPosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) =>
          ProgressDialog(message: 'Getting direction...'),
    );

    // make the request to google Directions API to get direction details info
    var directionDetailsInfo =
        await AssistantMethods.obtainOriginToDestinationDirectionDetails(
            originLatLng, destinationLatLng);

    // close the ProgressDialog box after making the request
    Navigator.pop(context);

    // print('These are points: ');
    // print(directionDetailsInfo!.ePoints);

    // draw polyline based on direction ePoints
    // google Direction API gave encoded points(ePoints) data, need to decode them first
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList =
        pPoints.decodePolyline(directionDetailsInfo!.ePoints.toString());

    pLineCoordinatesList.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      // a polyline contains points and we draw lines between those points
      // define the properties of the polyline
      Polyline polyline = Polyline(
        color: Colors.purple.shade400,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      polyLineSet.add(polyline);
    });

    LatLngBounds boundsLatLng;
    if (originLatLng.latitude > destinationLatLng.latitude &&
        originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: originLatLng);
    } else if (originLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, originLatLng.longitude),
      );
    } else if (originLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, originLatLng.longitude),
        northeast: LatLng(originLatLng.latitude, destinationLatLng.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLng, northeast: destinationLatLng);
    }

    // map camera animation to show full view of direction on screen
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 60.0));

    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow:
          InfoWindow(title: originPosition.locationName, snippet: "Origin"),
      position: originLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: "Destination",
      ),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });

    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: const Color(0xff00aa80),
      radius: 12.0,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.red.shade400,
      radius: 12.0,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLng,
    );

    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
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