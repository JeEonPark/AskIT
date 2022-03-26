import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ask_it/main.dart';
import 'package:flutter/scheduler.dart';

import 'main.dart';

class AddSessionPage extends StatefulWidget {
  AddSessionPage({Key? key}) : super(key: key);

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

class _AddSessionPageState extends State<AddSessionPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SafeArea(child: Scaffold(body: Center(child: Text("Add session page")))));
  }
}
