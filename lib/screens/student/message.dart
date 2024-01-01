import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plm_crs_grad/screens/student/student_dashboard.dart';

import '../../services/apiService.dart';

class StudentMessageApp extends StatelessWidget {
  final int studentId;

  const StudentMessageApp({super.key, required this.studentId});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: "",
          onMenuPressed: (){},
        ),
        body: StudentMessageAppPage(studentId: studentId),
      ),
    );
  }
}

class StudentMessageAppPage extends StatefulWidget {
  final int studentId;
  const StudentMessageAppPage({Key? key, required this.studentId}) : super(key: key);

  @override
  _StudentMessageAppPageState createState() => _StudentMessageAppPageState();
}

class _StudentMessageAppPageState extends State<StudentMessageAppPage> {
  APIService apiService = APIService();
  late List<Map<String, dynamic>> studentMessages = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    try {
      List<Map<String, dynamic>> data = await apiService.fetchUserMessages(widget.studentId);

      // Sort the list based on the 'date' field in descending order
      data.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateB.compareTo(dateA);
      });

      setState(() {
        studentMessages = data;
        print("STUDENT INFO: $studentMessages");
      });
    } catch (error) {
      print("Error fetching data: $error");
      // Handle error as needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.topCenter,
          color: Colors.red[800],
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(
              'Messages',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: studentMessages.length,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0), // Adjust vertical padding
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '*',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[900],
                        ),
                      ),
                      SizedBox(width: 8), // Add some space between '*' and the column
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentMessages[index]['title'] ?? '',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              studentMessages[index]['description'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat('h:mm a MMM dd, yyyy').format(DateTime.parse(studentMessages[index]['date'])),
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            Divider(
                              thickness: 1,
                              color: Colors.black,
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),

      ],
    );
  }

}




