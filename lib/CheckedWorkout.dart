import 'package:flutter/material.dart';

class CheckedWorkout extends StatefulWidget {
  CheckedWorkout({
    Key? key,
    this.timerIndex,
    required this.excerciseName,
  }) : super(key: key);

  int? timerIndex;
  String excerciseName;

  @override
  _CheckedWorkoutState createState() => _CheckedWorkoutState();
}

class _CheckedWorkoutState extends State<CheckedWorkout> {
  late String excerciseName;
  late TextEditingController _excerciseNameController;
  bool isChecked = false;
  @override
  void initState() {
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
    setState(() {
      excerciseName = _excerciseNameController.text;
      widget.excerciseName = excerciseName;
    });
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      title: Text(
        excerciseName,
      ),
      leading: Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        value: isChecked,
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
            // send callback to either start/stop the timers.
          });
        },
      ),
      trailing: Icon(Icons.drag_handle_sharp),
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
