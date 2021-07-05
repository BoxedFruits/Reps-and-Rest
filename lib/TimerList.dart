import 'dart:typed_data';
import 'package:myapp/Timer.dart';
import 'package:pausable_timer/pausable_timer.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';

const int _tSampleRate = 44100;
const int _tNumChannels = 44;

class TimerList extends StatefulWidget {
  TimerList({Key? key}) : super(key: key);

  @override
  _TimerListState createState() => _TimerListState();
}

class _TimerListState extends State<TimerList> {
  FlutterSoundPlayer? _myPlayer = FlutterSoundPlayer();
  bool _mPlayerIsInited = false;
  bool busy = false;
  Uint8List? soundAffectData;

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
    //Play sound at callback? If the sound has like 5 beats , can just add 5 more seconds to every timer so that it gives the user a headsup before the next excercise
    //https://tau.canardoux.xyz/tau_api_player_set_audio_focus.html

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
                if (_mPlayerIsInited) {play(soundAffectData)},
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

  _resetWorkout(PausableTimer activeTimer) {
    //Reset currentTimer and then reset currentTimerIndex back to 0
    setState(() {
      actionText = "Start Workout";
    });

    activeTimer.cancel();
    currentTimerIndex = 0;
    _startWorkout();
  }

  _resetCurrentExcercise(PausableTimer activeTimer) {
    //Show flood for last excercise when this is pressed?
    setState(() {
      actionText = "Pause Workout";
    });
    activeTimer.reset();
  }

  void play(Uint8List? data) async {
    if (!busy && _mPlayerIsInited) {
      busy = true;
      await _myPlayer!.feedFromStream(data!).then((value) => busy = false);
    }
    print("SOUND DOUNE");
  }

  Future<Uint8List> getAssetData(String path) async {
    var asset = await rootBundle.load(path);
    return asset.buffer.asUint8List();
  }

  Future<void> init() async {
    await _myPlayer!.openAudioSession();
    soundAffectData = FlutterSoundHelper().waveToPCMBuffer(
      inputBuffer: await getAssetData(
          'assets/soundaffects/mixkit-sport-start-bleeps-918.wav'),
    );
    await _myPlayer!.startPlayerFromStream(
      codec: Codec.pcm16,
      numChannels: _tNumChannels,
      sampleRate: _tSampleRate,
    );
  }

  @override
  void initState() {
    super.initState();
    // Be careful : openAudioSession return a Future.
    // Do not access your FlutterSoundPlayer or FlutterSoundRecorder before the completion of the Future
    init().then((value) => setState(() {
          _mPlayerIsInited = true;
        }));
  }

  @override
  void dispose() {
    // Be careful : you must `close` the audio session when you have finished with it.
    _myPlayer!.stopPlayer();
    _myPlayer!.closeAudioSession();
    _myPlayer = null;

    super.dispose();
  }

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
                      ])));
            },
          ),
        )
      ])
    ]);
  }
}
