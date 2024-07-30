import 'package:flutter/material.dart';
import 'package:musicplayer/data/constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
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
                  Future.delayed(const Duration(seconds: 2), () {
                    //2초 후 다음 페이지로 넘어감
                  });
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
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
                  );
                } else {
                  return const AlertDialog(
                    title: Text(Constant.APP_NAME),
                    content: Text('No internet'),
                  );
                }
              } else {
                return const Center(
                  child: Text('No data'),
                );
              }
            case ConnectionState.waiting:
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.none:
              return const Center(
                child: Text('No data'),
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
