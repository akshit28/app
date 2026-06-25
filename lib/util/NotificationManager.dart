import 'dart:async';
// import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:aap/providers/shared_pref.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

Future<void> onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp();

  if (message.data.containsKey('data')) {
    // Handle data message
    final data = message.data['data'];
  }

  // print("onBackgroundMessage called ******");
  _handleMessage(message);
  // Or do other work.
}

void _handleMessage(RemoteMessage message) {
  if (message.data.isNotEmpty) {
    // print("RemoteMessage ${message.data['route']}");
    // print("RemoteMessage ${message.data['sample_code']}");

    if (message.data['route'] == 'protocol') {
      String internalSampleId = message.data['sample_code'];
      FBroadcast.instance().stickyBroadcast(
        "scroll_to_protocol",
        value: internalSampleId,
      );
      FBroadcast.instance()
          .stickyBroadcast("scan_update", value: internalSampleId);
    }else if(message.data['route'] == 'home'){
      FBroadcast.instance().stickyBroadcast(
        "genric",
        value: message.data['message'],
      );
    }
  }
}

void _handleFroegroundMessage(RemoteMessage message){
  if (message.data.isNotEmpty) {
    if(message.data['route'] == 'home'){
      FBroadcast.instance().stickyBroadcast(
        "genric",
        value: message.data['message'],
      );
    }
  }
}

class FCM {
  final _firebaseMessaging = FirebaseMessaging.instance;

  final streamCtlr = StreamController<String>.broadcast();
  final titleCtlr = StreamController<String>.broadcast();
  final bodyCtlr = StreamController<String>.broadcast();
  var sharedIns = SharedPref();

  setNotifications() {
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    // handle when app in active state
    forgroundNotification();

    // handle when app running in background state
    backgroundNotification();

    // handle when app completely closed by the user
    terminateNotification();

    // With this token you can test it easily on your phone
    _firebaseMessaging.getToken().then((token) async {
      print("token - ${token!}");
      await sharedIns.saveValueToSharedPreferences(
          'fcmToken', token.toString());
    });
  }

  forgroundNotification() {
    FirebaseMessaging.onMessage.listen(
      (message) async {
        if (message.data.containsKey('data')) {
          // Handle data message
          streamCtlr.sink.add(message.data['data']);
        }
        if (message.data.containsKey('notification')) {
          // Handle notification message
          streamCtlr.sink.add(message.data['notification']);
        }
        // Or do other work.
        titleCtlr.sink.add(message.notification!.title!);
        bodyCtlr.sink.add(message.notification!.body!);

        FlutterRingtonePlayer().play(
            fromAsset: "assets/sounds/pause.mp3",
            ios: IosSounds.glass,
            looping: false, // Android only - API >= 28
            volume: 1.0, // Android only - API >= 28
            asAlarm: false);
        _handleFroegroundMessage(message);
      },
    );
  }

  backgroundNotification() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        // if (message.data != null) {
        //   // Handle data message
        //   streamCtlr.sink.add(message.data['data']);
        // }
        // if (message.notification != null) {
        //   // Handle notification message
        //   streamCtlr.sink.add(message.data['notification']);
        // }
        // Or do other work.
        // titleCtlr.sink.add(message.notification!.title!);
        // bodyCtlr.sink.add(message.notification!.body!);
        print(
            "Handling a background message notification dart: ${message.messageId}");
        _handleMessage(message);
      },
    );
  }

  terminateNotification() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      if (initialMessage.data.containsKey('data')) {
        // Handle data message
        streamCtlr.sink.add(initialMessage.data['data']);
      }
      if (initialMessage.data.containsKey('notification')) {
        // Handle notification message
        streamCtlr.sink.add(initialMessage.data['notification']);
      }
      // Or do other work.
      // titleCtlr.sink.add(initialMessage.notification!.title!);
      // bodyCtlr.sink.add(initialMessage.notification!.body!);
      _handleMessage(initialMessage);
    }
  }

  dispose() {
    streamCtlr.close();
    bodyCtlr.close();
    titleCtlr.close();
  }
}
