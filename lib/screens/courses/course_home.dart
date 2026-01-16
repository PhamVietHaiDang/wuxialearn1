import 'package:flutter/cupertino.dart';
import 'package:hsk_learner/screens/courses/hsk_course.dart';

class CourseHome extends StatelessWidget {
  const CourseHome({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Home"),
      ),
      child: SafeArea(
        child: HSKCourseView(),
      ),
    );
  }
}
