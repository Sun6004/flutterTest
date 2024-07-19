import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<StatefulWidget> createState() => _IntroPage();
}

class _IntroPage extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.data != null) {
                if (snapshot.data!) {
                  // 2초 후 MapPage로 이동
                  Future.delayed(const Duration(seconds: 2), () {
                    Navigator.of(context)
                        .pushReplacement(MaterialPageRoute(builder: (context) {
                      return const MapPage();
                    }));
                  });
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'budongsan',
                          style: TextStyle(fontSize: 50),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Icon(Icons.apartment_rounded, size: 100),
                      ],
                    ),
                  );
                } else {
                  return const AlertDialog(
                    title: Text('budongsan'),
                    content: Text('지금 인터넷에 연결되지 않아 앱을 사용할 수 없습니다.'
                        '다시 시도해주세요.'),
                  );
                }
              } else {
                return const Center(
                  child: Text('No Data'),
                );
              }
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.none:
              return const Center(
                child: Text('No Data'),
              );
          }
        },
        future: connectCheck(),
      ),
    );
  }

  Future<bool> connectCheck() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
}
