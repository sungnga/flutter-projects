import 'package:flutter/material.dart';
import 'package:users_app/models/directions.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation;

  // this method listens to changes to userPickUpAddress instance (from assistant_methods.dart)
  // and updates the userPickUpLocation instance
  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }
}
