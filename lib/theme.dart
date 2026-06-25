import 'package:flutter/material.dart';

class MyTheme {
  static lightTheme(BuildContext context) {
    return ThemeData(
        // useMaterial3:true,
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle:
              TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Cairo'),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: const TextTheme(
              // button: TextStyle(fontSize: 17, fontFamily: 'Cairo'),
              // bodyText1: TextStyle(fontSize: 17, fontFamily: 'Cairo'),
              // bodyText2: TextStyle(fontSize: 17, fontFamily: 'Cairo'),
              // headline4: TextStyle(fontFamily: 'Cairo'),
              // subtitle1: TextStyle(fontFamily: 'Cairo'),
              displayLarge: TextStyle(fontSize: 20, fontFamily: 'Cairo'),
              displayMedium: TextStyle(fontSize: 17, fontFamily: 'Cairo'),
              titleLarge: TextStyle(fontSize: 17, fontFamily: 'Cairo',),
        )

    );        
  }
}