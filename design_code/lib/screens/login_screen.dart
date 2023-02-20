import 'package:design_code/constants.dart';
import 'package:design_code/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late String email;
  late String password;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kSidebarBackgroundColor,
        child: ListView(
          children: [
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      transform: Matrix4.translationValues(0, -75, 0),
                      child: Image.asset(
                          'asset/illustrations/illustration-14.png'),
                    ),
                    Container(
                      transform: Matrix4.translationValues(0, -170, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Learn to design\nand code apps',
                            style:
                                kLargeTitleStyle.copyWith(color: Colors.white),
                          ),
                          SizedBox(
                            height: 7.0,
                          ),
                          Text(
                            'Completed courses about the best\ntools and design systems',
                            style: kHeadlineLabelStyle.copyWith(
                                color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Container(
                  transform: Matrix4.translationValues(0, -150, 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 53.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Log in',
                          style: kTitle1Style,
                        ),
                        Text(
                          'Start Learning',
                          style: kTitle1Style.apply(color: Color(0xff5b4cf0)),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          height: 130.0,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: kShadowColor,
                                          offset: Offset(0, 12),
                                          blurRadius: 16.0),
                                    ]),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, right: 15.0, left: 16.0),
                                      child: TextField(
                                        onChanged: (textEntered) {
                                          email = textEntered;
                                        },
                                        cursorColor: kPrimaryLabelColor,
                                        decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.email,
                                            color: Color(0xff5488f1),
                                            size: 20.0,
                                          ),
                                          border: InputBorder.none,
                                          hintText: 'Email Address',
                                          hintStyle: kLoginInputTextStyle,
                                        ),
                                        style: kLoginInputTextStyle.copyWith(
                                            color: Colors.black),
                                      ),
                                    ),
                                    Divider(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 5.0, right: 15.0, left: 16.0),
                                      child: TextField(
                                        onChanged: (textEntered) {
                                          password = textEntered;
                                        },
                                        cursorColor: kPrimaryLabelColor,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                          icon: Icon(
                                            Icons.lock,
                                            color: Color(0xff5488f1),
                                            size: 20.0,
                                          ),
                                          border: InputBorder.none,
                                          hintText: 'Password',
                                          hintStyle: kLoginInputTextStyle,
                                        ),
                                        style: kLoginInputTextStyle.copyWith(
                                            color: Colors.black),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                try {
                                  // try to signin user with email and password
                                  // then navigate to home screen
                                  await _auth.signInWithEmailAndPassword(
                                      email: email, password: password);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                      fullscreenDialog: false,
                                    ),
                                  );
                                } on FirebaseAuthException catch (err) {
                                  if (err.code == 'user-not-found') {
                                    try {
                                      // if user not found, create a user with email and password
                                      // then navigate to home screen
                                      await _auth
                                          .createUserWithEmailAndPassword(
                                              email: email, password: password)
                                          .then((user) => {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        HomeScreen(),
                                                    fullscreenDialog: false,
                                                  ),
                                                ),
                                              });
                                    } catch (err) {}
                                  } else {
                                    // if there are other errors, show the dialog with error
                                    // user needs to dismiss the dialog
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text(err.message.toString()),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('Ok!'))
                                          ],
                                        );
                                      },
                                    );
                                  }
                                }
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.3,
                                height: 47.0,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14.0),
                                  gradient: LinearGradient(colors: [
                                    Color(0xff73a0f4),
                                    Color(0xff4a47f5),
                                  ]),
                                ),
                                child: Text(
                                  'Login',
                                  style: kCalloutLabelStyle.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Container(
                          child: Text(
                            'Forgot Password?',
                            style: kCalloutLabelStyle.copyWith(
                                color: Color(0x721b1e9c)),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
