import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/ExcerciseTimer.dart';

import 'dart:convert';

class WorkoutList extends StatefulWidget {
  WorkoutList({Key? key, required this.updateExcerciseTimersCallback})
      : super(key: key);

  Function updateExcerciseTimersCallback;

  @override
  _WorkoutListState createState() => _WorkoutListState();
}

class _WorkoutListState extends State<WorkoutList> {
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
  //Seperate this into utils/parseDuration.dart. Don't know how to import right now
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