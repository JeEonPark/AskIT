import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

FocusNode titleFocus = FocusNode();
FocusNode questionFocus = FocusNode();

final titleInputController = TextEditingController();
final textsInputController = TextEditingController();

int currentIndex = 0;

final PageController controller = PageController(initialPage: 0, viewportFraction: 1);

class AddQuestionPage extends StatefulWidget {
  @override
  State<AddQuestionPage> createState() => _AddQuestionPageState();
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

void writeQuestionDocument(String title, String texts) async {
  await FirebaseFirestore.instance
      .collection('AskPage_Questions')
      .doc()
      .set({
        'author': await getUsernameByUid(),
        'title': title,
        'texts': texts,
        'date': Timestamp.now(),
        'uid': FirebaseAuth.instance.currentUser?.uid,
        'liked': [],
      })
      .then((value) => print("Question Added"))
      .catchError((error) => print("Failed to add user: $error"));
}

class _AddQuestionPageState extends State<AddQuestionPage> {
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
        questionFocus.unfocus();
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: const Color.fromARGB(255, 29, 30, 37),
          body: SafeArea(
            child: Container(
              child: Column(
                children: [
                  // 화살표, Add Question 상단바
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
                          },
                          icon: Icon(Icons.arrow_back_rounded),
                          color: Colors.white,
                          iconSize: 35,
                        ),
                        const Text(
                          "Add Question",
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
                      itemCount: 3,
                      controller: controller,
                      itemBuilder: (context, i) {
                        if (i == 0) {
                          return addQuestionFirstPage();
                        } else if (i == 1) {
                          return addQuestionSecondPage();
                        } else if (i == 2) {
                          return addQuestionThirdPage();
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
                            if (currentIndex == 1 || currentIndex == 2) {
                              controller.previousPage(
                                duration: Duration(milliseconds: 200),
                                curve: Curves.easeOut,
                              );
                            }
                          },
                          icon: Icon(
                            currentIndex == 0
                                ? Icons.photo_camera_outlined
                                : currentIndex == 1 || currentIndex == 2
                                    ? Icons.arrow_back_ios_new_rounded
                                    : null,
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Text(
                              currentIndex == 2 ? "Post" : "",
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
                                if (currentIndex == 2) {
                                  writeQuestionDocument(titleInputController.text, textsInputController.text);
                                  Navigator.pop(context);
                                  currentIndex = 0;
                                  titleInputController.clear();
                                  textsInputController.clear();
                                } else {
                                  controller.nextPage(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeOut,
                                  );
                                  titleFocus.unfocus();
                                  questionFocus.unfocus();
                                }
                              },
                              icon: Icon(
                                currentIndex == 2 ? Icons.check_outlined : Icons.arrow_forward_ios_rounded,
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
}

Widget addQuestionFirstPage() {
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
        SizedBox(height: 10),
        //question 텍스트 박스-------------------------
        FractionallySizedBox(
          widthFactor: 0.9,
          child: TextFormField(
            focusNode: questionFocus,
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
              hintText: "Write your question here.",
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

Widget addQuestionSecondPage() {
  return (Text("Select Categories"));
}

Widget addQuestionThirdPage() {
  return (Column(
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
          onPressed: () {},
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
  ));
}
