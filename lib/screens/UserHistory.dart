import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserHistory extends StatefulWidget {
  const UserHistory(
      {super.key, required this.accountName, required this.collection});

  final String accountName;
  final int collection;

  @override
  State<UserHistory> createState() => _UserHistoryState();
}

class _UserHistoryState extends State<UserHistory> {
  late Query dbRef;
  late DatabaseReference hisRef;
  late DatabaseReference accRef;
  late int invest;
  late int waste;
  late String number;
  late int total = 0;
  late int dep;
  late int balance;

  @override
  void initState() {
    super.initState();
    hisRef = FirebaseDatabase.instance.ref().child('history');
    accRef = FirebaseDatabase.instance.ref().child('accounts');
    dbRef = FirebaseDatabase.instance
        .ref()
        .child('history')
        .orderByChild("name")
        .equalTo(widget.accountName);

    dbRef.get().then((value) {
      if (value.value != null) {
        Map val = value.value as Map;
        val.forEach((key, valu) {
          if (valu['month'] == DateTime.now().month.toString() &&
              valu['year'] == DateTime.now().year.toString()) {
            setState(() {
              // number = valu['number'];
              // total += valu['due'] as int;
            });
          }
        });
      }
    });
  }

  void openDeposit(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter information"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              onChanged: (value) => {dep = int.parse(value)},
              decoration: InputDecoration(hintText: "Account $name"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => submit(name),
            child: const Text("Submit"),
          )
        ],
      ),
    );
  }

  Future<void> submit(String name) async {
    await accRef.orderByChild("name").equalTo(name).get().then((snap) async {
      Map value = snap.value as Map;
      value.forEach((key, value) {
        setState(() {
          balance = value['left'] - dep;
        });
        FirebaseDatabase.instance.ref().child("accounts").child(key).update({
          'left': balance,
        });
      });
    });

    Navigator.of(context).pop();
    Map<String, dynamic> newData = {
      'name': widget.accountName,
      'amount': dep,
      'balance': balance,
      'day': DateTime.now().day.toString(),
      'month': DateTime.now().month.toString(),
      'year': DateTime.now().year.toString(),
    };
    await hisRef.push().set(newData);
  }

  Future<void> delete(String key, int amount) async {
    hisRef.child(key).remove();
    accRef.orderByChild("name").equalTo(widget.accountName).get().then((snap) {
      Map value = snap.value as Map;
      value.forEach((key, value) {
        FirebaseDatabase.instance.ref().child("accounts").child(key).update({
          'left': value['left'] + amount,
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("${widget.accountName}'s history")),
            Text("Daily: ${widget.collection}"),
          ],
        ),
        backgroundColor: Colors.purple,
      ),
      body: FirebaseAnimatedList(
        query: dbRef,
        shrinkWrap: true,
        itemBuilder: (context, snapshot, animation, index) {
          // print(snapshot.value.runtimeType);
          Map data = snapshot.value as Map;
          data['key'] = snapshot.key;
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
                  onPressed: () => delete(data['key'], data['amount']),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${data['name']}",
                      style: const TextStyle(
                        // fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text("${data['day']}-${data['month']}-${data['year']}"),
                  ],
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "",
                    ),
                    Text(
                      "${NumberFormat("##,##,###").format(data['amount'])} tk",
                      style: TextStyle(
                        color: data['amount'] > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      "${NumberFormat("##,##,###").format(data['balance'])} tk",
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openDeposit(widget.accountName),
        child: const Icon(Icons.add),
      ),
    );
  }
}
