import 'package:flutter/material.dart';
import 'package:plm_crs_grad/screens/student/student_dashboard.dart';

class StudentEnrollmentApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: "",
          onMenuPressed: (){},
        ),
        body: StudentEnrollmentPage(),
      ),
    );
  }
}

class StudentEnrollmentPage extends StatefulWidget {
  const StudentEnrollmentPage({Key? key}) : super(key: key);

  @override
  _StudentEnrollmentPageState createState() => _StudentEnrollmentPageState();
}

class _StudentEnrollmentPageState extends State<StudentEnrollmentPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Enrollment',
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
