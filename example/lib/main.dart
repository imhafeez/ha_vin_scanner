import 'package:flutter/material.dart';
import 'package:ha_vin_scanner/ha_vin_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String vinNo = "";
  bool auto = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (vinNo.isNotEmpty) ...[
              const Text(
                'scanned vin no:',
              ),
              Text(
                '$vinNo',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
            SizedBox(
              height: 80,
            ),
            CheckboxListTile(
                title: Text("Auto Scan"),
                value: auto,
                onChanged: (value) {
                  setState(() {
                    auto = (value ?? false);
                  });
                }),
            SizedBox(
              height: 80,
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // RegExp regExp = RegExp(
          //     '(?=.*[0-9])(?=.*[A-z])[0-9A-z-]{17}\$'); //"^(?=.*[0-9])(?=.*[A-z])[0-9A-z-]{17}\$");

          // bool exists = "WE0YXXTTGHKJ64988".contains(regExp);
          // int index = "WE0YXXTTGHKJ64988".indexOf(regExp);
          // print(exists);
          HAVINScanner(
              autoScan: auto,
              didScan: (vin) {
                setState(() {
                  vinNo = vin;
                });
              }).show(context);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
