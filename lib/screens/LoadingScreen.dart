import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final dbRef = FirebaseDatabase.instance.ref().child("status");

  late String code;

  void getData(context) async {
    await Future.delayed(const Duration(seconds: 3));
    await dbRef.once().then((value) {
      value.snapshot.children.forEach((element) {
        Map val = element.value as Map;
        print(val['lock']);
        setState(() {
          code = val['lock'].toString();
        });
      });
    });
    await dbRef
        .orderByChild('paid')
        .equalTo(true)
        .get()
        .then((DataSnapshot snapshot) async {
      if (snapshot.value != null) {
        screenLock(
            context: context,
            correctString: code,
            canCancel: false,
            onUnlocked: () => Navigator.pushNamed(context, "/home"));
      } else {
        Navigator.pushNamed(context, "/error");
      }
    }).catchError((error) {
      print('Error retrieving data: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    dbRef.onChildChanged.listen((event) {
      Navigator.pushNamed(context, "/loading");
    });
    getData(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Material(
        child: Stack(
          children: <Widget>[
            Container(
              color: Colors.blue,
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 50.0,
                          child: Icon(
                            Icons.person_outline,
                            color: Theme.of(context).primaryColor,
                            size: 48.0,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'Forhad Enterprise',
                            style: TextStyle(
                              fontSize: 32,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const CircularProgressIndicator(
                    color: Colors.red,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 16, bottom: 32),
                    child: Text(
                      'Vadail Bazar, Savar EPZ, Savar, Dhaka',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

/* ******************************************
*********************************************
*********************************************
              *** END***
*********************************************
*********************************************
****************************************** */
