import 'package:flutter/material.dart';
import 'package:plm_crs_grad/screens/student/student_dashboard.dart';

class StudentMessageApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: "",
          onMenuPressed: (){},
        ),
        body: StudentMessageAppPage(),
      ),
    );
  }
}

class StudentMessageAppPage extends StatefulWidget {
  const StudentMessageAppPage({Key? key}) : super(key: key);

  @override
  _StudentMessageAppPageState createState() => _StudentMessageAppPageState();
}

class _StudentMessageAppPageState extends State<StudentMessageAppPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Message',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Add your enrollment-related widgets here
        ],
      ),
    );
  }
}

