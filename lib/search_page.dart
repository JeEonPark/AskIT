import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import 'ask_page.dart';
import 'main.dart';
import 'package:ask_it/main.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}




Future<List> getDocumentList(String searchData) async {
  List<String> lists = [];
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("AskPage_Questions")
      .orderBy('date', descending: true)//검색한 것만 뽑아서 가져오게 해야 함!!!
      .get();
  snapshot.docs.forEach((element) {
    lists.add(element.id);
    print(element.data());
  });

  return lists;
}

// Map<글 코드, 글 데이터맵>
Future<Map> getDocument(String searchData) async {
  List lists = await getDocumentList(searchData); //
  Map<String, Map<String, dynamic>?> map = {}; // {docid : [Map]}

  for (int i = 0; i < lists.length; i++) {
    final documentData = await FirebaseFirestore.instance
        .collection("AskPage_Questions")
        .doc(lists[i])
        .get();
    map[lists[i]] = documentData.data();
  }

  return map;
}

Widget first(
    String docId, String title, String texts, String author, DateTime date) {
  return GestureDetector(
    onTap: () {
      gotoQuestionViewPage(docId, title, texts, author, date);
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

Widget second(
    String docId, String title, String texts, String author, DateTime date) {
  return GestureDetector(
    onTap: () {
      gotoQuestionViewPage(docId, title, texts, author, date);
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
class _SearchPageState extends State<SearchPage> {
  //변수
  final searchInputController = TextEditingController();
  FocusNode textSearchFocus = FocusNode();
  bool isSearched = false;
  String searchData = "";

  @override
  Widget build(BuildContext context) {
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //뒤로가기 버튼
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        iconSize: 35,
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                      //검색바
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextFormField(
                          controller: searchInputController,
                          focusNode: textSearchFocus,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(14, 8, 8, 8),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            fillColor: Colors.white,
                            filled: true,
                            hintText: "Search",
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 125, 125, 125),
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      //검색 버튼
                      IconButton(
                        onPressed: () {
                          //누르면 검색 결과 넣어야 함
                          setState(() {
                            isSearched = true;
                            searchData = searchInputController.text;
                          });
                        },
                        iconSize: 35,
                        icon: const Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isSearched
                      ? FutureBuilder(
                          future: getDocument(searchData),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData == false) {
                              return const Text("loading",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 20,
                                  ));
                            // ignore: dead_code
                            } else {return RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  getDocument(searchData);
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
                                                  if (i == 0) SizedBox(height: 5),
                                                  first(
                                                      snapshot.data.keys
                                                          .elementAt(i),
                                                      snapshot.data.values
                                                          .elementAt(i)?['title'],
                                                      snapshot.data.values
                                                          .elementAt(i)?['texts'],
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['author'],
                                                      snapshot.data.values
                                                          .elementAt(i)?['date']
                                                          .toDate()),
                                                  if (i ==
                                                      snapshot.data.length - 1)
                                                    SizedBox(height: 5),
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  second(
                                                      snapshot.data.keys
                                                          .elementAt(i),
                                                      snapshot.data.values
                                                          .elementAt(i)?['title'],
                                                      snapshot.data.values
                                                          .elementAt(i)?['texts'],
                                                      snapshot.data.values
                                                          .elementAt(
                                                              i)?['author'],
                                                      snapshot.data.values
                                                          .elementAt(i)?['date']
                                                          .toDate()),
                                                  if (i ==
                                                      snapshot.data.length - 1)
                                                    SizedBox(height: 5),
                                                ],
                                              ),
                                    ],
                                  ),
                                )
                              );
                            }
                          },
                        )
                      : const Center(
                          child: Text(
                            "Search Anything!",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                            ),
                          ),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
