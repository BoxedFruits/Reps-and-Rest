import 'package:flutter/material.dart';
import 'package:myapp/ExcerciseTimerList.dart';
import 'package:myapp/ExcerciseTimer.dart';
import 'package:myapp/WorkoutList.dart';

void main() {
  runApp(MainPage());
}

class _MainPageState extends State<MainPage> {
  List<ExcerciseTimer> excerciseTimers = [];

  updateExcerciseTimers(List<ExcerciseTimer> timers) {
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
          body: ExcerciseTimerList(timers: excerciseTimers),
          drawer:
              WorkoutList(updateExcerciseTimersCallback: updateExcerciseTimers),
        ));
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}
