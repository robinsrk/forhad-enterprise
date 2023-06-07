import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MonthlyScreen extends StatefulWidget {
  const MonthlyScreen({super.key});

  @override
  State<MonthlyScreen> createState() => _MonthlyScreenState();
}

class _MonthlyScreenState extends State<MonthlyScreen> {
  late DatabaseReference dbRef;
  late int invest;
  late int waste;
  late int collection;
  late int total = 0;

  @override
  void initState() {
    super.initState();
    dbRef = FirebaseDatabase.instance.ref().child('monthly');

    dbRef.get().then((value) {
      if (value.value != null) {
        Map val = value.value as Map;
        val.forEach((key, valu) {
          if (valu['month'] == DateTime.now().month.toString() &&
              valu['year'] == DateTime.now().year.toString()) {
            setState(() {
              total += valu['due'] as int;
            });
          }
        });
      }
    });
  }

  Future<void> press() async {
    Navigator.of(context).pop();
    Map<String, dynamic> newData = {
      'invest': invest,
      'collection': collection,
      'waste': waste,
      'day': DateTime.now().day.toString(),
      'month': DateTime.now().month.toString(),
      'year': DateTime.now().year.toString(),
    };
    dbRef.push().set(newData);
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enter information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) => {invest = int.parse(value)},
                decoration: const InputDecoration(hintText: "Invest"),
              ),
              TextField(
                onChanged: (value) => {collection = int.parse(value)},
                decoration: const InputDecoration(hintText: "Collection"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                onChanged: (value) => {waste = int.parse(value)},
                decoration: const InputDecoration(hintText: "Waste"),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Monthly Screen"),
            Text("Total: ${NumberFormat("##,##,###").format(total)}"),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: FirebaseAnimatedList(
        query: dbRef,
        shrinkWrap: true,
        duration: const Duration(seconds: 3),
        itemBuilder: (context, snapshot, animation, index) {
          // print(snapshot.value.runtimeType);
          Map data = snapshot.value as Map;
          data['key'] = snapshot.key;
          if (data['month'] == DateTime.now().month.toString() &&
              data['year'] == DateTime.now().year.toString()) {
            return GestureDetector(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "",
                        style: TextStyle(
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
                      Text(
                        "${NumberFormat("##,##,###").format(data['invest'])} tk",
                        style: const TextStyle(
                          // fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${NumberFormat("##,##,###").format(data['collection'])} tk",
                      ),
                      Text(
                        "${NumberFormat("##,##,###").format(data['waste'])} tk",
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return const Column();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
