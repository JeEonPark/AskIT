import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;

import 'main.dart';

FocusNode titleFocus = FocusNode();
FocusNode sessionFocus = FocusNode();

final titleInputController = TextEditingController();
final textsInputController = TextEditingController();

int currentIndex = 0;

DateTime? dateTime_due_date;
String time = "?";

final PageController controller = PageController(initialPage: 0, viewportFraction: 1);

class AddSessionPage extends StatefulWidget {
  AddSessionPage({Key? key}) : super(key: key);

  @override
  State<AddSessionPage> createState() => _AddSessionPageState();
}

Future<String> getUsernameByUid() async {
  String answer = "";
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection("UserInformation")
      .where(
        'uid',
        isEqualTo: FirebaseAuth.instance.currentUser?.uid,
      )
      .get();
  answer = snapshot.docs.first.get("username");
  return answer;
}

void writeSessionDocument(String title, String texts, Timestamp due_date) async {
  await FirebaseFirestore.instance
      .collection('DiscussPage_Sessions')
      .doc()
      .set({
        'author': await getUsernameByUid(),
        'title': title,
        'texts': texts,
        'date': Timestamp.now(),
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'due_date': due_date,
        'liked': [],
        'joined': [FirebaseAuth.instance.currentUser?.uid],
        'chatroom_joined': [FirebaseAuth.instance.currentUser?.uid],
      })
      .then((value) => print("Session Added"))
      .catchError((error) => print("Failed to add user: $error"));
}

class _AddSessionPageState extends State<AddSessionPage> {
  @override
  void initState() {
    super.initState();

    /// Attach a listener which will update the state and refresh the page index
    controller.addListener(() {
      if (controller.page?.round() != currentIndex && this.mounted) {
        setState(() {
          currentIndex = controller.page?.round() as int;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        titleFocus.unfocus();
        sessionFocus.unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 29, 30, 37),
          body: SafeArea(
            child: Container(
              child: Column(
                children: [
                  // 화살표, Add Session 상단바
                  Container(
                    height: 80,
                    child: Row(
                      children: [
                        IconButton(
                          padding: EdgeInsets.all(20),
                          onPressed: () {
                            Navigator.pop(context);
                            currentIndex = 0;
                            titleInputController.clear();
                            textsInputController.clear();
                            dateTime_due_date = null;
                            time = "?";
                          },
                          icon: Icon(Icons.arrow_back_rounded),
                          color: Colors.white,
                          iconSize: 35,
                        ),
                        const Text(
                          "Add Session",
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
                    child: PageView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: 1,
                      controller: controller,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return addSessionFirstPage();
                        }
                        return Text("Loading");
                      },
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 60,
                    //구분선
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    //하단바-------------------------------------------------
                    child: Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          splashRadius: 25,
                          iconSize: 30,
                          onPressed: () {
                            print(controller.page);
                            if (currentIndex == 1) {
                              controller.previousPage(
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                            }
                          },
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
                                if (dateTime_due_date != null) {
                                  DateTime date_final =
                                      dateTime_due_date!.add(Duration(hours: 23, minutes: 59, seconds: 59));
                                  Timestamp timestamp_due_date = Timestamp.fromDate(date_final);
                                  writeSessionDocument(
                                      titleInputController.text, textsInputController.text, timestamp_due_date);
                                  Navigator.pop(context);
                                  currentIndex = 0;
                                  titleInputController.clear();
                                  textsInputController.clear();
                                  dateTime_due_date = null;
                                  time = "?";
                                } else {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Text("You miss the set date!"),
                                        actions: [
                                          TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("Close"))
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              icon: Icon(
                                currentIndex == 0 ? Icons.check_outlined : Icons.arrow_forward_ios_rounded,
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
        ),
      ),
    );
  }

  Widget addSessionFirstPage() {
    int _currentValue = 3;
    return SingleChildScrollView(
      child: Column(
        children: [
          //title 텍스트 박스-------------------------
          FractionallySizedBox(
            widthFactor: 0.9,
            child: SizedBox(
              height: 45,
              child: TextFormField(
                controller: titleInputController,
                focusNode: titleFocus,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontFamily: "Montserrat",
                ),
                decoration: const InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 127, 116, 255)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color.fromARGB(255, 127, 116, 255)),
                  ),
                  prefixIcon: SizedBox(
                    child: Center(
                      widthFactor: 0.0,
                      child: Text(
                        'Title : ',
                        style: TextStyle(
                          color: Color.fromARGB(128, 255, 255, 255),
                          fontFamily: "Montserrat",
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
            ),
          ),
          SizedBox(height: 5),
          // date picker period 박스 -------------------------------------------------------
          Row(
            children: [
              SizedBox(
                width: MediaQuery.of((navigatorKey.currentState?.context as BuildContext)).size.width * 0.05,
              ),
              ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final afterMonth = now.add(Duration(days: 30));
                    dateTime_due_date = (await showDatePicker(
                      context: navigatorKey.currentState?.context as BuildContext,
                      initialDate: now,
                      firstDate: DateTime(now.year, now.month, now.day),
                      lastDate: DateTime(afterMonth.year, afterMonth.month, afterMonth.day),
                    ))!;
                    time = intl.DateFormat('yyyy.MM.dd').format(dateTime_due_date as DateTime);
                    setState(() {});
                  },
                  child: Text("set date"),
                  style: ElevatedButton.styleFrom(primary: Color.fromARGB(255, 72, 63, 178))),
              SizedBox(width: 10),
              // due date
              Text(
                "~ " + time,
                style: TextStyle(
                  color: Color.fromARGB(128, 255, 255, 255),
                  fontFamily: "Montserrat",
                  fontSize: 14,
                ),
              ),
            ],
          ),

          //Session 텍스트 박스-------------------------
          FractionallySizedBox(
            widthFactor: 0.9,
            child: TextFormField(
              focusNode: sessionFocus,
              controller: textsInputController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontFamily: "Montserrat",
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintMaxLines: 4,
                hintText:
                    "Please write introduction about your session.\nYou can freely add chatting rules, live schedules, etc.",
                hintStyle: TextStyle(
                  color: Color.fromARGB(140, 255, 255, 255),
                  fontFamily: "Montserrat",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget addSessionSecondPage() {
    return (Text("Select Categories"));
  }
}
