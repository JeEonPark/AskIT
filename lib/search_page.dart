import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';
import 'package:ask_it/main.dart';

class SearchPage extends StatefulWidget {
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  //변수
  final searchInputController = TextEditingController();
  FocusNode textSearchFocus = FocusNode();
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
                          Navigator.pop(context);
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
                const Expanded(
                  child: Center(
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
