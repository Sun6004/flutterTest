import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON 변환을 위한 패키지

class Alarm {
  DateTime dateTime; // 알람이 울릴 날짜와 시간
  String memo; // 알람 메모

  // 생성자
  Alarm({required this.dateTime, required this.memo});

  // Alarm 객체를 JSON 형식으로 변환
  Map<String, dynamic> toJson() => {
        'dateTime': dateTime.toIso8601String(), // DateTime을 ISO 8601 문자열로 변환
        'memo': memo, // 메모 문자열
      };

  // JSON 형식의 데이터를 Alarm 객체로 변환
  static Alarm fromJson(Map<String, dynamic> json) {
    return Alarm(
      dateTime:
          DateTime.parse(json['dateTime']), // ISO 8601 문자열을 DateTime 객체로 변환
      memo: json['memo'], // 메모 문자열
    );
  }
}

// 알람을 SharedPreferences에 저장하는 함수
Future<void> saveAlarm(Alarm alarm) async {
  // SharedPreferences 인스턴스를 비동기로 가져옵니다.
  final prefs = await SharedPreferences.getInstance();

  // Alarm 객체를 JSON 문자열로 변환합니다.
  final jsonAlarm = jsonEncode(alarm.toJson());

  // JSON 문자열을 'alarm' 키에 저장합니다.
  await prefs.setString('alarm', jsonAlarm);
}

// SharedPreferences에서 알람을 불러오는 함수
Future<Alarm?> loadAlarm() async {
  // SharedPreferences 인스턴스를 비동기로 가져옵니다.
  final prefs = await SharedPreferences.getInstance();

  // 'alarm' 키로 저장된 JSON 문자열을 가져옵니다.
  final jsonString = prefs.getString('alarm');

  // JSON 문자열이 없으면 null을 반환합니다.
  if (jsonString == null) {
    return null;
  }

  // JSON 문자열을 Map 형식으로 디코딩합니다.
  final jsonMap = jsonDecode(jsonString);

  // 디코딩된 Map 데이터를 Alarm 객체로 변환하여 반환합니다.
  return Alarm.fromJson(jsonMap);
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
Future<void> saveAlarms(List<Alarm> alarms) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStrings =
      alarms.map((alarm) => jsonEncode(alarm.toJson())).toList();
  await prefs.setStringList('alarms', jsonStrings);
}
