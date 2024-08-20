import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'set_alram.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:test_project/save_image.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: DateCounterScreen(),
    );
  }
}

class DateCounterScreen extends StatefulWidget {
  @override
  _DateCounterScreenState createState() => _DateCounterScreenState();
}

class _DateCounterScreenState extends State<DateCounterScreen> {
  DateTime? _selectedDate; // 사용자가 선택한 날짜를 저장할 변수
  int? _daysPassed; // 선택한 날짜로부터 경과된 일 수를 저장할 변수
  File? _imageFile1;
  File? _imageFile2;
  String _UserName1 = '';
  String _UserName2 = '';
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedDate(); // 앱 시작 시 저장된 날짜를 불러옵니다.
    _loadData();
  }

  // SharedPreferences에서 저장된 날짜를 불러오는 메서드
  Future<void> _loadSavedDate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedDateString =
        prefs.getString('selectedDate'); // 저장된 날짜를 문자열로 가져옴
    if (savedDateString != null) {
      setState(() {
        _selectedDate =
            DateTime.parse(savedDateString); // 문자열을 DateTime 객체로 변환하여 저장
        _calculateDaysPassed(); // 경과된 일 수를 계산
      });
    }
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // 사용자 1의 데이터를 로드
      _UserName1 = prefs.getString('userName1') ?? '';
      _textController.text = _UserName1; // 사용자 1의 텍스트 컨트롤러에 이름 설정
      String? imagePath1 = prefs.getString('imagePath1');
      if (imagePath1 != null) {
        _imageFile1 = File(imagePath1); // 사용자 1의 이미지 파일 설정
      }

      // 사용자 2의 데이터를 로드
      _UserName2 = prefs.getString('userName2') ?? '';
      _textController.text = _UserName2; // 사용자 2의 텍스트 컨트롤러에 이름 설정
      String? imagePath2 = prefs.getString('imagePath2');
      if (imagePath2 != null) {
        _imageFile2 = File(imagePath2); // 사용자 2의 이미지 파일 설정
      }
    });
  }

  Future<void> _saveDataUser(String userNameKey, String imagePathKey,
      TextEditingController controller, File? imageFile) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(userNameKey, controller.text); // 사용자의 이름을 저장
    if (imageFile != null) {
      prefs.setString(imagePathKey, imageFile.path); // 사용자의 이미지 경로를 저장
    }
  }

  Future<void> _saveDataUser1() async {
    if (_imageFile1 != null) {
      await saveImageToInternalStorage(
          _imageFile1!, 'imagePath1'); // 사용자 1의 이미지를 내부 저장소에 저장
    }
    await _saveDataUser('userName1', 'imagePath1', _textController,
        _imageFile1); // 사용자 1의 데이터를 저장
  }

  Future<void> _saveDataUser2() async {
    if (_imageFile2 != null) {
      await saveImageToInternalStorage(
          _imageFile2!, 'imagePath2'); // 사용자 2의 이미지를 내부 저장소에 저장
    }
    await _saveDataUser('userName2', 'imagePath2', _textController,
        _imageFile2); // 사용자 2의 데이터를 저장
  }

  Future<void> _pickImage1() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile1 = File(pickedFile.path);
      });
      await _saveDataUser1();
    }
  }

  Future<void> _pickImage2() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile2 = File(pickedFile.path);
      });
      await _saveDataUser2();
    }
  }

  // 날짜 선택기를 통해 날짜를 선택하는 메서드
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now(), // 선택된 날짜가 없으면 현재 날짜를 기본값으로 설정
      firstDate: DateTime(2000), // 선택할 수 있는 최소 날짜
      lastDate: DateTime(2100), // 선택할 수 있는 최대 날짜
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // 사용자가 선택한 날짜로 업데이트
        _calculateDaysPassed(); // 새로운 날짜에 따른 경과된 일 수를 계산
        _saveDate(picked); // 선택한 날짜를 저장
      });
    }
  }

  // 선택한 날짜로부터 현재까지 경과된 일 수를 계산하는 메서드
  void _calculateDaysPassed() {
    if (_selectedDate != null) {
      final now = DateTime.now(); // 현재 날짜와 시간을 가져옴
      final difference =
          now.difference(_selectedDate!).inDays; // 현재 날짜와 선택된 날짜의 차이를 일 단위로 계산
      setState(() {
        _daysPassed = difference + 1; // 경과된 일 수를 저장(시작날짜 포함 +1)
      });
    }
  }

  // 선택한 날짜를 SharedPreferences에 저장하는 메서드
  Future<void> _saveDate(DateTime date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedDate', date.toIso8601String()); // 날짜를 문자열로 변환하여 저장
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Date Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // 선택된 날짜를 표시하는 텍스트 위젯
            Text(
              _selectedDate != null
                  ? 'Selected Date: ${DateFormat.yMMMd().format(_selectedDate!)}' // 선택된 날짜를 포맷하여 출력
                  : '날짜를 선택해 주세요.', // 선택된 날짜가 없으면 출력되는 기본 메시지
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            // 경과된 일 수를 표시하는 텍스트 위젯
            Text(
              _daysPassed != null
                  ? 'Days Passed: $_daysPassed' // 경과된 일 수를 출력
                  : '0', // 선택된 날짜가 없으면 출력되는 기본 메시지
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 40),
            // 날짜 설정 버튼
            ElevatedButton(
              onPressed: () => _selectDate(context), // 버튼 클릭 시 날짜 선택기 실행
              child: Text('Set Date'),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTapDown: (_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('이미지 및 텍스트 설정'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _pickImage1();
                                    },
                                    child: Text('이미지 선택'),
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: _textController,
                                    decoration:
                                        InputDecoration(labelText: '이름 입력'),
                                    // `onChanged` 콜백을 제거합니다.
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _UserName1 = _textController
                                          .text; // `TextField`의 값으로 `_UserName1`을 업데이트
                                    });
                                    _saveDataUser1(); // 저장 함수 호출
                                    _textController.clear(); // `TextField`를 초기화
                                    Navigator.pop(context); // 다이얼로그를 닫기
                                  },
                                  child: Text('저장'), // 저장 버튼
                                ),
                                TextButton(
                                  onPressed: () {
                                    _textController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text('닫기'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: ClipOval(
                        child: _imageFile1 != null
                            ? Image.file(
                                _imageFile1!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Color.fromARGB(255, 180, 214, 255),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color.fromARGB(255, 58, 110, 250),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _UserName1.isNotEmpty ? _UserName1 : '이름을 선택해주세요.',
                    ),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTapDown: (_) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('이미지 및 텍스트 설정'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _pickImage2();
                                    },
                                    child: Text('이미지 선택'),
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: _textController,
                                    decoration:
                                        InputDecoration(labelText: '이름 입력'),
                                    // `onChanged` 콜백을 제거합니다.
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _UserName2 = _textController
                                          .text; // `TextField`의 값으로 `_UserName1`을 업데이트
                                    });
                                    _saveDataUser2(); // 저장 함수 호출
                                    _textController.clear(); // `TextField`를 초기화
                                    Navigator.pop(context); // 다이얼로그를 닫기
                                  },
                                  child: Text('저장'), // 저장 버튼
                                ),
                                TextButton(
                                  onPressed: () {
                                    _textController.clear();
                                    Navigator.pop(context);
                                  },
                                  child: Text('닫기'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: ClipOval(
                        child: _imageFile2 != null
                            ? Image.file(
                                _imageFile2!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Color.fromARGB(255, 247, 212, 225),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color.fromARGB(255, 238, 79, 119),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _UserName2.isNotEmpty ? _UserName2 : '이름을 선택해주세요.',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: '알람',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '메세지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            // 알람 아이콘을 탭했을 때 set_alram.dart 페이지로 이동
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SaveAlarmEx()),
            );
          }
        },
      ),
    );
  }
}
