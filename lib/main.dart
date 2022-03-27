import 'package:ask_it/add_question_page.dart';
import 'package:ask_it/ask_answer_method_page.dart';
import 'package:ask_it/login_page.dart';
import 'package:ask_it/message_page.dart';
import 'package:ask_it/others_message_page.dart';
import 'package:ask_it/others_page_search_page.dart';
import 'package:ask_it/question_view_page.dart';
import 'package:ask_it/scratch_pad.dart';
import 'package:ask_it/sign_up_page.dart';
import 'package:ask_it/add_question_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ask_it/question_view_page.dart';
import 'package:ask_it/search_page.dart';
import 'package:ask_it/ask_answer_method_page.dart';
import 'package:ask_it/message_page.dart';
import 'package:ask_it/others_page_search_page.dart';
import 'package:ask_it/scratch_pad.dart';

import 'home_page.dart';
import 'login_page.dart';
import 'sign_up_page.dart';
import 'add_question_page.dart';
import 'question_view_page.dart';
import 'search_page.dart';
import 'ask_answer_method_page.dart';
import 'message_page.dart';
import 'session_view_page.dart';
import 'others_message_page.dart';
import 'add_session_page.dart';
import 'others_page_search_page.dart';
import 'scratch_pad.dart';
import 'participants_page.dart';

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
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/' : '/ask_page',
      routes: {
        '/': (context) => LoginPage(),
        '/sign_up_page': (context) => SignUpPage(),
        '/ask_page': (context) => HomePage(),
        '/add_question_page': (context) => AddQuestionPage(),
        '/question_view_page': (context) => QuestionViewPage(),
        '/search_page': (context) => SearchPage(),
        '/ask_answer_method_page': (context) => AskAnswerMethodPage(),
        '/message_page': (context) => MessagePage(),
        '/others_message_page': (context) => OthersMessagePage(),
        '/session_view_page': (context) => SessionViewPage(),
        '/add_session_page': (context) => AddSessionPage(),
        '/others_page_search_page': (context) => OthersPageSearchPage(),
        '/scratch_pad': (context) => ScratchPad(),
        '/participants_page': (context) => ParticipantsPage(),
      },
    ),
  );
}
