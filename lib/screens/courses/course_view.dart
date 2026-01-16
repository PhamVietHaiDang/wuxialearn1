import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../learn/unit_view.dart';
import '../settings/preferences.dart';

class CourseView extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> unitList;
  final List<Widget> Function(List<Map<String, dynamic>> hskList) gridItems;
  final Function update;
  final String courseName;
  const CourseView({
    super.key,
    required this.unitList,
    required this.gridItems,
    required this.update,
    required this.courseName,
  });

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  List<String> courses = Preferences.getPreference("courses");
  late int hskLevel;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.unitList,
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
              ) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> courseList = snapshot.data!;
                  hskLevel = getHskLevel(courseList);
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 16)),
                      ...widget.gridItems(courseList),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  int getHskLevel(List<Map<String, dynamic>> unitList) {
    if (widget.courseName != "hsk") {
      return 3;
    }
    int topHskLevel = 2;
    bool fullCompleted = true;
    for (final unit in unitList) {
      int hskLevel = unit["hsk"];
      if (hskLevel > topHskLevel) {
        int completed = unit["completed"];
        if (completed == 1) {
          topHskLevel = hskLevel;
        }
      } else if (hskLevel == topHskLevel) {
        int completed = unit["completed"];
        if (completed != 1) {
          fullCompleted = false;
        }
      }
    }
    topHskLevel = fullCompleted ? topHskLevel + 1 : topHskLevel;
    return topHskLevel;
  }
}

class GridItem extends StatelessWidget {
  final int index;
  final List<Map<String, dynamic>> unitList;
  final Function updateUnits;
  final String courseName;
  final bool allowSkipUnits;
  const GridItem({
    super.key,
    required this.index,
    required this.unitList,
    required this.courseName,
    required this.updateUnits,
    required this.allowSkipUnits,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = unitList[index]["completed"] == 1;
    final bool isUnitOpen = allowSkipUnits || index == 0 || unitList[index - 1]["completed"] == 1;
    
    final Color activeColor = Colors.blue.shade600;
    final Color completedColor = Colors.green.shade500;
    final Color lockedColor = Colors.grey.shade300;

    final Color statusColor = isCompleted ? completedColor : (isUnitOpen ? activeColor : lockedColor);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnitOpen ? statusColor.withOpacity(0.1) : Colors.transparent,
                border: Border.all(
                  color: statusColor,
                  width: 4,
                ),
                boxShadow: isUnitOpen && !isCompleted ? [
                  BoxShadow(
                    color: statusColor.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ] : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isUnitOpen ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnitView(
                          unit: unitList[index]["unit_id"],
                          name: unitList[index]["unit_name"],
                          updateUnits: updateUnits,
                          courseName: courseName,
                        ),
                      ),
                    ).then((_) => updateUnits());
                  } : null,
                  child: Center(
                    child: Icon(
                      isCompleted ? Icons.check : (isUnitOpen ? Icons.play_arrow_rounded : Icons.lock_outline_rounded),
                      color: statusColor,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
            if (isCompleted)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.star, color: Colors.white, size: 16),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          unitList[index]["unit_name"],
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isUnitOpen ? FontWeight.w600 : FontWeight.w400,
            color: isUnitOpen ? Colors.black87 : Colors.grey,
          ),
        ),
      ],
    );
  }
}
