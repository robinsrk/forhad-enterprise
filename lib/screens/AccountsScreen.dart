import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:forhad_enterprise/screens/UserHistory.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({Key? key}) : super(key: key);

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  late DatabaseReference dbRef;
  late DatabaseReference monRef;
  late DatabaseReference hisRef;
  late String account;
  late String number;
  late int loan;
  late int collection;
  late int due = 0;
  bool isVisible = true;

  @override
  void initState() {
    get();
    super.initState();
  }

  Future get() async {
    dbRef = FirebaseDatabase.instance.ref().child('accounts');
    hisRef = FirebaseDatabase.instance.ref().child('history');
    await dbRef.child('accounts').once();
    await dbRef.get().then((value) {
      if (value.value != null) {
        Map val = value.value as Map;
        val.forEach((key, valu) {
          setState(() {
            due += valu['due'] as int;
          });
        });
      }
    });
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enter information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                onChanged: (value) => {account = value},
                decoration: const InputDecoration(hintText: "Account name"),
              ),
              TextField(
                onChanged: (value) => {number = value},
                decoration: const InputDecoration(hintText: "Mobile number"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                onChanged: (value) => {loan = int.parse(value)},
                decoration: const InputDecoration(hintText: "Loan amount"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                onChanged: (value) => {collection = int.parse(value)},
                decoration:
                    const InputDecoration(hintText: "Collection amount"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: press,
              child: const Text("Submit"),
            )
          ],
        ),
      );

  Future<void> press() async {
    Navigator.of(context).pop();
    dbRef.orderByChild("name").equalTo(account).get().then((value) async {
      if (value.value != null) {
        PanaraInfoDialog.showAnimatedGrow(
          context,
          title: "Error",
          message: "Account already exists",
          textColor: Colors.redAccent,
          buttonText: "Okay",
          color: Colors.red,
          onTapDismiss: () {
            Navigator.pop(context);
          },
          panaraDialogType: PanaraDialogType.error,
          barrierDismissible: false, // optional parameter (default is true)
        );
        // Dialogs.bottomMaterialDialog(
        //     msg: 'User already exists',
        //     title: "Error",
        //     color: Colors.black26,
        //     context: context,
        //     actions: [
        //       IconsButton(
        //         onPressed: () {},
        //         text: 'OK',
        //         iconData: Icons.delete,
        //         color: Colors.red,
        //         textStyle: TextStyle(color: Colors.white),
        //         iconColor: Colors.white,
        //       ),
        //     ]);
      } else {
        Map<String, dynamic> newData = {
          'name': account,
          'number': number,
          'loan': loan,
          'left': loan,
          'due': 0,
          'collection': collection,
          'day': DateTime.now().day.toString(),
          'month': DateTime.now().month.toString(),
          'year': DateTime.now().year.toString(),
        };
        Map<String, dynamic> historyData = {
          'name': account,
          'amount': -loan,
          'balance': loan,
          'day': DateTime.now().day.toString(),
          'month': DateTime.now().month.toString(),
          'year': DateTime.now().year.toString(),
        };
        hisRef.push().set(historyData);
        dbRef.push().set(newData);
      }
    }).catchError((error) {
      print('Error retrieving data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Accounts"),
            Text("Due: ${NumberFormat("##,##,###").format(due)}"),
          ],
        ),
        backgroundColor: Colors.purple,
      ),
      body: NotificationListener<UserScrollNotification>(
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
          shrinkWrap: true,
          itemBuilder: (BuildContext context, DataSnapshot snapshot,
              Animation<double> animation, int index) {
            Map data = snapshot.value as Map;
            data['key'] = snapshot.key;
            return SizeTransition(
              // onTap: () {
              //   // dbRef
              //   //     .child(data['key'])
              //   //     .remove()
              //   //     .whenComplete(() => MotionToast.error(
              //   //           description: Text(
              //   //               "${data['name']}\'s data removed successfully"),
              //   //         ).show(context));
              // },
              sizeFactor: animation,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  onLongPress: () async {
                    launchUrl(Uri.parse("tel:${data['number']}"));
                  },
                  // onTap: () => openDeposit(data['name']),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserHistory(
                                accountName: data['name'],
                                collection: data['collection'],
                              ))),
                  isThreeLine: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.account_circle,
                      color: data['left'] > 0 ? Colors.green : Colors.red,
                    ),
                    onPressed: () {
                      // dbRef.child(data['key']).remove().whenComplete(
                      //       () => ScaffoldMessenger.of(context)
                      //           .showSnackBar(
                      //         SnackBar(
                      //           content: Text(
                      //               "${data['name'] / 's data deleted successfully'}"),
                      //           backgroundColor: Colors.red,
                      //         ),
                      //       ),
                      //     );
                    },
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['name'],
                        style: const TextStyle(
                          // fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${data['day']}-${data['month']}-${data['year']}",
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${data['number']}",
                        style: const TextStyle(
                          // fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            // "${data['due']} tk",
                            // "${NumberFormat("#,##,##0").format(data['due'])} tk",
                            data['due'] < 0
                                ? ((data['due'] % data['collection'] == 0)
                                    ? "${(data['due'] / data['collection'] * -1).toInt()} days"
                                    : "${data['due']} tk")
                                : "${data['due']} tk",
                            // data['due'] > 0
                            //     ? "data['due']"
                            //     : "data['collection']",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: data['due'] < 1
                                    ? Colors.green
                                    : Colors.red),
                          ),
                        ],
                      ),
                      Text(
                        "${NumberFormat("##,##,###").format(data['left'])} tk",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          // color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 500),
        offset: isVisible ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: isVisible ? 1 : 0,
          child: FloatingActionButton(
            heroTag: "Add",
            onPressed: () => openDialog(),
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}
