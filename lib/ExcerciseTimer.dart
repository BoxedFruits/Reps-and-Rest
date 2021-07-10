import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ExcerciseTimer extends StatefulWidget {
  ExcerciseTimer({
    Key? key,
    this.timerIndex,
    required this.excerciseName,
    required this.excerciseDuration,
  }) : super(key: key);

  ExcerciseTimer.fromJson(Map<String, dynamic> json)
      : excerciseName = json['excerciseName'],
        excerciseDuration = json['excerciseDuration'];

  Map<String, dynamic> toJson() {
    return {
      'excerciseName': excerciseName,
      'excerciseDuration': excerciseDuration
          .toString(), //Need to turn this back into Duration when retrieving data
    };
  }

  int? timerIndex;
  Duration excerciseDuration;
  String excerciseName;

  @override
  _ExcerciseTimerState createState() => _ExcerciseTimerState();
}

class _ExcerciseTimerState extends State<ExcerciseTimer> {
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
      widget.excerciseName = excerciseName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(
        excerciseName,
      ),
      trailing: Icon(Icons.drag_handle_sharp),
      subtitle: Text('Duration: ${excerciseDuration.inSeconds} seconds'),
      onTap: () {
        _showDialog(
          context,
          updateExcercise,
        );
      },
    ));
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
