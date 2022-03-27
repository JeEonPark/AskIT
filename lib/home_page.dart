import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'main.dart';
import 'package:ask_it/main.dart';

//안녕하세요
//박무바보
//바보바보
//전역변수
//#region 변수

int askPageSelected = 1;
int discussPageSelected = 1;
int _currentIndex = 0;
//#endregion

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

//#region 함수

// void readdata() async {
//   List<String> lists = [];
//   QuerySnapshot snapshot = await await FirebaseFirestore.instance
//       .collection("AskPage_Questions")
//       .get();
//   List<dynamic> result = snapshot.docs.map((doc) => doc.data()).toList();
//   print("aaaaa" + result.toString());
//   print(result[0]["texts"]);

//   // final usercol = await FirebaseFirestore.instance
//   //     .collection("AskPage_Questions")
//   //     .doc("9qK7py72Pd3CdfvrQBxe");
//   // usercol.get().then((value) => {print(value.data())});
// }

Future<List> askGetDocumnetList() async {
  List<String> lists = [];
  if (askPageSelected == 1) {
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
  } else if (askPageSelected == 2) {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("AskPage_Questions").orderBy('date', descending: true).get();
    snapshot.docs.forEach((element) {
      lists.add(element.id);
    });
  }

  return lists;
}

// Map<글 코드, 글 데이터맵>
Future<Map> askGetDocument() async {
  List lists = await askGetDocumnetList(); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance.collection("AskPage_Questions").doc(lists[i]).get();
    map[lists[i]] = documentData.data();
  }
  // print(DateFormat('yyyy.MM.dd')
  //     .format(map.values.elementAt(0)?['date'].toDate()));
  if (askPageSelected == 2) {
    for (int i = 0; i < map.length; i++) {
      if (map.values.elementAt(i)?['uid'] == FirebaseAuth.instance.currentUser?.uid) {
        map.remove(map.keys.elementAt(i));
        i--;
      }
    }
  }

  return map;
}

Future<List> discussGetDocumnetList() async {
  List<String> lists = [];
  if (discussPageSelected == 1) {
    //Explore 페이지
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("DiscussPage_Sessions").orderBy('date', descending: true).get();
    snapshot.docs.forEach((element) {
      lists.add(element.id);
    });

    snapshot.docs.forEach((element) {
      //due_date를 지났으면 제외
      DateTime due_date = element.get('due_date').toDate();
      if (due_date.isBefore(DateTime.now())) {
        lists.remove(element.id);
      }
    });
  } else if (discussPageSelected == 2) {
    //Joined 페이지
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("DiscussPage_Sessions")
        .orderBy('date', descending: true)
        .where('joined', arrayContains: FirebaseAuth.instance.currentUser?.uid)
        .get();
    snapshot.docs.forEach((element) {
      lists.add(element.id);
    });
  } else if (discussPageSelected == 3) {
    //Ended 페이지
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("DiscussPage_Sessions").orderBy('date', descending: true).get();

    snapshot.docs.forEach((element) {
      lists.add(element.id);
    });

    snapshot.docs.forEach((element) {
      //due_date를 지나지 않았으면(세션 진행중이면) 제외
      DateTime due_date = element.get('due_date').toDate();
      if (due_date.isAfter(DateTime.now())) {
        lists.remove(element.id);
      }
    });
  }

  return lists;
}

// Map<글 코드, 글 데이터맵>
Future<Map> discussGetDocument() async {
  List lists = await discussGetDocumnetList(); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance.collection("DiscussPage_Sessions").doc(lists[i]).get();
    map[lists[i]] = documentData.data();
  }
  //if (askPageSelected == 2) {
  //  for (int i = 0; i < map.length; i++) {
  //    if (map.values.elementAt(i)?['uid'] ==
  //        FirebaseAuth.instance.currentUser?.uid) {
  //      map.remove(map.keys.elementAt(i));
  //      i--;
  //    }
  //  }
  //}

  return map;
}

//#endregion

//#region 메인 homePage Class

