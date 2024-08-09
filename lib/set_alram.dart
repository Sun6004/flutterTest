import 'package:flutter/material.dart';
import 'alram.dart';
import 'alram_page.dart';

class SaveAlarmEx extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('save alram example'),
        ),
        body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              child: Text('알람 저장하기'),
              onPressed: () async {
                // 시간과 메모를 입력받기 위한 다이얼로그 표시
                TimeOfDay? selectedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );

                if (selectedTime == null) return; // 사용자가 시간을 선택하지 않으면 종료

                TextEditingController memoController = TextEditingController();
                String? memo = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('메모 입력'),
                      content: TextField(
                        controller: memoController,
                        decoration: InputDecoration(hintText: '메모를 입력하세요'),
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('취소'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('확인'),
                          onPressed: () {
                            Navigator.of(context).pop(memoController.text);
                          },
                        ),
                      ],
                    );
                  },
                );

                if (memo == null || memo.isEmpty)
                  return; // 사용자가 메모를 입력하지 않으면 종료

                // 현재 날짜와 선택한 시간으로 알람 시간 설정
                DateTime now = DateTime.now();
                DateTime alarmTime = DateTime(now.year, now.month, now.day,
                    selectedTime.hour, selectedTime.minute);

                // 새로운 Alarm 객체 생성
                Alarm newAlarm = Alarm(
                  dateTime: alarmTime,
                  memo: memo,
                );

                // 알람 저장
                await saveAlarm(newAlarm);

                // 저장 완료 메시지 표시
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('알람이 저장되었습니다.')),
                );
              },
            ),
            SizedBox(height: 25),
            ElevatedButton(
              child: Text('알람 목록 보기'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlarmPage()),
                );
              },
            ),
          ]),
        ));
  }
}
