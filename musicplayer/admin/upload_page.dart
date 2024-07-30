import 'dart:js_interop';

import 'package:flutter/material.dart';

import '../data/music.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

const List<String> list = <String>['piano', 'voice', 'violin'];

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // FilePickerResult 인스턴스 생성하기
  FilePickerResult? _pickedFile;
  FilePickerResult? _imagePickedFile;

  // 로컬에 있는 파일의 경로와 이름
  String? _filePath;
  String? _imageFilepath;

  // 로컬에 있는 파일이름
  String? _fileName;
  String? _imageFileName;

  // 업로드한 파일의 다운로드 URL
  String? _downloadUrl;

  // 업로드 중인지 여부
  bool _isUploading = false;

  final TextEditingController _composerController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();

  String dropdownValue = list.first;

  //로컬에서 파일을 선택하는 메소드
  Future<void> _pickFile(int type) async {
    var picked = await FilePicker.platform.pickFiles();

    // 선택된 파일이 있다면
    if (picked != null) {
      // 파일의 경로에 이름저장
      if (type == 1) {
        setState(() {
          _pickedFile = picked;
          _filePath = _pickedFile!.files.first.name;
          _fileName = _pickedFile!.files.first.name;
        });
      } else {
        setState(() {
          _imagePickedFile = picked;
          _imageFilepath = _imagePickedFile!.files.first.name;
          _imageFileName = _imagePickedFile!.files.first.name;
        });
      }
    }
  }

  // 파이어베이스 스토리지에 파일을 업로드 하는 메소드
  Future<void> _uploadFile() async {
    // 파일이 선택되었다면
    if (_filePath != null) {
      // 참조 생성하기
      Reference reference = _storage.ref().child('files/$_fileName');

      // 파일 업로드(byte사용)
      TaskSnapshot uploadTask =
          await reference.putData(_pickedFile!.files.first.bytes!);
      setState(() {
        _isUploading = true;
      });

      // 다운로드 url얻기
      String downloadUrl = await uploadTask.ref.getDownloadURL();
      CollectionReference _filesRef = _firestore.collection('files');
      String imageDownloadUrl = '';
      if (_imageFilepath != null) {
        Reference reference = _storage.ref().child('files/$_imageFileName');

        // 파일업로드
        TaskSnapshot uploadTask =
            await reference.putData(_imagePickedFile!.files.first.bytes!);

        // 다운로드 url얻기
        imageDownloadUrl = await uploadTask.ref.getDownloadURL();
      }
      // URL저장
      Music music = Music(
          _fileName!,
          _composerController.value.text!,
          _tagController.value.text,
          dropdownValue,
          _pickedFile!.files.single.size,
          'audio/${_pickedFile!.files.single.extension}',
          downloadUrl,
          imageDownloadUrl);

      await _filesRef.add(music.toMap());

      setState(() {
        _downloadUrl = downloadUrl;
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: TextField(
                decoration: InputDecoration(hintText: '작곡가'),
                controller: _composerController,
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: 250,
              child: TextField(
                  decoration: InputDecoration(hintText: 'TAG(쉼표로 구분)'),
                  controller: _tagController),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: dropdownValue,
              icon: const Icon(Icons.music_note),
              elevation: 16,
              underline: Container(
                height: 2,
                color: Colors.deepPurpleAccent,
              ),
              onChanged: (String? value) {
                setState(() {
                  dropdownValue = value!;
                });
              },
              items: list.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  child: Text(value),
                  value: value,
                );
              }).toList(),
            ),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  _pickFile(1);
                },
                child: Text('음악파일: ${_fileName}')),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  _pickFile(2);
                },
                child: Text('이미지파일: ${_imageFileName}')),
            SizedBox(height: 16),
            ElevatedButton(
                onPressed: () {
                  _uploadFile();
                },
                child: Text('Upload to Firebase Storage')),
            SizedBox(height: 16),
            _downloadUrl != null
                ? Text('File uploaded successfully')
                : Text('No file to display'),
            SizedBox(height: 16),
            _isUploading
                ? const CircularProgressIndicator(strokeWidth: 10)
                : Text('No file uploading'),
          ],
        ),
      ),
    );
  }
}
