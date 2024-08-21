import 'package:flutter/material.dart';
import 'alram.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class AlarmPage extends StatefulWidget {
  @override
  _AlarmPageState createState() => _AlarmPageState();
}

class _AlarmPageState extends State<AlarmPage> {
  List<Alarm> alarms = [];

  @override
  void initState() {
    super.initState();
    _loadAlarms();
  }

  void _loadAlarms() async {
    // 저장된 알람 불러오기
    List<Alarm> loadedAlarms = await getAlarms();
    setState(() {
      alarms = loadedAlarms;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알람 목록'),
      ),
      body: ListView.builder(
        itemCount: alarms.length,
        itemBuilder: (context, index) {
          return ListTile(
            title:
                Text('${alarms[index].time.hour}:${alarms[index].time.minute}'),
            subtitle: Text(alarms[index].memo),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: alarms[index].isEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      alarms[index].isEnabled = value;
                    });

                    if (value) {
                      // 알람 켜짐 상태로 변경
                      schedulingAlarm(alarms[index]);
                    } else {
                      // 알람 꺼짐 상태로 변경
                      _cancelAlarm(alarms[index].id);
                    }

                    // 알람 상태 변경 시 저장
                    _saveAlarms();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _editAlarm(index),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteAlarm(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _editAlarm(int index) async {
    // 시간 수정
    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(alarms[index].time),
    );

    if (newTime == null) return;

    // 메모 수정
    TextEditingController memoController =
        TextEditingController(text: alarms[index].memo);
    String? newMemo = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('메모 수정'),
          content: TextField(
            controller: memoController,
            decoration: InputDecoration(hintText: '메모를 입력하세요'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('확인'),
              onPressed: () => Navigator.of(context).pop(memoController.text),
            ),
          ],
        );
      },
    );

    if (newMemo == null) return;

    // 알람 업데이트
    setState(() {
      alarms[index] = Alarm(
        id: alarms[index].id,
        time: DateTime(
          alarms[index].time.year,
          alarms[index].time.month,
          alarms[index].time.day,
          newTime.hour,
          newTime.minute,
        ),
        memo: newMemo,
      );
    });

    // 알람 저장
    await saveAlarms(alarms);
  }

  void _deleteAlarm(int index) async {
    setState(() {
      alarms.removeAt(index);
    });
    await saveAlarms(alarms);
  }

  // 알람 상태 변경 시 알람 리스트 저장
  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonStrings =
        alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
    await prefs.setStringList('alarms', jsonStrings);
  }

  // 알람 취소 함수
  Future<void> _cancelAlarm(int alarmId) async {
    await flutterLocalNotificationsPlugin.cancel(alarmId);
  }
}
