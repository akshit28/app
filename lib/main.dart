import 'package:flutter/material.dart';
import 'package:piiko_app/screens/login.dart';
import 'package:piiko_app/screens/home.dart';
import 'package:provider/provider.dart';
import 'package:piiko_app/providers/scan_provider.dart';
import "package:piiko_app/providers/auth_provider.dart";
import 'package:piiko_app/services/auth_service.dart';

void main() {
  Provider.debugCheckInvalidValueType = null;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MultiProvider(providers: [
      ChangeNotifierProvider<AuthProvider>(create: (context) => AuthProvider()),
      ChangeNotifierProvider<ScanListProvider>(create: (_) => ScanListProvider()),
    ],
    child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Piiko App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,        
          ),
          home: const Home(),
          routes: {
            'home': (context) => const Home(),
            'login_page': (context) => const Login(),
          },
        ) 
    );
  }
}

class AuthContainer extends StatelessWidget {
  const AuthContainer({super.key});

  @override
  Widget build(BuildContext context) {
    var userData = context.watch<AuthProvider?>()?.loginSuccess;
    
    if(userData){
      return const Home();
    }else{
      return const Login();
    }
  }
}