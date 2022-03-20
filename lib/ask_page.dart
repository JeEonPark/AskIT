import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//전역변수
int pageSelected = 1;

class AskPage extends StatefulWidget {
  @override
  State<AskPage> createState() => _AskPageState();
}

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

Future<List> getDocumentList() async {
  List<String> lists = [];
  if (pageSelected == 1) {
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
  } else if (pageSelected == 2) {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection("AskPage_Questions")
        .orderBy('date', descending: true)
        .get();
    snapshot.docs.forEach((element) {
      lists.add(element.id);
    });
  }

  return lists;
}

// Map<글 코드, 글 데이터맵>
Future<Map> getDocument() async {
  List lists = await getDocumentList(); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance
        .collection("AskPage_Questions")
        .doc(lists[i])
        .get();
    map[lists[i]] = documentData.data();
  }

  // print(DateFormat('yyyy.MM.dd')
  //     .format(map.values.elementAt(0)?['date'].toDate()));
  if (pageSelected == 2) {
    for (int i = 0; i < map.length; i++) {
      if (map.values.elementAt(i)?['uid'] ==
          FirebaseAuth.instance.currentUser?.uid) {
        map.remove(map.keys.elementAt(i));
        i--;
      }
    }
  }

  return map;
}

class _AskPageState extends State<AskPage> {
  //변수들
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference collection_askPage_questions =
      FirebaseFirestore.instance.collection('AskPage_Questions');

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 37), //뒷 배경 색상
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
                              IconButton(
                                onPressed: () {},
                                iconSize: 35,
                                icon: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                ),
                              ),
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
                              primary: pageSelected == 1
                                  ? Colors.white
                                  : Color.fromARGB(100, 255, 255, 255),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                pageSelected = 1;
                              });
                            },
                            child: const Text("My Question"),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: pageSelected == 1
                                  ? Colors.white
                                  : const Color.fromARGB(0, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
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
                              tapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap, //???
                              splashFactory: NoSplash.splashFactory,
                              primary: pageSelected == 2
                                  ? Colors.white
                                  : Color.fromARGB(100, 255, 255, 255),
                              textStyle: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                pageSelected = 2;
                              });
                            },
                            child: const Text("Others Question"),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: pageSelected == 2
                                  ? Colors.white
                                  : const Color.fromARGB(0, 255, 255, 255),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(100)),
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
                          future: getDocument(),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData == false) {
                              //데이터 받아오는중
                              return Text("loading");
                            } else {
                              //데이터 다 받아옴
                              return RefreshIndicator(
                                onRefresh: () async {
                                  setState(() {
                                    getDocument();
                                  });
                                },
                                child: SingleChildScrollView(
                                  physics: AlwaysScrollableScrollPhysics(),
                                  child: Column(
                                    children: [
                                      for (int i = 0;
                                          i < snapshot.data.length;
                                          i++)
                                        i % 2 == 0
                                            ? Column(
                                                children: [
                                                  if (i == 0)
                                                    SizedBox(height: 5),
                                                  first(
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['title'],
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['texts'],
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['author'],
                                                      DateFormat('yyyy.MM.dd')
                                                          .format(snapshot
                                                              .data.values
                                                              .elementAt(
                                                                  i)?['date']
                                                              .toDate())),
                                                  if (i ==
                                                      snapshot.data.length - 1)
                                                    SizedBox(height: 5),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  second(
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['title'],
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['texts'],
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['author'],
                                                      DateFormat('yyyy.MM.dd')
                                                          .format(snapshot
                                                              .data.values
                                                              .elementAt(
                                                                  i)?['date']
                                                              .toDate())),
                                                  if (i ==
                                                      snapshot.data.length - 1)
                                                    SizedBox(height: 5),
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
          onPressed: () {
            // Add your onPressed code here!
            Navigator.pushNamed(context, '/add_question_page');
          },
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.add_outlined,
            color: Colors.black,
            size: 35,
          ),
        ),
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
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.question_answer_outlined),
                  label: ('Favourite'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite),
                  label: ('Favourite'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget first(String title, String texts, String author, String date) {
  return Container(
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
          Color.fromARGB(255, 91, 50, 180),
          Color.fromARGB(255, 88, 55, 165),
          Color.fromARGB(255, 49, 27, 96)
        ],
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
                  date,
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
  );
}

Widget second(String title, String texts, String author, String date) {
  return Container(
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
                  date,
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
  );
}
