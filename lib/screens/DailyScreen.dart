import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class DailyScreen extends StatefulWidget {
  const DailyScreen({super.key});

  @override
  State<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends State<DailyScreen> {
  late StateSetter _setState;
  late DatabaseReference dbRef;
  late Query accRef;
  late DatabaseEvent ds;
  late int total = 0;
  late int totalDue = 0;
  late int coll = 0;
  late int sum = 0;
  List accounts = [];
  late bool loading;
  late String name;
  late String number;
  late int paid;
  late int due;
  late int currentDue;
  late String day;
  late String month;
  late String year;
  late String key;
  late bool isVisible = true;
  String currentAccount = "";
  List<bool> isSelected = [true];

  @override
  void initState() {
    get();
    super.initState();
  }

  Future get() async {
    total = 0;
    setState(() {
      loading = true;
    });
    accounts.clear();
    dbRef = FirebaseDatabase.instance.ref().child('daily');
    accRef = FirebaseDatabase.instance.ref().child('accounts');
    await accRef.orderByChild("name").get().then((snapshot) {
      for (var element in snapshot.children) {
        Map data = element.value as Map;
        if (data['left'] > 0) {
          accounts.add(data['name'].toString());
        }
        setState(() {
          currentAccount = accounts.isNotEmpty ? accounts[0] : "";
          number = data['number'];
          currentDue = data['due'];
        });
      }
    });
    setState(() {
      loading = false;
    });
    await dbRef.get().then((value) {
      if (value.value != null) {
        Map val = value.value as Map;
        val.forEach((key, valu) {
          if (valu['day'] == DateTime.now().day.toString() &&
              valu['month'] == DateTime.now().month.toString() &&
              valu['year'] == DateTime.now().year.toString()) {
            setState(() {
              total += valu['paid'] as int;
              totalDue += valu['due'] as int;
            });
          }
        });
      }
    });
  }

  void openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Collection: "),
          content:
              StatefulBuilder(builder: (BuildContext context, StateSetter set) {
            _setState = set;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: currentAccount,
                      items: accounts.map((Object? string) {
                        return DropdownMenuItem<String>(
                          value: string?.toString() ?? '',
                          child: Text(string?.toString() ?? ''),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        accRef
                            .orderByChild("name")
                            .equalTo(currentAccount)
                            .get()
                            .then((value) async {
                          Map dt = value.value as Map;
                          dt.forEach((key, value) {
                            set(() {
                              coll = value['collection'];
                            });
                          });
                        });
                        setState(() {
                          currentAccount = newValue!;
                        });
                      },
                    ),
                    TextField(
                      onChanged: (value) => {paid = int.parse(value)},
                      decoration:
                          const InputDecoration(hintText: "Collection amount"),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ],
            );
          }),
          actions: [TextButton(onPressed: press, child: const Text("Submit"))],
        ),
      );

  Future<void> onChange() async {
    accRef
        .orderByChild("name")
        .equalTo(currentAccount)
        .get()
        .then((value) async {
      Map dt = value.value as Map;
      dt.forEach((key, value) {
        setState(() {
          coll = value['collection'];
        });
      });
    });
  }

  Future<void> press() async {
    Navigator.pop(context);
    accRef
        .orderByChild("name")
        .equalTo(currentAccount)
        .get()
        .then((snapshot) async {
      Map data = snapshot.value as Map;
      data.forEach((key, value) async {
        if (paid < 0) {
          PanaraInfoDialog.showAnimatedGrow(
            context,
            title: "Error",
            message: "Invalid paid amount",
            textColor: Colors.redAccent,
            buttonText: "Okay",
            color: Colors.red,
            onTapDismiss: () {
              Navigator.pop(context);
            },
            panaraDialogType: PanaraDialogType.error,
            barrierDismissible: false, // optional parameter (default is true)
          );
        } else {
          setState(() {
            currentAccount = value['name']
                .toString()
                .replaceAll(RegExp(r'\s*\{closed\}'), '');
            number = value['number'];
            due = value['due'] + value['collection'] - paid;

            Map<String, dynamic> newData = {
              'name': currentAccount,
              'number': number,
              'paid': paid,
              'due': due,
              'day': DateTime.now().day.toString(),
              'month': DateTime.now().month.toString(),
              'year': DateTime.now().year.toString(),
            };
            dbRef.push().set(newData);
            FirebaseDatabase.instance
                .ref()
                .child("accounts")
                .child(key)
                .update({'due': due, 'name': currentAccount});
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.fill,
          alignment: Alignment.topRight,
          child: isSelected[0]
              ? AutoSizeText(
                  "Total: ${NumberFormat("##,##,###").format(total)} Due: ${NumberFormat("##,##,###").format(totalDue)}",
                )
              : const Text(""),
        ),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Expanded(
            child: NotificationListener<UserScrollNotification>(
              onNotification: (notification) {
                if (notification.direction == ScrollDirection.forward) {
                  if (!isVisible) {
                    setState(() {
                      isVisible = true;
                    });
                  }
                } else if (notification.direction == ScrollDirection.reverse) {
                  if (isVisible) {
                    setState(() {
                      isVisible = false;
                    });
                  }
                }
                return true;
              },
              child: FirebaseAnimatedList(
                query: dbRef,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemBuilder: (context, snapshot, animation, index) {
                  Map data = snapshot.value as Map;
                  data['key'] = snapshot.key;
                  if (isSelected[0] == true) {
                    if (data['day'] == DateTime.now().day.toString() &&
                        data['month'] == DateTime.now().month.toString() &&
                        data['year'] == DateTime.now().year.toString()) {
                      for (int i = 0; i < accounts.length; i++) {
                        if (accounts[i] == data['name']) {
                          accounts.removeAt(i);
                        }
                      }
                      return SizeTransition(
                        sizeFactor: animation,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            onLongPress: () async {
                              launchUrl(Uri.parse("tel:${data['number']}"));
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () async {
                                await accRef
                                    .orderByChild("name")
                                    .equalTo(data['name'])
                                    .get()
                                    .then((snap) async {
                                  Map value = snap.value as Map;
                                  value.forEach((key, value) {
                                    FirebaseDatabase.instance
                                        .ref()
                                        .child("accounts")
                                        .child(key)
                                        .update({
                                      'due': value['due'] +
                                          data['paid'] -
                                          value['collection'],
                                    });
                                  });
                                }).whenComplete(() async {
                                  await dbRef
                                      .child(data['key'])
                                      .remove()
                                      .whenComplete(
                                        () => ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Deleted data of ${data['name']}",
                                            ),
                                            backgroundColor: Colors.redAccent,
                                          ),
                                        ),
                                      );
                                });
                              },
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  data['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(""),
                                Text(
                                  "${data['day']}-${data['month']}-${data['year']}",
                                ),
                              ],
                            ),
                            subtitle: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${data['number']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (data['paid'] > 0)
                                  Text(
                                    "${NumberFormat("##,##,###").format(data['paid'])} tk",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                else
                                  const Text(
                                    "Due",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                Text(
                                  "${NumberFormat("##,##,###").format(data['due'])} tk",
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      return const Column();
                    }
                  } else {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.grey,
                            ),
                            onPressed: () async {
                              await accRef
                                  .orderByChild("name")
                                  .equalTo(data['name'])
                                  .get()
                                  .then((snap) async {
                                Map value = snap.value as Map;
                                value.forEach((key, value) {
                                  FirebaseDatabase.instance
                                      .ref()
                                      .child("accounts")
                                      .child(key)
                                      .update({
                                    'due': value['due'] + data['paid'],
                                    'name': value['name'].replaceAll(
                                        RegExp(r'\s*\{closed\}'), '')
                                  });
                                });
                              }).whenComplete(() async {
                                await dbRef
                                    .child(data['key'])
                                    .remove()
                                    .whenComplete(
                                      () => ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Deleted data of ${data['name']}",
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      ),
                                    );
                              });
                            },
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                data['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(""),
                              Text(
                                "${data['day']}-${data['month']}-${data['year']}",
                              ),
                            ],
                          ),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${data['number']}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (data['paid'] > 0)
                                Text(
                                  "${NumberFormat("##,##,###").format(data['paid'])} tk",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                const Text(
                                  "Due",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              Text(
                                "${NumberFormat("##,##,###").format(data['due'])} tk",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(seconds: 1),
        offset: isVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(seconds: 1),
          opacity: isVisible ? 1 : 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                heroTag: "switch",
                onPressed: () => setState(() {
                  isSelected[0] = !isSelected[0];
                }),
                child: Icon(isSelected[0] ? Icons.today : Icons.calendar_month),
              ),
              FloatingActionButton(
                heroTag: "Add",
                onPressed: () {
                  onChange();
                  openDialog();
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
