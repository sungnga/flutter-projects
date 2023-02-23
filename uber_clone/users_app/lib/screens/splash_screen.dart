import 'package:flutter/material.dart';
import 'dart:async';
import 'package:users_app/authentication/auth.dart';
import 'package:users_app/screens/main_screen.dart';

class MySplashScreen extends StatefulWidget {
  const MySplashScreen({super.key});

  @override
  State<MySplashScreen> createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {
  startTimer() {
    Timer(const Duration(seconds: 2), () async {
      // check if user is authenticated aka is user logged in
      if (await fAuth.currentUser != null) {
        // if true, set user to currentFirebaseUser
        // NOTE: currentFirebaseUser object was instantiated in auth.dart file
        currentFirebaseUser = fAuth.currentUser;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } else {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => LoginScreen()),
        // );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('asset/logos/logo.png'),
              SizedBox(
                height: 10,
              ),
              Text(
                'Uber',
                style: TextStyle(
                  fontSize: 36.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
