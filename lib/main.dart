import 'package:flutter/material.dart';
import 'package:hack_princeton/firebase_options.dart';
import 'package:hack_princeton/screens/main_page.dart';
import 'package:hack_princeton/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: SafeArea(child: MainPage()),
    );
  }
}
