import 'package:firebase_database/firebase_database.dart';

class UserModel {
  UserModel({this.id, this.name, this.email, this.phone});

  String? id;
  String? name;
  String? email;
  String? phone;

  UserModel.fromSnapshot(DataSnapshot snap) {
    id = snap.key;
    name = (snap.value as dynamic)['name'];
    email = (snap.value as dynamic)['email'];
    phone = (snap.value as dynamic)['phone'];
  }
}
