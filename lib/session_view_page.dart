import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ask_it/main.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart' as intl;

import 'main.dart';

bool liveJoined = false;

class SessionViewPage extends StatefulWidget {
  SessionViewPage({Key? key}) : super(key: key);

  @override
  State<SessionViewPage> createState() => _SessionViewPageState();
}

//내 채팅 입력
void writeChatting(String docId, String texts) async {
  await FirebaseFirestore.instance
      .collection('DiscussPage_Sessions')
      .doc(docId)
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

//
Future<List> getDocumnetList(String docId) async {
  List<String> lists = [];

  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(docId).get();

  lists.add(snapshot.id);

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

//채팅방 uid 닉네임 맵 매치
Future<Map> getChatroomUidUsername(String docId) async {
  Map maps = {};
  //질문 올린 사람 uid 닉네임 매치
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(docId).get();
  List joinedList = snapshot.get('chatroom_joined');

  for (var element in joinedList) {
    maps[element] = await getUsernamebyUid(element.toString());
  }

  return maps;
}

// 채팅 스트림
Stream chattingStream(String docId) async* {
  Stream<QuerySnapshot> snapshot = FirebaseFirestore.instance
      .collection("DiscussPage_Sessions")
      .doc(docId)
      .collection("Messages")
      .orderBy('date', descending: false)
      .snapshots();
  // snapshot.docs.forEach((element) {
  //   lists.add(element.id);
  // });
  yield* snapshot;
}

// Map<글 코드, 글 데이터맵>
Future<Map> getDocument(String docId) async {
  List lists = await getDocumnetList(docId); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(lists[i]).get();
    map[lists[i]] = documentData.data();
  }

  return map;
}

// chatroom joined에 내 uid 없으면 넣기 (joined와는 상관없이 첫 채팅을 칠 시 작동)
Future editChatroomJoinedListArray(String docId) async {
//user uid 얻기
  String uid = FirebaseAuth.instance.currentUser!.uid;

  //이 세션의 chatroom joined 리스트 얻기
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(docId).get();

  List joinedList = snapshot.get('chatroom_joined');
  bool joined = joinedList.contains(FirebaseAuth.instance.currentUser?.uid);

  //내 이름이 리스트에 없을 때만 넣기
  if (!joined) {
    await FirebaseFirestore.instance
        .collection('DiscussPage_Sessions')
        .doc(docId)
        .update({
          'chatroom_joined': FieldValue.arrayUnion([uid]),
        })
        .then((value) => print("add in joined list"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}

// joined에 내 uid 넣거나 빼기
Future editJoinedArray(String docId) async {
  //user uid 얻기
  String uid = FirebaseAuth.instance.currentUser!.uid;

  //이 세션의 joined 리스트 얻기
  DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(docId).get();

  List joinedList = snapshot.get('joined');
  bool joined = joinedList.contains(FirebaseAuth.instance.currentUser?.uid);

  if (joined) {
    //참가했으면 리스트에서 빼기
    await FirebaseFirestore.instance
        .collection('DiscussPage_Sessions')
        .doc(docId)
        .update({
          'joined': FieldValue.arrayRemove([uid]),
        })
        .then((value) => print("remove in joined list"))
        .catchError((error) => print("Failed to add user: $error"));
  } else {
    //참가 안했으면 리스트에 넣기
    await FirebaseFirestore.instance
        .collection('DiscussPage_Sessions')
        .doc(docId)
        .update({
          'joined': FieldValue.arrayUnion([uid]),
        })
        .then((value) => print("add in joined list"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}

// liked에 내 uid 넣거나 빼기
Future editLikedArray(String docId) async {
  //user uid 얻기
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("UserInformation")
      .where(
        'uid',
        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
      )
      .get();
  String uid = snapshot.docs.first.get("uid");

  //이 세션의 liked 리스트 얻기
  DocumentSnapshot snapshot2 = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(docId).get();

  List likedList = snapshot2.get('liked');
  bool liked = likedList.contains(FirebaseAuth.instance.currentUser?.uid);

  if (liked) {
    //이미 좋아요 눌렀으면 리스트에서 빼기
    await FirebaseFirestore.instance
        .collection('DiscussPage_Sessions')
        .doc(docId)
        .update({
          'liked': FieldValue.arrayRemove([uid]),
        })
        .then((value) => print("remove in liked list"))
        .catchError((error) => print("Failed to add user: $error"));
  } else {
    //좋아요 안 눌렀으면 리스트에 넣기
    await FirebaseFirestore.instance
        .collection('DiscussPage_Sessions')
        .doc(docId)
        .update({
          'liked': FieldValue.arrayUnion([uid]),
        })
        .then((value) => print("add in liked list"))
        .catchError((error) => print("Failed to add user: $error"));
  }
}

class _SessionViewPageState extends State<SessionViewPage> {
  //변수들
  int pageSelected = 1;
  FocusNode textFocus = FocusNode();
  @override
  // void initState() {
  //   super.initState();

  //   Future.delayed(const Duration(milliseconds: 500), () {
  //     print(widget._TextBoxKey.currentContext);
  //     final RenderBox renderBox1 =
  //         widget._TextBoxKey.currentContext!.findRenderObject() as RenderBox;
  //     final position1 = renderBox1.localToGlobal(Offset.zero);

  //     final RenderBox renderBox2 =
  //         widget._ProfileBoxKey.currentContext!.findRenderObject() as RenderBox;
  //     final position2 = renderBox2.localToGlobal(Offset.zero);

  //     navigatorKey.currentState?.setState(() {
  //       textBoxHeight = position2.dy - position1.dy;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final textController = TextEditingController();
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: args["title"],
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Montserrat',
        ),
      ),
    )..layout(
        maxWidth: MediaQuery.of(context).size.width - 44,
      );
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 29, 30, 37),
          body: SafeArea(
            //앱 전체 감싸는 div
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
                          liveJoined = false;
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
                          Navigator.pushNamed(context, '/scratch_pad', arguments: {
                            "docId": args["docId"],
                          });
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
                          Navigator.pushNamed(context, '/participants_page', arguments: {'docId': args['docId']});
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
                Expanded(
                  child: FutureBuilder(
                      future: getDocument(args['docId']),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData == false) {
                          return Text("Loading...");
                        } else {
                          return Column(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //묶음 - 프로필 박스, 기간, 종료일(community 눌렀을 때 사라짐)
                                    AnimatedContainer(
                                      duration: Duration(milliseconds: 250),
                                      curve: Curves.easeInOut,
                                      child: pageSelected == 1
                                          ? SingleChildScrollView(
                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                //제목 박스
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(24, 0, 20, 0),
                                                  child: Text(
                                                    snapshot.data.values.elementAt(0)?['title'],
                                                    style: const TextStyle(
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
                                                            border: Border.all(color: Colors.white, width: 1.5)),
                                                        child:
                                                            Icon(Icons.person_outline, color: Colors.white, size: 40),
                                                      ),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          //작성자 이름+버튼
                                                          Row(
                                                            children: [
                                                              Container(
                                                                padding: EdgeInsets.fromLTRB(20, 2, 0, 0),
                                                                child: Text(
                                                                  snapshot.data.values.elementAt(0)?['author'],
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 16,
                                                                    fontFamily: 'Montserrat',
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 15),
                                                              SizedBox(
                                                                height: 16.0,
                                                                width: 16.0,
                                                                child: IconButton(
                                                                    splashRadius: 20,
                                                                    padding: EdgeInsets.fromLTRB(0, 2, 0, 0),
                                                                    iconSize: 16,
                                                                    onPressed: () {},
                                                                    icon: Icon(Icons.arrow_forward_ios,
                                                                        color: Colors.white)),
                                                              ),
                                                            ],
                                                          ),
                                                          Spacer(),
                                                          //level 등급. 임시로 egg level로 고정
                                                          Container(
                                                            padding: EdgeInsets.fromLTRB(20, 0, 0, 4),
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

                                                //기간 텍스트
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(24, 0, 0, 0),
                                                  child: Text(
                                                    intl.DateFormat('yyyy.MM.dd').format(
                                                            snapshot.data.values.elementAt(0)?['date'].toDate()) +
                                                        " ~ " +
                                                        intl.DateFormat('yyyy.MM.dd').format(
                                                            snapshot.data.values.elementAt(0)?['due_date'].toDate()),
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
                                                    "ended after " +
                                                        snapshot.data.values
                                                            .elementAt(0)['due_date']
                                                            .toDate()
                                                            .difference(DateTime.now())
                                                            .inDays
                                                            .toString() +
                                                        " days",
                                                    style: TextStyle(
                                                      color: Color.fromARGB(255, 255, 255, 255),
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 25),
                                              ]),
                                            )
                                          : null,
                                      height: pageSelected == 1 ? 200 + textPainter.size.height - 29 : 0,
                                    ),
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
                                          Container(
                                            child: Column(
                                              children: [
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    splashFactory: NoSplash.splashFactory,
                                                    primary: pageSelected == 1
                                                        ? Colors.white
                                                        : Color.fromARGB(100, 255, 255, 255),
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
                                                        : const Color.fromARGB(0, 255, 255, 255),
                                                    borderRadius: const BorderRadius.all(Radius.circular(100)),
                                                  ),
                                                  margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                                                  padding: const EdgeInsets.all(0),
                                                  width: 40,
                                                  height: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(
                                            flex: 2,
                                          ),
                                          //Community 버튼
                                          Column(
                                            children: [
                                              TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, //???
                                                  splashFactory: NoSplash.splashFactory,
                                                  primary: pageSelected == 2
                                                      ? Colors.white
                                                      : Color.fromARGB(100, 255, 255, 255),
                                                  textStyle: const TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: 'Montserrat',
                                                  ),
                                                ),
                                                onPressed: () {
                                                  FocusScope.of(context).unfocus();
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
                                                      : const Color.fromARGB(0, 255, 255, 255),
                                                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                                                ),
                                                margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
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
                                                  padding: EdgeInsets.fromLTRB(0, 15, 0, 0),
                                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap, //???
                                                  splashFactory: NoSplash.splashFactory,
                                                  primary: pageSelected == 3
                                                      ? Colors.white
                                                      : Color.fromARGB(100, 255, 255, 255),
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
                                                      : const Color.fromARGB(0, 255, 255, 255),
                                                  borderRadius: const BorderRadius.all(Radius.circular(100)),
                                                ),
                                                margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
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
                                    // 선택바 아래
                                    SizedBox(height: 15),
                                    if (pageSelected == 1)
                                      // Contents 화면
                                      Expanded(
                                        child: Container(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.fromLTRB(24, 0, 20, 0),
                                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                                  child: Text(
                                                    snapshot.data.values.elementAt(0)?['texts'].replaceAll("\\n", "\n"),
                                                    style: TextStyle(
                                                      height: 1.8,
                                                      color: Color.fromARGB(255, 255, 255, 255),
                                                      fontSize: 15,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (pageSelected == 2)
                                      //Community 화면
                                      Expanded(
                                        child: Container(
                                          child: SingleChildScrollView(
                                            reverse: true,
                                            child: Column(
                                              children: [
                                                StreamBuilder(
                                                    stream: chattingStream(args["docId"]),
                                                    builder: (context, AsyncSnapshot streamSnapshot) {
                                                      if (streamSnapshot.connectionState == ConnectionState.waiting) {
                                                        return Container(
                                                          height: 100,
                                                          alignment: Alignment.center,
                                                          child: const Text(
                                                            "Loading...",
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontFamily: "Montserrat",
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        List snapshotList = streamSnapshot.data.docs;
                                                        return FutureBuilder<Object>(
                                                            future: getChatroomUidUsername(args["docId"]),
                                                            builder: (context, AsyncSnapshot futureSnapshot) {
                                                              if (futureSnapshot.hasData == false) {
                                                                return Container(
                                                                  height: 100,
                                                                  alignment: Alignment.center,
                                                                  child: const Text(
                                                                    "Loading...",
                                                                    style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontFamily: "Montserrat",
                                                                    ),
                                                                  ),
                                                                );
                                                              } else {
                                                                Map futureSnapshotMap = futureSnapshot.data;
                                                                return Column(
                                                                  children: [
                                                                    for (int i = 0; i < snapshotList.length; i++)
                                                                      message(
                                                                          futureSnapshotMap[snapshotList[i]
                                                                              ["sender_uid"]],
                                                                          snapshotList[i]["texts"])
                                                                  ],
                                                                );
                                                              }
                                                            });
                                                      }
                                                    }),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),

                                    if (pageSelected == 3)
                                      //Live 화면
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          //사람 아이콘
                                                          personIcon("JeEon Park"),
                                                          SizedBox(width: 40),
                                                          //사람 아이콘
                                                          personIcon("Nan Park"),
                                                          SizedBox(width: 40),
                                                          //사람 아이콘
                                                          personIcon("Tom"),
                                                        ],
                                                      ),
                                                      SizedBox(height: 15),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          //사람 아이콘
                                                          personIcon("Harry"),
                                                          SizedBox(width: 40),
                                                          //사람 아이콘
                                                          personIcon("Hermione"),
                                                          SizedBox(width: 40),
                                                          //사람 아이콘
                                                          personIcon("Ronald"),
                                                        ],
                                                      ),
                                                      SizedBox(height: 15),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          //사람 아이콘
                                                          personIcon("Severus"),
                                                          SizedBox(width: 40),
                                                          //사람 아이콘
                                                          personIcon("Albus"),
                                                          SizedBox(width: 40),
                                                          //사람 아이콘
                                                          personIcon("Cedric"),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                alignment: Alignment.center,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.people_outline_outlined, color: Colors.white),
                                                        Text(
                                                          "16",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 25),
                                                    if (liveJoined)
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              Container(
                                                                width: 60,
                                                                height: 60,
                                                                decoration: BoxDecoration(
                                                                  border: Border.all(
                                                                    color: Colors.white,
                                                                  ),
                                                                  borderRadius: BorderRadius.circular(100),
                                                                ),
                                                                child: Icon(
                                                                  Icons.mic_off_outlined,
                                                                  color: Colors.white,
                                                                  size: 38,
                                                                ),
                                                              ),
                                                              SizedBox(height: 7),
                                                              Text(
                                                                "mute",
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.white,
                                                                  fontFamily: "Montserrat",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 45),
                                                          Column(
                                                            children: [
                                                              GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    liveJoined = false;
                                                                  });
                                                                },
                                                                child: Container(
                                                                  width: 60,
                                                                  height: 60,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.red,
                                                                    border: Border.all(
                                                                      color: Colors.red,
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(100),
                                                                  ),
                                                                  child: Icon(
                                                                    Icons.call_end_outlined,
                                                                    color: Colors.white,
                                                                    size: 38,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(height: 7),
                                                              Text(
                                                                "leave",
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors.white,
                                                                  fontFamily: "Montserrat",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )
                                                    else
                                                      Column(
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                liveJoined = true;
                                                              });
                                                            },
                                                            child: Container(
                                                              alignment: Alignment.center,
                                                              width: 160,
                                                              height: 50,
                                                              decoration: BoxDecoration(
                                                                color: Color.fromARGB(255, 63, 178, 109),
                                                                borderRadius: BorderRadius.circular(100),
                                                              ),
                                                              child: Text(
                                                                "Join Live",
                                                                style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors.white,
                                                                  fontFamily: "Montserrat",
                                                                ),
                                                              ),
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
                              //하단바
                              Container(
                                color: Color.fromARGB(255, 29, 30, 37),
                                height: 60,
                                child: Column(
                                  children: [
                                    //가로줄 Container
                                    Container(height: 1, width: MediaQuery.of(context).size.width, color: Colors.white),
                                    Expanded(
                                      child: pageSelected == 2 &&
                                              snapshot.data.values
                                                  .elementAt(0)['joined']
                                                  .contains(FirebaseAuth.instance.currentUser?.uid)
                                          ? Container(
                                              height: 60,
                                              //하단바
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
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
                                                  //메시지 입력창
                                                  Spacer(),
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width * 0.7,
                                                    child: TextFormField(
                                                      controller: textController,
                                                      focusNode: textFocus,
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
                                                        hintText: "Message...",
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
                                                          if (textController.text.isNotEmpty) {
                                                            writeChatting(args['docId'], textController.text);
                                                            textController.clear();
                                                          }
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
                                              ),
                                            )
                                          : Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Spacer(),
                                                //하트
                                                SizedBox(
                                                  height: 35,
                                                  child: IconButton(
                                                    splashRadius: 10,
                                                    iconSize: 35,
                                                    padding: EdgeInsets.all(0),
                                                    onPressed: () async {
                                                      await editLikedArray(args['docId']);
                                                      setState(() {});
                                                    },
                                                    icon: Icon(
                                                      (!snapshot.data.values
                                                              .elementAt(0)['liked']
                                                              .contains(FirebaseAuth.instance.currentUser?.uid))
                                                          ? Icons.favorite_border
                                                          : Icons.favorite,
                                                      color: (snapshot.data.values
                                                              .elementAt(0)['liked']
                                                              .contains(FirebaseAuth.instance.currentUser?.uid))
                                                          ? Color.fromARGB(255, 206, 55, 55)
                                                          : Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                //좋아요 수
                                                Container(
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                  width: 40,
                                                  child: Text(
                                                    (snapshot.data.values.elementAt(0)['liked'].length.toString()),
                                                    style: TextStyle(
                                                      color: Color.fromARGB(255, 255, 255, 255),
                                                      fontSize: 18,
                                                      fontFamily: 'Montserrat',
                                                    ),
                                                  ),
                                                ),
                                                //Join this session 버튼(join 누르면 joined 리스트에 내가 추가됨. join 안했으면 반대)
                                                Container(
                                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                  height: 40,
                                                  width: 280,
                                                  child: ElevatedButton.icon(
                                                    onPressed: () async {
                                                      if (snapshot.data.values.elementAt(0)['uid'] !=
                                                          FirebaseAuth.instance.currentUser?.uid) {
                                                        await editJoinedArray(args['docId']);
                                                        await editChatroomJoinedListArray(args['docId']);
                                                        setState(() {});
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      primary: (snapshot.data.values.elementAt(0)['uid'] !=
                                                              FirebaseAuth.instance.currentUser?.uid)
                                                          ? Colors.white
                                                          : Color.fromARGB(255, 108, 103, 103),
                                                    ),
                                                    icon: Icon(
                                                      Icons.question_answer,
                                                      color: (snapshot.data.values.elementAt(0)['uid'] !=
                                                              FirebaseAuth.instance.currentUser?.uid)
                                                          ? Colors.black
                                                          : Color.fromARGB(127, 255, 255, 255),
                                                    ),
                                                    label: (!snapshot.data.values
                                                            .elementAt(0)['joined']
                                                            .contains(FirebaseAuth.instance.currentUser?.uid))
                                                        ? Text(
                                                            "Join this Session",
                                                            style: TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 18,
                                                              fontFamily: 'Montserrat',
                                                            ),
                                                          )
                                                        : Text(
                                                            "Leave this Session",
                                                            style: TextStyle(
                                                              color: (snapshot.data.values.elementAt(0)['uid'] !=
                                                                      FirebaseAuth.instance.currentUser?.uid)
                                                                  ? Colors.black
                                                                  : Color.fromARGB(127, 255, 255, 255),
                                                              fontSize: 18,
                                                              fontFamily: 'Montserrat',
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                                Spacer(),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget message(String username, String texts) {
  return //대화 내용
      Container(
    width: MediaQuery.of(navigatorKey.currentState?.context as BuildContext).size.width,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 20),
        //프로필 사진
        Column(
          children: [
            SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5)),
              child: Icon(Icons.person_outline, color: Colors.white, size: 34),
            ),
          ],
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  username,
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "22/03/27 at 15:33",
                  style: TextStyle(
                    fontFamily: "Montserrat",
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Color.fromARGB(100, 255, 255, 255),
                  ),
                ),
              ],
            ),
            Container(
              width: MediaQuery.of(navigatorKey.currentState?.context as BuildContext).size.width - 85,
              child: RichText(
                text: TextSpan(
                  text: texts,
                  style: TextStyle(fontFamily: "Montserrat", fontSize: 15, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ],
    ),
  );
}

Widget personIcon(String name) {
  return Column(
    children: [
      Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Icon(
          Icons.person_outline_outlined,
          color: Colors.black,
          size: 38,
        ),
      ),
      SizedBox(height: 7),
      Text(
        name,
        style: TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontFamily: "Montserrat",
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
