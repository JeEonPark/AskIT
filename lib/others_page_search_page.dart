import 'package:ask_it/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'package:ask_it/main.dart';
import 'home_page.dart';

class OthersPageSearchPage extends StatefulWidget {
  OthersPageSearchPage({Key? key}) : super(key: key);

  @override
  State<OthersPageSearchPage> createState() => _OthersPageSearchPageState();
}

//#region Firebase 함수
//내가 답변한 글 리스트 불러오기
Future<List> getAnsweredDocumentList() async {
  List<String> lists = [];

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collectionGroup("ChatRoom")
      .where(
        'replier',
        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
      )
      .get();

  snapshot.docs.forEach((element) {
    lists.add(element.reference.parent.parent!.id);
  });

  return lists;
}

//내 글 리스트 불러오기
Future<List> getDocumentList() async {
  List<String> lists = [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("AskPage_Questions")
      .orderBy('date', descending: true)
      .where(
        'uid',
        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
      )
      .get();
  snapshot.docs.forEach((element) {
    lists.add(element.id);
  });

  return lists;
}

// Map<글 코드, 글 데이터맵>
Future<Map> getDocument(Map args) async {
  List lists = [];
  if (args["page"] == "questions") {
    lists = await getDocumentList();
  } else if (args["page"] == "ianswered") {
    lists = await getAnsweredDocumentList();
  }
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance.collection("AskPage_Questions").doc(lists[i]).get();
    map[lists[i]] = documentData.data();
  }

  return map;
}

//#endregion Firebase 함수

//#region First, Second 위젯
Widget first(String docId, String title, String texts, String author, DateTime date, String uid, List joined) {
  return GestureDetector(
    onTap: () {
      gotoQuestionViewPage(docId, title, texts, author, date, uid, joined);
    },
    child: Container(
      height: 150,
      margin: EdgeInsets.fromLTRB(8, 5, 8, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 89, 47, 178),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 0.35, 1],
          colors: [Color.fromARGB(255, 91, 50, 180), Color.fromARGB(255, 88, 55, 165), Color.fromARGB(255, 49, 27, 96)],
        ),
      ),
      child: Column(
        children: [
          Container(
            //width = MediaQuery.of(context).size.width * 0.8,
            padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
            alignment: Alignment.bottomLeft,
            height: 43,
            child: RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              text: TextSpan(
                text: title,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
              alignment: Alignment.topLeft,
              width: 100,
              height: 60,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                text: TextSpan(
                  text: texts,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 5, 5, 0),
              width: 100,
              height: 35,
              child: Row(
                children: [
                  Text(
                    author,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateFormat('yyyy.MM.dd').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget second(String docId, String title, String texts, String author, DateTime date, String uid, List joined) {
  return GestureDetector(
    onTap: () {
      gotoQuestionViewPage(docId, title, texts, author, date, uid, joined);
    },
    child: Container(
      height: 150,
      margin: EdgeInsets.fromLTRB(8, 5, 8, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color.fromARGB(255, 89, 47, 178),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, 0.35, 1],
          colors: [
            Color.fromARGB(255, 162, 61, 209),
            Color.fromARGB(255, 148, 66, 205),
            Color.fromARGB(255, 54, 27, 99)
          ],
        ),
      ),
      child: Column(
        children: [
          FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
              alignment: Alignment.bottomLeft,
              height: 43,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                text: TextSpan(
                  text: title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 5, 15, 0),
              alignment: Alignment.topLeft,
              width: 100,
              height: 60,
              child: RichText(
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                text: TextSpan(
                  text: texts,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 1,
            child: Container(
              padding: EdgeInsets.fromLTRB(15, 5, 5, 0),
              width: 100,
              height: 35,
              child: Row(
                children: [
                  Text(
                    author,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  Spacer(),
                  Text(
                    DateFormat('yyyy.MM.dd').format(date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    onPressed: () {},
                    icon: const Icon(
                      Icons.thumb_up_alt_outlined,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

//#endregion First, Second 위젯

class _OthersPageSearchPageState extends State<OthersPageSearchPage> {
  //변수
  @override
  Widget build(BuildContext context) {
    getAnsweredDocumentList();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 37),
        body: SafeArea(
          //앱 전체 감싸는 div
          child: Container(
            child: Column(
              children: [
                //상단바 div
                Container(
                  height: 70,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      //뒤로가기 버튼
                      IconButton(
                        padding: EdgeInsets.all(20),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close),
                        color: Colors.white,
                        iconSize: 35,
                      ),
                      //Answer 텍스트
                      Text(
                        args['page'] == 'questions'
                            ? "Questions"
                            : args['page'] == 'ianswered'
                                ? "I Answered"
                                : "Liked",
                        style: const TextStyle(
                          fontFamily: "Montserrat",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: getDocument(args),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.hasData == false) {
                        return const Text("Loading...",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                            ));
                      } else {
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              getDocument(args);
                            });
                          },
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                for (int i = 0; i < snapshot.data.length; i++)
                                  i % 2 == 0
                                      ? Column(
                                          children: [
                                            if (i == 0) SizedBox(height: 5),
                                            first(
                                              snapshot.data.keys.elementAt(i),
                                              snapshot.data.values.elementAt(i)?['title'],
                                              snapshot.data.values.elementAt(i)?['texts'],
                                              snapshot.data.values.elementAt(i)?['author'],
                                              snapshot.data.values.elementAt(i)?['date'].toDate(),
                                              snapshot.data.values.elementAt(i)?['uid'],
                                              snapshot.data.values.elementAt(i)?['joined'],
                                            ),
                                            if (i == snapshot.data.length - 1) SizedBox(height: 5),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            second(
                                              snapshot.data.keys.elementAt(i),
                                              snapshot.data.values.elementAt(i)?['title'],
                                              snapshot.data.values.elementAt(i)?['texts'],
                                              snapshot.data.values.elementAt(i)?['author'],
                                              snapshot.data.values.elementAt(i)?['date'].toDate(),
                                              snapshot.data.values.elementAt(i)?['uid'],
                                              snapshot.data.values.elementAt(i)?['joined'],
                                            ),
                                            if (i == snapshot.data.length - 1) SizedBox(height: 5),
                                          ],
                                        ),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
