// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plm_crs_grad/screens/student/student_dashboard.dart';

import '../../services/apiService.dart';

class StudentGradesApp extends StatelessWidget {
  final int studentId;

  const StudentGradesApp({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: CustomAppBar(
          title: "",
          onMenuPressed: (){},
        ),
        body: StudentGradesAppPage(studentId: studentId),
      ),
    );
  }
}
class StudentGradesAppPage extends StatefulWidget {
  final int studentId;
  const StudentGradesAppPage({Key? key, required this.studentId}) : super(key: key);
  @override
  _StudentGradesAppPageState createState() => _StudentGradesAppPageState(studentId);
}

class _StudentGradesAppPageState extends State<StudentGradesAppPage> {
  final int studentId;

  _StudentGradesAppPageState(this.studentId);

  Future<void>? fetchData;

  APIService apiService = APIService();
  late Map<String, dynamic> studentInfo = {};
  late List<Map<String, dynamic>> classInfos = [];
  late List<Map<String, dynamic>> classInfo = [];
  late List<Map<String, dynamic>> flags = [];
  late List<Map<String, dynamic>> visibleClassInfos = [];

  int _currentPage = 1;
  int _rowsPerPage = 7;
  int totalPages = 0;



  @override
  void initState() {
    super.initState();
    apiService.fetchUserInfo(widget.studentId).then((data) {
      setState(() {
        studentInfo = data;
        print("STUDENT INFO: $studentInfo");
      });
    });

    apiService.fetchFlags().then((flag){
      if (flag != null) {
        print(flag.first);
        setState(() {
          flags = flag;
        });
        int value = int.parse(flags.first['value']);
        if (value != null) {
          fetchData = fetchDataAsync(value);
        } else {
          fetchData = Future.error('Enrollment status is 1'); // Set a completed future with an error
        }
      }
    });

  }

  Future<void> fetchDataAsync(int flagValue) async {
    try {
      print("STUDENT ID: ${widget.studentId}");
      print("FLAGS VALUE: $flagValue");
      classInfo = await apiService.fetchStudentGrades(widget.studentId, flagValue);

      setState(() {
        classInfos = classInfo;
        int startIndex = (_currentPage - 1) * _rowsPerPage;
        int endIndex = startIndex + _rowsPerPage;
        endIndex = endIndex > classInfos.length ? classInfos.length : endIndex;
        visibleClassInfos = classInfos.sublist(startIndex, endIndex);
        print("VISIBLE CLASS INFOS: $visibleClassInfos");
        totalPages = (classInfos.length / _rowsPerPage).ceil();


        print("CLASS INFO: $classInfos");
      });

    } catch (error) {
      // Handle errors here
      print('Error fetching data: $error');
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchData,
        builder: (context, snapshot){
      if (fetchData == null) {
        // Handle the case when fetchData is null
        return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
      }
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Future is still loading, return a loading indicator or placeholder
        return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red[900]!)));
      } else {
        return SingleChildScrollView(
          child: SizedBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10.0),
                Container(
                  width: double.infinity, // Maximize the width of the container
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      // borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(
                          width: 1,
                          color: Colors.red[800]!,
                          style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3.0,
                    margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Container(
                          //   width: double.infinity,
                          //   // Maximize the width of the title background
                          //   padding: const EdgeInsets.all(10.0),
                          //   decoration: BoxDecoration(
                          //     color: Colors.red[900],
                          //     borderRadius: BorderRadius.circular(10.0),
                          //   ),
                          //   child: const Text(
                          //     'STUDENT INFORMATION',
                          //     style: TextStyle(
                          //       color: Colors.white,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 8.0, 10.0, 8.0),
                                  child: Text(
                                    'STUDENT ID : ${widget.studentId}',
                                    style: const TextStyle(color: Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  )
                              ),
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 8.0, 10.0, 8.0),
                                  child: Text(
                                    'STUDENT NAME: ${studentInfo['firstName']} ${studentInfo['middleName']} ${studentInfo['lastName']}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  )
                              ),
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 8.0, 10.0, 8.0),
                                  child: Text(
                                    'COURSE : ${classInfos.first['program']}',
                                    style: const TextStyle(color: Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  )
                              ),
                              Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 8.0, 10.0, 8.0),
                                  child: Text(
                                    'GRADUATE SCHOOL : ${classInfos[0]['college']}',
                                    style: const TextStyle(color: Colors.black,
                                      fontSize: 14.0,
                                    ),
                                  )
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                Container(
                  color: Colors.red[900],
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Flexible(
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Page $_currentPage of $totalPages',
                                  style: TextStyle(color: Colors.white)),
                              IconButton(
                                icon: Icon(Icons.arrow_back_ios_new_rounded),
                                color: Colors.white,
                                onPressed: _currentPage == 1
                                    ? null  // Disable the button if the current page is equal to total pages
                                    : () {
                                  _handlePreviousPage();
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.arrow_forward_ios_rounded),
                                color: Colors.white,
                                onPressed: totalPages == _currentPage
                                    ? null  // Disable the button if the current page is equal to total pages
                                    : () {
                                  _handleNextPage();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 5.0, 0),
                          // Search bar goes here
                          color: Colors.white,
                          child: SearchBar(),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      height: 300,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Subject Code/Section')),
                          DataColumn(label: Text('Subject Title')),
                          DataColumn(label: Text('Units')),
                          DataColumn(label: Text('Grade')),
                          DataColumn(label: Text('Remarks')),
                        ],
                        rows: visibleClassInfos.map<DataRow>((classInfo) {
                          String program = classInfo['program'] ?? '';
                          int classSection = classInfo['section'] ?? 0;
                          String classTitle = classInfo['subjectName'] ?? '';
                          int units = classInfo['subjectUnits'] ?? 0;
                          double grade = classInfo['grade'] ?? 0.0;
                          dynamic remarks = classInfo['remarks'] ?? 0;


                          return DataRow(
                            cells: [
                              DataCell(Text("${program} ${classSection.toString()}")),
                              DataCell(Text(classTitle)),
                              DataCell(Text(units.toString())),
                              DataCell(Text(grade.toString())), // Replace with actual value
                              DataCell(Text(remarks.toString())), // Replace with actual value
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                // Add your enrollment-related widgets here
              ],
            ),
          )
        );
      }
    }

    );
  }

  // Pagination Button
  void _handleNextPage() {
    setState(() {
      _currentPage++;
    });
  }

  void _handlePreviousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
      }
    });
  }


}

// Custom Search Bar
class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      height: MediaQuery.of(context).size.height * 0.06,
      child: const TextField(
        style: TextStyle(fontSize: 14.0), // Adjust the font size
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjust padding
          labelText: 'Search',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }
}

