import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../model/course.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key, required this.course});

  final Course course;

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  Widget indicators() {
    List<Widget> indicators = [];

    for (var i = 0; i < 9; i++) {
      indicators.add(Container(
        width: 7.0,
        height: 7.0,
        margin: EdgeInsets.symmetric(horizontal: 6.0),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: i == 0 ? Color(0xff0971fe) : Color(0xffa6aebd),
        ),
      ));
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: indicators,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: kBackgroundColor,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.hardEdge,
                alignment: Alignment.bottomRight,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      decoration:
                          BoxDecoration(gradient: widget.course.background),
                    ),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    width: 60.0,
                                    height: 60.0,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18.0),
                                    ),
                                    child: Hero(
                                      tag: 'logo',
                                      child: Image.asset(
                                        'asset/logos/${widget.course.logo}',
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20.0,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag: 'subtitle',
                                          child: Text(
                                            widget.course.courseSubtitle,
                                            style: kSecondaryCalloutLabelStyle
                                                .copyWith(
                                                    color: Colors.white70),
                                          ),
                                        ),
                                        Hero(
                                          tag: 'title',
                                          child: Text(
                                            widget.course.courseTitle,
                                            style: kLargeTitleStyle.copyWith(
                                                color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: Container(
                                      width: 36.0,
                                      height: 36.0,
                                      decoration: BoxDecoration(
                                        color:
                                            kPrimaryLabelColor.withOpacity(0.8),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 28.0,
                            ),
                            Expanded(
                              child: Hero(
                                tag: 'illustration',
                                child: Image.asset(
                                  'asset/illustrations/${widget.course.illustration}',
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 28.0),
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 12.5,
                        bottom: 13.5,
                        left: 20.5,
                        right: 14.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.0),
                        boxShadow: [
                          BoxShadow(
                            color: kShadowColor,
                            offset: Offset(0, 4),
                            blurRadius: 16.0,
                          ),
                        ],
                      ),
                      width: 60.0,
                      height: 60.0,
                      child: Image.asset('asset/icons/icon-play.png'),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 12.0,
                  left: 28.0,
                  right: 28.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Container(
                              padding: EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                child: Icon(
                                  Platform.isAndroid
                                      ? Icons.people
                                      : CupertinoIcons.group_solid,
                                  color: Colors.white,
                                ),
                                radius: 21.0,
                                backgroundColor: kCourseElementIconColor,
                              ),
                              decoration: BoxDecoration(
                                color: kBackgroundColor,
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                            ),
                          ),
                          width: 58.0,
                          height: 58.0,
                          decoration: BoxDecoration(
                            gradient: widget.course.background,
                            borderRadius: BorderRadius.circular(29.0),
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '28.7k',
                              style: kTitle2Style,
                            ),
                            Text(
                              'Students',
                              style: kSearchPlaceholderStyle,
                            )
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          child: Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Container(
                              padding: EdgeInsets.all(4.0),
                              child: CircleAvatar(
                                child: Icon(
                                  Platform.isAndroid
                                      ? Icons.format_quote
                                      : CupertinoIcons.news_solid,
                                  color: Colors.white,
                                ),
                                radius: 21.0,
                                backgroundColor: kCourseElementIconColor,
                              ),
                              decoration: BoxDecoration(
                                color: kBackgroundColor,
                                borderRadius: BorderRadius.circular(29.0),
                              ),
                            ),
                          ),
                          width: 58.0,
                          height: 58.0,
                          decoration: BoxDecoration(
                            gradient: widget.course.background,
                            borderRadius: BorderRadius.circular(29.0),
                          ),
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '12.4k',
                              style: kTitle2Style,
                            ),
                            Text(
                              'Comments',
                              style: kSearchPlaceholderStyle,
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 28.0, vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    indicators(),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: 80.0,
                        height: 40.0,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14.0),
                            boxShadow: [
                              BoxShadow(
                                  color: kShadowColor,
                                  offset: Offset(0, 12),
                                  blurRadius: 16.0)
                            ]),
                        child: Text(
                          'View all',
                          style: kSearchTextStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "5 years ago, I couldn’t write a single line of Swift. I learned it and moved to React, Flutter while using increasingly complex design tools. I don’t regret learning them because SwiftUI takes all of their best concepts. It is hands-down the best way for designers to take a first step into code.",
                      style: kBodyLabelStyle,
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      'About this course',
                      style: kTitle1Style,
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                    Text(
                      "This course was written for people who are passionate about design and about Apple's SwiftUI. It beginner-friendly, but it is also packed with tricks and cool workflows about building the best UI. Currently, Xcode 11 is still in beta so the installation process may be a little hard. However, once you get everything working, then it'll get much friendlier!",
                      style: kBodyLabelStyle,
                    ),
                    SizedBox(
                      height: 24.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}