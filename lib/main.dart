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
            children: <Widget>[
              DrawerHeader(child: Text('Timers')),
            ],
          ),
        ),
      ),
    );
  }
}

class TimerList extends StatefulWidget {
  TimerList({Key? key}) : super(key: key);

  @override
  _TimerListState createState() => _TimerListState();
}

class _TimerListState extends State<TimerList> {
  List<Timer> timers = [];

  _addTimer() {
    final newIndex = timers.length;
    final newTimer = Timer(
      key: ValueKey(newIndex),
      timerIndex: newIndex,
      excerciseName: "New Excercise",
      excerciseDuration: new Duration(minutes: 0, seconds: 0),
    );

    setState(() {
      timers.add(newTimer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: ListView.builder(
            itemCount: timers.length,
            itemBuilder: (context, index) => this._buildTimer(index)),
      ),
      ElevatedButton(onPressed: _addTimer, child: Text("Add Timer")),
      ElevatedButton(onPressed: () {}, child: Text("Start Workout")),
      ElevatedButton(onPressed: () {}, child: Text("Pause Timer")),
      ElevatedButton(onPressed: () {}, child: Text("Reset Current Timer"))
    ]);
  }

  _buildTimer(int timerIndex) {
    return timers[timerIndex];
  }
}

class Timer extends StatefulWidget {
  Timer({
    Key? key,
    required this.timerIndex,
    required this.excerciseName,
    required this.excerciseDuration,
  }) : super(key: key);

  final int timerIndex;
  final Duration excerciseDuration;
  final String excerciseName;

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  late Duration excerciseDuration;
  late String excerciseName;
  late TextEditingController _excerciseNameController;

  @override
  void initState() {
    excerciseDuration = widget.excerciseDuration;
    excerciseName = widget.excerciseName;
    _excerciseNameController = TextEditingController(text: excerciseName);
    super.initState();
  }

  @override
  void dispose() {
    _excerciseNameController.dispose();
    super.dispose();
  }

  Future<void> updateExcercise() async {
    // call set sate to rebuild the widget
    setState(() {
      excerciseName = _excerciseNameController.text;
    });
  }

  //Needs to be stateful so that user can pause timer.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      title: Text(
        (widget.timerIndex + 1).toString() + " " + excerciseName,
      ),
      subtitle: Text('Time left ${excerciseDuration.inSeconds} seconds'),
      onTap: () {
        _showDialog(
          context,
          updateExcercise,
        ); //When creating a new timer, have Exercise name as default
      },
    );
  }

  _showDialog(
    BuildContext context,
    Function updateExcerciseCallback,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  excerciseDuration = newTime;
                },
              ),
            ),
            new TextButton(
              child: new Text('Save'),
              onPressed: () {
                //SetState when clicking saved
                updateExcerciseCallback();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
