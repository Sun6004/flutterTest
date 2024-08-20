import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

Future<void> saveImageToInternalStorage(
    File imageFile, String imagePathKey) async {
  try {
    // 앱의 내부 저장소 경로를 가져옵니다.
    final directory = await getApplicationDocumentsDirectory();
    final folderPath =
        path.join(directory.path, 'images'); // 'images' 폴더를 만듭니다.

    // 폴더가 존재하지 않으면 생성합니다.
    final folder = Directory(folderPath);
    if (!(await folder.exists())) {
      await folder.create();
    }

    // 이미지 파일 이름을 얻습니다.
    final fileName = path.basename(imageFile.path);

    // 파일을 저장할 경로를 만듭니다.
    final savedImagePath = path.join(folderPath, fileName);

    // 이미지 파일을 해당 경로로 복사합니다.
    final savedImage = await imageFile.copy(savedImagePath);

    // SharedPreferences에 이미지 경로를 저장합니다.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(imagePathKey, savedImage.path);
  } catch (e) {
    print('Error saving image: $e');
  }
}
