import 'package:flutter/material.dart';

class RouteButton extends StatefulWidget {
  RouteButton({Key? key}) : super(key: key);

  @override
  State<RouteButton> createState() => _RouteButtonState();
}

class _RouteButtonState extends State<RouteButton> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SafeArea(
        child: Column(
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/question_view_page');
                },
                child: Text("To view question")),
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Pop"))
          ],
        ),
      ),
    );
  }
}
