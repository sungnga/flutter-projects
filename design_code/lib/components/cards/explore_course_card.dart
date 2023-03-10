import 'package:design_code/constants.dart';
import 'package:design_code/model/course.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ExploreCourseCard extends StatefulWidget {
  const ExploreCourseCard({super.key, required this.course});

  final Course course;

  @override
  State<ExploreCourseCard> createState() => _ExploreCourseCardState();
}

class _ExploreCourseCardState extends State<ExploreCourseCard> {
  final _storage = FirebaseStorage.instance;
  // var illustrationURL;

  @override
  void initState() {
    super.initState();
    // getIllustration();
  }

  // void getIllustration() {
  //   _storage
  //       .ref('illustrations/${widget.course.illustration}')
  //       .getDownloadURL()
  //       .then((url) {
  //     setState(() {
  //       illustrationURL = url;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(41.0),
        child: Container(
          width: 280.0,
          height: 120.0,
          decoration: BoxDecoration(gradient: widget.course.background),
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
                        widget.course.courseSubtitle,
                        style: kCardSubtitleStyle,
                        // maxLines: 2,
                        // overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 6.0,
                      ),
                      Text(
                        widget.course.courseTitle,
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
                    // (illustrationURL != null)
                    //     ? Image.network(
                    //         illustrationURL,
                    //         fit: BoxFit.cover,
                    //         height: 100.0,
                    //       )
                    //     : Image.asset(
                    //         'asset/illustrations/${widget.course.illustration}',
                    //         fit: BoxFit.cover,
                    //         height: 100.0,
                    //       ),
                    Image.asset(
                      'asset/illustrations/${widget.course.illustration}',
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
