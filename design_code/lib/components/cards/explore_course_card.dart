import 'package:design_code/constants.dart';
import 'package:design_code/model/course.dart';
import 'package:flutter/material.dart';

class ExploreCourseCard extends StatelessWidget {
  const ExploreCourseCard({super.key, required this.course});

  final Course course;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(41.0),
        child: Container(
          width: 280.0,
          height: 120.0,
          decoration: BoxDecoration(gradient: course.background),
          child: Padding(
            padding: const EdgeInsets.only(left: 32.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.courseSubtitle,
                        style: kCardSubtitleStyle,
                      ),
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                        course.courseTitle,
                        style: kCardTitleStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'asset/illustrations/${course.illustration}',
                      fit: BoxFit.cover,
                      height: 100.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
