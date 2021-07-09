import 'package:flutter/material.dart';
import 'package:myapp/ExcerciseTimerList.dart';
import 'package:myapp/ExcerciseTimer.dart';
import 'package:myapp/WorkoutList.dart';

//Agenda:
//1) [Done] Clean things up and put widgets into their own seperate files.
//2) [Done] Implement ReordableLists so that can move around list items https://api.flutter.dev/flutter/material/ReorderableListView-class.html
//3) [Done] Implement Drag to dismiss https://flutter.dev/docs/cookbook/gestures/dismissible
//4) [DONE!!!] save and load workouts
//5) [ehh done I guess]clean up
//6) UI enhancements

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
