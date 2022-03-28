import 'package:flutter/material.dart';
import 'package:ask_it/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';

class ParticipantsPage extends StatefulWidget {
  ParticipantsPage({Key? key}) : super(key: key);

  @override
  State<ParticipantsPage> createState() => _ParticipantsPageState();
}

Future<List> getDocumnetList(String docId) async {
  List<String> lists = [];

  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(docId).get();

  lists.add(snapshot.id);

  return lists;
}

//닉네임 리스트
Future<List> getUsername(String docId) async {
  List lists = [];
  //uid 닉네임 매치
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(docId).get();

  List joined = snapshot.get('joined'); //uid list
  String uid;
  String username;
  for (int i = 0; i < joined.length; i++) {
    uid = joined[i];
    username = await getUsernamebyUid(uid);
    lists.add(username);
  }

  return lists;
}

Future<Map> getDocument(String docId) async {
  List lists = await getDocumnetList(docId); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(lists[i]).get();
    map[lists[i]] = documentData.data();
  }
  // 유저 닉네임까지 붙여줌
  List joinedUsername = await getUsername(docId); //uid: username
  map.values.forEach((element) {
    element?.addAll({"joinedUsername": joinedUsername});
  });
  print(map);
  return map;
}

//uid로 닉네임 불러오기
Future<String> getUsernamebyUid(String uid) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("UserInformation")
      .where(
        'uid',
        isEqualTo: uid,
      )
      .get();

  return snapshot.docs.elementAt(0)["username"];
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 29, 30, 37),
          body: Column(
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
                    const Text(
                      "Participants",
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

              Expanded(
                child: FutureBuilder(
                  future: getDocument(args['docId']),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.hasData == false) {
                      return Text("Loading...");
                    } else {
                      List joinedUsername = snapshot.data.values.elementAt(0)['joinedUsername'];
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(30, 0, 0, 0),
                                child: Icon(
                                  Icons.people_outline_rounded,
                                  color: Colors.white,
                                  size: 35,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                                width: 45,
                                child: Text(
                                  joinedUsername.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),
                              Container(
                                child: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ]),
                            SizedBox(height: 10),
                            for (int i = 0; i < joinedUsername.length; i++) participant(joinedUsername[i])
                          ],
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
    );
  }

  Widget participant(String participant) {
    return Container(
        width: 230,
        height: 60,
        margin: EdgeInsets.fromLTRB(30, 5, 0, 0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 40,
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Text(
                participant,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Montserrat',
                ),
              ),
            )
          ],
        ));
  }
}
