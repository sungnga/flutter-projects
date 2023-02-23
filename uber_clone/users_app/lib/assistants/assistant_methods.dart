import 'package:firebase_database/firebase_database.dart';
import 'package:users_app/authentication/auth.dart';
import 'package:users_app/models/user.dart';
import 'package:users_app/models/user_model.dart';

class AssistantMethods {
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