class _HomePageState extends State<HomePage> {
  //변수들
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final List<Widget> _children = [Ask(), Discuss(), Other()];
  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    BuildContext contextGlobal = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 37), //뒷 배경 색상
        body: _children[_currentIndex],
        //바텀 네비게이션바
        bottomNavigationBar: Container(
          height: 60,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20),
              topLeft: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: BottomNavigationBar(
              backgroundColor: Color.fromARGB(255, 72, 63, 178),
              selectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontFamily: 'Montserrat',
              ),
              selectedItemColor: Colors.white,
              unselectedItemColor: Color.fromARGB(100, 255, 255, 255),
              onTap: _onTap,
              currentIndex: _currentIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.question_answer_outlined),
                  label: ('Ask'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: ('Discuss'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.more_horiz_rounded),
                  label: ('Others'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//#endregion

//#region first, second 함수

Widget first(String docId, String title, String texts, String author, DateTime date, String uid, List joined) {
  return GestureDetector(
    onTap: () async {
      await gotoQuestionViewPage(docId, title, texts, author, date, uid, joined);
      navigatorKey.currentState?.setState(() {});
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
      navigatorKey.currentState?.setState(() {});
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

//#endregion

//#region gotoQuestionViewPage 함수
Future gotoQuestionViewPage(String docId, String title, String texts, String author, DateTime date, String uid, List joined) async {
  if (_currentIndex == 0) {
    await navigatorKey.currentState?.pushNamed(
      '/question_view_page',
      arguments: {
        "docId": docId,
        "title": title,
        "texts": texts,
        "author": author,
        "date": DateFormat('yyyy.MM.dd hh:mm').format(date),
        "uid": uid,
      },
    );
  } else if (_currentIndex == 1) {
    await navigatorKey.currentState?.pushNamed('/session_view_page', arguments: {
      "docId": docId,
      "title": title,
      "texts": texts,
      "author": author,
      "date": DateFormat('yyyy.MM.dd hh:mm').format(date),
      "uid": uid,
      "joined": joined,
    });
  } else if (_currentIndex == 2) {
    await navigatorKey.currentState?.pushNamed(
      '/question_view_page',
      arguments: {
        "docId": docId,
        "title": title,
        "texts": texts,
        "author": author,
        "date": DateFormat('yyyy.MM.dd hh:mm').format(date),
        "uid": uid,
      },
    );
  }
}

//#endregion

//#region Ask 페이지

class Ask extends StatefulWidget {
  @override
  State<Ask> createState() => _AskState();
}

class _AskState extends State<Ask> {
  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 30, 37),
      body: SafeArea(
        //앱 전체 감싸는 div
        child: Container(
          child: Column(
            children: [
              //상단 바 div
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Text(
                        "Ask",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Container(
                        child: Row(
                          children: [
                            //검색버튼
                            IconButton(
                              onPressed: () {
                                navigatorKey.currentState?.pushNamed('/search_page');
                              },
                              iconSize: 35,
                              icon: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                            ),
                            //설정버튼
                            IconButton(
                              onPressed: () {},
                              iconSize: 35,
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //질문 선택 버튼 바
              Container(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(
                      flex: 1,
                    ),
                    //My Question 버튼
                    Column(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            splashFactory: NoSplash.splashFactory,
                            primary: askPageSelected == 1 ? Colors.white : Color.fromARGB(100, 255, 255, 255),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              askPageSelected = 1;
                              loading = true;
                            });
                          },
                          child: const Text("My Question"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: askPageSelected == 1 ? Colors.white : const Color.fromARGB(0, 255, 255, 255),
                            borderRadius: const BorderRadius.all(Radius.circular(100)),
                          ),
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.all(0),
                          width: 75,
                          height: 2,
                        ),
                      ],
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                    //Others Question 버튼
                    Column(
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.all(0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap, //???
                            splashFactory: NoSplash.splashFactory,
                            primary: askPageSelected == 2 ? Colors.white : Color.fromARGB(100, 255, 255, 255),
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              askPageSelected = 2;
                              loading = true;
                            });
                          },
                          child: const Text("Others Question"),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: askPageSelected == 2 ? Colors.white : const Color.fromARGB(0, 255, 255, 255),
                            borderRadius: const BorderRadius.all(Radius.circular(100)),
                          ),
                          margin: const EdgeInsets.all(0),
                          padding: const EdgeInsets.all(0),
                          width: 75,
                          height: 2,
                        ),
                      ],
                    ),
                    const Spacer(
                      flex: 1,
                    ),
                  ],
                ),
              ),
              //회색 스크롤 배경
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: 0.97,
                  widthFactor: 0.95,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(25, 255, 255, 255),
                      ),
                      child: FutureBuilder(
                        future: askGetDocument(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData == false || loading == true) {
                            //데이터 받아오는중
                            loading = false;
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Loading...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Montserrat",
                                  fontSize: 16,
                                ),
                              ),
                            );
                          } else {
                            //데이터 다 받아옴
                            loading = false;
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  askGetDocument();
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
                                                  snapshot.data.values.elementAt(i)?['texts'].replaceAll("\\n", " "),
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
                                                  snapshot.data.values.elementAt(i)?['texts'].replaceAll("\\n", " "),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add your onPressed code here!
          await navigatorKey.currentState?.pushNamed('/add_question_page');
          setState(() {});
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add_outlined,
          color: Colors.black,
          size: 35,
        ),
      ),
    );
  }
}

