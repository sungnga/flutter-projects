import 'package:flutter/material.dart';
import 'package:users_app/models/directions_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? userPickUpLocation, userDropOffLocation;

  // this method listens to changes to userPickUpAddress instance (from assistant_methods.dart)
  // and updates the userPickUpLocation instance
  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    userPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  // this method is called in place_prediction_tile.dart
  void updateDropOffLocationAddress(Directions dropOffAddress) {
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
