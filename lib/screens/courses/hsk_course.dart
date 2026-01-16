import 'package:flutter/material.dart';
import 'package:hsk_learner/screens/learn/test_out.dart';
import '../../sql/learn_sql.dart';
import '../settings/preferences.dart';
import 'course_view.dart';

class HSKCourseView extends StatefulWidget {
  const HSKCourseView({Key? key}) : super(key: key);

  @override
  State<HSKCourseView> createState() => _HSKCourseViewState();
}

class _HSKCourseViewState extends State<HSKCourseView> {
  late Future<List<Map<String, dynamic>>> unitNumList;
  final bool debug = Preferences.getPreference("debug");
  @override
  void initState() {
    super.initState();
    unitNumList = getUnitNum();
  }

  Future<List<Map<String, dynamic>>> getUnitNum() async {
    final data = await LearnSql.count2(courseName: 'hsk');
    return data;
  }

  updateUnits() {
    setState(() {
      unitNumList = getUnitNum();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool allowSkipUnits = Preferences.getPreference("allow_skip_units");
    List<Widget> gridItems(List<Map<String, dynamic>> hskList) {
      List<Widget> widgets = [];
      List<int> hskListOffset = [];
      List<int> hskListUnitLengths = [];
      List<bool> hskIsCompletedList = [];
      for (int i = 0; i < hskList.length; i++) {
        if (i == 0) {
          hskListOffset.add(0);
        } else if (hskList[i]["hsk"] != hskList[i - 1]["hsk"]) {
          hskListUnitLengths.add(i - hskListOffset.last);
          hskListOffset.add(i);
          hskIsCompletedList.add(hskList[i - 1]["completed"] == 1);
        }
        if (i == hskList.length - 1) {
          hskListUnitLengths.add(i - hskListOffset.last + 1);
          hskIsCompletedList.add(hskList[i]["completed"] == 1);
        }
      }
      for (int i = 0; i < hskListOffset.length; i++) {
        // We keep the real hskLevel for logic (like TestOut)
        int realHskLevel = hskList[hskListOffset[i]]["hsk"];
        
        widgets.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 32, 8, 16),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "HSK ${i + 1}", // This masks the level for the UI
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  if (!hskIsCompletedList[i])
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TestOut(hsk: realHskLevel),
                          ),
                        ).then((_) {
                          setState(() {
                            unitNumList = getUnitNum();
                          });
                        });
                      },
                      icon: const Icon(Icons.bolt, size: 18),
                      label: const Text("Test Out"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.orange.shade800,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
        widgets.add(
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 150.0,
                mainAxisSpacing: 24.0,
                crossAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                return GridItem(
                  index: index + hskListOffset[i],
                  unitList: hskList,
                  updateUnits: updateUnits,
                  courseName: "hsk",
                  allowSkipUnits: allowSkipUnits,
                );
              }, childCount: hskListUnitLengths[i]),
            ),
          ),
        );
      }
      return widgets;
    }

    return CourseView(
      unitList: unitNumList,
      gridItems: gridItems,
      update: updateUnits,
      courseName: "hsk",
    );
  }
}
