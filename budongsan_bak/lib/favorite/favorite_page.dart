import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../map/apt_page.dart';

class MyFavoritePage extends StatefulWidget {
  const MyFavoritePage({super.key});

  @override
  State<MyFavoritePage> createState() => _MyFavoritePage();
}

class _MyFavoritePage extends State<MyFavoritePage> {
  List<Map<String, dynamic>> favoriteList = List.empty(growable: true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection('rollcake')
        .doc('favorite')
        .get()
        .then((value) => {
              setState(() {
                favoriteList.add(value.data()!);
              })
            });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My favorite list'),
      ),
      body: ListView.builder(
        itemBuilder: (context, snapshot) {
          return Card(
            child: InkWell(
              child: SizedBox(
                height: 50,
                child: Column(
                  children: [Text(favoriteList[snapshot]['name'])],
                ),
              ),
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return AptPage(
                    aptHash: favoriteList[snapshot]['position']['geohash'],
                    aptInfo: favoriteList[snapshot],
                  );
                }));
              },
            ),
          );
        },
        itemCount: favoriteList.length,
      ),
    );
  }
}