//#endregion

//#region Discuss 페이지
class Discuss extends StatefulWidget {
  @override
  State<Discuss> createState() => _DiscussState();
}

class _DiscussState extends State<Discuss> {
  bool loading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 30, 37),
      body: SafeArea(
        //앱 전체 감싸는 div
        child: Container(
          child: Column(
            children: [
              //상단 바 div
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Text(
                        "Discuss",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                      child: Container(
                        child: Row(
                          children: [
                            //검색버튼
                            IconButton(
                              onPressed: () async {
                                await navigatorKey.currentState?.pushNamed('/search_page');
                                setState(() {});
                              },
                              iconSize: 35,
                              icon: const Icon(
                                Icons.search_rounded,
                                color: Colors.white,
                              ),
                            ),
                            //설정버튼
                            IconButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, '/');
                                await FirebaseAuth.instance.signOut();
                              },
                              iconSize: 35,
                              icon: const Icon(
                                Icons.settings_outlined,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              //질문 선택 버튼 바
              Container(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Explore 버튼
                      Column(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              splashFactory: NoSplash.splashFactory,
                              primary: discussPageSelected == 1 ? Colors.white : Color.fromARGB(100, 255, 255, 255),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                loading = true;
                                discussPageSelected = 1;
                              });
                            },
                            child: const Text("Explore"),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: discussPageSelected == 1 ? Colors.white : const Color.fromARGB(0, 255, 255, 255),
                              borderRadius: const BorderRadius.all(Radius.circular(100)),
                            ),
                            margin: const EdgeInsets.all(0),
                            padding: const EdgeInsets.all(0),
                            width: 50,
                            height: 2,
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      //Joined 버튼
                      Column(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, //???
                              splashFactory: NoSplash.splashFactory,
                              primary: discussPageSelected == 2 ? Colors.white : Color.fromARGB(100, 255, 255, 255),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                loading = true;
                                discussPageSelected = 2;
                              });
                            },
                            child: const Text("Joined"),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: discussPageSelected == 2 ? Colors.white : const Color.fromARGB(0, 255, 255, 255),
                              borderRadius: const BorderRadius.all(Radius.circular(100)),
                            ),
                            margin: const EdgeInsets.all(0),
                            padding: const EdgeInsets.all(0),
                            width: 50,
                            height: 2,
                          ),
                        ],
                      ),
                      SizedBox(width: 30),
                      //Ended 버튼
                      Column(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.all(0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap, //???
                              splashFactory: NoSplash.splashFactory,
                              primary: discussPageSelected == 3 ? Colors.white : Color.fromARGB(100, 255, 255, 255),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                loading = true;
                                discussPageSelected = 3;
                              });
                            },
                            child: const Text("Ended"),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: discussPageSelected == 3 ? Colors.white : const Color.fromARGB(0, 255, 255, 255),
                              borderRadius: const BorderRadius.all(Radius.circular(100)),
                            ),
                            margin: const EdgeInsets.all(0),
                            padding: const EdgeInsets.all(0),
                            width: 50,
                            height: 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              //회색 스크롤 배경
              Expanded(
                child: FractionallySizedBox(
                  heightFactor: 0.97,
                  widthFactor: 0.95,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color.fromARGB(25, 255, 255, 255),
                      ),
                      child: FutureBuilder(
                        future: discussGetDocument(),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData == false || loading == true) {
                            //데이터 받아오는중
                            loading = false;
                            return Container(
                              alignment: Alignment.center,
                              child: Text(
                                "Loading...",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: "Montserrat",
                                  fontSize: 16,
                                ),
                              ),
                            );
                          } else {
                            //데이터 다 받아옴
                            return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  discussGetDocument();
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
                                                    snapshot.data.values.elementAt(i)?['texts'].replaceAll("\\n", " "),
                                                    snapshot.data.values.elementAt(i)?['author'],
                                                    snapshot.data.values.elementAt(i)?['date'].toDate(),
                                                    snapshot.data.values.elementAt(i)?['uid'],
                                                    snapshot.data.values.elementAt(i)?['joined']),
                                                if (i == snapshot.data.length - 1) SizedBox(height: 5),
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                second(
                                                  snapshot.data.keys.elementAt(i),
                                                  snapshot.data.values.elementAt(i)?['title'],
                                                  snapshot.data.values.elementAt(i)?['texts'].replaceAll("\\n", " "),
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
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      //플로팅 액션 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Add your onPressed code here!
          await navigatorKey.currentState?.pushNamed('/add_session_page');
          setState(() {});
        },
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add_outlined,
          color: Colors.black,
          size: 35,
        ),
      ),
    );
  }
}

