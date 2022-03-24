import 'package:ask_it/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AskAnswerMethodPage extends StatefulWidget {
  AskAnswerMethodPage({Key? key}) : super(key: key);

  @override
  State<AskAnswerMethodPage> createState() => _AskAnswerMethodPageState();
}

//채팅방 Id 불러오기 for 답변자
Future<String> getChatRoomId(String questionDocId) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("AskPage_Questions")
      .doc(questionDocId)
      .collection("ChatRoom")
      .where(
        'replier',
        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
      )
      .get();

  return snapshot.docs.elementAt(0).id;
}

//채팅방 생성
void createChatroom(String questionDocId, Map args) async {
  await FirebaseFirestore.instance
      .collection('AskPage_Questions')
      .doc(questionDocId)
      .collection('ChatRoom')
      .doc()
      .set({
        'replier': FirebaseAuth.instance.currentUser?.uid,
      })
      .then((value) => print("Created"))
      .catchError((error) => print("Failed to add user: $error"));

  String chatRoomId = await getChatRoomId(questionDocId);

  await FirebaseFirestore.instance
      .collection('AskPage_Questions')
      .doc(questionDocId)
      .collection('ChatRoom')
      .doc(chatRoomId)
      .collection('Messages')
      .doc()
      .set({
        'texts': args["texts"],
        'date': Timestamp.now(),
        'sender_uid': args["uid"],
      })
      .then((value) => print("Created 2"))
      .catchError((error) => print("Failed to add user: $error"));
}

class _AskAnswerMethodPageState extends State<AskAnswerMethodPage> {
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
              //상단바 영역
              Container(
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width,
                height: 80,
                child: Row(
                  children: [
                    //뒤로가기 버튼
                    IconButton(
                      padding: EdgeInsets.all(20),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_rounded),
                      color: Colors.white,
                      iconSize: 35,
                    ),
                    //Answer 텍스트
                    const Text(
                      "Answer",
                      style: TextStyle(
                        fontFamily: "Montserrat",
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    "Answer Method",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    color: Colors.white,
                    height: 1,
                    width: 165,
                  ),
                  SizedBox(height: 30),
                  //Text Chat 버튼
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () async {
                        print(args["uid"]);
                        createChatroom(args["docId"], args);
                        navigatorKey.currentState?.pop();
                        navigatorKey.currentState?.pushNamed(
                          '/message_page',
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
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Text Chat",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Voice Call 버튼
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.phone_outlined,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Text & Voice Call",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Video Call 버튼
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.videocam_outlined,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Text & Video Call",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
