import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ask_it/main.dart';

import 'main.dart';

class SessionViewPage extends StatefulWidget {
  SessionViewPage({Key? key}) : super(key: key);

  @override
  State<SessionViewPage> createState() => _SessionViewPageState();
}

Future<List> getDocumnetList(String docId) async {
  List<String> lists = [];

  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("DiscussPage_Sessions")
      .where('docId', isEqualTo: docId) //끝난 페이지는 제외
      .get();
  snapshot.docs.forEach((element) {
    lists.add(element.id);
  });

  return lists;
}

// Map<글 코드, 글 데이터맵>
Future<Map> getDocument(String docId) async {
  List lists = await getDocumnetList(docId); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance
        .collection("DiscussPage_Sessions")
        .doc(lists[i])
        .get();
    map[lists[i]] = documentData.data();
  }

  return map;
}

class _SessionViewPageState extends State<SessionViewPage> {
  @override
  Widget build(BuildContext context) {
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
                      children: [
                        //뒤로가기 버튼
                        IconButton(
                          padding: EdgeInsets.all(20),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          iconSize: 35,
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        //scratch pad 버튼
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          iconSize: 35,
                          icon: const Icon(
                            Icons.sticky_note_2_outlined,
                            color: Colors.white,
                          ),
                        ),
                        //참가자목록 버튼
                        IconButton(
                          padding: EdgeInsets.fromLTRB(10, 0, 20, 0),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          iconSize: 35,
                          icon: const Icon(
                            Icons.people_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FutureBuilder(
                      future: getDocument(args['docId']),
                      builder: (context, snapshot) {
                        if (snapshot.hasData == false) {
                          return Text("loading");
                        } else {
                          return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  getDocument('docId');
                                });
                              },
                              child: Column(
                                children: [
                                  //제목 박스
                                  Container(
                                    padding: EdgeInsets.fromLTRB(25, 0, 20, 0),
                                    child: Text(
                                      "",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        }
                      }),
                ],
              ),
            ),
          ),
        ));
  }
}
