import 'package:design_code/components/searchfield_widget.dart';
import 'package:design_code/components/sidebar_button.dart';
import 'package:design_code/constants.dart';
import 'package:design_code/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreenNavBar extends StatelessWidget {
  HomeScreenNavBar({super.key, required this.triggerAnimation});

  final photoURL = FirebaseAuth.instance.currentUser!.photoURL;
  final void Function() triggerAnimation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SidebarButton(
            triggerAnimation: triggerAnimation,
          ),
          SearchFieldWidget(),
          Icon(
            Icons.notifications,
            color: kPrimaryLabelColor,
          ),
          SizedBox(
            width: 16.0,
          ),
          GestureDetector(
            onTap: (() => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => ProfileScreen()))),
            child: CircleAvatar(
              backgroundColor: Color(0xffe7eefb),
              radius: 18.0,
              child: (photoURL != null)
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(18.0),
                      child: Image.network(
                        photoURL.toString(),
                        width: 36.0,
                        height: 36.0,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(Icons.person),
            ),
          ),
        ],
      ),
    );
  }
}
