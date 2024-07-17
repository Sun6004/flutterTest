import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final String question;
  final String answer;

  const ResultPage({super.key, required this.question, required this.answer});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.question),
            Text(widget.answer),
            ElevatedButton(
                onPressed: () {
                  //Navigator.of(context).pop();
                  Navigator.pop(context);
                },
                child: const Text('돌아가기'))
          ],
        ),
      ),
    );
  }
}
