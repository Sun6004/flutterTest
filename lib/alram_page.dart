import 'package:flutter/material.dart';
import 'alram.dart';

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
            title: Text(
                '${alarms[index].dateTime.hour}:${alarms[index].dateTime.minute}'),
            subtitle: Text(alarms[index].memo),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
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
      initialTime: TimeOfDay.fromDateTime(alarms[index].dateTime),
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
        dateTime: DateTime(
          alarms[index].dateTime.year,
          alarms[index].dateTime.month,
          alarms[index].dateTime.day,
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
}
