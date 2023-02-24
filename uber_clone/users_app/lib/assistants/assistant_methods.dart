import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:users_app/assistants/request_assistant.dart';
import 'package:users_app/authentication/auth.dart';
import 'package:users_app/models/user.dart';
import 'package:users_app/google_maps/map_key.dart';
import 'package:users_app/models/user_model.dart';

class AssistantMethods {
  // This method does reverse geocoding to human-readable address
  // using google geocoding api
  // docs: https://developers.google.com/maps/documentation/geocoding/requests-reverse-geocoding
  // the position arg is the userCurrentPosition in latitude and longitude
  static Future<String> searchAddressForGeoCoord(Position position) async {
    String apiURL =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";

    // get human-readable address as response
    var response = await RequestAssistant.receiveRequest(apiURL);
    if (response != "Request failed.") {
      humanReadableAddress = response['results'][0]['formatted_address'];
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
}
