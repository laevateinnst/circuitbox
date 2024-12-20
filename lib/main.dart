import 'package:flutter/material.dart';
import 'screens/splashscreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      theme: ThemeData(
        fontFamily: 'Helvetica',
      ),
      home: SplashScreen(),
    );
  }
}
