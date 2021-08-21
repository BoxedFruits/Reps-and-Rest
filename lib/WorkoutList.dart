import 'package:flutter/material.dart';
import 'package:myapp/workoutWidgets/CheckedWorkout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myapp/workoutWidgets/TimerWorkout.dart';

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
      child: Column(
        children: [
          Container(
              child: Text('Workouts',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32)),
              padding: EdgeInsets.only(top: 32, bottom: 32)),
          ListView.separated(
              separatorBuilder: (context, index) => Divider(
                    color: Colors.black,
                  ),
              shrinkWrap: true,
              itemCount: workouts.length,
              itemBuilder: (context, int index) {
                return Dismissible(
                    key: Key(workouts.elementAt(index) +
                        "_" +
                        workouts.hashCode.toRadixString(3)),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) {
                      _prefs.then((SharedPreferences pref) {
                        pref.remove(workouts.elementAt(index));
                        setState(() {
                          workouts.remove(workouts.elementAt(index));
                        });
                      });
                    },
                    child: ListTile(
                        title: Text(workouts.elementAt(index)),
                        onTap: () {
                          _prefs.then((SharedPreferences pref) {
                            List<dynamic> decodedJson = jsonDecode(
                                //Part of the trouble. Have to decode the json again
                                pref.getString(workouts.elementAt(index)) ??
                                    '');
                            List<dynamic> decodedWorkout = [];

                            decodedJson.forEach((e) => {
                                  if (e['excerciseDuration'] != null)
                                    {
                                      decodedWorkout.add(TimerWorkout.fromJson({
                                        'excerciseName': e['excerciseName'],
                                        'excerciseDuration':
                                            e['excerciseDuration'].toString(),
                                      }))
                                    }
                                  else
                                    {
                                      decodedWorkout
                                          .add(CheckedWorkout.fromJson({
                                        'excerciseName': e['excerciseName'],
                                        'isCurrentExcercise':
                                            e['isCurrentExcercise'],
                                        'checked': e['checked']
                                      }))
                                    }
                                });

                            widget
                                .updateExcerciseTimersCallback(decodedWorkout);
                            Navigator.of(context).pop();
                          });
                        }));
              }),
          Container(
            alignment: Alignment.bottomRight,
            margin: EdgeInsets.only(right: 16),
            child: OutlinedButton(
                onPressed: () {
                  widget.updateExcerciseTimersCallback([
                    new TimerWorkout(
                        excerciseName: 'New Excercise',
                        excerciseDuration: Duration())
                  ]);
                  Navigator.of(context).pop();
                },
                child: Text("Add Workout")),
          )
        ],
      ),
    );
  }
}
