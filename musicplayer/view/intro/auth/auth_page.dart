import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:musicplayer/data/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  // firebase Auth 객체 생성하기
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 이메일/비밀번호 입력 컨트롤러 생성
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 인증 상태 메세지
  String _message = '';

  // 이메일과 비밀번호로 회원가입하는 메소드
  void _signUp() async {
    try {
      // createUserWithEmailAndPassword 메소드로 회원 가입 요청하기
      await _auth.createUserWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      setState(() {
        _message = 'success';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        // 에러 발생 시 메세지
        _message = e.message!;
      });
    }
  }

  // 로그인
  void _signIn() async {
    try {
      // signInWithEmailAndPassword 메서드로 로그인 요청
      await _auth.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);

      setState(() {
        _message = 'success';
      });
      final SharedPreferences preferences =
          await SharedPreferences.getInstance();
      preferences.setString("id", _emailController.text);
      preferences.setString("pw", _passwordController.text);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_emailController.text)
          .set({
        'email': _emailController.text,
        'token': _auth.currentUser?.uid
      }).then((value) {});
    } on FirebaseAuthException catch (e) {
      setState(() {
        _message = e.message!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Constant.APP_NAME),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // email입력필드
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'email',
                    hintText: 'example@google.com',
                    prefixIcon: Icon(Icons.email),
                    suffixIcon: Icon(Icons.check)),
              ),
              SizedBox(height: 20),
              // pw입력필드
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'pass word',
                  prefixIcon: Icon(Icons.password),
                  suffixIcon: Icon(Icons.check),
                ),
                obscureText: true, //비밀번호 숨기기
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(onPressed: _signUp, child: Text('회원 가입')),
                  ElevatedButton(onPressed: _signIn, child: Text('Log In'))
                ],
              ),
              Text(_message),
            ],
          ),
        ),
      ),
    );
  }
}
