import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screen_lock/flutter_screen_lock.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class MyHomeWidget extends StatefulWidget {
  const MyHomeWidget({super.key});

  @override
  State<MyHomeWidget> createState() => _MyHomeWidgetState();
}

class _MyHomeWidgetState extends State<MyHomeWidget> {
  bool net = false;

  void buttonClick(route) {
    Navigator.pushNamed(context, route);
  }

  @override
  void initState() {
    Timer.periodic(
      const Duration(seconds: 1),
      (arg) async {
        bool test = await InternetConnectionChecker().hasConnection;
        setState(() {
          net = test;
        });
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        exit(0);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Forhad Enterprise"),
              net
                  ? TextButton(
                      onPressed: () => {},
                      child: const Icon(
                        Icons.signal_cellular_4_bar,
                        color: Colors.greenAccent,
                      ),
                    )
                  : TextButton(
                      onPressed: () => {},
                      child: const Icon(
                        Icons.signal_cellular_nodata,
                        color: Colors.redAccent,
                      ),
                    ),
            ],
          ),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.green),
                        fixedSize: MaterialStateProperty.all(
                          Size(width * 0.4, height * 0.2),
                        ),
                      ),
                      onPressed: () => buttonClick("/daily"),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.money_off),
                          Text("Daily"),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        fixedSize: MaterialStateProperty.all(
                          Size(width * 0.4, height * 0.2),
                        ),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(10)),
                        alignment: Alignment.center,
                      ),
                      onPressed: () => buttonClick("/monthly"),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.money_off),
                          Text("Monthly"),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        fixedSize: MaterialStateProperty.all(
                          Size(width * 0.4, height * 0.2),
                        ),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(10)),
                        alignment: Alignment.center,
                      ),
                      onPressed: () => {Navigator.pushNamed(context, "/waste")},
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.money_off),
                          Text("Waste"),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.purple),
                        fixedSize: MaterialStateProperty.all(
                          Size(width * 0.4, height * 0.2),
                        ),
                        padding:
                            MaterialStateProperty.all(const EdgeInsets.all(10)),
                        alignment: Alignment.center,
                      ),
                      onPressed: () => buttonClick("/accounts"),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person),
                          Text("Accounts"),
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
