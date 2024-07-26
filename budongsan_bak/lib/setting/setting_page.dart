import 'package:budongsan/intro/intro_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int mapType = 0;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    initShared();
  }

  void initShared() async {
    prefs = await SharedPreferences.getInstance();
    var type = prefs.getInt('mapType');
    if (type != null) {
      setState(() {
        mapType = type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Setting'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) {
                    return const IntroPage();
                  }), (root) => false);
                },
                child: Text('Log out')),
            SizedBox(
              height: 30,
            ),
            Text('지도유형'),
            SizedBox(
              height: 200,
              child: ListView(
                children: [
                  RadioListTile<int>(
                    title: const Text('terrain'),
                    value: 0,
                    groupValue: mapType,
                    onChanged: (value) async {
                      await prefs.setInt('mapType', value!);
                      setState(() {
                        mapType = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('satellite'),
                    value: 1,
                    groupValue: mapType,
                    onChanged: (value) async {
                      await prefs.setInt('mapType', value!);
                      setState(() {
                        mapType = value!;
                      });
                    },
                  ),
                  RadioListTile<int>(
                    title: const Text('hybrid'),
                    value: 2,
                    groupValue: mapType,
                    onChanged: (value) async {
                      await prefs.setInt('mapType', value!);
                      setState(() {
                        mapType = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
