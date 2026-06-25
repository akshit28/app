import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import "package:aap/providers/protocol_provider.dart";
import 'package:provider/provider.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int initialTimeInSeconds;
  String? internalSampleId;

  CountdownTimerWidget({super.key, required this.initialTimeInSeconds, this.internalSampleId});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  late Timer _timer;
  int _currentTimeInSeconds = 0;
  late var protocolPvdr = context.read<ProtocolProvider>();
  int timerVal = 0;

   @override
  void initState() {
    print("CountdownTimerWidget called *************");
    super.initState();

    DateTime currentTime = DateTime.now();
    DateTime ts = DateTime.fromMillisecondsSinceEpoch(widget.initialTimeInSeconds*1000);
    Duration diff = ts.difference(currentTime);
    _currentTimeInSeconds = diff.inSeconds;
    // _currentTimeInSeconds = widget.initialTimeInSeconds;
    startTimer();
    timerVal = widget.initialTimeInSeconds;
    print(_currentTimeInSeconds);
    playRinger(true);
  }

  void playRinger(bool ringerFlag) async{
    print("play ringer  timer**********************$ringerFlag");
    if (ringerFlag) {
      FlutterRingtonePlayer().play(
          fromAsset: "assets/sounds/pause.mp3",
          ios: IosSounds.glass,
          looping: false, // Android only - API >= 28
          volume: 1, // Android only - API >= 28
          asAlarm: false);
    } else {
      FlutterRingtonePlayer().stop();   
    }
  }

  void startTimer() {
    print("startTimer called **********************");
    print(widget.internalSampleId);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      
        // if (_currentTimeInSeconds > 0) {
        if(timerVal > 0){  
          // _currentTimeInSeconds--
          DateTime currentTime = DateTime.now();
          DateTime ts = DateTime.fromMillisecondsSinceEpoch(widget.initialTimeInSeconds*1000);
          Duration diff = ts.difference(currentTime);
          _currentTimeInSeconds = diff.inSeconds;

          // _currentTimeInSeconds = --timerVal;
          setState(() {
            _currentTimeInSeconds;
          });
        } else {
          _timer.cancel();
          // playRinger(false);
          protocolPvdr.removeInstruction(widget.internalSampleId.toString());
        }
      });
    
  }

  void restartTimer() {
    _timer.cancel();
    startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTimeInSeconds != widget.initialTimeInSeconds) {
      DateTime currentTime = DateTime.now();
      DateTime ts = DateTime.fromMillisecondsSinceEpoch(widget.initialTimeInSeconds*1000);
      Duration diff = ts.difference(currentTime);
      _currentTimeInSeconds = diff.inSeconds;
      // _currentTimeInSeconds = widget.initialTimeInSeconds;
      restartTimer();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedTime = _formatTime(_currentTimeInSeconds);

     return Text(
      formattedTime,
      style: const TextStyle(fontSize: 28, fontFamily: "Cairo", color: Colors.red, fontWeight: FontWeight.w800),
    );
  }

  String _formatTime(int time) {
    // int hours = seconds ~/ 3600;
    int minutes = time ~/ 60;
    int remainingSeconds = time % 60;

    // String hoursStr = (hours < 10) ? '0$hours' : '$hours';
    String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
    String secondsStr = (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';
    if(time>0){
      return '${minutesStr}m:${secondsStr}s';
    }else{
      return '';
    }
    
  }
}