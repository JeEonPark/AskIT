import 'package:ask_it/add_question_page.dart';
import 'package:ask_it/login_page.dart';
import 'package:ask_it/sign_up_page.dart';
import 'package:ask_it/add_question_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ask_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'add_question_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Paint.enableDithering = true;
  print(FirebaseAuth.instance.currentUser);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigator',
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/' : '/ask_page',
      routes: {
        '/': (context) => LoginPage(),
        '/sign_up_page': (context) => SignUpPage(),
        '/ask_page': (context) => AskPage(),
        '/add_question_page': (context) => AddQuestionPage()
      },
    ),
  );
}
