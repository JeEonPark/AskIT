import 'package:ask_it/add_question_page.dart';
import 'package:ask_it/login_page.dart';
import 'package:ask_it/question_view_page.dart';
import 'package:ask_it/sign_up_page.dart';
import 'package:ask_it/add_question_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ask_it/question_view_page.dart';
import 'package:ask_it/route_button.dart';

import 'ask_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'add_question_page.dart';
import 'question_view_page.dart';
import 'route_button.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Paint.enableDithering = true;
  print(FirebaseAuth.instance.currentUser);

  runApp(
    MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Navigator',
      initialRoute:
          FirebaseAuth.instance.currentUser == null ? '/' : '/ask_page',
      routes: {
        '/': (context) => LoginPage(),
        '/sign_up_page': (context) => SignUpPage(),
        '/ask_page': (context) => AskPage(),
        '/add_question_page': (context) => AddQuestionPage(),
        '/question_view_page': (context) => QuestionViewPage(),
        '/route_button': (context) => RouteButton(),
      },
    ),
  );
}
