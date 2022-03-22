import 'package:ask_it/main.dart';
import 'package:flutter/material.dart';

class AskAnswerMethodPage extends StatefulWidget {
  AskAnswerMethodPage({Key? key}) : super(key: key);

  @override
  State<AskAnswerMethodPage> createState() => _AskAnswerMethodPageState();
}

class _AskAnswerMethodPageState extends State<AskAnswerMethodPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 30, 37),
        body: SafeArea(
          child: Column(
            children: [
              //상단바 영역
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
              Column(
                children: [
                  Text(
                    "Answer Method",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Montserrat",
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Container(
                    color: Colors.white,
                    height: 1,
                    width: 165,
                  ),
                  SizedBox(height: 30),
                  //Text Chat 버튼
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {
                        navigatorKey.currentState?.pop();
                        navigatorKey.currentState?.pushNamed('/message_page');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.question_answer_outlined,
                            size: 22,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Text Chat",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Voice Call 버튼
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.phone_outlined,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Text & Voice Call",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //Video Call 버튼
                  SizedBox(height: 10),
                  SizedBox(
                    height: 50,
                    width: 280,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: const Color.fromARGB(255, 127, 116, 255),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.videocam_outlined,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Text & Video Call",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
