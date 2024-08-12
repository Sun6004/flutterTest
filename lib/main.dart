import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'set_alram.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  File? _imageFile;
  String _text = '';
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
      _text = prefs.getString('userText') ?? '';
      _textController.text = _text;
      String? imagePath = prefs.getString('imagePath');
      if (imagePath != null) {
        _imageFile = File(imagePath);
      }
    });
  }

  Future<void> _saveData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('userText', _textController.text);
    if (_imageFile != null) {
      prefs.setString('imagePath', _imageFile!.path);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _saveData();
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
        _daysPassed = difference; // 경과된 일 수를 저장
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
                                      _pickImage();
                                    },
                                    child: Text('이미지 선택'),
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: _textController,
                                    decoration:
                                        InputDecoration(labelText: '이름 입력'),
                                    onChanged: (value) {
                                      setState(() {
                                        _text = value;
                                      });
                                      _saveData();
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('닫기'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: _imageFile != null
                          ? Image.file(_imageFile!, width: 100, height: 100)
                          : Placeholder(
                              fallbackWidth: 100, fallbackHeight: 100),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _saveData != null
                          ? 'Entered Text: $_text' // 경과된 일 수를 출력
                          : '0',
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Select Image'),
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
                                      _pickImage();
                                    },
                                    child: Text('이미지 선택'),
                                  ),
                                  SizedBox(height: 16),
                                  TextField(
                                    controller: _textController,
                                    decoration:
                                        InputDecoration(labelText: '이름 입력'),
                                    onChanged: (value) {
                                      setState(() {
                                        _text = value;
                                      });
                                      _saveData();
                                    },
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('닫기'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: _imageFile != null
                          ? Image.file(_imageFile!, width: 100, height: 100)
                          : Placeholder(
                              fallbackWidth: 100, fallbackHeight: 100),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _saveData != null
                          ? 'Entered Text: $_text' // 경과된 일 수를 출력
                          : '0',
                    ),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Select Image'),
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
