import 'package:ask_it/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OthersMessagePage extends StatefulWidget {
  OthersMessagePage({Key? key}) : super(key: key);

  @override
  State<OthersMessagePage> createState() => _OthersMessagePageState();
  FocusNode textFocus = FocusNode();
}

//내 채팅 입력
void writeChatting(String questionDocId, String texts, String chatRoomId) async {
  await FirebaseFirestore.instance
      .collection('AskPage_Questions')
      .doc(questionDocId)
      .collection('ChatRoom')
      .doc(chatRoomId)
      .collection('Messages')
      .doc()
      .set({
        'texts': texts,
        'date': Timestamp.now(),
        'sender_uid': FirebaseAuth.instance.currentUser?.uid,
      })
      .then((value) => print("Sent"))
      .catchError((error) => print("Failed to add user: $error"));
}

// 채팅 스트림
Stream chattingStream(String questionDocId, String chatRoomId) async* {
  Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance
      .collection("AskPage_Questions")
      .doc(questionDocId)
      .collection("ChatRoom")
      .doc(chatRoomId)
      .collection("Messages")
      //.orderBy('date', descending: false)
      .snapshots();
  // snapshot.docs.forEach((element) {
  //   lists.add(element.id);
  // });
  yield* snapshot;
}

// 메시지 도큐멘트 전부 리스트화
Future<List> getDocumentList(String questionDocId, String chatRoomId) async {
  List<String> lists = [];
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

// 메시지 도큐멘트 전부 맵으로 만들기
// Map<채팅 글 코드, 글 데이터맵>
Future<Map> getDocument(String questionDocId, String chatRoomId) async {
  List lists = await getDocumentList(questionDocId, chatRoomId); //
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

  // 유저 닉네임까지 붙여줌
  Map uidUsername = await getChatroomUidUsername(questionDocId, chatRoomId);
  map.values.forEach((element) {
    element?.addAll({"username": uidUsername[element["sender_uid"]]});
  });

  return map;
}

//채팅방 uid 닉네임 맵 매치
Future<Map> getChatroomUidUsername(String questionDocId, String chatRoomId) async {
  Map lists = {};
  //질문 올린 사람 uid 닉네임 매치
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("AskPage_Questions").doc(questionDocId).get();

  String uid1 = snapshot.get("uid");
  String username1 = await getUsernamebyUid(uid1);
  lists[uid1] = username1;

  //답변 하는 사람 uid 닉네임 매치
  snapshot = await FirebaseFirestore.instance
      .collection("AskPage_Questions")
      .doc(questionDocId)
      .collection("ChatRoom")
      .doc(chatRoomId)
      .get();
  String uid2 = snapshot.get("replier");
  String username2 = await getUsernamebyUid(uid2);
  lists[uid2] = username2;

  return lists;
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

class _OthersMessagePageState extends State<OthersMessagePage> {
  final textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    return SafeArea(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 29, 30, 37),
          body: Column(
            // 상단바 영역
            children: [
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
                  child: StreamBuilder(
                      stream: chattingStream(args["docId"], args["chatRoomUid"]),
                      builder: (BuildContext context, AsyncSnapshot streamsnapshot) {
                        if (streamsnapshot.connectionState == ConnectionState.waiting) {
                          //데이터 받아오는중
                          return Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Loading...",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Montserrat",
                              ),
                            ),
                          );
                        } else {
                          // Map snapshotMap = snapshot.data as Map;
                          return FutureBuilder(
                              future: getDocument(args['docId'], args['chatRoomUid']),
                              builder: (BuildContext context, AsyncSnapshot snapshot) {
                                if (snapshot.hasData == false) {
                                  return Container(
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Loading...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Montserrat",
                                      ),
                                    ),
                                  );
                                } else {
                                  Map snapshotMap = snapshot.data;
                                  return SingleChildScrollView(
                                    reverse: true,
                                    child: Column(
                                      children: [
                                        for (int i = 0; i < snapshotMap.length; i++)
                                          // 내가 보낸 채팅일 경우
                                          if (snapshotMap.values.elementAt(i)["sender_uid"] ==
                                              FirebaseAuth.instance.currentUser?.uid)
                                            MessageFromRight(
                                                snapshotMap.values.elementAt(i)["texts"],
                                                snapshotMap.values.elementAt(i)["date"].toDate(),
                                                snapshotMap.values.elementAt(i)["username"])
                                          // 상대가 보낸 채팅일 경우
                                          else
                                            MessageFromLeft(
                                                snapshotMap.values.elementAt(i)["texts"],
                                                snapshotMap.values.elementAt(i)["date"].toDate(),
                                                snapshotMap.values.elementAt(i)["username"])
                                      ],
                                    ),
                                  );
                                }
                              });
                        }
                      }),
                ),
              ),
              //하단바 영역-----------------------------------------------
              Container(
                height: 60,
                //구분선
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white, width: 1),
                  ),
                ),
                //하단바
                child: args["uid"] == FirebaseAuth.instance.currentUser?.uid
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (args["uid"] == FirebaseAuth.instance.currentUser?.uid)
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
                          //메시지 입력창
                          Spacer(),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: TextFormField(
                              controller: textController,
                              focusNode: widget.textFocus,
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                fillColor: Colors.white,
                                filled: true,
                                hintText: "Search",
                                hintStyle: const TextStyle(
                                  color: Color.fromARGB(255, 125, 125, 125),
                                  fontFamily: 'Montserrat',
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Row(
                            children: [
                              IconButton(
                                padding: EdgeInsets.zero,
                                splashRadius: 25,
                                iconSize: 30,
                                onPressed: () {
                                  writeChatting(args['docId'], textController.text, args['chatRoomUid']);
                                  textController.clear();
                                },
                                icon: Icon(
                                  Icons.send_outlined,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Read Only",
                            style: TextStyle(
                              fontFamily: "Montserrat",
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
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

Widget MessageFromRight(String texts, DateTime date, String sender) {
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
                sender,
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
              maxWidth: MediaQuery.of(navigatorKey.currentState?.context as BuildContext).size.width * 0.8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 72, 63, 178),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                  child: Text(
                    texts,
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

Widget MessageFromLeft(String texts, DateTime date, String sender) {
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
                sender,
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
              maxWidth: MediaQuery.of(navigatorKey.currentState?.context as BuildContext).size.width * 0.8,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(17, 10, 17, 10),
                  child: Text(
                    texts,
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
