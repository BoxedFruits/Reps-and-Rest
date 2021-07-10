import 'dart:convert';
import 'dart:typed_data';
import 'package:myapp/ExcerciseTimer.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const int _tSampleRate = 44100;
const int _tNumChannels = 2;

//Each time user adds a workout, should save the data

class ExcerciseTimerList extends StatefulWidget {
  ExcerciseTimerList({Key? key, this.timers}) : super(key: key);

  List<ExcerciseTimer>? timers = [];
  @override
  _ExcerciseTimerListState createState() => _ExcerciseTimerListState();
}

class _ExcerciseTimerListState extends State<ExcerciseTimerList> {
  FlutterSoundPlayer? _myPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  bool busy = false;
  Uint8List? soundAffectData;

  late SharedPreferences _prefs;

  late TextEditingController _workoutNameController;
  int currentTimerIndex = 0;
  String workoutName = "New Workout";
  String actionText = "Start Workout";
  PausableTimer currentTimer =
      PausableTimer(Duration(minutes: 0, seconds: 0), () {});

  _addTimer() {
    final newIndex = widget.timers?.length;
    final newTimer = ExcerciseTimer(
        key: ValueKey(newIndex),
        timerIndex: newIndex,
        excerciseName: "New Excercise",
        excerciseDuration: new Duration(minutes: 0, seconds: 0));

    setState(() {
      widget.timers?.add(newTimer);
    });
  }

  _buildTimer(int timerIndex) {
    //Because using a ReorderableListView, the list items get rebuild on long presses and drags which means that their key also changes.
    //Using the hash of the widget to get around using the same key. Not the best solution but it works for now
    return Container(
        color:
            timerIndex == currentTimerIndex ? Colors.red : Colors.transparent,
        key: Key(widget.timers![timerIndex].excerciseName +
            "_" +
            widget.timers![timerIndex].hashCode.toRadixString(3)),
        child: Dismissible(
            key: Key(widget.timers![timerIndex].excerciseName +
                "_" +
                widget.timers![timerIndex].hashCode.toRadixString(3)),
            child: widget.timers![timerIndex],
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              setState(() {
                widget.timers?.removeAt(timerIndex);
              });
            }));
  }

  _startWorkout() {
    //Start at 0 index of timers and start duration. Highlight current Timer?
    if (currentTimerIndex < widget.timers!.length) {
      setState(() {
        actionText = "Pause Workout";
      });
      currentTimer = PausableTimer(
          widget.timers![currentTimerIndex].excerciseDuration,
          () => {
                currentTimerIndex += 1,
                if (_mPlayerIsInited)
                  {
                    play(soundAffectData)
                  }, //Need to find a way to execute the sound when its 4 sec away from duration end.
                _startWorkout()
              });
      currentTimer.start();
    } else {
      setState(() {
        actionText = "Start Workout";
      });
      currentTimerIndex = 0;
    }
  }

  _workoutHandler(PausableTimer activeTimer) {
    //Make this more general purpose. Pass in enum to identify events: Pause, Resume, Start, ResetAllWorkouts, ResetCurrentWorkout
    if (activeTimer.isActive) {
      _pauseWorkout(activeTimer);
    } else if (activeTimer.isPaused &&
        activeTimer.elapsed > Duration(milliseconds: 100)) {
      _resumeWorkout(activeTimer);
    } else {
      _startWorkout();
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

  _resetWorkout(PausableTimer activeTimer) {
    setState(() {
      actionText = "Start Workout";
    });

    activeTimer.cancel();
    currentTimerIndex = 0;
    _startWorkout();
  }

  _resetCurrentExcercise(PausableTimer activeTimer) {
    setState(() {
      actionText = "Pause Workout";
    });
    activeTimer.reset();
  }

  _saveWorkout() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
            title: Text("Enter the name of the workout"),
            children: [
              Padding(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _workoutNameController,
                ),
              ),
              TextButton(
                child: Text('Save'),
                onPressed: () {
                  setState(() {
                    workoutName = _workoutNameController
                        .text; //Make sure its not empty string
                  });
                  String encodedTimers = jsonEncode(widget.timers);

                  _prefs.setString('${workoutName}', encodedTimers);

                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  void play(Uint8List? data) async {
    if (!busy && _mPlayerIsInited) {
      busy = true;
      await _myPlayer!.feedFromStream(data!).then((value) => busy = false);
    }
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  Future<void> init() async {
    await _myPlayer!.openAudioSession();
    soundAffectData = FlutterSoundHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(
          'assets/soundaffects/mixkit-digital-quick-tone-2866.wav'),
    );
    await _myPlayer!.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: _tNumChannels,
      sampleRate: _tSampleRate,
    );
  }

  void loadSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();

    _workoutNameController = TextEditingController(text: workoutName);

    loadSharedPreferences();

    init().then((value) => setState(() {
          _mPlayerIsInited = true;
        }));
  }

  @override
  void dispose() {
    _myPlayer!.stopPlayer();
    _myPlayer!.closeAudioSession();
    _myPlayer = null;

    _workoutNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Flex(direction: Axis.vertical, children: [
        Expanded(
          child: ReorderableListView.builder(
            itemCount: widget.timers!.length,
            itemBuilder: (context, index) => this._buildTimer(index),
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final ExcerciseTimer item = widget.timers!.removeAt(oldIndex);
                widget.timers?.insert(newIndex, item);
              });
            },
          ),
        )
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        //Should try to make this bottom nav bar on Scaffold
        Container(
          height: 200,
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
                            onPressed: () => _workoutHandler(currentTimer),
                            child: Text(actionText)),
                        ElevatedButton(
                            onPressed: () => _resetWorkout(currentTimer),
                            child: Text("Reset Workout")),
                        ElevatedButton(
                            onPressed: () =>
                                _resetCurrentExcercise(currentTimer),
                            child: Text("Reset Current Timer")),
                        ElevatedButton(
                            onPressed: _saveWorkout,
                            child: Text("Save Workout")),
                      ])));
            },
          ),
        )
      ])
    ]);
  }
}
