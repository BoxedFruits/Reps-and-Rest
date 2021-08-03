import 'package:flutter/material.dart';
import 'package:myapp/ExcerciseList.dart';
import 'package:myapp/TimerWorkout.dart';
import 'package:myapp/WorkoutList.dart';

void main() {
  runApp(MainPage());
}

class _MainPageState extends State<MainPage> {
  List<dynamic> excerciseTimers = [];

  updateExcerciseTimers(List<dynamic> timers) {
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
          body: ExcerciseList(excerciseList: excerciseTimers),
          drawer:
              WorkoutList(updateExcerciseTimersCallback: updateExcerciseTimers),
        ));
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
