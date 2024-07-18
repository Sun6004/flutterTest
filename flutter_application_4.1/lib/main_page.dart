import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'question_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_database/firebase_database.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MainPage();
  }
}

final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

class _MainPage extends State<MainPage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  late DatabaseReference _testRef;
  late List<String> testList = List.empty(growable: true);

  Future<List<String>> loadAsset() async {
    var connectivityRes = await Connectivity().checkConnectivity();
    if (connectivityRes == ConnectivityResult.mobile ||
        connectivityRes == ConnectivityResult.wifi) {
      await _testRef.get().then((value) => value.children.forEach((element) {
            testList.add(element.value.toString());
          }));
    } else {
      if (mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('App'),
              content: Text('지금 인터넷에 연결되어있지 않아 앱을 사용할 수 없습니다.'
                  '다시 시도해주세요.'),
            );
          },
        );
      }
    }
    return testList;
  }

  String welcomeTitle = '?';
  bool bannerUse = false;
  int itemHeight = 50;

  @override
  void initState() {
    super.initState();
    remoteConfigInit();
    _testRef = database.ref('test');
  }

  Future<void> remoteConfigInit() async {
    try {
      // 기본값 설정
      await remoteConfig.setDefaults({
        'welcome': '?',
        'banner': false,
        'item_height': 50,
      });

      // 최소 페치 간격 설정 (개발 중에는 짧게 설정)
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // 값 가져오기
      await remoteConfig.fetchAndActivate();

      setState(() {
        welcomeTitle = remoteConfig.getString("welcome");
        bannerUse = remoteConfig.getBool("banner");
        itemHeight = remoteConfig.getInt("item_height");
      });
    } catch (e) {
      print('Failed to fetch remote config. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: bannerUse
          ? AppBar(
              title: Text(welcomeTitle),
            )
          : null,
      body: FutureBuilder(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              return ListView.builder(
                itemBuilder: (context, value) {
                  Map<String, dynamic> item = jsonDecode(snapshot.data![value]);
                  return InkWell(
                    child: SizedBox(
                      height: remoteConfig.getInt("item_height").toDouble(),
                      child: Card(
                        color: Colors.amber,
                        child: Text(item['title'].toString()),
                      ),
                    ),
                    onTap: () async {
                      await FirebaseAnalytics.instance.logEvent(
                        name: 'test_click',
                        parameters: {'test_name': item['title'].toString()},
                      ).then((result) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return QuestionPage(question: item);
                        }));
                      });
                    },
                  );
                },
                itemCount: snapshot.data!.length,
              );
            case ConnectionState.none:
              return const Center(
                child: Text('No Data'),
              );
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
        future: loadAsset(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          FirebaseDatabase database = FirebaseDatabase.instance;
          DatabaseReference testRef = database.ref('test');
          testRef.push().set("""{
            "title": "당신이 좋아하는 애완동물은?",
            "question": "무인도에 떠내려왔을때 보이는 이것은?",
            "selects": [
              "생존 키트",
              "phone",
              "tent",
              "무인도에서 살아남기"
            ],
            "answer": [
              "No Animals",
              "tiger",
              "cat",
              "bird"
            ]
          }""");
          testRef.push().set("""{
            "title": "5sec MBTI I/E",
            "question": "친구와 함께 간 미술관 당신이라면?",
            "selects": [
              "Say a lot",
              "Thinking a lot"
            ],
            "answer": [
              "E",
              "I"
            ]
          }""");
          testRef.push().set("""{
            "title": "Which love do u want?",
            "question": "Where do u wash first?",
            "selects": [
              "Head",
              "Body",
              "Legs"
            ],
            "answer": [
              "1",
              "2",
              "3"
            ]
           }""");
        },
      ),
    );
  }
}
