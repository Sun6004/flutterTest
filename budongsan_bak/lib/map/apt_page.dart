import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';

class AptPage extends StatefulWidget {
  final String aptHash;
  final Map<String, dynamic> aptInfo;

  const AptPage({super.key, required this.aptHash, required this.aptInfo});

  @override
  State<AptPage> createState() => _AptPage();
}

class _AptPage extends State<AptPage> {
  late CollectionReference aptRef;

  @override
  void initState() {
    super.initState();
    aptRef = FirebaseFirestore.instance.collection('wydmu17me');
  }

  int startYear = 2006;
  Icon favoriteIcon = const Icon(Icons.favorite_border);

  @override
  Widget build(BuildContext context) {
    final usersQuery = aptRef
            .orderBy('deal_ymd')
            .where('deal_ymd', isGreaterThanOrEqualTo: '${startYear}0000')
        as Query<Map<String, dynamic>>;

    // 현재 디바이스의 화면 크기, 방향, 해상도 등과 같은 정보를 제공하는 클래스
    // 화면 크기와 방향에 대응하는 레이아웃을 만들 수 있어 반응형 디자인을 구현할 때 유용
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('rollcake')
                    .doc('favorite')
                    .set(widget.aptInfo);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('즐겨찾기로 등록했습니다.')));
              },
              icon: favoriteIcon)
        ],
        title: Text(widget.aptInfo['name']),
      ),
      body: Column(
        children: [
          SizedBox(
            width: screenSize.width,
            child: Text('Apt name: ${widget.aptInfo['name']}'),
          ),
          SizedBox(
            width: screenSize.width,
            child: Text('Apt Address: ${widget.aptInfo['address']}'),
          ),
          SizedBox(
            width: screenSize.width,
            child: Text('세대 수: ${widget.aptInfo['ALL_HSHLD_CO']}'),
          ),
          SizedBox(
            width: screenSize.width,
            child: Text('Total parking: ${widget.aptInfo['CNT_PA']}'),
          ),
          SizedBox(
            width: screenSize.width,
            child: Text('60m2 이하: ${widget.aptInfo['KAPTMPAREA60']} 세대'),
          ),
          SizedBox(
            width: screenSize.width,
            child: Text('60m2 ~ 85m2: ${widget.aptInfo['KAPTMPAREA85']} 세대'),
          ),
          Container(
            color: Colors.black,
            height: 1,
            margin: const EdgeInsets.only(top: 5, bottom: 5),
          ),
          Text('검색 시작 년도: ${startYear}년'),
          Slider(
            value: startYear.toDouble(),
            onChanged: (value) {
              setState(() {
                startYear = value.toInt();
              });
            },
            min: 2006,
            max: 2023,
          ),
          Expanded(
              child: FirestoreListView<Map<String, dynamic>>(
            query: usersQuery,
            pageSize: 20,
            itemBuilder: (context, snapshot) {
              Map<String, dynamic> apt = snapshot.data();
              return Card(
                child: Row(
                  children: [
                    Column(
                      children: [
                        Text('계약일시: ${apt['deal_ymd'].toString()}'),
                        Text('계약층: ${apt['floor'].toString()}층'),
                        Text('계약가격: ${double.parse(apt['obj_amt']) / 10000}억'),
                        Text('전용면적: ${apt['bldg_area']}m2'),
                      ],
                    ),
                    Expanded(child: Container())
                  ],
                ),
              );
            },
            emptyBuilder: (context) {
              return const Text('No sales data');
            },
            errorBuilder: (context, err, Stack) {
              return const Text('No data');
            },
          ))
        ],
      ),
    );
  }
}
