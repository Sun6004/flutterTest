import 'package:flutter/material.dart';
import 'package:musicplayer/data/constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'auth/auth_page.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              Constant.APP_NAME,
              style: TextStyle(fontSize: 50),
            ),
            SizedBox(
              height: 20,
            ),
            Icon(
              Icons.audiotrack,
              size: 100,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context){
        return AuthPage();
      }))
    });
  }

  // 인터넷 연결체크 로직
  // Future<bool> connectCheck() async {
  //   var connectivityResult = await Connectivity().checkConnectivity();
  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // }
}
