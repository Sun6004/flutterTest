import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class Elite {
  String eliteName;
  bool isPresent;

  Elite({required this.eliteName, this.isPresent = true});

  Map<String, dynamic> toJson() => {
        'eliteName': eliteName,
        'isPresent': isPresent,
      };

  Elite.fromJson(Map<String, dynamic> json)
      : eliteName = json['eliteName'],
        isPresent = json['isPresent'];
}

class EliteMemberPage extends StatefulWidget {
  const EliteMemberPage({super.key});

  @override
  State<EliteMemberPage> createState() => _EliteMemberListScreenState();
}

class _EliteMemberListScreenState extends State<EliteMemberPage> {
  List<Elite> _eliteMem = [];

  @override
  void initState() {
    super.initState();
    _loadEliteMembers();
  }

  void _loadEliteMembers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _eliteMem = (prefs.getStringList('eliteMembers') ?? [])
          .map((item) => Elite.fromJson(json.decode(item)))
          .toList();
    });
  }

  void _saveEliteMembers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('eliteMembers',
        _eliteMem.map((item) => json.encode(item.toJson())).toList());
  }

  void _addEliteMember(String eliteName) {
    setState(() {
      _eliteMem.add(Elite(eliteName: eliteName));
      _saveEliteMembers();
    });
  }

  void _editEliteMember(int index, String newEliteName) {
    setState(() {
      _eliteMem[index].eliteName = newEliteName;
      _saveEliteMembers();
    });
  }

  void _deleteEliteMember(int index) {
    setState(() {
      _eliteMem.removeAt(index);
      _saveEliteMembers();
    });
  }

  void _toggleEliteMemberPresence(int index) {
    setState(() {
      _eliteMem[index].isPresent = !_eliteMem[index].isPresent;
      _saveEliteMembers();
    });
  }

  @override
  void dispose() {
    _saveEliteMembers(); // 페이지가 닫힐 때 데이터 저장
    super.dispose();
  }

  void _showRewardDialog(BuildContext context) {
    List<Elite> presentMembers = _eliteMem.where((m) => m.isPresent).toList();
    if (presentMembers.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('참석한 멤버가 9명 이상이어야 합니다.')),
      );
      return;
    }

    presentMembers.shuffle(Random());

    List<Elite> firstPlace = presentMembers.sublist(0, 2);
    List<Elite> secondPlace = presentMembers.sublist(2, 4);
    List<Elite> thirdPlace = presentMembers.sublist(4, 6);
    List<Elite> fourthPlace = presentMembers.sublist(6, 9);
    List<Elite> remainingMembers = presentMembers.sublist(9);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('보상 목록'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    '1등 (2명): ${firstPlace.map((e) => e.eliteName).join(', ')}'),
                SizedBox(height: 8),
                Text(
                    '2등 (2명): ${secondPlace.map((e) => e.eliteName).join(', ')}'),
                SizedBox(height: 8),
                Text(
                    '3등 (2명): ${thirdPlace.map((e) => e.eliteName).join(', ')}'),
                SizedBox(height: 8),
                Text(
                    '4등 (3명): ${fourthPlace.map((e) => e.eliteName).join(', ')}'),
                if (remainingMembers.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                      '남은 멤버들: ${remainingMembers.map((e) => e.eliteName).join(', ')}'),
                ],
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('닫기'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                _saveRewardResult(firstPlace, secondPlace, thirdPlace,
                    fourthPlace, remainingMembers);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveRewardResult(List<Elite> first, List<Elite> second,
      List<Elite> third, List<Elite> fourth, List<Elite> remaining) async {
    final prefs = await SharedPreferences.getInstance();
    final rewardResult = {
      'first': first.map((e) => e.toJson()).toList(),
      'second': second.map((e) => e.toJson()).toList(),
      'third': third.map((e) => e.toJson()).toList(),
      'fourth': fourth.map((e) => e.toJson()).toList(),
      'remaining': remaining.map((e) => e.toJson()).toList(),
    };
    await prefs.setString('rewardResult', json.encode(rewardResult));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('보상 결과가 저장되었습니다.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('엘리트조 목록'),
      ),
      body: ListView.builder(
        itemCount: _eliteMem.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Checkbox(
                value: _eliteMem[index].isPresent,
                onChanged: (bool? value) {
                  _toggleEliteMemberPresence(index);
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              title: Text(
                _eliteMem[index].eliteName,
                style: TextStyle(
                  decoration: _eliteMem[index].isPresent
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                  color: _eliteMem[index].isPresent
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Colors.grey,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showEditDialog(context, index);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteEliteMember(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showRewardDialog(context),
            child: Icon(Icons.emoji_events),
            heroTag: 'reward',
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _showAddDialog(context);
            },
            child: Icon(Icons.add),
            heroTag: 'add',
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newMember = '';
        TextEditingController controller = TextEditingController(text: "Hero_");

        return AlertDialog(
          title: Text('Add member'),
          content: TextField(
            controller: controller,
            onChanged: (value) {
              newMember = value;
            },
            decoration: InputDecoration(hintText: "Enter member name"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Add'),
              onPressed: () {
                if (newMember.isNotEmpty) {
                  _addEliteMember(newMember);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String editedMember = _eliteMem[index].eliteName;
        return AlertDialog(
          title: Text('Edit member'),
          content: TextField(
            onChanged: (value) {
              editedMember = value;
            },
            decoration: InputDecoration(hintText: "Edit member name"),
            controller: TextEditingController(text: _eliteMem[index].eliteName),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                if (editedMember.isNotEmpty) {
                  _editEliteMember(index, editedMember);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
