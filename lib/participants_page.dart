import 'package:flutter/material.dart';

import 'main.dart';

class ParticipantsPage extends StatefulWidget {
  ParticipantsPage({Key? key}) : super(key: key);

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          body: Center(
            child: Text("Participants"),
          ),
        ),
      ),
    );
  }
}
