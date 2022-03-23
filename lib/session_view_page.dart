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

  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection("DiscussPage_Sessions")
      .doc(docId)
      .get();

  lists.add(snapshot.id);

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
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                                    padding: EdgeInsets.fromLTRB(16, 0, 20, 0),
                                    child: Text(
                                      snapshot.data.values
                                          .elementAt(0)?['title'],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  //프로필
                                  Container(
                                    height: 100,
                                    padding: EdgeInsets.all(25),
                                    child: Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white,
                                                  width: 1.5)),
                                          child: Icon(Icons.person_outline,
                                              color: Colors.white, size: 40),
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            //작성자 이름+버튼
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(
                                                      20, 2, 0, 0),
                                                  child: Text(
                                                    snapshot.data.values
                                                        .elementAt(
                                                            0)?['author'],
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 16.0,
                                                  width: 16.0,
                                                  child: IconButton(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              15, 2, 0, 0),
                                                      iconSize: 16,
                                                      onPressed: () {},
                                                      icon: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color: Colors.white)),
                                                ),
                                              ],
                                            ),
                                            Spacer(),
                                            //level 등급. 임시로 egg level로 고정
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  20, 0, 0, 4),
                                              child: Text(
                                                "Egg level",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontFamily: 'Montserrat',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
