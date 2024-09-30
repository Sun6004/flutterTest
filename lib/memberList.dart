import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

class Member {
  String name;
  bool isPresent;

  Member({required this.name, this.isPresent = true});

  Map<String, dynamic> toJson() => {
        'name': name,
        'isPresent': isPresent,
      };

  Member.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        isPresent = json['isPresent'];
}

class MemberListPage extends StatefulWidget {
  const MemberListPage({super.key});

  @override
  State<MemberListPage> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListPage> {
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _members = (prefs.getStringList('members') ?? [])
          .map((item) => Member.fromJson(json.decode(item)))
          .toList();
    });
  }

  void _saveMembers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'members', _members.map((item) => json.encode(item.toJson())).toList());
  }

  void _addMember(String name) {
    setState(() {
      _members.add(Member(name: name));
      _saveMembers();
    });
  }

  void _editMember(int index, String newName) {
    setState(() {
      _members[index].name = newName;
      _saveMembers();
    });
  }

  void _deleteMember(int index) {
    setState(() {
      _members.removeAt(index);
      _saveMembers();
    });
  }

  void _toggleMemberPresence(int index) {
    setState(() {
      _members[index].isPresent = !_members[index].isPresent;
      _saveMembers();
    });
  }

  void _matchMembers() {
    List<Member> presentMembers = _members.where((m) => m.isPresent).toList();
    presentMembers.shuffle(Random());

    List<List<Member>> groups = [];
    List<Member> remainingMembers = [];

    for (int i = 0; i < presentMembers.length; i += 3) {
      if (i + 3 <= presentMembers.length) {
        groups.add(presentMembers.sublist(i, i + 3));
      } else {
        remainingMembers = presentMembers.sublist(i);
      }
    }

    List<Member> absentMembers = _members.where((m) => !m.isPresent).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MatchResultScreen(
          groups: groups,
          remainingMembers: remainingMembers,
          absentMembers: absentMembers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Member List'),
      ),
      body: ListView.builder(
        itemCount: _members.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: Checkbox(
                value: _members[index].isPresent,
                onChanged: (bool? value) {
                  _toggleMemberPresence(index);
                },
                activeColor: Theme.of(context).primaryColor,
              ),
              title: Text(
                _members[index].name,
                style: TextStyle(
                  decoration: _members[index].isPresent
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                  color: _members[index].isPresent
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
                      _deleteMember(index);
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
            onPressed: _matchMembers,
            child: Icon(Icons.group),
            heroTag: 'match',
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
        return AlertDialog(
          title: Text('Add member'),
          content: TextField(
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
                  _addMember(newMember);
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
        String editedMember = _members[index].name;
        return AlertDialog(
          title: Text('Edit member'),
          content: TextField(
            onChanged: (value) {
              editedMember = value;
            },
            decoration: InputDecoration(hintText: "Edit member name"),
            controller: TextEditingController(text: _members[index].name),
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
                  _editMember(index, editedMember);
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

class MatchResultScreen extends StatefulWidget {
  final List<List<Member>> groups;
  final List<Member> remainingMembers;
  final List<Member> absentMembers;

  MatchResultScreen({
    required this.groups,
    required this.remainingMembers,
    required this.absentMembers,
  });

  @override
  _MatchResultScreenState createState() => _MatchResultScreenState();
}

class _MatchResultScreenState extends State<MatchResultScreen> {
  @override
  void initState() {
    super.initState();
    _saveMatchResult();
  }

  void _saveMatchResult() async {
    final prefs = await SharedPreferences.getInstance();
    final matchResult = {
      'groups': widget.groups
          .map((group) => group.map((member) => member.toJson()).toList())
          .toList(),
      'remainingMembers':
          widget.remainingMembers.map((member) => member.toJson()).toList(),
      'absentMembers':
          widget.absentMembers.map((member) => member.toJson()).toList(),
    };
    await prefs.setString('matchResult', json.encode(matchResult));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Match Result'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Matched Groups:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.groups.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    title: Text('Group ${index + 1}'),
                    subtitle: Text(
                        widget.groups[index].map((m) => m.name).join(', ')),
                  ),
                );
              },
            ),
            if (widget.remainingMembers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Remaining Members:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(
                      widget.remainingMembers.map((m) => m.name).join(', ')),
                ),
              ),
            ],
            if (widget.absentMembers.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Absent Members:',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              Card(
                margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title:
                      Text(widget.absentMembers.map((m) => m.name).join(', ')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
