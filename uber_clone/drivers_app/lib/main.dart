import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:drivers_app/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp(
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Drivers App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MySplashScreen(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  final Widget? child;
  MyApp({this.child});

  // When the app restarts, it'll restart from the beginning, clearing any global variables
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()!.restartApp();
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child!,
    );
  }
}
