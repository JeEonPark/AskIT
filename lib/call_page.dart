import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  CallPage({Key? key}) : super(key: key);

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 37),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5)),
              child: Icon(Icons.person_outline, color: Colors.white, size: 70),
            ),
            Text("")
          ],
        ),
      ),
    );
  }
}
