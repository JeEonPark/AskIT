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
  //변수들
  int pageSelected = 1;
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //제목 박스
                              Container(
                                padding: EdgeInsets.fromLTRB(24, 0, 20, 0),
                                child: Text(
                                  snapshot.data.values.elementAt(0)?['title'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              //프로필 박스
                              Container(
                                height: 100,
                                padding: EdgeInsets.all(25),
                                child: Row(
                                  children: [
                                    //프로필 사진
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors.white, width: 1.5)),
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
                                                    .elementAt(0)?['author'],
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
                                                  padding: EdgeInsets.fromLTRB(
                                                      15, 2, 0, 0),
                                                  iconSize: 16,
                                                  onPressed: () {},
                                                  icon: Icon(
                                                      Icons.arrow_forward_ios,
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        //level 등급. 임시로 egg level로 고정
                                        Container(
                                          padding:
                                              EdgeInsets.fromLTRB(20, 0, 0, 4),
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
                              //기간 텍스트(임시로 고정)
                              Container(
                                padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                                child: Text(
                                  "2022.03.06 ~ 2022.04.10",
                                  style: TextStyle(
                                    color: Color.fromARGB(153, 255, 255, 255),
                                    fontSize: 15,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              //며칠 후 종료 텍스트(임시로 고정)
                              Container(
                                padding: EdgeInsets.fromLTRB(24, 5, 0, 0),
                                child: Text(
                                  "ended after 3 days",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              SizedBox(height: 35),
                              Container(
                                height: 1,
                                width: MediaQuery.of(context).size.width,
                                color: Color.fromARGB(102, 255, 255, 255),
                              ),
                              //Contents, community, live 선택바
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Spacer(
                                      flex: 1,
                                    ),
                                    //Contents 버튼
                                    Column(
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 15, 0, 0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                            splashFactory:
                                                NoSplash.splashFactory,
                                            primary: pageSelected == 1
                                                ? Colors.white
                                                : Color.fromARGB(
                                                    100, 255, 255, 255),
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              pageSelected = 1;
                                            });
                                          },
                                          child: const Text("Contents"),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: pageSelected == 1
                                                ? Colors.white
                                                : const Color.fromARGB(
                                                    0, 255, 255, 255),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 2, 0, 0),
                                          padding: const EdgeInsets.all(0),
                                          width: 40,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                    const Spacer(
                                      flex: 2,
                                    ),
                                    //Community 버튼
                                    Column(
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 15, 0, 0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap, //???
                                            splashFactory:
                                                NoSplash.splashFactory,
                                            primary: pageSelected == 2
                                                ? Colors.white
                                                : Color.fromARGB(
                                                    100, 255, 255, 255),
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              pageSelected = 2;
                                            });
                                          },
                                          child: const Text("Community"),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: pageSelected == 2
                                                ? Colors.white
                                                : const Color.fromARGB(
                                                    0, 255, 255, 255),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 2, 0, 0),
                                          padding: const EdgeInsets.all(0),
                                          width: 40,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                    const Spacer(
                                      flex: 2,
                                    ),
                                    //Live 버튼
                                    Column(
                                      children: [
                                        TextButton(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 15, 0, 0),
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap, //???
                                            splashFactory:
                                                NoSplash.splashFactory,
                                            primary: pageSelected == 3
                                                ? Colors.white
                                                : Color.fromARGB(
                                                    100, 255, 255, 255),
                                            textStyle: const TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'Montserrat',
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              pageSelected = 3;
                                            });
                                          },
                                          child: const Text("Live"),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: pageSelected == 3
                                                ? Colors.white
                                                : const Color.fromARGB(
                                                    0, 255, 255, 255),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(100)),
                                          ),
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 2, 0, 0),
                                          padding: const EdgeInsets.all(0),
                                          width: 20,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                    Spacer(flex: 1),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    }),
                    
              ],
            ),
          ),
        ),
        //하단바(host 포함해서 join된 사람들은 보이지 않아야 함)
        bottomNavigationBar: Container(
          height: 60,
          child: Column(
            children: [
              Container(
                  height: 1,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(width: 20),
                    //하트(안눌렀을때, 눌렀을때 색깔 변화 나중에 넣기)
                    SizedBox(
                      height: 35,
                      child: IconButton(
                        splashRadius: 30,
                        iconSize: 35,
                        padding: EdgeInsets.all(0),
                        onPressed: () {},
                        icon: Icon(
                          Icons.favorite,
                          color: Color.fromARGB(255, 206, 55, 55),
                        ),
                      ),
                    ),
                    //좋아요 수(나중에 liked array length로 넣기)
                    Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        "16",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    //Join this session 버튼
                    Container(
                      padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                      height: 40,
                      width: 280,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          primary: Colors.white,
                        ),
                        icon: Icon(
                          Icons.question_answer,
                          color: Colors.black,
                        ),
                        label: Text(
                          "Join this Session",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontFamily: 'Montserrat',
                          ),
                        ),
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
