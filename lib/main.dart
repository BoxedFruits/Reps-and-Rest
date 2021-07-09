import 'package:flutter/material.dart';
import 'package:myapp/TimerList.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/ExcerciseTimer.dart';
import 'dart:convert';

//Agenda:
//1) [Done] Clean things up and put widgets into their own seperate files.
//2) [Done] Implement ReordableLists so that can move around list items https://api.flutter.dev/flutter/material/ReorderableListView-class.html
//3) [Done] Implement Drag to dismiss https://flutter.dev/docs/cookbook/gestures/dismissible
//4) [DONE!!!] save and load workouts
//5) clean up
//6) UI enhancements

void main() {
  runApp(MyApp());
}

class _MyAppState extends State<MyApp> {
  List<ExcerciseTimer> excerciseTimers = [];
  //Pass this into the TimerList constructor inorder to build it with all the timers

  updateExcerciseTimers(List<ExcerciseTimer> timers) {
    print("in the callback");
    setState(() {
      excerciseTimers = timers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Rest and Reps 💪',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Rest and Reps 💪"),
          ),
          body: TimerList(timers: excerciseTimers),
          drawer: ExcerciseSelect(
              updateExcerciseTimersCallback: updateExcerciseTimers),
        ));
  }
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class ExcerciseSelect extends StatefulWidget {
  ExcerciseSelect({Key? key, required this.updateExcerciseTimersCallback})
      : super(key: key);

  Function updateExcerciseTimersCallback;

  @override
  _ExcerciseSelectState createState() => _ExcerciseSelectState();
}

class _ExcerciseSelectState extends State<ExcerciseSelect> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Set<String> workouts = {};

  @override
  void initState() {
    super.initState();
    _prefs.then((SharedPreferences pref) {
      setState(() {
        workouts = pref.getKeys();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          DrawerHeader(child: Text('Timers')),
          ListView.builder(
              shrinkWrap: true,
              itemCount: workouts.length,
              itemBuilder: (context, int index) {
                return ListTile(
                    title: Text(workouts.elementAt(index)),
                    onTap: () {
                      _prefs.then((SharedPreferences pref) {
                        List<dynamic> decodedJson = jsonDecode(
                            pref.getString(workouts.elementAt(index)) ?? '');
                        List<ExcerciseTimer> foo = decodedJson
                            .map((e) => ExcerciseTimer.fromJson({
                                  'excerciseName': e['excerciseName'],
                                  'excerciseDuration':
                                      parseDuration(e['excerciseDuration'])
                                }))
                            .toList();
                        widget.updateExcerciseTimersCallback(foo);
                        Navigator.of(context).pop();
                      });
                    });
              }),
          Container(
            alignment: Alignment.bottomRight,
            child: OutlinedButton(onPressed: () {}, child: Text("Add Workout")),
          )
        ],
      ),
    );
  }
}

Duration parseDuration(String s) {
  int hours = 0;
  int minutes = 0;
  int micros;
  List<String> parts = s.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}
