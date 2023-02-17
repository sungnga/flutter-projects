import 'package:design_code/constants.dart';
import 'package:flutter/material.dart';

class SearchFieldWidget extends StatelessWidget {
  const SearchFieldWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 12.0, right: 28.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.0),
              boxShadow: [
                BoxShadow(
                  color: kShadowColor,
                  offset: Offset(0, 12),
                  blurRadius: 16.0,
                )
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (newText) {
                print(newText);
              },
              cursorColor: kPrimaryLabelColor,
              style: kSearchTextStyle,
              decoration: InputDecoration(
                icon: Icon(
                  Icons.search,
                  color: kPrimaryLabelColor,
                  size: 20.0,
                ),
                border: InputBorder.none,
                hintText: "Search for courses",
                hintStyle: kSearchPlaceholderStyle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
