import 'package:cloud_firestore/cloud_firestore.dart';

class Music {
  final String name; //이름
  final String composer; //작곡가
  final String tag; //태그
  final String category; //카테고리
  final int size; //파일크기
  final String type; //파일유형
  final String downloadUrl;
  final String imageDownloadUrl; //썸네일 URL

  Music(this.name, this.composer, this.tag, this.category, this.size, this.type,
      this.downloadUrl, this.imageDownloadUrl);

  // fire store에 저장된 데이터를 객체로 반환
  static Music fromStoreData(DocumentSnapshot snapshot) {
    var data = snapshot.data() as Map<String, dynamic>;
    return Music(
        data['name'],
        data['composer'],
        data['tag'],
        data['category'],
        data['size'],
        data['type'],
        data['downloadUrl'],
        data['imageDownloadUrl']);
  }

  // 데이터를 Map형식으로 반환
  Map<String, dynamic> toMap() {
    Map<String, dynamic> mapMusic = {};
    mapMusic['name'] = name;
    mapMusic['composer'] = composer;
    mapMusic['tag'] = tag;
    mapMusic['category'] = category;
    mapMusic['size'] = size;
    mapMusic['type'] = type;
    mapMusic['downloadUrl'] = downloadUrl;
    mapMusic['imageDownloadUrl'] = imageDownloadUrl;
    return mapMusic;
  }
}
