import 'dart:convert'; // JSON 변환을 위한 패키지
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Alarm {
  final int id;
  final DateTime time;
  final String memo;
  bool isEnabled; // 알람 활성화 상태

  Alarm({
    required this.id,
    required this.time,
    required this.memo,
    this.isEnabled = true, // 기본값은 true (켜짐 상태)
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'time': time.toIso8601String(),
        'memo': memo,
        'isEnabled': isEnabled,
      };

  factory Alarm.fromJson(Map<String, dynamic> json) => Alarm(
        id: json['id'],
        time: DateTime.parse(json['time']),
        memo: json['memo'],
        isEnabled: json['isEnabled'] ?? true, // JSON에서 상태 불러오기
      );
}

// 알림 플러그인 인스턴스 생성
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// 알림 시스템 초기화 함수
Future<void> initializeNotifications() async {
  final AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // 안드로이드용 초기화 설정
  final DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(); // iOS용 초기화 설정
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS); // 전체 초기화 설정
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

// DateTime을 TZDateTime으로 변환하는 함수
tz.TZDateTime _convertToTZDateTime(DateTime dateTime) {
  final location = tz.getLocation('Asia/Seoul'); // 한국 시간대
  return tz.TZDateTime.from(dateTime, location);
}

// 알람 예약 함수
Future<void> scheduleAlarm(Alarm alarm) async {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_channel_id',
    'Alarm Channel',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
  );

  final DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();

  final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  // DateTime을 TZDateTime으로 변환
  tz.TZDateTime scheduledDate = _convertToTZDateTime(alarm.time);

  // 알람 스케줄링
  await flutterLocalNotificationsPlugin.zonedSchedule(
    alarm.id,
    '알람',
    alarm.memo,
    scheduledDate,
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}

// 고유 ID를 생성하는 함수 (시간 기반)
int generateUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(100000);
  // 현재 시간을 밀리초 단위로 가져와서 나머지를 사용해 ID 생성 (0~99999 범위)
}

// SharedPreferences에서 저장된 알람을 로드하고, 각각의 알람을 스케줄링하는 함수
Future<void> loadAndScheduleAlarms() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> jsonStrings =
      prefs.getStringList('alarms') ?? []; // 저장된 알람 데이터 불러오기
  final List<Alarm> alarms = jsonStrings
      .map((jsonString) => Alarm.fromJson(jsonDecode(jsonString)))
      .toList(); // JSON 문자열을 Alarm 객체 리스트로 변환

  // 모든 알람에 대해 스케줄링
  for (var alarm in alarms) {
    await scheduleAlarm(alarm);
  }
}

// 알람 스케줄링 함수
Future<void> schedulingAlarm(Alarm alarm) async {
  if (alarm.isEnabled) {
    // 이미 활성화되어 있는 알람은 새로 스케줄링
    tz.TZDateTime scheduledDate = _convertToTZDateTime(alarm.time);
    final NotificationDetails platformChannelSpecifics =
        _getPlatformChannelSpecifics();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      alarm.id,
      '알람',
      alarm.memo,
      scheduledDate,
      platformChannelSpecifics,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}

// 여러 알람을 SharedPreferences에서 불러오는 함수
Future<List<Alarm>> getAlarms() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? jsonStrings = prefs.getStringList('alarms');

  if (jsonStrings == null) {
    return [];
  }

  return jsonStrings.map((jsonString) {
    final jsonMap = jsonDecode(jsonString);
    return Alarm.fromJson(jsonMap);
  }).toList();
}

// 여러 알람을 SharedPreferences에 저장하는 함수
Future<void> saveAlarms(List<Alarm> newAlarms) async {
  final prefs = await SharedPreferences.getInstance();

  // 기존 알람 데이터 불러오기
  final List<String> existingJsonStrings = prefs.getStringList('alarms') ?? [];
  final List<Alarm> existingAlarms = existingJsonStrings
      .map((jsonString) => Alarm.fromJson(jsonDecode(jsonString)))
      .toList();

  // 새로운 알람 추가
  existingAlarms.addAll(newAlarms);

  // 모든 알람을 JSON 문자열로 변환
  final jsonStrings =
      existingAlarms.map((alarm) => jsonEncode(alarm.toJson())).toList();

  // 업데이트된 알람 리스트 저장
  await prefs.setStringList('alarms', jsonStrings);
}

// 플랫폼별 알림 세부 설정 함수 (재사용)
NotificationDetails _getPlatformChannelSpecifics() {
  final AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_channel_id',
    'Alarm Channel',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
  );

  final DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails();

  return NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);
}
