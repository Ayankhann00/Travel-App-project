import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/firebase_options.dart';
import 'package:travel_app/pages/add_page.dart';
import 'package:travel_app/pages/comment.dart';
import 'package:travel_app/pages/home.dart';
import 'package:travel_app/pages/top_places.dart';
import 'pages/signup.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourists Travel Community',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: Home(),
    );
  }
}
