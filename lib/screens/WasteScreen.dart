import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class WasteScreen extends StatefulWidget {
  const WasteScreen({super.key});

  @override
  State<WasteScreen> createState() => _WasteScreenState();
}

class _WasteScreenState extends State<WasteScreen> {
  late bool loading;
  late DatabaseReference dbRef;
  late String waste;
  late String purpose;
  String currentType = "Forhad";

  List types = ['Forhad', 'Office'];

  @override
  void initState() {
    get();
    super.initState();
  }

  Future get() async {
    setState(() {
      loading = true;
    });
    dbRef = FirebaseDatabase.instance.ref().child('waste');
    setState(() {
      loading = false;
    });
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Enter information"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: currentType,
                    items: types.map((Object? string) {
                      return DropdownMenuItem<String>(
                        value: string?.toString() ?? '',
                        child: Text(string?.toString() ?? ''),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        currentType = newValue!;
                      });
                    },
                  ),
                  TextField(
                    onChanged: (value) => {waste = value},
                    decoration: const InputDecoration(hintText: "Amount"),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    onChanged: (value) => {purpose = value},
                    decoration: const InputDecoration(hintText: "Purpose"),
                  ),
                ],
              ),
            ],
          ),
          actions: [TextButton(onPressed: press, child: const Text("Submit"))],
        ),
      );

  Future<void> press() async {
    late bool completed;
    Map<String, String> contact = {
      'amount': waste,
      'type': currentType,
      'purpose': purpose,
      'day': DateTime.now().day.toString(),
      'month': DateTime.now().month.toString(),
      'year': DateTime.now().year.toString(),
    };
    await dbRef.push().set(contact).whenComplete(() {
      completed = true;
    });
    if (completed) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully added data"),
          backgroundColor: Colors.lightGreenAccent,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error adding data"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Waste Screen"),
        backgroundColor: Colors.red,
      ),
      body: FirebaseAnimatedList(
        reverse: true,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    dbRef.child(data['key']).remove().whenComplete(
                          () => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "${data['name'] / 's data deleted successfully'}"),
                              backgroundColor: Colors.red,
                            ),
                          ),
                        );
                  },
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${data['type']}",
                      style: const TextStyle(
                        // fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${data['day']}-${data['month']}-${data['year']}",
                    ),
                    Text("${data['amount']} tk")
                  ],
                ),
                subtitle: Text(data['purpose']),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
