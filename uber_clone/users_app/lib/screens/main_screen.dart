import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
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
import 'package:users_app/models/user.dart';
import 'package:users_app/assistants/geofire_assistant.dart';
import 'package:users_app/models/active_nearby_available_drivers.dart';

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

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 300;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? permission;
  double bottomPaddingOfMap = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};

  String userName = "Your name";
  String userEmail = "Your email";

  bool openSidebar = true;

  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyDriverIcon;

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

    // String humanReadableAddress =
    //     await AssistantMethods.searchAddressForGeoCoord(
    //         userCurrentPosition!, context);
    // print("Your address is: ${humanReadableAddress}");

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;

    initializeGeoFireListener();
  }

  @override
  Widget build(BuildContext context) {
    createActiveNearbyDriverIconMarker();

    return Scaffold(
      key: scaffoldKey,
      drawer: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.black,
        ),
        child: Sidebar(
          name: userName,
          email: userEmail,
        ),
      ),
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
            top: 50.0,
            left: 20.0,
            child: GestureDetector(
              onTap: () {
                if (openSidebar) {
                  scaffoldKey.currentState!.openDrawer();
                } else {
                  // restart-refresh-minimize app
                  // SystemNavigator.pop();

                  // when the user clicks on the close[X] button
                  // this cancels the destination location set by user
                  // takes user back to MainScreen and direction polyline disappears
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MainScreen()));
                }
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey,
                child: Icon(
                  openSidebar ? Icons.menu : Icons.close,
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
                              SizedBox(
                                height: 6.0,
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
                            // once the Search Place screen is closed,
                            // change the sidebar icon to close[X] icon
                            setState(() {
                              openSidebar = false;
                            });

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
                                SizedBox(
                                  height: 6.0,
                                ),
                                Text(
                                  Provider.of<AppInfo>(context)
                                              .userDropOffLocation !=
                                          null
                                      ? "${Provider.of<AppInfo>(context).userDropOffLocation!.locationName!.substring(0, 30)} ..."
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
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
    );

    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
        title: destinationPosition.locationName,
        snippet: "Destination",
      ),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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

  // this method is called when a driver comes online and display it on user's app
  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");

    // 1st arg - user current position latitude
    // 2nd arg - user current position longitude
    // 3rd arg - distance radius around user current position in kilometer
    // NOTE activeDrivers who are outside of this radius will not be displayed on map
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {

          // whenever any driver becomes active/online -> add to our active drivers list
          case Geofire.onKeyEntered:
            // create one activeNearbyAvailableDriver instance
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();

            // get driver's latLng in activeDrivers node in fb realtime db
            // assign it to activeNearbyAvailableDrivers model
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId =
                map['key']; // key is the driver uid

            // add the driver instance to the active drivers list
            GeoFireAssistant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDriver);

            // if driver_uid exists in activeDrivers node in db, display driver marker on user's map
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiveDriversOnUsersMap();
            }
            break;

          // whenever any driver becomes non-active/offline ->
          //   remove driver from active drivers list
          //   display the updated list on user's map
          case Geofire.onKeyExited:
            // remove that driver from the active drivers list
            // map['key'] is getting driver uid in activeDrivers node in fb realtime db
            GeoFireAssistant.deleteOfflineDriverFromList(map['key']);
            displayActiveDriversOnUsersMap();
            break;

          // whenever the driver moves ->
          //   update that driver latLng in model
          //   update driver latLng in active drivers list
          //   display the updated driver marker on user's map
          case Geofire.onKeyMoved:
            // update the driver location in active drivers list
            ActiveNearbyAvailableDrivers activeNearbyAvailableDriver =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDriver.locationLatitude = map['latitude'];
            activeNearbyAvailableDriver.locationLongitude = map['longitude'];
            activeNearbyAvailableDriver.driverId = map['key'];
            GeoFireAssistant.updateActiveNearbyAvailableDriverLocation(
                activeNearbyAvailableDriver);

            // update driver marker on user's map
            displayActiveDriversOnUsersMap();
            break;

          // display those online/active drivers on user's map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiveDriversOnUsersMap();
            break;
        }
      }

      setState(() {});
    });
  }

  displayActiveDriversOnUsersMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      // for each driver in the active drivers list...
      for (ActiveNearbyAvailableDrivers eachDriver
          in GeoFireAssistant.activeNearbyAvailableDriversList) {
        // get the driver's current position
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

        // display a marker at the driver's position
        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyDriverIcon!,
          rotation: 360,
        );

        // add this driver's market to the driversMarkerSet
        driversMarkerSet.add(marker);
      }

      setState(() {
        markerSet = driversMarkerSet;
      });
    });
  }

  // custom active nearby driver marker
  createActiveNearbyDriverIconMarker() {
    if (activeNearbyDriverIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'asset/images/car.png')
          .then((value) {
        activeNearbyDriverIcon = value;
      });
    }
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
