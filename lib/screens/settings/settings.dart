import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hsk_learner/sql/pg_update.dart';
import 'package:hsk_learner/sql/preferences_sql.dart';
import 'package:hsk_learner/sql/sql_helper.dart';
import '../../sql/character_stokes_sql.dart';
import '../../utils/platform_info.dart';
import 'preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool translation = Preferences.getPreference("showTranslations");
  bool reviewPinyin = Preferences.getPreference(
    "show_pinyin_by_default_in_review",
  );
  bool checkVersionOnStart = Preferences.getPreference(
    "check_for_new_version_on_start",
  );
  bool debug = Preferences.getPreference("debug");
  bool allowSkipUnits = Preferences.getPreference("allow_skip_units");
  bool showExampleSentences = Preferences.getPreference("show_sentences");
  bool allowAutoComplete = Preferences.getPreference(
    "allow_auto_complete_unit",
  );
  bool showLiteralInUnitLearn = Preferences.getPreference(
    "show_literal_meaning_in_unit_learn",
  );
  List<String> courses = Preferences.getPreference("courses");
  List<String> homePages = ["home", "review", "stats"];
  String defaultHomePage = Preferences.getPreference("default_home_page");
  bool showDebugOptions = false;
  bool isDownloading = false;
  bool isDeleting = false;
  bool isDataDownloaded =
      SharedPrefs.prefs.getBool('character_stroke_data_downloaded') ?? false;

  setSettingBool({
    required String name,
    required String type,
    required bool value,
  }) {
    String val = value == true ? "1" : "0";
    PreferencesSql.setPreference(name: name, value: val, type: type);
    Preferences.setPreference(name: name, value: value);
  }

  setSettingString({
    required String name,
    required String type,
    required String value,
  }) {
    PreferencesSql.setPreference(name: name, value: value, type: type);
    Preferences.setPreference(name: name, value: value);
  }

  _showDefaultHomePageActionSheet<bool>(BuildContext context) {
    showCupertinoModalPopup<bool>(
      context: context,
      builder: (BuildContext context) =>
          CupertinoActionSheet(
            title: const Text('Select a default home page'),
            actions: List<CupertinoActionSheetAction>.generate(
              homePages.length,
              (index) {
                return CupertinoActionSheetAction(
                  isDefaultAction: true,
                  onPressed: () {
                    setSettingString(
                      name: 'default_home_page',
                      type: 'string',
                      value: homePages[index],
                    );
                    Navigator.pop(context, true);
                    setState(() {
                      defaultHomePage = Preferences.getPreference(
                        "default_home_page",
                      );
                    });
                  },
                  child: Text(homePages[index]),
                );
              },
            ),
          ),
    );
  }

  _showThemeSelectionDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) =>
          CupertinoActionSheet(
            title: const Text('Select Theme'),
            actions: [
              CupertinoActionSheetAction(
                onPressed: () {
                  SharedPrefs.prefs.setString('theme', 'light');
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Light'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  SharedPrefs.prefs.setString('theme', 'dark');
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('Dark'),
              ),
              CupertinoActionSheetAction(
                onPressed: () {
                  SharedPrefs.prefs.setString('theme', 'system');
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text('System'),
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(middle: Text("Settings")),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text("REVIEW"),
              children: [
                CupertinoListTile(
                  title: const Text("Show translations in preview"),
                  trailing: CupertinoSwitch(
                    value: translation,
                    activeTrackColor: CupertinoColors.activeBlue,
                    onChanged: (bool value) {
                      setSettingBool(
                        name: "showTranslations",
                        type: "bool",
                        value: value,
                      );
                      setState(() => translation = value);
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text("Show pinyin by default"),
                  trailing: CupertinoSwitch(
                    value: reviewPinyin,
                    activeTrackColor: CupertinoColors.activeBlue,
                    onChanged: (bool value) {
                      setSettingBool(
                        name: "show_pinyin_by_default_in_review",
                        type: "bool",
                        value: value,
                      );
                      setState(() => reviewPinyin = value);
                    },
                  ),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text("LEARN"),
              children: [
                CupertinoListTile(
                  title: const Text("Show example sentences"),
                  trailing: CupertinoSwitch(
                    value: showExampleSentences,
                    activeTrackColor: CupertinoColors.activeBlue,
                    onChanged: (bool value) {
                      setSettingBool(
                        name: "show_sentences",
                        type: "bool",
                        value: value,
                      );
                      setState(() => showExampleSentences = value);
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text("Show literal meaning"),
                  trailing: CupertinoSwitch(
                    value: showLiteralInUnitLearn,
                    activeTrackColor: CupertinoColors.activeBlue,
                    onChanged: (bool value) {
                      setSettingBool(
                        name: "show_literal_meaning_in_unit_learn",
                        type: "bool",
                        value: value,
                      );
                      setState(() => showLiteralInUnitLearn = value);
                    },
                  ),
                ),
                CupertinoListTile(
                  title: const Text("Default home page"),
                  trailing: const CupertinoListTileChevron(),
                  additionalInfo: Text(defaultHomePage),
                  onTap: () => _showDefaultHomePageActionSheet(context),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text("APPEARANCE"),
              children: [
                CupertinoListTile(
                  title: const Text("Theme"),
                  trailing: const CupertinoListTileChevron(),
                  additionalInfo: Text(switch (SharedPrefs.prefs.getString('theme')) {
                    "dark" => "Dark",
                    "light" => "Light",
                    _ => "System",
                  }),
                  onTap: () => _showThemeSelectionDialog(context),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text("DATA"),
              children: [
                CupertinoListTile(
                  title: const Text("Character stroke data (30MB)"),
                  subtitle: Text(isDataDownloaded ? "Downloaded" : "Not downloaded"),
                  trailing: isDownloading 
                    ? const CupertinoActivityIndicator() 
                    : (isDataDownloaded ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeGreen) : const Icon(CupertinoIcons.cloud_download, color: CupertinoColors.activeBlue)),
                  onTap: isDataDownloaded || isDownloading ? null : () async {
                    setState(() => isDownloading = true);
                    CharacterStokesSql.createTable().then((value) {
                      SharedPrefs.prefs.setBool('character_stroke_data_downloaded', true);
                      setState(() => isDataDownloaded = true);
                    }).whenComplete(() => setState(() => isDownloading = false));
                  },
                ),
              ],
            ),
            if (showDebugOptions)
              CupertinoListSection.insetGrouped(
                header: const Text("DEBUG OPTIONS"),
                children: [
                  CupertinoListTile(
                    title: const Text("Debug mode"),
                    trailing: CupertinoSwitch(
                      value: debug,
                      onChanged: (bool value) {
                        setSettingBool(name: "debug", type: "bool", value: value);
                        setState(() => debug = value);
                      },
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text("Allow skip units"),
                    trailing: CupertinoSwitch(
                      value: allowSkipUnits,
                      onChanged: (bool value) {
                        setSettingBool(name: "allow_skip_units", type: "bool", value: value);
                        setState(() => allowSkipUnits = value);
                      },
                    ),
                  ),
                  CupertinoListTile(
                    title: const Text("Refresh DB"),
                    onTap: isDeleting ? null : () async {
                      setState(() => isDeleting = true);
                      await SQLHelper.refreshDB();
                      setState(() => isDeleting = false);
                    },
                  ),
                ],
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
