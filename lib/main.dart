import 'package:flutter/material.dart';
import 'package:myapp/TimerList.dart';

//Agenda:
//1) [Done] Clean things up and put widgets into their own seperate files.
//2) [Done] Implement ReordableLists so that can move around list items https://api.flutter.dev/flutter/material/ReorderableListView-class.html
//3) [Done] Implement Drag to dismiss https://flutter.dev/docs/cookbook/gestures/dismissible
//4) save and load workouts
//5) UI enhancements

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
            body: TimerList(),
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(child: Text('Timers')),
                ],
              ),
            )));
  }
}
