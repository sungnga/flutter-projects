import 'package:design_code/components/searchfield_widget.dart';
import 'package:design_code/components/sidebar_button.dart';
import 'package:design_code/constants.dart';
import 'package:flutter/material.dart';

class HomeScreenNavBar extends StatelessWidget {
  const HomeScreenNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SidebarButton(),
          SearchFieldWidget(),
          Icon(
            Icons.notifications,
            color: kPrimaryLabelColor,
          ),
          SizedBox(width: 16.0),
          CircleAvatar(
            radius: 18.0,
            backgroundImage: AssetImage('asset/images/profile.jpg'),
          ),
        ],
      ),
    );
  }
}
