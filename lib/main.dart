import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pausable_timer/pausable_timer.dart';

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
            )));
  }
}

class TimerList extends StatefulWidget {
  TimerList({Key? key}) : super(key: key);

  @override
  _TimerListState createState() => _TimerListState();
}

class _TimerListState extends State<TimerList> {
  List<Timer> timers = [];
  int currentTimerIndex = 0;
  String actionText = "Start Workout";
  PausableTimer currentTimer =
      PausableTimer(Duration(minutes: 0, seconds: 0), () {});

  _addTimer() {
    final newIndex = timers.length;
    final newTimer = Timer(
        key: ValueKey(newIndex),
        timerIndex: newIndex,
        excerciseName: "New Excercise",
        excerciseDuration: new Duration(minutes: 0, seconds: 0));

    setState(() {
      timers.add(newTimer);
    });
  }

  _buildTimer(int timerIndex) {
    return timers[timerIndex];
  }

  _startWorkout() {
    //Start at 0 index of timers and start duration. Highlight current Timer
    //Play sound?

    if (currentTimerIndex < timers.length) {
      setState(() {
        actionText = "Pause Workout";
      });

      currentTimer = PausableTimer(
          timers[currentTimerIndex].excerciseDuration,
          () => {
                print('Fired! for timer: ' +
                    timers[currentTimerIndex].excerciseName),
                currentTimerIndex += 1,
                _startWorkout() //Trying to take advantage of callback that fires when timer is done.
              });
      currentTimer.start();
    } else {
      setState(() {
        actionText = "Start Workout";
      });
      currentTimerIndex = 0;
    }
  }

  _pauseWorkout(PausableTimer activeTimer) {
    setState(() {
      actionText = "Resume Workout";
    });

    activeTimer.pause();
  }

  _resumeWorkout(PausableTimer activeTimer) {
    setState(() {
      actionText = "Pause Workout";
    });

    activeTimer.start();
  }

  _workoutHandler(PausableTimer activeTimer) {
    if (activeTimer.isActive) {
      _pauseWorkout(activeTimer);
    } else if (activeTimer.isPaused &&
        activeTimer.elapsed > Duration(milliseconds: 100)) {
      _resumeWorkout(activeTimer);
    } else {
      _startWorkout();
    }
  }

  // _resetWorkout() {} //Reset currentTimer and then reset currentTimerIndex back to 0. call startWorkout.
  // _resetCurrentWorkout() {} //Reset currentTimer. Take in currentTimerIndex and pause that.

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Flex(direction: Axis.vertical, children: [
        Expanded(
          child: ListView.builder(
              itemCount: timers.length,
              itemBuilder: (context, index) => this._buildTimer(index)),
        )
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        //Should try to make this bottom nav bar on Scaffold
        Container(
          height: 150,
          child: DraggableScrollableSheet(
            expand: false,
            minChildSize: 0.085,
            builder: (BuildContext context, ScrollController scrollController) {
              return IntrinsicHeight(
                  child: Container(
                      color: Colors.white,
                      child: ListView(controller: scrollController, children: [
                        //Need to add a bit of styling to make it look better and obvious that its a draggableDrawer
                        ElevatedButton(
                            onPressed: _addTimer, child: Text("Add Timer")),
                        ElevatedButton(
                            onPressed: () {
                              _workoutHandler(currentTimer);
                            },
                            child: Text(actionText)),
                        ElevatedButton(
                            onPressed: () {},
                            child: Text("Reset Current Timer")),
                      ])));
            },
          ),
        )
      ])
    ]);
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
  Duration excerciseDuration;
  String excerciseName;

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  late Duration excerciseDuration;
  late String excerciseName;
  late TextEditingController _excerciseNameController;

  // @override
  // bool get wantKeepAlive => true;

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
      widget.excerciseName = excerciseName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      title: Text(
        (widget.timerIndex + 1).toString() + " " + excerciseName,
      ),
      subtitle: Text('Time left: ${excerciseDuration.inSeconds} seconds'),
      onTap: () {
        _showDialog(
          context,
          updateExcercise,
        );
      },
    );
  }

  _showDialog(
    BuildContext context,
    Function updateExcerciseCallback,
  ) {
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
                  excerciseDuration = newTime;
                  widget.excerciseDuration = excerciseDuration;
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
