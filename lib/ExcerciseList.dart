import 'dart:convert';
import 'dart:typed_data';
import 'package:myapp/workoutWidgets/CheckedWorkout.dart';
import 'package:myapp/workoutWidgets/TimerWorkout.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const int _tSampleRate = 44100;
const int _tNumChannels = 2;

class ExcerciseList extends StatefulWidget {
  ExcerciseList({Key? key, this.excerciseList}) : super(key: key);

  List<dynamic>? excerciseList = []; // Takes in TimerWorkout and CheckedWorkout
  @override
  _ExcerciseListState createState() => _ExcerciseListState();
}

class _ExcerciseListState extends State<ExcerciseList> {
  FlutterSoundPlayer? _myPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  bool busy = false;
  Uint8List? soundAffectData;

  late SharedPreferences _prefs;

  late TextEditingController _workoutNameController;
  int currentExcerciseIndex = 0;
  String workoutName = "New Workout";
  String actionText = "Start Workout";

  bool isWorkoutActive = false;

  PausableTimer currentTimer =
      PausableTimer(Duration(minutes: 0, seconds: 0), () {});

  _addExcercise() {
    final newIndex = (widget.excerciseList as dynamic).length;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new SimpleDialog(
              title: Text("Select Type Of Excercise"),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              final newTimer = TimerWorkout(
                                  key: ValueKey(newIndex),
                                  timerIndex: newIndex,
                                  excerciseName: "New Excercise",
                                  excerciseDuration:
                                      new Duration(minutes: 0, seconds: 0));
                              widget.excerciseList?.add(newTimer);
                            });
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.timer),
                          label: Text('Timed')),
                    ),
                    Expanded(
                        child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                final newTimer = CheckedWorkout(
                                  key: ValueKey(newIndex),
                                  update: () => {},
                                  isCurrentExcercise: newIndex == 0,
                                  excerciseName: "New Excercise",
                                  checked: false,
                                );
                                widget.excerciseList?.add(newTimer);
                              });
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.check_box),
                            label: Text('Checked')))
                  ],
                )
              ]);
        });
  }

  _buildTimer(int timerIndex) {
    //Because using a ReorderableListView, the list items get rebuild on long presses and drags which means that their key also changes.
    //Using the hash of the widget to get around using the same key. Not the best solution but it works for now
    // print(widget.excerciseList![timerIndex].runtimeType);
    return Container(
        color: timerIndex == currentExcerciseIndex
            ? Colors.red
            : Colors.transparent,
        key: Key(widget.excerciseList![timerIndex].excerciseName +
            "_" +
            widget.excerciseList![timerIndex].hashCode.toRadixString(3)),
        child: Dismissible(
            key: Key(widget.excerciseList![timerIndex].excerciseName +
                "_" +
                widget.excerciseList![timerIndex].hashCode.toRadixString(3)),
            child: widget.excerciseList![timerIndex],
            background: Container(color: Colors.red),
            onDismissed: (direction) {
              setState(() {
                widget.excerciseList?.removeAt(timerIndex);
              });
            }));
  }

  _startWorkout() {
    if (currentExcerciseIndex < widget.excerciseList!.length) {
      setState(() {
        actionText = "Pause Workout";
        isWorkoutActive = true;
      });
      if (widget.excerciseList?[currentExcerciseIndex].runtimeType ==
          TimerWorkout) {
        currentTimer = PausableTimer(
            widget.excerciseList![currentExcerciseIndex].excerciseDuration,
            () => {
                  setState(() {
                    currentExcerciseIndex += 1;
                  }),
                  if (_mPlayerIsInited)
                    {
                      play(soundAffectData)
                    }, //Need to find a way to execute the sound when its 4 sec away from duration end.
                  _startWorkout()
                });
        currentTimer.start();
      } else {
        CheckedWorkout foo = widget.excerciseList?[currentExcerciseIndex];
        foo.checked = true;
        foo.isCurrentExcercise = false;
        CheckedWorkout workout = CheckedWorkout(
          excerciseName: foo.excerciseName,
          isCurrentExcercise: true,
          update: () => {
            setState(() {
              widget.excerciseList?[currentExcerciseIndex] = foo;
              currentExcerciseIndex += 1;
              _startWorkout();
            }),
          },
          checked: false,
        );
        widget.excerciseList?[currentExcerciseIndex] = workout;
      }
    } else {
      // Workout is finished
      // Reset all the CheckedWorkouts
      // Break this out into a method?
      for (var i = 0; i < widget.excerciseList!.length; i++) {
        if (widget.excerciseList?[i].runtimeType == CheckedWorkout) {
          var originalExcercise = widget.excerciseList?[i];
          widget.excerciseList?[i] = CheckedWorkout(
              excerciseName: originalExcercise.excerciseName,
              isCurrentExcercise: false,
              update: () => {},
              checked: false);
        }
      }

      setState(() {
        actionText = "Start Workout";
        isWorkoutActive = false;
        currentExcerciseIndex = 0;
      });
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
      isWorkoutActive = false;
    });

    activeTimer.pause();
  }

  _resumeWorkout(PausableTimer activeTimer) {
    setState(() {
      actionText = "Pause Workout";
      isWorkoutActive = false;
    });

    activeTimer.start();
  }

  _resetWorkout(PausableTimer activeTimer) {
    setState(() {
      actionText = "Start Workout";
      isWorkoutActive = true;
      currentExcerciseIndex = 0;
    });

    activeTimer.cancel();
    _startWorkout();
  }

  _resetCurrentExcercise(PausableTimer activeTimer) {
    setState(() {
      actionText = "Pause Workout";
      isWorkoutActive = true;
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
                  String encodedExcercises = jsonEncode(widget.excerciseList);
                  _prefs.setString('${workoutName}', encodedExcercises);

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
            itemCount: widget.excerciseList!.length,
            itemBuilder: (context, index) => this._buildTimer(index),
            onReorder: (int oldIndex, int newIndex) {
              if (!isWorkoutActive) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final dynamic item = widget.excerciseList!.removeAt(oldIndex);
                  widget.excerciseList?.insert(newIndex, item);
                });
              }
            },
          ),
        )
      ]),
      Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        //Should try to make this bottom nav bar on Scaffold
        Container(
          height: 270,
          child: DraggableScrollableSheet(
            expand: false,
            minChildSize: 0.085,
            builder: (BuildContext context, ScrollController scrollController) {
              return IntrinsicHeight(
                  child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.horizontal(
                            left: Radius.circular(25),
                            right: Radius.circular(25)),
                        color: Colors.grey,
                      ),
                      child: ListView(controller: scrollController, children: [
                        Icon(Icons.drag_handle_rounded),
                        ElevatedButton(
                            onPressed: _addExcercise,
                            child: Text("Add Excercise")),
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
