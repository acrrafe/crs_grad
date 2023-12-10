import 'package:flutter/material.dart';
import 'package:plm_crs_grad/screens/student/student_dashboard.dart';

class StudentGradesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: "",
          onMenuPressed: (){},
        ),
        body: StudentGradesAppPage(),
      ),
    );
  }
}
class StudentGradesAppPage extends StatefulWidget {
  const StudentGradesAppPage({Key? key}) : super(key: key);
  @override
  _StudentGradesAppPageState createState() => _StudentGradesAppPageState();
}

class _StudentGradesAppPageState extends State<StudentGradesAppPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Grades',
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

