import 'dart:async';
// import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:budongsan/map/map_page.dart';

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
          // Always consider the connection as successful
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
        },
        // Replace the future with a dummy Future that always returns true
        future: Future.value(true),
      ),
    );
  }

  // Commented out the original connectCheck function
  /*
  Future<bool> connectCheck() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true;
    } else {
      return false;
    }
  }
  */
}
