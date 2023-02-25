import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/authentication/auth.dart';
import 'package:users_app/models/user.dart';
import 'package:users_app/google_maps/map_key.dart';
import 'package:users_app/models/user_model.dart';
import 'package:users_app/utils/app_info_provider.dart';
import 'package:users_app/models/directions.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:users_app/models/direction_details_info.dart';

class AssistantMethods {
  // This method does reverse geocoding to human-readable address
  // using google geocoding api
  // docs: https://developers.google.com/maps/documentation/geocoding/requests-reverse-geocoding
  // the position arg is the userCurrentPosition in latitude and longitude
  static Future<String> searchAddressForGeoCoord(
      Position position, context) async {
    String apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    // get human-readable address as response
    var response = await RequestAssistant.receiveRequest(apiURL);
    if (response != "Request failed.") {
      humanReadableAddress = response['results'][0]['formatted_address'];

      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;

      // update the userPickUpLocation state in AppInfo provider
      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fAuth.currentUser;

    // Find currentFirebaseUser by uid in users node in db
    DatabaseReference userRef = FirebaseDatabase.instance
        .ref()
        .child('users')
        .child(currentFirebaseUser!.uid);

    // Get user data from db and assign it to userModelCurrentInfo object
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        // NOTE: userModelCurrentInfo object was instantiated in user.dart file
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
        // print("name = ${userModelCurrentInfo!.name}");
      }
    });
  }

  // GOOGLE DIRECTIONS API DOCS:
  // https://developers.google.com/maps/documentation/directions/get-api-key
  // this method is being called in main_screen.dart
  static Future<DirectionDetailsInfo?>
      obtainOriginToDestinationDirectionDetails(
          LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude}, ${originPosition.longitude}&destination=${destinationPosition.latitude}, ${destinationPosition.longitude}&key=$mapKey";

    // the response from the api is direction details in json data
    var responseDirectionApi = await RequestAssistant.receiveRequest(
        urlOriginToDestinationDirectionDetails);

    if (responseDirectionApi == "Request failed.") {
      return null;
    }

    DirectionDetailsInfo directionDetailsInfo = DirectionDetailsInfo();
    // use google Directions API docs to read json-format data
    directionDetailsInfo.ePoints =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailsInfo.distanceText =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailsInfo.distanceValue =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailsInfo.durationText =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailsInfo.durationValue =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetailsInfo;
  }
}
