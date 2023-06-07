import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:forhad_enterprise/screens/AccountsScreen.dart';
import 'package:forhad_enterprise/screens/DailyScreen.dart';
import 'package:forhad_enterprise/screens/ErrorScreen.dart';
import 'package:forhad_enterprise/screens/HomeScreen.dart';
import 'package:forhad_enterprise/screens/LoadingScreen.dart';
import 'package:forhad_enterprise/screens/MonthlyScreen.dart';
import 'package:forhad_enterprise/screens/WasteScreen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseDatabase.instance.setPersistenceEnabled(true);
  FirebaseDatabase.instance.ref().keepSynced(true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      initialRoute: "/loading",
      routes: {
        "/loading": (context) => const LoadingScreen(),
        "/error": (context) => const ErrorScreen(),
        "/home": (context) => const MyHomeWidget(),
        "/daily": (context) => const DailyScreen(),
        "/monthly": (context) => const MonthlyScreen(),
        "/waste": (context) => const WasteScreen(),
        "/accounts": (context) => const AccountsScreen()
      },
    );
  }
}
