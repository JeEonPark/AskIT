import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ask_it/main.dart';

import 'main.dart';

class QuestionViewPage extends StatefulWidget {
  QuestionViewPage({Key? key}) : super(key: key);

  @override
  State<QuestionViewPage> createState() => _QuestionViewPageState();
}

// Future<Map<String, dynamic>?> getDocument(String docId) async {
//   final documentData = await FirebaseFirestore.instance
//       .collection("AskPage_Questions")
//       .doc(docId)
//       .get();
//   print(documentData.data()!["texts"]);

//   return documentData.data();
// }

class _QuestionViewPageState extends State<QuestionViewPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 37),
        body: SafeArea(
          child: Column(
            children: [
              // 스크롤 영역
              Container(
                child: Column(
                  children: [
                    // 화살표 상단바
                    Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width,
                      height: 80,
                      child: IconButton(
                        padding: EdgeInsets.all(20),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back_rounded),
                        color: Colors.white,
                        iconSize: 35,
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.825,
                      width: MediaQuery.of(context).size.width * 0.86,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //제목
                          Text(
                            args["title"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          //이름 날짜
                          Row(
                            children: [
                              Text(
                                args["author"],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                ),
                              ),
                              SizedBox(width: 5),
                              Text(
                                args["date"],
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Montserrat',
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 12),
                          //글
                          Text(
                            args["texts"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          //이미지
                          //하단 구분선
                          SizedBox(height: 14),
                          Container(
                            height: 1,
                            color: Color.fromARGB(255, 127, 116, 255),
                          ),
                          Spacer(),
                          Row(
                            children: [
                              Spacer(),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                height: 45,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/ask_answer_method_page',
                                      arguments: {
                                        "docId": args['docId'],
                                        "title": args['title'],
                                        "texts": args['texts'],
                                        "author": args['author'],
                                      },
                                    );
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.question_answer_outlined,
                                        size: 30,
                                        color: Colors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Answer this question",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: 'Montserrat',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
