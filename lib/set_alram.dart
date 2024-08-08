import 'package:flutter/material.dart';
import 'alram.dart';

class SaveAlarmExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알람 저장 예시'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('알람 저장하기'),
          onPressed: () async {
            // 현재 시간으로부터 1시간 후로 알람 설정
            DateTime alarmTime = DateTime.now().add(Duration(hours: 1));

            // 새로운 Alarm 객체 생성
            Alarm newAlarm = Alarm(
              dateTime: alarmTime,
              memo: '1시간 후 알람',
            );

            // 알람 저장
            await saveAlarm(newAlarm);

            // 저장 완료 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('알람이 저장되었습니다.')),
            );
          },
        ),
      ),
    );
  }
}