//#endregion

//#region Others 페이지
class Other extends StatefulWidget {
  @override
  State<Other> createState() => _OtherState();
}

class _OtherState extends State<Other> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 30, 37),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              //#region 상단 바 Container
              Container(
                height: 70,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                      child: Text(
                        "Others",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 30,
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              SizedBox(height: 20),
              //#endregion
              //#region 프로필 영역 Container
              Container(
                height: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //프로필 사진
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5)),
                      child: Icon(Icons.person_outline, color: Colors.white, size: 60),
                    ),
                    SizedBox(height: 10),
                    //이름 레벨
                    Text(
                      "JeEon Park",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Egg level",
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: "Montserrat",
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 20),
                    //질문, 답변, 좋아요 수
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            navigatorKey.currentState
                                ?.pushNamed('/others_page_search_page', arguments: {"page": "questions"});
                          },
                          child: Container(
                            color: const Color.fromARGB(255, 29, 30, 37),
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "Questions",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "6",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            navigatorKey.currentState
                                ?.pushNamed('/others_page_search_page', arguments: {"page": "ianswered"});
                          },
                          child: Container(
                            color: const Color.fromARGB(255, 29, 30, 37),
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "I Answered",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "12",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            navigatorKey.currentState
                                ?.pushNamed('/others_page_search_page', arguments: {"page": "liked"});
                          },
                          child: Container(
                            color: const Color.fromARGB(255, 29, 30, 37),
                            width: 100,
                            child: Column(
                              children: [
                                Text(
                                  "Liked",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "57",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Montserrat",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              //#endregion
              //#region 메뉴 목록
              Column(
                children: [
                  //My Profile 메뉴
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(46, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(flex: 1),
                        Text(
                          "My Profile",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(flex: 10),
                        Icon(
                          Icons.chevron_right_outlined,
                          color: Colors.white,
                        ),
                        Spacer(flex: 1),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  //Settings 메뉴
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(46, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(flex: 1),
                        Text(
                          "Settings",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(flex: 10),
                        Icon(
                          Icons.chevron_right_outlined,
                          color: Colors.white,
                        ),
                        Spacer(flex: 1),
                      ],
                    ),
                  ),
                  SizedBox(height: 15),
                  //About 메뉴
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(46, 255, 255, 255),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(flex: 1),
                        Text(
                          "About",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: "Montserrat",
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Spacer(flex: 10),
                        Icon(
                          Icons.chevron_right_outlined,
                          color: Colors.white,
                        ),
                        Spacer(flex: 1),
                      ],
                    ),
                  ),
                ],
              ),
              //#endregion
              //#region 로그아웃 버튼
              Spacer(),
              GestureDetector(
                onTap: () async {
                  navigatorKey.currentState?.pop(context);
                  navigatorKey.currentState?.pushNamed('/');
                  await FirebaseAuth.instance.signOut();
                  _currentIndex = 1;
                },
                child: Container(
                  alignment: Alignment.center,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 127, 116, 255),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Sign Out",
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: "Montserrat",
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              //#endregion 로그아웃 버튼
            ],
          ),
        ),
      ),
    );
  }
}
//#endregion
