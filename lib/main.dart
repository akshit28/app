import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aap/screens/bottom_nav.dart';
import 'package:aap/screens/login.dart';
import 'package:aap/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:aap/providers/scan_provider.dart';
import "package:aap/providers/auth_provider.dart";
import "package:aap/providers/protocol_provider.dart";
import 'package:aap/providers/shared_pref.dart';
import 'package:aap/screens/scan_form.dart';
import 'package:aap/theme.dart';
import 'package:aap/screens/add_patient.dart';
import 'package:aap/screens/protocol.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:aap/util/NotificationManager.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:aap/util/snackbar.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:fbroadcast/fbroadcast.dart';


late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void main() async {
  Provider.debugCheckInvalidValueType = null;
  // WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Future.delayed(const Duration(seconds: 1), () {
    WakelockPlus.enable();
  });
  setFirebase();
  final userToken = await getToken();
  runApp(MyApp(isLoggedIn: userToken != null));
}

getToken() async {
  var sharedIns = SharedPref();
  final userToken = await sharedIns.getValueFromSharedPreferences("userToken");
  return userToken;
}

void setFirebase() async {
  await FirebaseMessaging.instance.setAutoInitEnabled(true);
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!kIsWeb) {
    await setupFlutterNotifications();
  }
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
      'high_importance_channel6', // id
      'High Importance Notifications6', // title
      description:
          'This channel is used for important custom notifications.', // description
      importance: Importance.max,
      enableLights: true,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('pause'));

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  String? initialMessage;
  bool _resolved = false;
  // AppUpdateInfo? _updateInfo;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      requestPermission();
      // setupInteractedMessage();
      final firebaseMessaging = FCM();
      firebaseMessaging.setNotifications();
      if (defaultTargetPlatform == TargetPlatform.android) {
        checkForUpdate();
      }
      FlutterNativeSplash.remove();
    }
    //  FBroadcast.instance().register('genric', (value, callback) { });
  }

  Future<void> requestPermission() async {
    String permissionStatus = 'denied';
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      announcement: false,
      sound: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      alert: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      permissionStatus = 'authorized';
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      permissionStatus = 'provisional';
    } else {
      permissionStatus = 'denied';
    }
    var sharedIns = SharedPref();
    await sharedIns.saveValueToSharedPreferences(
        'pushPermissionStatus', permissionStatus);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      // setState(() {
      //   _updateInfo = info;
      // });

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        InAppUpdate.performImmediateUpdate().catchError((e) {
          CustomSnackBar(seconds: 2, text: e.toString(), type: 'error')
              .show(context);
        });
      }
    }).catchError((e) {
      CustomSnackBar(seconds: 2, text: e.toString(), type: 'error')
          .show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>(
              create: (context) => AuthProvider()),
          ChangeNotifierProvider<ScanListProvider>(
              create: (_) => ScanListProvider()),
          ChangeNotifierProvider<ProtocolProvider>(
              create: (_) => ProtocolProvider()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AAP',
          theme: MyTheme.lightTheme(context),
          home: widget.isLoggedIn
              ? BottomNav(routeIndex: 0)
              : const AuthContainer(),
          localizationsDelegates: const [
            MonthYearPickerLocalizations.delegate
          ],
          routes: {
            '/nav': (context) => BottomNav(routeIndex: 0),
            '/home': (context) => const Home(),
            '/scan_form': (context) => const ScanForm(),
            '/add_patient': (context) => const AddPatient(),
            '/protocol': (context) => const Protocol(),
          },
        ));
  }
}

class AuthContainer extends StatefulWidget {
  const AuthContainer({super.key});

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  @override
  Widget build(BuildContext context) {
    var userData = context.watch<AuthProvider?>()?.loginSuccess;
    var token = context.watch<AuthProvider?>()?.userToken;
    if (token != '' || userData) {
      return BottomNav(routeIndex: 0);
    } else {
      return const Login();
    }
  }
}
