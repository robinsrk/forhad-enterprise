import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({Key? key}) : super(key: key);

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Lottie.asset(
            "assets/lottie/storage.json",
            // fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            animate: true,
          ),
        ],
      ),
    );
  }
}
