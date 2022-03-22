import 'package:ask_it/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MessagePage extends StatefulWidget {
  MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

//채팅방 Id 불러오기
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

Future<List> getDocumentList(String questionDocId) async {
  List<String> lists = [];
  String chatRoomId = await getChatRoomId(questionDocId);
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("AskPage_Questions")
      .doc(questionDocId)
      .collection("ChatRoom")
      .doc(chatRoomId)
      .collection("Messages")
      .orderBy('date', descending: false)
      .get();
  snapshot.docs.forEach((element) {
    lists.add(element.id);
  });

  return lists;
}

// Map<글 코드, 글 데이터맵>
Future<Map> getDocument(String questionDocId) async {
  String chatRoomId = await getChatRoomId(questionDocId);
  List lists = await getDocumentList(questionDocId); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance
        .collection("AskPage_Questions")
        .doc(questionDocId)
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("Messages")
        .doc(lists[i])
        .get();
    map[lists[i]] = documentData.data();
  }

  return map;
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 29, 30, 37),
          body: Column(
            children: [
              //상단바 영역-----------------------------------------------
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
              //메시지 영역-----------------------------------------------
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    reverse: true,
                    child: FutureBuilder(
                        future: getDocument(args["docId"]),
                        builder:
                            (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData == false) {
                            //데이터 받아오는중
                            return Text("loading");
                          } else {
                            print(snapshot.data);
                            return Column(
                              children: [],
                            );
                          }
                        }),
                  ),
                ),
              ),
              //하단바 영역-----------------------------------------------
              Container(
                height: 60,
                //구분선
                decoration: BoxDecoration(
                  color: Colors.red,
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                //하단바
                child: Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 25,
                      iconSize: 30,
                      onPressed: () {},
                      icon: Icon(
                        Icons.photo_camera_outlined,
                        color: Colors.white,
                      ),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          "Post",
                          style: const TextStyle(
                            fontFamily: "Montserrat",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          splashRadius: 25,
                          iconSize: 30,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.check_outlined,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 5,
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

Widget MessageFromMe() {
  return Container(
    alignment: Alignment.centerRight,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              child: Text(
                "JeEon Park",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
            SizedBox(width: 28)
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            LimitedBox(
              maxWidth: MediaQuery.of(
                          navigatorKey.currentState?.context as BuildContext)
                      .size
                      .width *
                  0.8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 72, 63, 178),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                  child: Text(
                    "Can you tell me more specific?",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Montserrat",
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 20)
          ],
        ),
        SizedBox(height: 9)
      ],
    ),
  );
}

Widget MessageFromOthers() {
  return Container(
    alignment: Alignment.centerRight,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(width: 28),
        SizedBox(height: 9),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 28),
            SizedBox(
              child: Text(
                "Nan Park",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 20),
            LimitedBox(
              maxWidth: MediaQuery.of(
                          navigatorKey.currentState?.context as BuildContext)
                      .size
                      .width *
                  0.8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                  child: Text(
                    "Can you tell me more specific?",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Montserrat",
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 9)
      ],
    ),
  );
}
