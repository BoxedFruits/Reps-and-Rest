import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
