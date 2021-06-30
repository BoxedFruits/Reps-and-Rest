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
      ElevatedButton(onPressed: _addTimer, child: Text("Add Timer"))
    ]);
  }

  _buildTimer(int timerIndex) {
    //Each row show be a widget. Should have Gif/image of Rxcercise, Excercise name and timer length
    return Timer(timerIndex: timerIndex);
  }
}

class Timer extends StatefulWidget {
  Timer({Key? key, required this.timerIndex}) : super(key: key);

  final int timerIndex;

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  //Needs to be stateful so that user can pause timer.
  @override
  Widget build(BuildContext context) {
    return ListTile(
      isThreeLine: true,
      title: Text(widget.timerIndex.toString() + ' Excercise Name'),
      subtitle: Text('Time left'),
      onTap: () {
        _popDialog(context);
      },
    );
  }
}

_popDialog(BuildContext context) {
  showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return new SimpleDialog(
          title: new Text('You clicked on'),
          children: [
            new TextButton(
              child: new Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      });
}
