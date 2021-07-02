import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("Rest and Reps"),
          ),
          body: TimerList(),
          drawer: Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[DrawerHeader(child: Text('Timers'))],
            ),
          ),
        ));
  }
}

class TimerList extends StatefulWidget {
  TimerList({Key? key}) : super(key: key);

  @override
  _TimerListState createState() => _TimerListState();
}

class _TimerListState extends State<TimerList> {
  int timers = 1;

  _addTimer() {
    setState(() {
      timers += 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
            itemCount: this.timers,
            itemBuilder: (context, index) => this._buildTimer(index)),
      ),
      ElevatedButton(onPressed: _addTimer, child: Text("Add Timer")),
      ElevatedButton(onPressed: () {}, child: Text("Start Workout")),
      ElevatedButton(onPressed: () {}, child: Text("Pause Timer")),
      ElevatedButton(onPressed: () {}, child: Text("Reset Current Timer"))
    ]);
  }

  _buildTimer(int timerIndex) {
    //Each row show be a widget. Should have Gif/image of Rxcercise, Excercise name and timer length
    return Timer(
        timerIndex: timerIndex,
        excerciseName: "New Excercise",
        excerciseDuration: new Duration(minutes: 0, seconds: 0));
  }
}

class Timer extends StatefulWidget {
  Timer(
      {Key? key,
      required this.timerIndex,
      required this.excerciseName,
      required this.excerciseDuration})
      : super(key: key);

  int timerIndex;
  String excerciseName;
  Duration excerciseDuration;

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  //Needs to be stateful so that user can pause timer.
  @override
  Widget build(BuildContext context) {
    Future<void> setExcerciseName(passedInName) async {
      print(passedInName);
      setState(() {
        widget.excerciseName = passedInName;
      });
    }

    return ListTile(
      isThreeLine: true,
      title: Text((widget.timerIndex + 1).toString() +
          " " +
          widget.excerciseName.toString()),
      subtitle: Text('Time left'),
      onTap: () {
        setState(() {
          widget.excerciseName = "mememe";
        });
        _popDialog(context, widget.excerciseName,
            setExcerciseName); //When creating a new timer, have Exercise name as default
      },
    );
  }
}

_popDialog(BuildContext context, String excerciseName,
    Function setExcerciseNameCallback) {
  TextEditingController _excerciseNameController;

  _excerciseNameController =
      TextEditingController.fromValue(TextEditingValue(text: excerciseName));
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return new SimpleDialog(
            title: TextField(
              controller: _excerciseNameController,
            ),
            children: [
              Container(
                  width: 280,
                  height: 280,
                  child: CupertinoTimerPicker(
                      mode: CupertinoTimerPickerMode.ms,
                      onTimerDurationChanged: (newTime) {
                        //newTime is what will set the new duration. newTime is typeof Duration.
                        print(newTime);
                      })),
              new TextButton(
                child: new Text('Save'),
                onPressed: () {
                  //SetState when clicking saved
                  setExcerciseNameCallback(_excerciseNameController.text);
                  Navigator.of(context).pop();
                },
              ),
            ]);
      });
}
