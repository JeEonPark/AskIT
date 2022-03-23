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

//My Answer 최우선, 나머지 답변들
Future<List> chatRoomList(String questionDocId) async {
  List result = [];

  //내 답변
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('AskPage_Questions')
      .doc(questionDocId)
      .collection("ChatRoom")
      .where('replier', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
      .get();
  if (snapshot.docs.length == 1) {
    result.add(snapshot.docs.elementAt(0).id);
  }

  //나머지 답변
  snapshot = await FirebaseFirestore.instance
      .collection('AskPage_Questions')
      .doc(questionDocId)
      .collection("ChatRoom")
      .get();
  snapshot.docs.forEach((element) {
    if (element.get("replier") != FirebaseAuth.instance.currentUser?.uid) {
      result.add(element.id);
    }
  });

  return result;
}

//Map<채팅방 uid, 마지막 채팅>
Future<Map> mapChatroomUidChat(String questionDocId) async {
  List list = await chatRoomList(questionDocId);
  Map map = {};
  list.forEach((element) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('AskPage_Questions')
        .doc(questionDocId)
        .collection("ChatRoom")
        .doc(element)
        .collection("Messages")
        .orderBy('date', descending: true)
        .get();
    map[element] = snapshot.docs.first.get("texts");
  });

  print(map);
  return map;
}

// Future<bool> myAnswer(String questionDocId) async {
//   QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection('AskPage_Questions')
//       .doc(questionDocId)
//       .collection("ChatRoom")
//       .where('replier', isEqualTo: "asd")
//       .get();

//   if (snapshot.docs.length == 0) {
//     return false;
//   }

//   return true;
// }

class _QuestionViewPageState extends State<QuestionViewPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    mapChatroomUidChat(args['docId']);
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
                      child: SingleChildScrollView(
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
                            SizedBox(height: 25),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 내 답변
                                Container(
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 127, 116, 255),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "My Answer",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "So did you understand my answer?",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat",
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 15),
                                    ],
                                  ),
                                ),
                                //하단 구분선
                                SizedBox(height: 14),
                                Container(
                                  height: 1,
                                  color: Colors.white,
                                ),
                                SizedBox(height: 14),
                                // 타인 답변
                                Container(
                                  height: 70,
                                  width:
                                      MediaQuery.of(context).size.width * 0.86,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 80, 87, 152),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 15),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Severus",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat",
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "umm. okay",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: "Montserrat",
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 15),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
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
          backgroundColor: Colors.white,
          icon: Icon(
            Icons.question_answer_outlined,
            size: 30,
            color: Colors.black,
          ),
          label: Text(
            'Answer this Question',
            style: TextStyle(
              fontSize: 18,
              fontFamily: 'Montserrat',
              color: Colors.black,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
