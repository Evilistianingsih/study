import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(DailyPlannerPro());
}

class DailyPlannerPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Planner Pro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Register'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text(_isLogin ? 'Login' : 'Register'),
              onPressed: () {
                if (_isLogin) {
                  // Implement login logic
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => DashboardPage()),
                  );
                } else {
                  // Implement registration logic
                  setState(() {
                    _isLogin = true;
                  });
                }
              },
            ),
            TextButton(
              child: Text(_isLogin
                  ? 'Don\'t have an account? Register'
                  : 'Already have an account? Login'),
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _schedules = [];
  List<String> _diaryEntries = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _addSchedule(String name, String time) {
    setState(() {
      _schedules.add({
        'name': name,
        'time': time,
        'isCompleted': false,
      });
    });
  }

  void _editSchedule(int index, String newName, String newTime) {
    setState(() {
      _schedules[index]['name'] = newName;
      _schedules[index]['time'] = newTime;
    });
  }

  void _deleteSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  void _toggleScheduleCompletion(int index) {
    setState(() {
      _schedules[index]['isCompleted'] = !_schedules[index]['isCompleted'];
    });
  }

  void _addDiaryEntry(String entry) {
    setState(() {
      _diaryEntries.add(entry);
    });
  }

  void _editDiaryEntry(int index, String newEntry) {
    setState(() {
      _diaryEntries[index] = newEntry;
    });
  }

  void _deleteDiaryEntry(int index) {
    setState(() {
      _diaryEntries.removeAt(index);
    });
  }

  List<Widget> _pages() => [
        SchedulePage(
          schedules: _schedules,
          addSchedule: _addSchedule,
          editSchedule: _editSchedule,
          deleteSchedule: _deleteSchedule,
          toggleScheduleCompletion: _toggleScheduleCompletion,
        ),
        TimerPage(),
        DiaryPage(
          diaryEntries: _diaryEntries,
          addDiaryEntry: _addDiaryEntry,
          editDiaryEntry: _editDiaryEntry,
          deleteDiaryEntry: _deleteDiaryEntry,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Planner Pro'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Jadwal'),
            Tab(text: 'Timer'),
            Tab(text: 'Diary'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _pages(),
      ),
    );
  }
}

class SchedulePage extends StatelessWidget {
  final List<Map<String, dynamic>> schedules;
  final Function(String, String) addSchedule;
  final Function(int, String, String) editSchedule;
  final Function(int) deleteSchedule;
  final Function(int) toggleScheduleCompletion;

  SchedulePage({
    required this.schedules,
    required this.addSchedule,
    required this.editSchedule,
    required this.deleteSchedule,
    required this.toggleScheduleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              schedules[index]['name'],
              style: TextStyle(
                decoration: schedules[index]['isCompleted']
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: Text(schedules[index]['time']),
            leading: Checkbox(
              value: schedules[index]['isCompleted'],
              onChanged: (value) {
                toggleScheduleCompletion(index);
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showScheduleDialog(context, schedules[index]['name'],
                        schedules[index]['time'], (newName, newTime) {
                      editSchedule(index, newName, newTime);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteSchedule(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showScheduleDialog(context, '', '', (name, time) {
            addSchedule(name, time);
          });
        },
      ),
    );
  }

  void _showScheduleDialog(BuildContext context, String initialName,
      String initialTime, Function(String, String) onSave) {
    final TextEditingController nameController =
        TextEditingController(text: initialName);
    final TextEditingController timeController =
        TextEditingController(text: initialTime);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Enter schedule name'),
              ),
              TextField(
                controller: timeController,
                decoration: InputDecoration(labelText: 'Enter schedule time'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                onSave(nameController.text, timeController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _seconds = 0;
  int _startFrom = 0;
  Timer? _timer;

  void _startTimer(int seconds) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _seconds = seconds;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _timer!.cancel();
        }
      });
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _seconds = _startFrom;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Countdown Timer: ${_seconds ~/ 3600}:${(_seconds ~/ 60) % 60}:${_seconds % 60}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        int inputSeconds = 0;
                        return AlertDialog(
                          title: Text('Set Timer'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextField(
                                keyboardType: TextInputType.number,
                                decoration:
                                    InputDecoration(labelText: 'Enter seconds'),
                                onChanged: (value) {
                                  inputSeconds = int.tryParse(value) ?? 0;
                                },
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            ElevatedButton(
                              child: Text('Start Timer'),
                              onPressed: () {
                                _startTimer(inputSeconds);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Set Timer'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: Text('Stop Timer'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: Text('Reset Timer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class DiaryPage extends StatelessWidget {
  final List<String> diaryEntries;
  final Function(String) addDiaryEntry;
  final Function(int, String) editDiaryEntry;
  final Function(int) deleteDiaryEntry;

  DiaryPage({
    required this.diaryEntries,
    required this.addDiaryEntry,
    required this.editDiaryEntry,
    required this.deleteDiaryEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: diaryEntries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(diaryEntries[index]),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showDiaryDialog(context, diaryEntries[index], (newEntry) {
                      editDiaryEntry(index, newEntry);
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteDiaryEntry(index);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showDiaryDialog(context, '', (entry) {
            addDiaryEntry(entry);
          });
        },
      ),
    );
  }

  void _showDiaryDialog(
      BuildContext context, String initialEntry, Function(String) onSave) {
    final TextEditingController entryController =
        TextEditingController(text: initialEntry);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Diary Entry'),
          content: TextField(
            controller: entryController,
            decoration: InputDecoration(labelText: 'Enter your diary entry'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                onSave(entryController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
